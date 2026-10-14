import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'timed_lyrics.dart';

/// Reads the ID3v2 SYLT frame (synchronised lyrics) of an mp3 and turns it
/// into LRC. Neither jaudiotagger's FieldKey.LYRICS nor ffprobe expose this
/// frame - both only return USLT, the unsynced copy taggers write next to
/// it - so a file with synced lyrics showed up as plain text.
///
/// The frame body, after the tag and frame headers:
///
///   encoding (1) | language (3) | timestamp format (1) | content type (1)
///   descriptor, terminated
///   then repeated: text, terminated | timestamp (4, big-endian)
///
/// An entry is a whole line or, in word-timed files, a single word - there
/// a newline in the text marks where a line ends. Words are joined back
/// into lines, each timed by its first word.
///
/// Everything here is best effort on untrusted bytes: anything unexpected
/// (corrupt sizes, compressed or encrypted frames, MPEG-frame timestamps)
/// gives null and the caller falls back to the USLT text.
class Id3SyltReader {
  /// Tags are mostly cover art; one past this size isn't worth loading.
  static const int _maxTagBytes = 32 * 1024 * 1024;

  static const int _timestampMs = 2;
  static const int _contentOther = 0;
  static const int _contentLyrics = 1;
  static const int _contentTranscription = 2;

  /// The synced lyrics of the file at [path] as LRC, or null.
  static Future<String?> readFile(String path) async {
    RandomAccessFile? file;
    try {
      file = await File(path).open();
      final header = await file.read(10);
      final size = _tagSize(header);
      if (size == null || size > _maxTagBytes) return null;
      final data = await file.read(size);
      return fromTag(Uint8List.fromList([...header, ...data]));
    } catch (_) {
      return null;
    } finally {
      await file?.close();
    }
  }

  /// The synced lyrics in [tag] - a file's bytes from its `ID3` header on,
  /// anything after the tag ignored - as LRC, or null.
  static String? fromTag(Uint8List tag) {
    try {
      return _fromTag(tag);
    } catch (_) {
      return null;
    }
  }

  static int? _tagSize(List<int> header) {
    if (header.length < 10) return null;
    if (header[0] != 0x49 || header[1] != 0x44 || header[2] != 0x33) {
      return null;
    }
    return _syncSafe(header, 6);
  }

  static String? _fromTag(Uint8List tag) {
    final size = _tagSize(tag);
    if (size == null) return null;
    final version = tag[3];
    if (version < 2 || version > 4) return null;
    final flags = tag[5];
    final tagUnsync = flags & 0x80 != 0;

    var data = Uint8List.sublistView(
      tag,
      10,
      10 + size > tag.length ? tag.length : 10 + size,
    );
    // Up to v2.3 the whole tag is unsynchronised at once; v2.4 does it
    // frame by frame, with the sizes counting the stored bytes.
    if (tagUnsync && version < 4) data = _resync(data);

    var pos = 0;
    if (flags & 0x40 != 0) {
      // v2.2 used this bit for a compression scheme that was never defined.
      if (version == 2) return null;
      if (data.length < 4) return null;
      pos = version == 3 ? 4 + _uint32(data, 0) : _syncSafe(data, 0);
    }

    final idLength = version == 2 ? 3 : 4;
    final headerLength = version == 2 ? 6 : 10;
    final wanted = version == 2 ? 'SLT' : 'SYLT';

    String? fallback;
    while (pos + headerLength <= data.length) {
      if (data[pos] == 0) break; // padding
      final id = String.fromCharCodes(data, pos, pos + idLength);
      final frameSize = switch (version) {
        2 => (data[pos + 3] << 16) | (data[pos + 4] << 8) | data[pos + 5],
        3 => _uint32(data, pos + 4),
        _ => _syncSafe(data, pos + 4),
      };
      final formatFlags = version == 2 ? 0 : data[pos + 9];
      final start = pos + headerLength;
      final end = start + frameSize;
      if (frameSize <= 0 || end > data.length) break;
      pos = end;
      if (id != wanted) continue;

      final body = _frameBody(
        Uint8List.sublistView(data, start, end),
        version,
        formatFlags,
        tagUnsync,
      );
      if (body == null || body.length < 6) continue;
      if (body[4] != _timestampMs) continue;
      final contentType = body[5];
      if (contentType != _contentLyrics &&
          contentType != _contentOther &&
          contentType != _contentTranscription) {
        continue;
      }
      final lrc = _toLrc(body);
      if (lrc == null) continue;
      if (contentType == _contentLyrics) return lrc;
      fallback ??= lrc;
    }
    return fallback;
  }

  /// The frame's content with its format flags undone, or null when it is
  /// compressed or encrypted.
  static Uint8List? _frameBody(
    Uint8List body,
    int version,
    int formatFlags,
    bool tagUnsync,
  ) {
    if (version == 3) {
      if (formatFlags & 0xc0 != 0) return null; // compressed / encrypted
      return formatFlags & 0x20 != 0 ? _skip(body, 1) : body; // group id
    }
    if (version == 4) {
      if (formatFlags & 0x0c != 0) return null; // compressed / encrypted
      var out = body;
      if (formatFlags & 0x40 != 0) out = _skip(out, 1); // group id
      if (formatFlags & 0x01 != 0) out = _skip(out, 4); // data length
      if (tagUnsync || formatFlags & 0x02 != 0) out = _resync(out);
      return out;
    }
    return body;
  }

  static Uint8List _skip(Uint8List bytes, int count) =>
      Uint8List.sublistView(bytes, count > bytes.length ? bytes.length : count);

  static String? _toLrc(Uint8List body) {
    final encoding = body[0];
    if (encoding > 3) return null;
    final wide = encoding == 1 || encoding == 2;

    // Descriptor first, then text + timestamp pairs.
    var pos = _terminator(body, 6, wide);
    if (pos < 0) return null;
    pos += wide ? 2 : 1;

    final entries = <({String text, int ms})>[];
    while (pos < body.length) {
      final textEnd = _terminator(body, pos, wide);
      if (textEnd < 0) break;
      final stamp = textEnd + (wide ? 2 : 1);
      if (stamp + 4 > body.length) break;
      entries.add((
        text: _decode(body, pos, textEnd, encoding).replaceAll('\r', ''),
        ms: _uint32(body, stamp),
      ));
      pos = stamp + 4;
    }
    if (entries.isEmpty) return null;

    final lines = <({int ms, String text})>[];
    if (entries.any((e) => e.text.contains('\n'))) {
      // Word-timed: a line runs until the next newline.
      int? lineMs;
      final text = StringBuffer();
      void endLine() {
        if (lineMs != null) lines.add((ms: lineMs!, text: text.toString()));
        lineMs = null;
        text.clear();
      }

      for (final entry in entries) {
        final pieces = entry.text.split('\n');
        for (var i = 0; i < pieces.length; i++) {
          if (i > 0) endLine();
          if (pieces[i].isEmpty) continue;
          lineMs ??= entry.ms;
          text.write(pieces[i]);
        }
      }
      endLine();
    } else {
      for (final entry in entries) {
        lines.add((ms: entry.ms, text: entry.text));
      }
    }

    return TimedLrcWriter.write([
      for (var i = 0; i < lines.length; i++)
        TimedLyricLine(
          startMs: lines[i].ms,
          endMs: i + 1 < lines.length ? lines[i + 1].ms : lines[i].ms,
          text: lines[i].text.trim(),
        ),
    ]);
  }

  /// Index of the string terminator at or after [from], or -1. UTF-16
  /// terminators are two zero bytes on a character boundary.
  static int _terminator(Uint8List bytes, int from, bool wide) {
    if (!wide) return bytes.indexOf(0, from);
    for (var i = from; i + 1 < bytes.length; i += 2) {
      if (bytes[i] == 0 && bytes[i + 1] == 0) return i;
    }
    return -1;
  }

  static String _decode(Uint8List bytes, int start, int end, int encoding) {
    final slice = Uint8List.sublistView(bytes, start, end);
    switch (encoding) {
      case 0:
        return latin1.decode(slice);
      case 3:
        return utf8.decode(slice, allowMalformed: true);
    }
    // UTF-16: with a byte order mark (1), or big-endian without one (2).
    var bigEndian = encoding == 2;
    var i = 0;
    if (slice.length >= 2) {
      if (slice[0] == 0xff && slice[1] == 0xfe) {
        bigEndian = false;
        i = 2;
      } else if (slice[0] == 0xfe && slice[1] == 0xff) {
        bigEndian = true;
        i = 2;
      }
    }
    final units = <int>[];
    for (; i + 1 < slice.length; i += 2) {
      units.add(
        bigEndian
            ? (slice[i] << 8) | slice[i + 1]
            : (slice[i + 1] << 8) | slice[i],
      );
    }
    return String.fromCharCodes(units);
  }

  /// Reverses unsynchronisation: drops the 0x00 inserted after every 0xff.
  static Uint8List _resync(Uint8List bytes) {
    final out = BytesBuilder(copy: false);
    for (var i = 0; i < bytes.length; i++) {
      out.addByte(bytes[i]);
      if (bytes[i] == 0xff && i + 1 < bytes.length && bytes[i + 1] == 0) i++;
    }
    return out.toBytes();
  }

  static int _uint32(List<int> b, int at) =>
      (b[at] << 24) | (b[at + 1] << 16) | (b[at + 2] << 8) | b[at + 3];

  static int _syncSafe(List<int> b, int at) =>
      ((b[at] & 0x7f) << 21) |
      ((b[at + 1] & 0x7f) << 14) |
      ((b[at + 2] & 0x7f) << 7) |
      (b[at + 3] & 0x7f);
}
