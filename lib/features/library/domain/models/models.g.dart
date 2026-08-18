// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSongCollection on Isar {
  IsarCollection<Song> get songs => this.collection();
}

const SongSchema = CollectionSchema(
  name: r'Song',
  id: -5548886644249537934,
  properties: {
    r'album': PropertySchema(
      id: 0,
      name: r'album',
      type: IsarType.string,
    ),
    r'albumArtist': PropertySchema(
      id: 1,
      name: r'albumArtist',
      type: IsarType.string,
    ),
    r'artPath': PropertySchema(
      id: 2,
      name: r'artPath',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 3,
      name: r'artist',
      type: IsarType.string,
    ),
    r'dateAdded': PropertySchema(
      id: 4,
      name: r'dateAdded',
      type: IsarType.dateTime,
    ),
    r'discNumber': PropertySchema(
      id: 5,
      name: r'discNumber',
      type: IsarType.long,
    ),
    r'discTotal': PropertySchema(
      id: 6,
      name: r'discTotal',
      type: IsarType.long,
    ),
    r'duration': PropertySchema(
      id: 7,
      name: r'duration',
      type: IsarType.long,
    ),
    r'equalizerGains': PropertySchema(
      id: 8,
      name: r'equalizerGains',
      type: IsarType.doubleList,
    ),
    r'genre': PropertySchema(
      id: 9,
      name: r'genre',
      type: IsarType.string,
    ),
    r'hasCustomEqualizer': PropertySchema(
      id: 10,
      name: r'hasCustomEqualizer',
      type: IsarType.bool,
    ),
    r'isFavorite': PropertySchema(
      id: 11,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'isOnlineStream': PropertySchema(
      id: 12,
      name: r'isOnlineStream',
      type: IsarType.bool,
    ),
    r'lastPlayed': PropertySchema(
      id: 13,
      name: r'lastPlayed',
      type: IsarType.dateTime,
    ),
    r'lyrics': PropertySchema(
      id: 14,
      name: r'lyrics',
      type: IsarType.string,
    ),
    r'lyricsOffsetMs': PropertySchema(
      id: 15,
      name: r'lyricsOffsetMs',
      type: IsarType.long,
    ),
    r'onlineArtUrl': PropertySchema(
      id: 16,
      name: r'onlineArtUrl',
      type: IsarType.string,
    ),
    r'path': PropertySchema(
      id: 17,
      name: r'path',
      type: IsarType.string,
    ),
    r'playCount': PropertySchema(
      id: 18,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'searchTerms': PropertySchema(
      id: 19,
      name: r'searchTerms',
      type: IsarType.stringList,
    ),
    r'streamQuality': PropertySchema(
      id: 20,
      name: r'streamQuality',
      type: IsarType.long,
    ),
    r'streamUrl': PropertySchema(
      id: 21,
      name: r'streamUrl',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 22,
      name: r'title',
      type: IsarType.string,
    ),
    r'trackNumber': PropertySchema(
      id: 23,
      name: r'trackNumber',
      type: IsarType.long,
    ),
    r'trackTotal': PropertySchema(
      id: 24,
      name: r'trackTotal',
      type: IsarType.long,
    ),
    r'year': PropertySchema(
      id: 25,
      name: r'year',
      type: IsarType.long,
    ),
    r'youtubeId': PropertySchema(
      id: 26,
      name: r'youtubeId',
      type: IsarType.string,
    )
  },
  estimateSize: _songEstimateSize,
  serialize: _songSerialize,
  deserialize: _songDeserialize,
  deserializeProp: _songDeserializeProp,
  idName: r'id',
  indexes: {
    r'path': IndexSchema(
      id: 8756705481922369689,
      name: r'path',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'artist': IndexSchema(
      id: 5842945185359817302,
      name: r'artist',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'artist',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'albumArtist': IndexSchema(
      id: -2813310885085277532,
      name: r'albumArtist',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'albumArtist',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'album': IndexSchema(
      id: 6222745341035631462,
      name: r'album',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'album',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dateAdded': IndexSchema(
      id: 7425792204428031576,
      name: r'dateAdded',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateAdded',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'lastPlayed': IndexSchema(
      id: -8420677377986255979,
      name: r'lastPlayed',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastPlayed',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'searchTerms': IndexSchema(
      id: 255720506161592250,
      name: r'searchTerms',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'searchTerms',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _songGetId,
  getLinks: _songGetLinks,
  attach: _songAttach,
  version: '3.1.0+1',
);

int _songEstimateSize(
  Song object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.album;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.albumArtist;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artist;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.equalizerGains;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.genre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lyrics;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.onlineArtUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.path.length * 3;
  bytesCount += 3 + object.searchTerms.length * 3;
  {
    for (var i = 0; i < object.searchTerms.length; i++) {
      final value = object.searchTerms[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.streamUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.youtubeId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _songSerialize(
  Song object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.album);
  writer.writeString(offsets[1], object.albumArtist);
  writer.writeString(offsets[2], object.artPath);
  writer.writeString(offsets[3], object.artist);
  writer.writeDateTime(offsets[4], object.dateAdded);
  writer.writeLong(offsets[5], object.discNumber);
  writer.writeLong(offsets[6], object.discTotal);
  writer.writeLong(offsets[7], object.duration);
  writer.writeDoubleList(offsets[8], object.equalizerGains);
  writer.writeString(offsets[9], object.genre);
  writer.writeBool(offsets[10], object.hasCustomEqualizer);
  writer.writeBool(offsets[11], object.isFavorite);
  writer.writeBool(offsets[12], object.isOnlineStream);
  writer.writeDateTime(offsets[13], object.lastPlayed);
  writer.writeString(offsets[14], object.lyrics);
  writer.writeLong(offsets[15], object.lyricsOffsetMs);
  writer.writeString(offsets[16], object.onlineArtUrl);
  writer.writeString(offsets[17], object.path);
  writer.writeLong(offsets[18], object.playCount);
  writer.writeStringList(offsets[19], object.searchTerms);
  writer.writeLong(offsets[20], object.streamQuality);
  writer.writeString(offsets[21], object.streamUrl);
  writer.writeString(offsets[22], object.title);
  writer.writeLong(offsets[23], object.trackNumber);
  writer.writeLong(offsets[24], object.trackTotal);
  writer.writeLong(offsets[25], object.year);
  writer.writeString(offsets[26], object.youtubeId);
}

Song _songDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Song();
  object.album = reader.readStringOrNull(offsets[0]);
  object.albumArtist = reader.readStringOrNull(offsets[1]);
  object.artPath = reader.readStringOrNull(offsets[2]);
  object.artist = reader.readStringOrNull(offsets[3]);
  object.dateAdded = reader.readDateTime(offsets[4]);
  object.discNumber = reader.readLongOrNull(offsets[5]);
  object.discTotal = reader.readLongOrNull(offsets[6]);
  object.duration = reader.readLongOrNull(offsets[7]);
  object.equalizerGains = reader.readDoubleList(offsets[8]);
  object.genre = reader.readStringOrNull(offsets[9]);
  object.hasCustomEqualizer = reader.readBool(offsets[10]);
  object.id = id;
  object.isFavorite = reader.readBool(offsets[11]);
  object.isOnlineStream = reader.readBool(offsets[12]);
  object.lastPlayed = reader.readDateTimeOrNull(offsets[13]);
  object.lyrics = reader.readStringOrNull(offsets[14]);
  object.lyricsOffsetMs = reader.readLongOrNull(offsets[15]);
  object.onlineArtUrl = reader.readStringOrNull(offsets[16]);
  object.path = reader.readString(offsets[17]);
  object.playCount = reader.readLong(offsets[18]);
  object.streamQuality = reader.readLongOrNull(offsets[20]);
  object.streamUrl = reader.readStringOrNull(offsets[21]);
  object.title = reader.readString(offsets[22]);
  object.trackNumber = reader.readLongOrNull(offsets[23]);
  object.trackTotal = reader.readLongOrNull(offsets[24]);
  object.year = reader.readLongOrNull(offsets[25]);
  object.youtubeId = reader.readStringOrNull(offsets[26]);
  return object;
}

P _songDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleList(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readStringList(offset) ?? []) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readLongOrNull(offset)) as P;
    case 24:
      return (reader.readLongOrNull(offset)) as P;
    case 25:
      return (reader.readLongOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _songGetId(Song object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _songGetLinks(Song object) {
  return [];
}

void _songAttach(IsarCollection<dynamic> col, Id id, Song object) {
  object.id = id;
}

extension SongByIndex on IsarCollection<Song> {
  Future<Song?> getByPath(String path) {
    return getByIndex(r'path', [path]);
  }

  Song? getByPathSync(String path) {
    return getByIndexSync(r'path', [path]);
  }

  Future<bool> deleteByPath(String path) {
    return deleteByIndex(r'path', [path]);
  }

  bool deleteByPathSync(String path) {
    return deleteByIndexSync(r'path', [path]);
  }

  Future<List<Song?>> getAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndex(r'path', values);
  }

  List<Song?> getAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'path', values);
  }

  Future<int> deleteAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'path', values);
  }

  int deleteAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'path', values);
  }

  Future<Id> putByPath(Song object) {
    return putByIndex(r'path', object);
  }

  Id putByPathSync(Song object, {bool saveLinks = true}) {
    return putByIndexSync(r'path', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPath(List<Song> objects) {
    return putAllByIndex(r'path', objects);
  }

  List<Id> putAllByPathSync(List<Song> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'path', objects, saveLinks: saveLinks);
  }
}

extension SongQueryWhereSort on QueryBuilder<Song, Song, QWhere> {
  QueryBuilder<Song, Song, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Song, Song, QAfterWhere> anyDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateAdded'),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhere> anyLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastPlayed'),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhere> anySearchTermsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'searchTerms'),
      );
    });
  }
}

extension SongQueryWhere on QueryBuilder<Song, Song, QWhereClause> {
  QueryBuilder<Song, Song, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path',
        value: [path],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathNotEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'artist',
        value: [null],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'artist',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistEqualTo(String? artist) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'artist',
        value: [artist],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistNotEqualTo(String? artist) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [],
              upper: [artist],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [artist],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [artist],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [],
              upper: [artist],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumArtistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'albumArtist',
        value: [null],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumArtistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'albumArtist',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumArtistEqualTo(
      String? albumArtist) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'albumArtist',
        value: [albumArtist],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumArtistNotEqualTo(
      String? albumArtist) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'albumArtist',
              lower: [],
              upper: [albumArtist],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'albumArtist',
              lower: [albumArtist],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'albumArtist',
              lower: [albumArtist],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'albumArtist',
              lower: [],
              upper: [albumArtist],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'album',
        value: [null],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'album',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumEqualTo(String? album) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'album',
        value: [album],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumNotEqualTo(String? album) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [],
              upper: [album],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [album],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [album],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [],
              upper: [album],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedEqualTo(
      DateTime dateAdded) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateAdded',
        value: [dateAdded],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedNotEqualTo(
      DateTime dateAdded) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [],
              upper: [dateAdded],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [dateAdded],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [dateAdded],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [],
              upper: [dateAdded],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedGreaterThan(
    DateTime dateAdded, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [dateAdded],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedLessThan(
    DateTime dateAdded, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [],
        upper: [dateAdded],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> dateAddedBetween(
    DateTime lowerDateAdded,
    DateTime upperDateAdded, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [lowerDateAdded],
        includeLower: includeLower,
        upper: [upperDateAdded],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastPlayed',
        value: [null],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedEqualTo(
      DateTime? lastPlayed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastPlayed',
        value: [lastPlayed],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedNotEqualTo(
      DateTime? lastPlayed) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [],
              upper: [lastPlayed],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [lastPlayed],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [lastPlayed],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [],
              upper: [lastPlayed],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedGreaterThan(
    DateTime? lastPlayed, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [lastPlayed],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedLessThan(
    DateTime? lastPlayed, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [],
        upper: [lastPlayed],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> lastPlayedBetween(
    DateTime? lowerLastPlayed,
    DateTime? upperLastPlayed, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [lowerLastPlayed],
        includeLower: includeLower,
        upper: [upperLastPlayed],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementEqualTo(
      String searchTermsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchTerms',
        value: [searchTermsElement],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementNotEqualTo(
      String searchTermsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerms',
              lower: [],
              upper: [searchTermsElement],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerms',
              lower: [searchTermsElement],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerms',
              lower: [searchTermsElement],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTerms',
              lower: [],
              upper: [searchTermsElement],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementGreaterThan(
    String searchTermsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchTerms',
        lower: [searchTermsElement],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementLessThan(
    String searchTermsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchTerms',
        lower: [],
        upper: [searchTermsElement],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementBetween(
    String lowerSearchTermsElement,
    String upperSearchTermsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchTerms',
        lower: [lowerSearchTermsElement],
        includeLower: includeLower,
        upper: [upperSearchTermsElement],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementStartsWith(
      String SearchTermsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'searchTerms',
        lower: [SearchTermsElementPrefix],
        upper: ['$SearchTermsElementPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchTerms',
        value: [''],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> searchTermsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'searchTerms',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'searchTerms',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'searchTerms',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'searchTerms',
              upper: [''],
            ));
      }
    });
  }
}

extension SongQueryFilter on QueryBuilder<Song, Song, QFilterCondition> {
  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'album',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'album',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'albumArtist',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'albumArtist',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'albumArtist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'albumArtist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumArtist',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumArtistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'albumArtist',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateAdded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'discNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'discNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'discTotal',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'discTotal',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discTotalEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discTotalGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discTotalLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discTotalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'equalizerGains',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'equalizerGains',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'equalizerGains',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      equalizerGainsElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'equalizerGains',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'equalizerGains',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'equalizerGains',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equalizerGains',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equalizerGains',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equalizerGains',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equalizerGains',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      equalizerGainsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equalizerGains',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> equalizerGainsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'equalizerGains',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> hasCustomEqualizerEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasCustomEqualizer',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> isFavoriteEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> isOnlineStreamEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOnlineStream',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlayed',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlayed',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lyrics',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lyrics',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyrics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lyrics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsOffsetMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lyricsOffsetMs',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsOffsetMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lyricsOffsetMs',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsOffsetMsEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsOffsetMs',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsOffsetMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyricsOffsetMs',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsOffsetMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyricsOffsetMs',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsOffsetMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyricsOffsetMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'onlineArtUrl',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'onlineArtUrl',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onlineArtUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'onlineArtUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'onlineArtUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'onlineArtUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'onlineArtUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'onlineArtUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'onlineArtUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'onlineArtUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onlineArtUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> onlineArtUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'onlineArtUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> playCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> playCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> playCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> playCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchTerms',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchTerms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchTerms',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTerms',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      searchTermsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchTerms',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> searchTermsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTerms',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamQualityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamQuality',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamQualityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamQuality',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamQualityEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamQualityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamQualityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamQualityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamQuality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamUrl',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamUrl',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streamUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streamUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> streamUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trackNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trackNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trackTotal',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trackTotal',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackTotalEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackTotalGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackTotalLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackTotalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'youtubeId',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'youtubeId',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'youtubeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'youtubeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'youtubeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'youtubeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'youtubeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'youtubeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'youtubeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'youtubeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'youtubeId',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> youtubeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'youtubeId',
        value: '',
      ));
    });
  }
}

extension SongQueryObject on QueryBuilder<Song, Song, QFilterCondition> {}

extension SongQueryLinks on QueryBuilder<Song, Song, QFilterCondition> {}

extension SongQuerySortBy on QueryBuilder<Song, Song, QSortBy> {
  QueryBuilder<Song, Song, QAfterSortBy> sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByAlbumArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumArtist', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByAlbumArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumArtist', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDiscNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDiscNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDiscTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discTotal', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDiscTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discTotal', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByHasCustomEqualizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCustomEqualizer', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByHasCustomEqualizerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCustomEqualizer', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByIsOnlineStream() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnlineStream', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByIsOnlineStreamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnlineStream', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyricsOffsetMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsOffsetMs', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyricsOffsetMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsOffsetMs', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByOnlineArtUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onlineArtUrl', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByOnlineArtUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onlineArtUrl', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByStreamQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamQuality', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByStreamQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamQuality', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByStreamUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamUrl', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByStreamUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamUrl', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTrackNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTrackTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackTotal', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTrackTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackTotal', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByYoutubeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'youtubeId', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByYoutubeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'youtubeId', Sort.desc);
    });
  }
}

extension SongQuerySortThenBy on QueryBuilder<Song, Song, QSortThenBy> {
  QueryBuilder<Song, Song, QAfterSortBy> thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByAlbumArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumArtist', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByAlbumArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumArtist', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDiscNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDiscNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDiscTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discTotal', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDiscTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discTotal', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByHasCustomEqualizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCustomEqualizer', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByHasCustomEqualizerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCustomEqualizer', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIsOnlineStream() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnlineStream', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIsOnlineStreamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOnlineStream', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyricsOffsetMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsOffsetMs', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyricsOffsetMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsOffsetMs', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByOnlineArtUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onlineArtUrl', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByOnlineArtUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onlineArtUrl', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByStreamQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamQuality', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByStreamQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamQuality', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByStreamUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamUrl', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByStreamUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamUrl', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTrackNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTrackTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackTotal', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTrackTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackTotal', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByYoutubeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'youtubeId', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByYoutubeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'youtubeId', Sort.desc);
    });
  }
}

extension SongQueryWhereDistinct on QueryBuilder<Song, Song, QDistinct> {
  QueryBuilder<Song, Song, QDistinct> distinctByAlbum(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByAlbumArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'albumArtist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByArtPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateAdded');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDiscNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discNumber');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDiscTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discTotal');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByEqualizerGains() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'equalizerGains');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByGenre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByHasCustomEqualizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasCustomEqualizer');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByIsOnlineStream() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOnlineStream');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayed');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByLyrics(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyrics', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByLyricsOffsetMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyricsOffsetMs');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByOnlineArtUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onlineArtUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playCount');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctBySearchTerms() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchTerms');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByStreamQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamQuality');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByStreamUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackNumber');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByTrackTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackTotal');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByYoutubeId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'youtubeId', caseSensitive: caseSensitive);
    });
  }
}

extension SongQueryProperty on QueryBuilder<Song, Song, QQueryProperty> {
  QueryBuilder<Song, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> albumArtistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'albumArtist');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> artPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artPath');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<Song, DateTime, QQueryOperations> dateAddedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateAdded');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> discNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discNumber');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> discTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discTotal');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<Song, List<double>?, QQueryOperations> equalizerGainsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'equalizerGains');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> genreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genre');
    });
  }

  QueryBuilder<Song, bool, QQueryOperations> hasCustomEqualizerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasCustomEqualizer');
    });
  }

  QueryBuilder<Song, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<Song, bool, QQueryOperations> isOnlineStreamProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOnlineStream');
    });
  }

  QueryBuilder<Song, DateTime?, QQueryOperations> lastPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayed');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> lyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyrics');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> lyricsOffsetMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyricsOffsetMs');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> onlineArtUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onlineArtUrl');
    });
  }

  QueryBuilder<Song, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<Song, int, QQueryOperations> playCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playCount');
    });
  }

  QueryBuilder<Song, List<String>, QQueryOperations> searchTermsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchTerms');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> streamQualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamQuality');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> streamUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamUrl');
    });
  }

  QueryBuilder<Song, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> trackNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackNumber');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> trackTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackTotal');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> youtubeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'youtubeId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAlbumCollection on Isar {
  IsarCollection<Album> get albums => this.collection();
}

const AlbumSchema = CollectionSchema(
  name: r'Album',
  id: -1355968412107120937,
  properties: {
    r'artPath': PropertySchema(
      id: 0,
      name: r'artPath',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 1,
      name: r'artist',
      type: IsarType.string,
    ),
    r'dateAdded': PropertySchema(
      id: 2,
      name: r'dateAdded',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'year': PropertySchema(
      id: 4,
      name: r'year',
      type: IsarType.long,
    )
  },
  estimateSize: _albumEstimateSize,
  serialize: _albumSerialize,
  deserialize: _albumDeserialize,
  deserializeProp: _albumDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dateAdded': IndexSchema(
      id: 7425792204428031576,
      name: r'dateAdded',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateAdded',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _albumGetId,
  getLinks: _albumGetLinks,
  attach: _albumAttach,
  version: '3.1.0+1',
);

int _albumEstimateSize(
  Album object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.artPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artist;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _albumSerialize(
  Album object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artPath);
  writer.writeString(offsets[1], object.artist);
  writer.writeDateTime(offsets[2], object.dateAdded);
  writer.writeString(offsets[3], object.name);
  writer.writeLong(offsets[4], object.year);
}

Album _albumDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Album();
  object.artPath = reader.readStringOrNull(offsets[0]);
  object.artist = reader.readStringOrNull(offsets[1]);
  object.dateAdded = reader.readDateTime(offsets[2]);
  object.id = id;
  object.name = reader.readString(offsets[3]);
  object.year = reader.readLongOrNull(offsets[4]);
  return object;
}

P _albumDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _albumGetId(Album object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _albumGetLinks(Album object) {
  return [];
}

void _albumAttach(IsarCollection<dynamic> col, Id id, Album object) {
  object.id = id;
}

extension AlbumByIndex on IsarCollection<Album> {
  Future<Album?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  Album? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Album?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Album?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Album object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Album object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Album> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Album> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension AlbumQueryWhereSort on QueryBuilder<Album, Album, QWhere> {
  QueryBuilder<Album, Album, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Album, Album, QAfterWhere> anyDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateAdded'),
      );
    });
  }
}

extension AlbumQueryWhere on QueryBuilder<Album, Album, QWhereClause> {
  QueryBuilder<Album, Album, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedEqualTo(
      DateTime dateAdded) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateAdded',
        value: [dateAdded],
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedNotEqualTo(
      DateTime dateAdded) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [],
              upper: [dateAdded],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [dateAdded],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [dateAdded],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateAdded',
              lower: [],
              upper: [dateAdded],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedGreaterThan(
    DateTime dateAdded, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [dateAdded],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedLessThan(
    DateTime dateAdded, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [],
        upper: [dateAdded],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> dateAddedBetween(
    DateTime lowerDateAdded,
    DateTime upperDateAdded, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateAdded',
        lower: [lowerDateAdded],
        includeLower: includeLower,
        upper: [upperDateAdded],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AlbumQueryFilter on QueryBuilder<Album, Album, QFilterCondition> {
  QueryBuilder<Album, Album, QAfterFilterCondition> artPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> dateAddedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> dateAddedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> dateAddedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> dateAddedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateAdded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> yearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AlbumQueryObject on QueryBuilder<Album, Album, QFilterCondition> {}

extension AlbumQueryLinks on QueryBuilder<Album, Album, QFilterCondition> {}

extension AlbumQuerySortBy on QueryBuilder<Album, Album, QSortBy> {
  QueryBuilder<Album, Album, QAfterSortBy> sortByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension AlbumQuerySortThenBy on QueryBuilder<Album, Album, QSortThenBy> {
  QueryBuilder<Album, Album, QAfterSortBy> thenByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension AlbumQueryWhereDistinct on QueryBuilder<Album, Album, QDistinct> {
  QueryBuilder<Album, Album, QDistinct> distinctByArtPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Album, Album, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Album, Album, QDistinct> distinctByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateAdded');
    });
  }

  QueryBuilder<Album, Album, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Album, Album, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension AlbumQueryProperty on QueryBuilder<Album, Album, QQueryProperty> {
  QueryBuilder<Album, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Album, String?, QQueryOperations> artPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artPath');
    });
  }

  QueryBuilder<Album, String?, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<Album, DateTime, QQueryOperations> dateAddedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateAdded');
    });
  }

  QueryBuilder<Album, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Album, int?, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetArtistCollection on Isar {
  IsarCollection<Artist> get artists => this.collection();
}

const ArtistSchema = CollectionSchema(
  name: r'Artist',
  id: 3750894727498641923,
  properties: {
    r'artPath': PropertySchema(
      id: 0,
      name: r'artPath',
      type: IsarType.string,
    ),
    r'artistImageUrl': PropertySchema(
      id: 1,
      name: r'artistImageUrl',
      type: IsarType.string,
    ),
    r'artistImages': PropertySchema(
      id: 2,
      name: r'artistImages',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _artistEstimateSize,
  serialize: _artistSerialize,
  deserialize: _artistDeserialize,
  deserializeProp: _artistDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _artistGetId,
  getLinks: _artistGetLinks,
  attach: _artistAttach,
  version: '3.1.0+1',
);

int _artistEstimateSize(
  Artist object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.artPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artistImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.artistImages.length * 3;
  {
    for (var i = 0; i < object.artistImages.length; i++) {
      final value = object.artistImages[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _artistSerialize(
  Artist object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artPath);
  writer.writeString(offsets[1], object.artistImageUrl);
  writer.writeStringList(offsets[2], object.artistImages);
  writer.writeString(offsets[3], object.name);
}

Artist _artistDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Artist();
  object.artPath = reader.readStringOrNull(offsets[0]);
  object.artistImageUrl = reader.readStringOrNull(offsets[1]);
  object.artistImages = reader.readStringList(offsets[2]) ?? [];
  object.id = id;
  object.name = reader.readString(offsets[3]);
  return object;
}

P _artistDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _artistGetId(Artist object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _artistGetLinks(Artist object) {
  return [];
}

void _artistAttach(IsarCollection<dynamic> col, Id id, Artist object) {
  object.id = id;
}

extension ArtistByIndex on IsarCollection<Artist> {
  Future<Artist?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  Artist? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Artist?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Artist?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Artist object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Artist object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Artist> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Artist> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension ArtistQueryWhereSort on QueryBuilder<Artist, Artist, QWhere> {
  QueryBuilder<Artist, Artist, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ArtistQueryWhere on QueryBuilder<Artist, Artist, QWhereClause> {
  QueryBuilder<Artist, Artist, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterWhereClause> nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ArtistQueryFilter on QueryBuilder<Artist, Artist, QFilterCondition> {
  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artistImageUrl',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artistImageUrl',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artistImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artistImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artistImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artistImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artistImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artistImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artistImages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artistImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artistImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artistImages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artistImages',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistImages',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artistImages',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImagesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistImages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistImages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistImages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistImages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition>
      artistImagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistImages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> artistImagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artistImages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Artist, Artist, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension ArtistQueryObject on QueryBuilder<Artist, Artist, QFilterCondition> {}

extension ArtistQueryLinks on QueryBuilder<Artist, Artist, QFilterCondition> {}

extension ArtistQuerySortBy on QueryBuilder<Artist, Artist, QSortBy> {
  QueryBuilder<Artist, Artist, QAfterSortBy> sortByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByArtistImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistImageUrl', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByArtistImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistImageUrl', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ArtistQuerySortThenBy on QueryBuilder<Artist, Artist, QSortThenBy> {
  QueryBuilder<Artist, Artist, QAfterSortBy> thenByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByArtistImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistImageUrl', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByArtistImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistImageUrl', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Artist, Artist, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ArtistQueryWhereDistinct on QueryBuilder<Artist, Artist, QDistinct> {
  QueryBuilder<Artist, Artist, QDistinct> distinctByArtPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Artist, Artist, QDistinct> distinctByArtistImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistImageUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Artist, Artist, QDistinct> distinctByArtistImages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistImages');
    });
  }

  QueryBuilder<Artist, Artist, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension ArtistQueryProperty on QueryBuilder<Artist, Artist, QQueryProperty> {
  QueryBuilder<Artist, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Artist, String?, QQueryOperations> artPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artPath');
    });
  }

  QueryBuilder<Artist, String?, QQueryOperations> artistImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistImageUrl');
    });
  }

  QueryBuilder<Artist, List<String>, QQueryOperations> artistImagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistImages');
    });
  }

  QueryBuilder<Artist, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaylistCollection on Isar {
  IsarCollection<Playlist> get playlists => this.collection();
}

const PlaylistSchema = CollectionSchema(
  name: r'Playlist',
  id: 4190497698144499986,
  properties: {
    r'dateCreated': PropertySchema(
      id: 0,
      name: r'dateCreated',
      type: IsarType.dateTime,
    ),
    r'dateModified': PropertySchema(
      id: 1,
      name: r'dateModified',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'songPaths': PropertySchema(
      id: 3,
      name: r'songPaths',
      type: IsarType.stringList,
    )
  },
  estimateSize: _playlistEstimateSize,
  serialize: _playlistSerialize,
  deserialize: _playlistDeserialize,
  deserializeProp: _playlistDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _playlistGetId,
  getLinks: _playlistGetLinks,
  attach: _playlistAttach,
  version: '3.1.0+1',
);

int _playlistEstimateSize(
  Playlist object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.songPaths.length * 3;
  {
    for (var i = 0; i < object.songPaths.length; i++) {
      final value = object.songPaths[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _playlistSerialize(
  Playlist object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateCreated);
  writer.writeDateTime(offsets[1], object.dateModified);
  writer.writeString(offsets[2], object.name);
  writer.writeStringList(offsets[3], object.songPaths);
}

Playlist _playlistDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Playlist();
  object.dateCreated = reader.readDateTime(offsets[0]);
  object.dateModified = reader.readDateTime(offsets[1]);
  object.id = id;
  object.name = reader.readString(offsets[2]);
  object.songPaths = reader.readStringList(offsets[3]) ?? [];
  return object;
}

P _playlistDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playlistGetId(Playlist object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playlistGetLinks(Playlist object) {
  return [];
}

void _playlistAttach(IsarCollection<dynamic> col, Id id, Playlist object) {
  object.id = id;
}

extension PlaylistByIndex on IsarCollection<Playlist> {
  Future<Playlist?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  Playlist? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Playlist?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Playlist?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Playlist object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Playlist object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Playlist> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Playlist> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension PlaylistQueryWhereSort on QueryBuilder<Playlist, Playlist, QWhere> {
  QueryBuilder<Playlist, Playlist, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlaylistQueryWhere on QueryBuilder<Playlist, Playlist, QWhereClause> {
  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlaylistQueryFilter
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {
  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateCreatedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      dateCreatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateCreatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateCreatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateCreated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateModifiedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      dateModifiedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateModifiedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> dateModifiedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateModified',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'songPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'songPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'songPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> songPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      songPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension PlaylistQueryObject
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {}

extension PlaylistQueryLinks
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {}

extension PlaylistQuerySortBy on QueryBuilder<Playlist, Playlist, QSortBy> {
  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByDateCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByDateModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension PlaylistQuerySortThenBy
    on QueryBuilder<Playlist, Playlist, QSortThenBy> {
  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByDateCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCreated', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByDateModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension PlaylistQueryWhereDistinct
    on QueryBuilder<Playlist, Playlist, QDistinct> {
  QueryBuilder<Playlist, Playlist, QDistinct> distinctByDateCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateCreated');
    });
  }

  QueryBuilder<Playlist, Playlist, QDistinct> distinctByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateModified');
    });
  }

  QueryBuilder<Playlist, Playlist, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Playlist, Playlist, QDistinct> distinctBySongPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songPaths');
    });
  }
}

extension PlaylistQueryProperty
    on QueryBuilder<Playlist, Playlist, QQueryProperty> {
  QueryBuilder<Playlist, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Playlist, DateTime, QQueryOperations> dateCreatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateCreated');
    });
  }

  QueryBuilder<Playlist, DateTime, QQueryOperations> dateModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateModified');
    });
  }

  QueryBuilder<Playlist, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Playlist, List<String>, QQueryOperations> songPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songPaths');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSavedQueueCollection on Isar {
  IsarCollection<SavedQueue> get savedQueues => this.collection();
}

const SavedQueueSchema = CollectionSchema(
  name: r'SavedQueue',
  id: -6242105563991824807,
  properties: {
    r'currentIndex': PropertySchema(
      id: 0,
      name: r'currentIndex',
      type: IsarType.long,
    ),
    r'isPermanent': PropertySchema(
      id: 1,
      name: r'isPermanent',
      type: IsarType.bool,
    ),
    r'isShuffle': PropertySchema(
      id: 2,
      name: r'isShuffle',
      type: IsarType.bool,
    ),
    r'lastPlayed': PropertySchema(
      id: 3,
      name: r'lastPlayed',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'positionMs': PropertySchema(
      id: 5,
      name: r'positionMs',
      type: IsarType.long,
    ),
    r'songIds': PropertySchema(
      id: 6,
      name: r'songIds',
      type: IsarType.longList,
    )
  },
  estimateSize: _savedQueueEstimateSize,
  serialize: _savedQueueSerialize,
  deserialize: _savedQueueDeserialize,
  deserializeProp: _savedQueueDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _savedQueueGetId,
  getLinks: _savedQueueGetLinks,
  attach: _savedQueueAttach,
  version: '3.1.0+1',
);

int _savedQueueEstimateSize(
  SavedQueue object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.songIds.length * 8;
  return bytesCount;
}

void _savedQueueSerialize(
  SavedQueue object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentIndex);
  writer.writeBool(offsets[1], object.isPermanent);
  writer.writeBool(offsets[2], object.isShuffle);
  writer.writeDateTime(offsets[3], object.lastPlayed);
  writer.writeString(offsets[4], object.name);
  writer.writeLong(offsets[5], object.positionMs);
  writer.writeLongList(offsets[6], object.songIds);
}

SavedQueue _savedQueueDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavedQueue();
  object.currentIndex = reader.readLong(offsets[0]);
  object.id = id;
  object.isPermanent = reader.readBool(offsets[1]);
  object.isShuffle = reader.readBool(offsets[2]);
  object.lastPlayed = reader.readDateTime(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.positionMs = reader.readLong(offsets[5]);
  object.songIds = reader.readLongList(offsets[6]) ?? [];
  return object;
}

P _savedQueueDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _savedQueueGetId(SavedQueue object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _savedQueueGetLinks(SavedQueue object) {
  return [];
}

void _savedQueueAttach(IsarCollection<dynamic> col, Id id, SavedQueue object) {
  object.id = id;
}

extension SavedQueueByIndex on IsarCollection<SavedQueue> {
  Future<SavedQueue?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  SavedQueue? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<SavedQueue?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<SavedQueue?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(SavedQueue object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(SavedQueue object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<SavedQueue> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<SavedQueue> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension SavedQueueQueryWhereSort
    on QueryBuilder<SavedQueue, SavedQueue, QWhere> {
  QueryBuilder<SavedQueue, SavedQueue, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SavedQueueQueryWhere
    on QueryBuilder<SavedQueue, SavedQueue, QWhereClause> {
  QueryBuilder<SavedQueue, SavedQueue, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SavedQueueQueryFilter
    on QueryBuilder<SavedQueue, SavedQueue, QFilterCondition> {
  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      currentIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      currentIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      currentIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      currentIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      isPermanentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPermanent',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> isShuffleEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isShuffle',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> lastPlayedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      lastPlayedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      lastPlayedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> lastPlayedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> positionMsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      positionMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      positionMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> positionMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'positionMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition> songIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterFilterCondition>
      songIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension SavedQueueQueryObject
    on QueryBuilder<SavedQueue, SavedQueue, QFilterCondition> {}

extension SavedQueueQueryLinks
    on QueryBuilder<SavedQueue, SavedQueue, QFilterCondition> {}

extension SavedQueueQuerySortBy
    on QueryBuilder<SavedQueue, SavedQueue, QSortBy> {
  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByCurrentIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByIsPermanent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPermanent', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByIsPermanentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPermanent', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByIsShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShuffle', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByIsShuffleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShuffle', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> sortByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }
}

extension SavedQueueQuerySortThenBy
    on QueryBuilder<SavedQueue, SavedQueue, QSortThenBy> {
  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByCurrentIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByIsPermanent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPermanent', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByIsPermanentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPermanent', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByIsShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShuffle', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByIsShuffleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShuffle', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QAfterSortBy> thenByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }
}

extension SavedQueueQueryWhereDistinct
    on QueryBuilder<SavedQueue, SavedQueue, QDistinct> {
  QueryBuilder<SavedQueue, SavedQueue, QDistinct> distinctByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentIndex');
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QDistinct> distinctByIsPermanent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPermanent');
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QDistinct> distinctByIsShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isShuffle');
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QDistinct> distinctByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayed');
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QDistinct> distinctByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionMs');
    });
  }

  QueryBuilder<SavedQueue, SavedQueue, QDistinct> distinctBySongIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songIds');
    });
  }
}

extension SavedQueueQueryProperty
    on QueryBuilder<SavedQueue, SavedQueue, QQueryProperty> {
  QueryBuilder<SavedQueue, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SavedQueue, int, QQueryOperations> currentIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentIndex');
    });
  }

  QueryBuilder<SavedQueue, bool, QQueryOperations> isPermanentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPermanent');
    });
  }

  QueryBuilder<SavedQueue, bool, QQueryOperations> isShuffleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isShuffle');
    });
  }

  QueryBuilder<SavedQueue, DateTime, QQueryOperations> lastPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayed');
    });
  }

  QueryBuilder<SavedQueue, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SavedQueue, int, QQueryOperations> positionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionMs');
    });
  }

  QueryBuilder<SavedQueue, List<int>, QQueryOperations> songIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songIds');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsCollection on Isar {
  IsarCollection<AppSettings> get appSettings => this.collection();
}

const AppSettingsSchema = CollectionSchema(
  name: r'AppSettings',
  id: -5633561779022347008,
  properties: {
    r'accentColor': PropertySchema(
      id: 0,
      name: r'accentColor',
      type: IsarType.long,
    ),
    r'activeLyricsFontWeightDelta': PropertySchema(
      id: 1,
      name: r'activeLyricsFontWeightDelta',
      type: IsarType.long,
    ),
    r'activeQueueName': PropertySchema(
      id: 2,
      name: r'activeQueueName',
      type: IsarType.string,
    ),
    r'albumDetailSortAscending': PropertySchema(
      id: 3,
      name: r'albumDetailSortAscending',
      type: IsarType.bool,
    ),
    r'albumDetailSortOptionIndex': PropertySchema(
      id: 4,
      name: r'albumDetailSortOptionIndex',
      type: IsarType.long,
    ),
    r'albumSortOptionIndex': PropertySchema(
      id: 5,
      name: r'albumSortOptionIndex',
      type: IsarType.long,
    ),
    r'artistDetailSortAscending': PropertySchema(
      id: 6,
      name: r'artistDetailSortAscending',
      type: IsarType.bool,
    ),
    r'artistDetailSortOptionIndex': PropertySchema(
      id: 7,
      name: r'artistDetailSortOptionIndex',
      type: IsarType.long,
    ),
    r'artistSortOptionIndex': PropertySchema(
      id: 8,
      name: r'artistSortOptionIndex',
      type: IsarType.long,
    ),
    r'audioBackCacheSizeMB': PropertySchema(
      id: 9,
      name: r'audioBackCacheSizeMB',
      type: IsarType.long,
    ),
    r'audioCacheSecs': PropertySchema(
      id: 10,
      name: r'audioCacheSecs',
      type: IsarType.long,
    ),
    r'audioCacheSizeMB': PropertySchema(
      id: 11,
      name: r'audioCacheSizeMB',
      type: IsarType.long,
    ),
    r'audioFocus': PropertySchema(
      id: 12,
      name: r'audioFocus',
      type: IsarType.bool,
    ),
    r'audioFocusReleaseOnPause': PropertySchema(
      id: 13,
      name: r'audioFocusReleaseOnPause',
      type: IsarType.bool,
    ),
    r'audioFocusRequestOnPlay': PropertySchema(
      id: 14,
      name: r'audioFocusRequestOnPlay',
      type: IsarType.bool,
    ),
    r'audioFocusRestartOnGain': PropertySchema(
      id: 15,
      name: r'audioFocusRestartOnGain',
      type: IsarType.bool,
    ),
    r'audioFocusStopOnOtherSession': PropertySchema(
      id: 16,
      name: r'audioFocusStopOnOtherSession',
      type: IsarType.bool,
    ),
    r'bgBrightness': PropertySchema(
      id: 17,
      name: r'bgBrightness',
      type: IsarType.double,
    ),
    r'bgOpacity': PropertySchema(
      id: 18,
      name: r'bgOpacity',
      type: IsarType.double,
    ),
    r'blurredArtworkForLyrics': PropertySchema(
      id: 19,
      name: r'blurredArtworkForLyrics',
      type: IsarType.bool,
    ),
    r'cacheOnlineStreams': PropertySchema(
      id: 20,
      name: r'cacheOnlineStreams',
      type: IsarType.bool,
    ),
    r'collectionSortAscending': PropertySchema(
      id: 21,
      name: r'collectionSortAscending',
      type: IsarType.bool,
    ),
    r'collectionSortOptionIndex': PropertySchema(
      id: 22,
      name: r'collectionSortOptionIndex',
      type: IsarType.long,
    ),
    r'crossfadeDuration': PropertySchema(
      id: 23,
      name: r'crossfadeDuration',
      type: IsarType.long,
    ),
    r'crossfadeMode': PropertySchema(
      id: 24,
      name: r'crossfadeMode',
      type: IsarType.long,
    ),
    r'customBackgroundImagePath': PropertySchema(
      id: 25,
      name: r'customBackgroundImagePath',
      type: IsarType.string,
    ),
    r'customFontFamily': PropertySchema(
      id: 26,
      name: r'customFontFamily',
      type: IsarType.string,
    ),
    r'customFontFamilyLyrics': PropertySchema(
      id: 27,
      name: r'customFontFamilyLyrics',
      type: IsarType.string,
    ),
    r'customFontWeight': PropertySchema(
      id: 28,
      name: r'customFontWeight',
      type: IsarType.long,
    ),
    r'customFontWeightDelta': PropertySchema(
      id: 29,
      name: r'customFontWeightDelta',
      type: IsarType.long,
    ),
    r'customFontWeightLyrics': PropertySchema(
      id: 30,
      name: r'customFontWeightLyrics',
      type: IsarType.string,
    ),
    r'customFontWeightLyricsDelta': PropertySchema(
      id: 31,
      name: r'customFontWeightLyricsDelta',
      type: IsarType.long,
    ),
    r'customShortcutsJson': PropertySchema(
      id: 32,
      name: r'customShortcutsJson',
      type: IsarType.string,
    ),
    r'darkTheme': PropertySchema(
      id: 33,
      name: r'darkTheme',
      type: IsarType.bool,
    ),
    r'defaultMiniPlayerType': PropertySchema(
      id: 34,
      name: r'defaultMiniPlayerType',
      type: IsarType.long,
    ),
    r'disableAnimatedDuration': PropertySchema(
      id: 35,
      name: r'disableAnimatedDuration',
      type: IsarType.bool,
    ),
    r'disableBlur': PropertySchema(
      id: 36,
      name: r'disableBlur',
      type: IsarType.bool,
    ),
    r'disableSquiggle': PropertySchema(
      id: 37,
      name: r'disableSquiggle',
      type: IsarType.bool,
    ),
    r'downloadArtwork': PropertySchema(
      id: 38,
      name: r'downloadArtwork',
      type: IsarType.bool,
    ),
    r'dynamicAccentColor': PropertySchema(
      id: 39,
      name: r'dynamicAccentColor',
      type: IsarType.bool,
    ),
    r'dynamicColorActiveLyrics': PropertySchema(
      id: 40,
      name: r'dynamicColorActiveLyrics',
      type: IsarType.bool,
    ),
    r'dynamicLyrics': PropertySchema(
      id: 41,
      name: r'dynamicLyrics',
      type: IsarType.bool,
    ),
    r'enableAudioCache': PropertySchema(
      id: 42,
      name: r'enableAudioCache',
      type: IsarType.bool,
    ),
    r'enableDiscordRpc': PropertySchema(
      id: 43,
      name: r'enableDiscordRpc',
      type: IsarType.bool,
    ),
    r'enableDynamicTheming': PropertySchema(
      id: 44,
      name: r'enableDynamicTheming',
      type: IsarType.bool,
    ),
    r'enableInternet': PropertySchema(
      id: 45,
      name: r'enableInternet',
      type: IsarType.bool,
    ),
    r'enableLastFmScrobbling': PropertySchema(
      id: 46,
      name: r'enableLastFmScrobbling',
      type: IsarType.bool,
    ),
    r'enableListenBrainzScrobbling': PropertySchema(
      id: 47,
      name: r'enableListenBrainzScrobbling',
      type: IsarType.bool,
    ),
    r'enablePlayerGradient': PropertySchema(
      id: 48,
      name: r'enablePlayerGradient',
      type: IsarType.bool,
    ),
    r'enableSlideGesture': PropertySchema(
      id: 49,
      name: r'enableSlideGesture',
      type: IsarType.bool,
    ),
    r'equalizerEnabled': PropertySchema(
      id: 50,
      name: r'equalizerEnabled',
      type: IsarType.bool,
    ),
    r'equalizerGlobalMode': PropertySchema(
      id: 51,
      name: r'equalizerGlobalMode',
      type: IsarType.bool,
    ),
    r'exclusiveHardwareMode': PropertySchema(
      id: 52,
      name: r'exclusiveHardwareMode',
      type: IsarType.bool,
    ),
    r'fadePlayPauseStop': PropertySchema(
      id: 53,
      name: r'fadePlayPauseStop',
      type: IsarType.bool,
    ),
    r'firstTimeEqualizer': PropertySchema(
      id: 54,
      name: r'firstTimeEqualizer',
      type: IsarType.bool,
    ),
    r'fullscreenVisualizerEnabled': PropertySchema(
      id: 55,
      name: r'fullscreenVisualizerEnabled',
      type: IsarType.bool,
    ),
    r'gaplessPlayback': PropertySchema(
      id: 56,
      name: r'gaplessPlayback',
      type: IsarType.bool,
    ),
    r'genreSortOptionIndex': PropertySchema(
      id: 57,
      name: r'genreSortOptionIndex',
      type: IsarType.long,
    ),
    r'globalEqualizerGains': PropertySchema(
      id: 58,
      name: r'globalEqualizerGains',
      type: IsarType.doubleList,
    ),
    r'homeDarkness': PropertySchema(
      id: 59,
      name: r'homeDarkness',
      type: IsarType.double,
    ),
    r'homeSectionOrder': PropertySchema(
      id: 60,
      name: r'homeSectionOrder',
      type: IsarType.stringList,
    ),
    r'keepBackgroundGradient': PropertySchema(
      id: 61,
      name: r'keepBackgroundGradient',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 62,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastFmApiKey': PropertySchema(
      id: 63,
      name: r'lastFmApiKey',
      type: IsarType.string,
    ),
    r'lastFmSecret': PropertySchema(
      id: 64,
      name: r'lastFmSecret',
      type: IsarType.string,
    ),
    r'lastFmSessionKey': PropertySchema(
      id: 65,
      name: r'lastFmSessionKey',
      type: IsarType.string,
    ),
    r'lastFmUsername': PropertySchema(
      id: 66,
      name: r'lastFmUsername',
      type: IsarType.string,
    ),
    r'lastPlayedSongId': PropertySchema(
      id: 67,
      name: r'lastPlayedSongId',
      type: IsarType.long,
    ),
    r'lastPositionMs': PropertySchema(
      id: 68,
      name: r'lastPositionMs',
      type: IsarType.long,
    ),
    r'lastQueueIndex': PropertySchema(
      id: 69,
      name: r'lastQueueIndex',
      type: IsarType.long,
    ),
    r'lastQueueSongIds': PropertySchema(
      id: 70,
      name: r'lastQueueSongIds',
      type: IsarType.longList,
    ),
    r'libraryDarkness': PropertySchema(
      id: 71,
      name: r'libraryDarkness',
      type: IsarType.double,
    ),
    r'libraryFolders': PropertySchema(
      id: 72,
      name: r'libraryFolders',
      type: IsarType.stringList,
    ),
    r'listenBrainzUserToken': PropertySchema(
      id: 73,
      name: r'listenBrainzUserToken',
      type: IsarType.string,
    ),
    r'lyricsAlignment': PropertySchema(
      id: 74,
      name: r'lyricsAlignment',
      type: IsarType.string,
    ),
    r'lyricsDarkness': PropertySchema(
      id: 75,
      name: r'lyricsDarkness',
      type: IsarType.double,
    ),
    r'lyricsProvider': PropertySchema(
      id: 76,
      name: r'lyricsProvider',
      type: IsarType.string,
    ),
    r'minimizeToTray': PropertySchema(
      id: 77,
      name: r'minimizeToTray',
      type: IsarType.bool,
    ),
    r'musicDarkness': PropertySchema(
      id: 78,
      name: r'musicDarkness',
      type: IsarType.double,
    ),
    r'nowPlayingFullscreen': PropertySchema(
      id: 79,
      name: r'nowPlayingFullscreen',
      type: IsarType.bool,
    ),
    r'pauseOnDuck': PropertySchema(
      id: 80,
      name: r'pauseOnDuck',
      type: IsarType.bool,
    ),
    r'permanentAudioFocusChange': PropertySchema(
      id: 81,
      name: r'permanentAudioFocusChange',
      type: IsarType.bool,
    ),
    r'persistQueue': PropertySchema(
      id: 82,
      name: r'persistQueue',
      type: IsarType.bool,
    ),
    r'playPauseStopFadeLength': PropertySchema(
      id: 83,
      name: r'playPauseStopFadeLength',
      type: IsarType.long,
    ),
    r'playbackModeIndex': PropertySchema(
      id: 84,
      name: r'playbackModeIndex',
      type: IsarType.long,
    ),
    r'playlistDetailSortAscending': PropertySchema(
      id: 85,
      name: r'playlistDetailSortAscending',
      type: IsarType.bool,
    ),
    r'playlistDetailSortOptionIndex': PropertySchema(
      id: 86,
      name: r'playlistDetailSortOptionIndex',
      type: IsarType.long,
    ),
    r'repeatMode': PropertySchema(
      id: 87,
      name: r'repeatMode',
      type: IsarType.long,
    ),
    r'resumeAfterCall': PropertySchema(
      id: 88,
      name: r'resumeAfterCall',
      type: IsarType.bool,
    ),
    r'resumeOnBluetoothConnect': PropertySchema(
      id: 89,
      name: r'resumeOnBluetoothConnect',
      type: IsarType.bool,
    ),
    r'resumeOnStart': PropertySchema(
      id: 90,
      name: r'resumeOnStart',
      type: IsarType.bool,
    ),
    r'saveDynamicColor': PropertySchema(
      id: 91,
      name: r'saveDynamicColor',
      type: IsarType.bool,
    ),
    r'scrobbleThresholdPercent': PropertySchema(
      id: 92,
      name: r'scrobbleThresholdPercent',
      type: IsarType.long,
    ),
    r'seekBarStyleIndex': PropertySchema(
      id: 93,
      name: r'seekBarStyleIndex',
      type: IsarType.long,
    ),
    r'settingsV2': PropertySchema(
      id: 94,
      name: r'settingsV2',
      type: IsarType.bool,
    ),
    r'settingsV3': PropertySchema(
      id: 95,
      name: r'settingsV3',
      type: IsarType.bool,
    ),
    r'showFullscreenABLooper': PropertySchema(
      id: 96,
      name: r'showFullscreenABLooper',
      type: IsarType.bool,
    ),
    r'showFullscreenSleepTimer': PropertySchema(
      id: 97,
      name: r'showFullscreenSleepTimer',
      type: IsarType.bool,
    ),
    r'showHomeAlbums': PropertySchema(
      id: 98,
      name: r'showHomeAlbums',
      type: IsarType.bool,
    ),
    r'showHomeArtists': PropertySchema(
      id: 99,
      name: r'showHomeArtists',
      type: IsarType.bool,
    ),
    r'showHomeGenres': PropertySchema(
      id: 100,
      name: r'showHomeGenres',
      type: IsarType.bool,
    ),
    r'showPerformanceOptimizer': PropertySchema(
      id: 101,
      name: r'showPerformanceOptimizer',
      type: IsarType.bool,
    ),
    r'showPlayedSongsInQueue': PropertySchema(
      id: 102,
      name: r'showPlayedSongsInQueue',
      type: IsarType.bool,
    ),
    r'showQualityBadge': PropertySchema(
      id: 103,
      name: r'showQualityBadge',
      type: IsarType.bool,
    ),
    r'shuffle': PropertySchema(
      id: 104,
      name: r'shuffle',
      type: IsarType.bool,
    ),
    r'songsDarkness': PropertySchema(
      id: 105,
      name: r'songsDarkness',
      type: IsarType.double,
    ),
    r'sortAscending': PropertySchema(
      id: 106,
      name: r'sortAscending',
      type: IsarType.bool,
    ),
    r'sortStrategyIndex': PropertySchema(
      id: 107,
      name: r'sortStrategyIndex',
      type: IsarType.long,
    ),
    r'stopOnTaskRemoved': PropertySchema(
      id: 108,
      name: r'stopOnTaskRemoved',
      type: IsarType.bool,
    ),
    r'streamingQuality': PropertySchema(
      id: 109,
      name: r'streamingQuality',
      type: IsarType.long,
    ),
    r'uniformLyricsFontSize': PropertySchema(
      id: 110,
      name: r'uniformLyricsFontSize',
      type: IsarType.bool,
    ),
    r'useAlbumArtistForArtists': PropertySchema(
      id: 111,
      name: r'useAlbumArtistForArtists',
      type: IsarType.bool,
    ),
    r'useNewFont': PropertySchema(
      id: 112,
      name: r'useNewFont',
      type: IsarType.bool,
    ),
    r'useNewFontLyrics': PropertySchema(
      id: 113,
      name: r'useNewFontLyrics',
      type: IsarType.bool,
    ),
    r'volume': PropertySchema(
      id: 114,
      name: r'volume',
      type: IsarType.double,
    )
  },
  estimateSize: _appSettingsEstimateSize,
  serialize: _appSettingsSerialize,
  deserialize: _appSettingsDeserialize,
  deserializeProp: _appSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsGetId,
  getLinks: _appSettingsGetLinks,
  attach: _appSettingsAttach,
  version: '3.1.0+1',
);

int _appSettingsEstimateSize(
  AppSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeQueueName.length * 3;
  {
    final value = object.customBackgroundImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.customFontFamily.length * 3;
  bytesCount += 3 + object.customFontFamilyLyrics.length * 3;
  bytesCount += 3 + object.customFontWeightLyrics.length * 3;
  bytesCount += 3 + object.customShortcutsJson.length * 3;
  bytesCount += 3 + object.globalEqualizerGains.length * 8;
  bytesCount += 3 + object.homeSectionOrder.length * 3;
  {
    for (var i = 0; i < object.homeSectionOrder.length; i++) {
      final value = object.homeSectionOrder[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.language.length * 3;
  bytesCount += 3 + object.lastFmApiKey.length * 3;
  bytesCount += 3 + object.lastFmSecret.length * 3;
  bytesCount += 3 + object.lastFmSessionKey.length * 3;
  bytesCount += 3 + object.lastFmUsername.length * 3;
  bytesCount += 3 + object.lastQueueSongIds.length * 8;
  bytesCount += 3 + object.libraryFolders.length * 3;
  {
    for (var i = 0; i < object.libraryFolders.length; i++) {
      final value = object.libraryFolders[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.listenBrainzUserToken.length * 3;
  bytesCount += 3 + object.lyricsAlignment.length * 3;
  bytesCount += 3 + object.lyricsProvider.length * 3;
  return bytesCount;
}

void _appSettingsSerialize(
  AppSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.accentColor);
  writer.writeLong(offsets[1], object.activeLyricsFontWeightDelta);
  writer.writeString(offsets[2], object.activeQueueName);
  writer.writeBool(offsets[3], object.albumDetailSortAscending);
  writer.writeLong(offsets[4], object.albumDetailSortOptionIndex);
  writer.writeLong(offsets[5], object.albumSortOptionIndex);
  writer.writeBool(offsets[6], object.artistDetailSortAscending);
  writer.writeLong(offsets[7], object.artistDetailSortOptionIndex);
  writer.writeLong(offsets[8], object.artistSortOptionIndex);
  writer.writeLong(offsets[9], object.audioBackCacheSizeMB);
  writer.writeLong(offsets[10], object.audioCacheSecs);
  writer.writeLong(offsets[11], object.audioCacheSizeMB);
  writer.writeBool(offsets[12], object.audioFocus);
  writer.writeBool(offsets[13], object.audioFocusReleaseOnPause);
  writer.writeBool(offsets[14], object.audioFocusRequestOnPlay);
  writer.writeBool(offsets[15], object.audioFocusRestartOnGain);
  writer.writeBool(offsets[16], object.audioFocusStopOnOtherSession);
  writer.writeDouble(offsets[17], object.bgBrightness);
  writer.writeDouble(offsets[18], object.bgOpacity);
  writer.writeBool(offsets[19], object.blurredArtworkForLyrics);
  writer.writeBool(offsets[20], object.cacheOnlineStreams);
  writer.writeBool(offsets[21], object.collectionSortAscending);
  writer.writeLong(offsets[22], object.collectionSortOptionIndex);
  writer.writeLong(offsets[23], object.crossfadeDuration);
  writer.writeLong(offsets[24], object.crossfadeMode);
  writer.writeString(offsets[25], object.customBackgroundImagePath);
  writer.writeString(offsets[26], object.customFontFamily);
  writer.writeString(offsets[27], object.customFontFamilyLyrics);
  writer.writeLong(offsets[28], object.customFontWeight);
  writer.writeLong(offsets[29], object.customFontWeightDelta);
  writer.writeString(offsets[30], object.customFontWeightLyrics);
  writer.writeLong(offsets[31], object.customFontWeightLyricsDelta);
  writer.writeString(offsets[32], object.customShortcutsJson);
  writer.writeBool(offsets[33], object.darkTheme);
  writer.writeLong(offsets[34], object.defaultMiniPlayerType);
  writer.writeBool(offsets[35], object.disableAnimatedDuration);
  writer.writeBool(offsets[36], object.disableBlur);
  writer.writeBool(offsets[37], object.disableSquiggle);
  writer.writeBool(offsets[38], object.downloadArtwork);
  writer.writeBool(offsets[39], object.dynamicAccentColor);
  writer.writeBool(offsets[40], object.dynamicColorActiveLyrics);
  writer.writeBool(offsets[41], object.dynamicLyrics);
  writer.writeBool(offsets[42], object.enableAudioCache);
  writer.writeBool(offsets[43], object.enableDiscordRpc);
  writer.writeBool(offsets[44], object.enableDynamicTheming);
  writer.writeBool(offsets[45], object.enableInternet);
  writer.writeBool(offsets[46], object.enableLastFmScrobbling);
  writer.writeBool(offsets[47], object.enableListenBrainzScrobbling);
  writer.writeBool(offsets[48], object.enablePlayerGradient);
  writer.writeBool(offsets[49], object.enableSlideGesture);
  writer.writeBool(offsets[50], object.equalizerEnabled);
  writer.writeBool(offsets[51], object.equalizerGlobalMode);
  writer.writeBool(offsets[52], object.exclusiveHardwareMode);
  writer.writeBool(offsets[53], object.fadePlayPauseStop);
  writer.writeBool(offsets[54], object.firstTimeEqualizer);
  writer.writeBool(offsets[55], object.fullscreenVisualizerEnabled);
  writer.writeBool(offsets[56], object.gaplessPlayback);
  writer.writeLong(offsets[57], object.genreSortOptionIndex);
  writer.writeDoubleList(offsets[58], object.globalEqualizerGains);
  writer.writeDouble(offsets[59], object.homeDarkness);
  writer.writeStringList(offsets[60], object.homeSectionOrder);
  writer.writeBool(offsets[61], object.keepBackgroundGradient);
  writer.writeString(offsets[62], object.language);
  writer.writeString(offsets[63], object.lastFmApiKey);
  writer.writeString(offsets[64], object.lastFmSecret);
  writer.writeString(offsets[65], object.lastFmSessionKey);
  writer.writeString(offsets[66], object.lastFmUsername);
  writer.writeLong(offsets[67], object.lastPlayedSongId);
  writer.writeLong(offsets[68], object.lastPositionMs);
  writer.writeLong(offsets[69], object.lastQueueIndex);
  writer.writeLongList(offsets[70], object.lastQueueSongIds);
  writer.writeDouble(offsets[71], object.libraryDarkness);
  writer.writeStringList(offsets[72], object.libraryFolders);
  writer.writeString(offsets[73], object.listenBrainzUserToken);
  writer.writeString(offsets[74], object.lyricsAlignment);
  writer.writeDouble(offsets[75], object.lyricsDarkness);
  writer.writeString(offsets[76], object.lyricsProvider);
  writer.writeBool(offsets[77], object.minimizeToTray);
  writer.writeDouble(offsets[78], object.musicDarkness);
  writer.writeBool(offsets[79], object.nowPlayingFullscreen);
  writer.writeBool(offsets[80], object.pauseOnDuck);
  writer.writeBool(offsets[81], object.permanentAudioFocusChange);
  writer.writeBool(offsets[82], object.persistQueue);
  writer.writeLong(offsets[83], object.playPauseStopFadeLength);
  writer.writeLong(offsets[84], object.playbackModeIndex);
  writer.writeBool(offsets[85], object.playlistDetailSortAscending);
  writer.writeLong(offsets[86], object.playlistDetailSortOptionIndex);
  writer.writeLong(offsets[87], object.repeatMode);
  writer.writeBool(offsets[88], object.resumeAfterCall);
  writer.writeBool(offsets[89], object.resumeOnBluetoothConnect);
  writer.writeBool(offsets[90], object.resumeOnStart);
  writer.writeBool(offsets[91], object.saveDynamicColor);
  writer.writeLong(offsets[92], object.scrobbleThresholdPercent);
  writer.writeLong(offsets[93], object.seekBarStyleIndex);
  writer.writeBool(offsets[94], object.settingsV2);
  writer.writeBool(offsets[95], object.settingsV3);
  writer.writeBool(offsets[96], object.showFullscreenABLooper);
  writer.writeBool(offsets[97], object.showFullscreenSleepTimer);
  writer.writeBool(offsets[98], object.showHomeAlbums);
  writer.writeBool(offsets[99], object.showHomeArtists);
  writer.writeBool(offsets[100], object.showHomeGenres);
  writer.writeBool(offsets[101], object.showPerformanceOptimizer);
  writer.writeBool(offsets[102], object.showPlayedSongsInQueue);
  writer.writeBool(offsets[103], object.showQualityBadge);
  writer.writeBool(offsets[104], object.shuffle);
  writer.writeDouble(offsets[105], object.songsDarkness);
  writer.writeBool(offsets[106], object.sortAscending);
  writer.writeLong(offsets[107], object.sortStrategyIndex);
  writer.writeBool(offsets[108], object.stopOnTaskRemoved);
  writer.writeLong(offsets[109], object.streamingQuality);
  writer.writeBool(offsets[110], object.uniformLyricsFontSize);
  writer.writeBool(offsets[111], object.useAlbumArtistForArtists);
  writer.writeBool(offsets[112], object.useNewFont);
  writer.writeBool(offsets[113], object.useNewFontLyrics);
  writer.writeDouble(offsets[114], object.volume);
}

AppSettings _appSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettings();
  object.accentColor = reader.readLong(offsets[0]);
  object.activeLyricsFontWeightDelta = reader.readLong(offsets[1]);
  object.activeQueueName = reader.readString(offsets[2]);
  object.albumDetailSortAscending = reader.readBool(offsets[3]);
  object.albumDetailSortOptionIndex = reader.readLong(offsets[4]);
  object.albumSortOptionIndex = reader.readLong(offsets[5]);
  object.artistDetailSortAscending = reader.readBool(offsets[6]);
  object.artistDetailSortOptionIndex = reader.readLong(offsets[7]);
  object.artistSortOptionIndex = reader.readLong(offsets[8]);
  object.audioBackCacheSizeMB = reader.readLong(offsets[9]);
  object.audioCacheSecs = reader.readLong(offsets[10]);
  object.audioCacheSizeMB = reader.readLong(offsets[11]);
  object.audioFocus = reader.readBool(offsets[12]);
  object.audioFocusReleaseOnPause = reader.readBool(offsets[13]);
  object.audioFocusRequestOnPlay = reader.readBool(offsets[14]);
  object.audioFocusRestartOnGain = reader.readBool(offsets[15]);
  object.audioFocusStopOnOtherSession = reader.readBool(offsets[16]);
  object.bgBrightness = reader.readDouble(offsets[17]);
  object.bgOpacity = reader.readDouble(offsets[18]);
  object.blurredArtworkForLyrics = reader.readBool(offsets[19]);
  object.cacheOnlineStreams = reader.readBool(offsets[20]);
  object.collectionSortAscending = reader.readBool(offsets[21]);
  object.collectionSortOptionIndex = reader.readLong(offsets[22]);
  object.crossfadeDuration = reader.readLong(offsets[23]);
  object.crossfadeMode = reader.readLong(offsets[24]);
  object.customBackgroundImagePath = reader.readStringOrNull(offsets[25]);
  object.customFontFamily = reader.readString(offsets[26]);
  object.customFontFamilyLyrics = reader.readString(offsets[27]);
  object.customFontWeight = reader.readLong(offsets[28]);
  object.customFontWeightDelta = reader.readLong(offsets[29]);
  object.customFontWeightLyrics = reader.readString(offsets[30]);
  object.customFontWeightLyricsDelta = reader.readLong(offsets[31]);
  object.customShortcutsJson = reader.readString(offsets[32]);
  object.darkTheme = reader.readBool(offsets[33]);
  object.defaultMiniPlayerType = reader.readLong(offsets[34]);
  object.disableAnimatedDuration = reader.readBool(offsets[35]);
  object.disableBlur = reader.readBool(offsets[36]);
  object.disableSquiggle = reader.readBool(offsets[37]);
  object.downloadArtwork = reader.readBool(offsets[38]);
  object.dynamicAccentColor = reader.readBool(offsets[39]);
  object.dynamicColorActiveLyrics = reader.readBool(offsets[40]);
  object.dynamicLyrics = reader.readBool(offsets[41]);
  object.enableAudioCache = reader.readBool(offsets[42]);
  object.enableDiscordRpc = reader.readBool(offsets[43]);
  object.enableDynamicTheming = reader.readBool(offsets[44]);
  object.enableInternet = reader.readBool(offsets[45]);
  object.enableLastFmScrobbling = reader.readBool(offsets[46]);
  object.enableListenBrainzScrobbling = reader.readBool(offsets[47]);
  object.enablePlayerGradient = reader.readBool(offsets[48]);
  object.enableSlideGesture = reader.readBool(offsets[49]);
  object.equalizerEnabled = reader.readBool(offsets[50]);
  object.equalizerGlobalMode = reader.readBool(offsets[51]);
  object.exclusiveHardwareMode = reader.readBool(offsets[52]);
  object.fadePlayPauseStop = reader.readBool(offsets[53]);
  object.firstTimeEqualizer = reader.readBool(offsets[54]);
  object.fullscreenVisualizerEnabled = reader.readBool(offsets[55]);
  object.gaplessPlayback = reader.readBool(offsets[56]);
  object.genreSortOptionIndex = reader.readLong(offsets[57]);
  object.globalEqualizerGains = reader.readDoubleList(offsets[58]) ?? [];
  object.homeDarkness = reader.readDouble(offsets[59]);
  object.homeSectionOrder = reader.readStringList(offsets[60]) ?? [];
  object.id = id;
  object.keepBackgroundGradient = reader.readBool(offsets[61]);
  object.language = reader.readString(offsets[62]);
  object.lastFmApiKey = reader.readString(offsets[63]);
  object.lastFmSecret = reader.readString(offsets[64]);
  object.lastFmSessionKey = reader.readString(offsets[65]);
  object.lastFmUsername = reader.readString(offsets[66]);
  object.lastPlayedSongId = reader.readLongOrNull(offsets[67]);
  object.lastPositionMs = reader.readLong(offsets[68]);
  object.lastQueueIndex = reader.readLong(offsets[69]);
  object.lastQueueSongIds = reader.readLongList(offsets[70]) ?? [];
  object.libraryDarkness = reader.readDouble(offsets[71]);
  object.libraryFolders = reader.readStringList(offsets[72]) ?? [];
  object.listenBrainzUserToken = reader.readString(offsets[73]);
  object.lyricsAlignment = reader.readString(offsets[74]);
  object.lyricsDarkness = reader.readDouble(offsets[75]);
  object.lyricsProvider = reader.readString(offsets[76]);
  object.minimizeToTray = reader.readBool(offsets[77]);
  object.musicDarkness = reader.readDouble(offsets[78]);
  object.nowPlayingFullscreen = reader.readBool(offsets[79]);
  object.pauseOnDuck = reader.readBool(offsets[80]);
  object.permanentAudioFocusChange = reader.readBool(offsets[81]);
  object.persistQueue = reader.readBool(offsets[82]);
  object.playPauseStopFadeLength = reader.readLong(offsets[83]);
  object.playbackModeIndex = reader.readLong(offsets[84]);
  object.playlistDetailSortAscending = reader.readBool(offsets[85]);
  object.playlistDetailSortOptionIndex = reader.readLong(offsets[86]);
  object.repeatMode = reader.readLong(offsets[87]);
  object.resumeAfterCall = reader.readBool(offsets[88]);
  object.resumeOnBluetoothConnect = reader.readBool(offsets[89]);
  object.resumeOnStart = reader.readBool(offsets[90]);
  object.saveDynamicColor = reader.readBool(offsets[91]);
  object.scrobbleThresholdPercent = reader.readLong(offsets[92]);
  object.seekBarStyleIndex = reader.readLong(offsets[93]);
  object.settingsV2 = reader.readBool(offsets[94]);
  object.settingsV3 = reader.readBool(offsets[95]);
  object.showFullscreenABLooper = reader.readBool(offsets[96]);
  object.showFullscreenSleepTimer = reader.readBool(offsets[97]);
  object.showHomeAlbums = reader.readBool(offsets[98]);
  object.showHomeArtists = reader.readBool(offsets[99]);
  object.showHomeGenres = reader.readBool(offsets[100]);
  object.showPerformanceOptimizer = reader.readBool(offsets[101]);
  object.showPlayedSongsInQueue = reader.readBool(offsets[102]);
  object.showQualityBadge = reader.readBool(offsets[103]);
  object.shuffle = reader.readBool(offsets[104]);
  object.songsDarkness = reader.readDouble(offsets[105]);
  object.sortAscending = reader.readBool(offsets[106]);
  object.sortStrategyIndex = reader.readLong(offsets[107]);
  object.stopOnTaskRemoved = reader.readBool(offsets[108]);
  object.streamingQuality = reader.readLong(offsets[109]);
  object.uniformLyricsFontSize = reader.readBool(offsets[110]);
  object.useAlbumArtistForArtists = reader.readBool(offsets[111]);
  object.useNewFont = reader.readBool(offsets[112]);
  object.useNewFontLyrics = reader.readBool(offsets[113]);
  object.volume = reader.readDouble(offsets[114]);
  return object;
}

P _appSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readLong(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readLong(offset)) as P;
    case 29:
      return (reader.readLong(offset)) as P;
    case 30:
      return (reader.readString(offset)) as P;
    case 31:
      return (reader.readLong(offset)) as P;
    case 32:
      return (reader.readString(offset)) as P;
    case 33:
      return (reader.readBool(offset)) as P;
    case 34:
      return (reader.readLong(offset)) as P;
    case 35:
      return (reader.readBool(offset)) as P;
    case 36:
      return (reader.readBool(offset)) as P;
    case 37:
      return (reader.readBool(offset)) as P;
    case 38:
      return (reader.readBool(offset)) as P;
    case 39:
      return (reader.readBool(offset)) as P;
    case 40:
      return (reader.readBool(offset)) as P;
    case 41:
      return (reader.readBool(offset)) as P;
    case 42:
      return (reader.readBool(offset)) as P;
    case 43:
      return (reader.readBool(offset)) as P;
    case 44:
      return (reader.readBool(offset)) as P;
    case 45:
      return (reader.readBool(offset)) as P;
    case 46:
      return (reader.readBool(offset)) as P;
    case 47:
      return (reader.readBool(offset)) as P;
    case 48:
      return (reader.readBool(offset)) as P;
    case 49:
      return (reader.readBool(offset)) as P;
    case 50:
      return (reader.readBool(offset)) as P;
    case 51:
      return (reader.readBool(offset)) as P;
    case 52:
      return (reader.readBool(offset)) as P;
    case 53:
      return (reader.readBool(offset)) as P;
    case 54:
      return (reader.readBool(offset)) as P;
    case 55:
      return (reader.readBool(offset)) as P;
    case 56:
      return (reader.readBool(offset)) as P;
    case 57:
      return (reader.readLong(offset)) as P;
    case 58:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 59:
      return (reader.readDouble(offset)) as P;
    case 60:
      return (reader.readStringList(offset) ?? []) as P;
    case 61:
      return (reader.readBool(offset)) as P;
    case 62:
      return (reader.readString(offset)) as P;
    case 63:
      return (reader.readString(offset)) as P;
    case 64:
      return (reader.readString(offset)) as P;
    case 65:
      return (reader.readString(offset)) as P;
    case 66:
      return (reader.readString(offset)) as P;
    case 67:
      return (reader.readLongOrNull(offset)) as P;
    case 68:
      return (reader.readLong(offset)) as P;
    case 69:
      return (reader.readLong(offset)) as P;
    case 70:
      return (reader.readLongList(offset) ?? []) as P;
    case 71:
      return (reader.readDouble(offset)) as P;
    case 72:
      return (reader.readStringList(offset) ?? []) as P;
    case 73:
      return (reader.readString(offset)) as P;
    case 74:
      return (reader.readString(offset)) as P;
    case 75:
      return (reader.readDouble(offset)) as P;
    case 76:
      return (reader.readString(offset)) as P;
    case 77:
      return (reader.readBool(offset)) as P;
    case 78:
      return (reader.readDouble(offset)) as P;
    case 79:
      return (reader.readBool(offset)) as P;
    case 80:
      return (reader.readBool(offset)) as P;
    case 81:
      return (reader.readBool(offset)) as P;
    case 82:
      return (reader.readBool(offset)) as P;
    case 83:
      return (reader.readLong(offset)) as P;
    case 84:
      return (reader.readLong(offset)) as P;
    case 85:
      return (reader.readBool(offset)) as P;
    case 86:
      return (reader.readLong(offset)) as P;
    case 87:
      return (reader.readLong(offset)) as P;
    case 88:
      return (reader.readBool(offset)) as P;
    case 89:
      return (reader.readBool(offset)) as P;
    case 90:
      return (reader.readBool(offset)) as P;
    case 91:
      return (reader.readBool(offset)) as P;
    case 92:
      return (reader.readLong(offset)) as P;
    case 93:
      return (reader.readLong(offset)) as P;
    case 94:
      return (reader.readBool(offset)) as P;
    case 95:
      return (reader.readBool(offset)) as P;
    case 96:
      return (reader.readBool(offset)) as P;
    case 97:
      return (reader.readBool(offset)) as P;
    case 98:
      return (reader.readBool(offset)) as P;
    case 99:
      return (reader.readBool(offset)) as P;
    case 100:
      return (reader.readBool(offset)) as P;
    case 101:
      return (reader.readBool(offset)) as P;
    case 102:
      return (reader.readBool(offset)) as P;
    case 103:
      return (reader.readBool(offset)) as P;
    case 104:
      return (reader.readBool(offset)) as P;
    case 105:
      return (reader.readDouble(offset)) as P;
    case 106:
      return (reader.readBool(offset)) as P;
    case 107:
      return (reader.readLong(offset)) as P;
    case 108:
      return (reader.readBool(offset)) as P;
    case 109:
      return (reader.readLong(offset)) as P;
    case 110:
      return (reader.readBool(offset)) as P;
    case 111:
      return (reader.readBool(offset)) as P;
    case 112:
      return (reader.readBool(offset)) as P;
    case 113:
      return (reader.readBool(offset)) as P;
    case 114:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsGetId(AppSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsGetLinks(AppSettings object) {
  return [];
}

void _appSettingsAttach(
    IsarCollection<dynamic> col, Id id, AppSettings object) {
  object.id = id;
}

extension AppSettingsQueryWhereSort
    on QueryBuilder<AppSettings, AppSettings, QWhere> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsQueryWhere
    on QueryBuilder<AppSettings, AppSettings, QWhereClause> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsQueryFilter
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {
  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      accentColorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accentColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeLyricsFontWeightDeltaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeLyricsFontWeightDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeLyricsFontWeightDeltaGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeLyricsFontWeightDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeLyricsFontWeightDeltaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeLyricsFontWeightDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeLyricsFontWeightDeltaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeLyricsFontWeightDelta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeQueueName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeQueueName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeQueueName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeQueueName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeQueueName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeQueueName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeQueueName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeQueueName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeQueueName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      activeQueueNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeQueueName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumDetailSortAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumDetailSortAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumDetailSortOptionIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumDetailSortOptionIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'albumDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumDetailSortOptionIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'albumDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumDetailSortOptionIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'albumDetailSortOptionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumSortOptionIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumSortOptionIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'albumSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumSortOptionIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'albumSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      albumSortOptionIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'albumSortOptionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistDetailSortAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistDetailSortAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistDetailSortOptionIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistDetailSortOptionIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artistDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistDetailSortOptionIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artistDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistDetailSortOptionIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artistDetailSortOptionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistSortOptionIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistSortOptionIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artistSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistSortOptionIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artistSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      artistSortOptionIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artistSortOptionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioBackCacheSizeMBEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioBackCacheSizeMB',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioBackCacheSizeMBGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioBackCacheSizeMB',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioBackCacheSizeMBLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioBackCacheSizeMB',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioBackCacheSizeMBBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioBackCacheSizeMB',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioCacheSecsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioCacheSecs',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioCacheSecsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioCacheSecs',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioCacheSecsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioCacheSecs',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioCacheSecsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioCacheSecs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioCacheSizeMBEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioCacheSizeMB',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioCacheSizeMBGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioCacheSizeMB',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioCacheSizeMBLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioCacheSizeMB',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioCacheSizeMBBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioCacheSizeMB',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioFocusEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioFocus',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioFocusReleaseOnPauseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioFocusReleaseOnPause',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioFocusRequestOnPlayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioFocusRequestOnPlay',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioFocusRestartOnGainEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioFocusRestartOnGain',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      audioFocusStopOnOtherSessionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioFocusStopOnOtherSession',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgBrightnessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bgBrightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgBrightnessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bgBrightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgBrightnessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bgBrightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgBrightnessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bgBrightness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgOpacityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bgOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgOpacityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bgOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgOpacityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bgOpacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bgOpacityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bgOpacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      blurredArtworkForLyricsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blurredArtworkForLyrics',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      cacheOnlineStreamsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheOnlineStreams',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      collectionSortAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionSortAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      collectionSortOptionIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      collectionSortOptionIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      collectionSortOptionIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      collectionSortOptionIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionSortOptionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossfadeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'crossfadeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'crossfadeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'crossfadeDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeModeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossfadeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeModeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'crossfadeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeModeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'crossfadeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      crossfadeModeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'crossfadeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customBackgroundImagePath',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customBackgroundImagePath',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customBackgroundImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customBackgroundImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customBackgroundImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customBackgroundImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customBackgroundImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customBackgroundImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customFontFamily',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customFontFamily',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontFamilyLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customFontFamilyLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customFontFamilyLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customFontFamilyLyrics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customFontFamilyLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customFontFamilyLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customFontFamilyLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customFontFamilyLyrics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontFamilyLyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontFamilyLyricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customFontFamilyLyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontWeight',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customFontWeight',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customFontWeight',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customFontWeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightDeltaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontWeightDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightDeltaGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customFontWeightDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightDeltaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customFontWeightDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightDeltaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customFontWeightDelta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontWeightLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customFontWeightLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customFontWeightLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customFontWeightLyrics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customFontWeightLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customFontWeightLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customFontWeightLyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customFontWeightLyrics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontWeightLyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customFontWeightLyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsDeltaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFontWeightLyricsDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsDeltaGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customFontWeightLyricsDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsDeltaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customFontWeightLyricsDelta',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customFontWeightLyricsDeltaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customFontWeightLyricsDelta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customShortcutsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customShortcutsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customShortcutsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customShortcutsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customShortcutsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customShortcutsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customShortcutsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customShortcutsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customShortcutsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      customShortcutsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customShortcutsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      darkThemeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'darkTheme',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultMiniPlayerTypeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultMiniPlayerType',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultMiniPlayerTypeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultMiniPlayerType',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultMiniPlayerTypeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultMiniPlayerType',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      defaultMiniPlayerTypeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultMiniPlayerType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      disableAnimatedDurationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableAnimatedDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      disableBlurEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableBlur',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      disableSquiggleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableSquiggle',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      downloadArtworkEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadArtwork',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      dynamicAccentColorEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicAccentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      dynamicColorActiveLyricsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicColorActiveLyrics',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      dynamicLyricsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicLyrics',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableAudioCacheEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableAudioCache',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableDiscordRpcEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableDiscordRpc',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableDynamicThemingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableDynamicTheming',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableInternetEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableInternet',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableLastFmScrobblingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableLastFmScrobbling',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableListenBrainzScrobblingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableListenBrainzScrobbling',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enablePlayerGradientEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enablePlayerGradient',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      enableSlideGestureEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableSlideGesture',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      equalizerEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'equalizerEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      equalizerGlobalModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'equalizerGlobalMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      exclusiveHardwareModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exclusiveHardwareMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      fadePlayPauseStopEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fadePlayPauseStop',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      firstTimeEqualizerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstTimeEqualizer',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      fullscreenVisualizerEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullscreenVisualizerEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      gaplessPlaybackEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gaplessPlayback',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      genreSortOptionIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genreSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      genreSortOptionIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genreSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      genreSortOptionIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genreSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      genreSortOptionIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genreSortOptionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'globalEqualizerGains',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'globalEqualizerGains',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'globalEqualizerGains',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'globalEqualizerGains',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalEqualizerGains',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalEqualizerGains',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalEqualizerGains',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalEqualizerGains',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalEqualizerGains',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      globalEqualizerGainsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalEqualizerGains',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'homeDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'homeDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'homeDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'homeSectionOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'homeSectionOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'homeSectionOrder',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeSectionOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'homeSectionOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      homeSectionOrderLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeSectionOrder',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      keepBackgroundGradientEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keepBackgroundGradient',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> languageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFmApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFmApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFmApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFmApiKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastFmApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastFmApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastFmApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastFmApiKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFmApiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmApiKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastFmApiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFmSecret',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFmSecret',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFmSecret',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFmSecret',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastFmSecret',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastFmSecret',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastFmSecret',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastFmSecret',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFmSecret',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSecretIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastFmSecret',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFmSessionKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFmSessionKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFmSessionKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFmSessionKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastFmSessionKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastFmSessionKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastFmSessionKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastFmSessionKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFmSessionKey',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmSessionKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastFmSessionKey',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFmUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFmUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFmUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFmUsername',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastFmUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastFmUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastFmUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastFmUsername',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFmUsername',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastFmUsernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastFmUsername',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlayedSongId',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlayedSongId',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayedSongId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayedSongId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayedSongId',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPlayedSongIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayedSongId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPositionMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPositionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPositionMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPositionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPositionMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPositionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastPositionMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPositionMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastQueueIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastQueueIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastQueueIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastQueueIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastQueueSongIds',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastQueueSongIds',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastQueueSongIds',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastQueueSongIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lastQueueSongIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lastQueueSongIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lastQueueSongIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lastQueueSongIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lastQueueSongIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lastQueueSongIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lastQueueSongIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'libraryDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'libraryDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'libraryDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'libraryDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'libraryFolders',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'libraryFolders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'libraryFolders',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'libraryFolders',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'libraryFolders',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      libraryFoldersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryFolders',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'listenBrainzUserToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'listenBrainzUserToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'listenBrainzUserToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'listenBrainzUserToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'listenBrainzUserToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'listenBrainzUserToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'listenBrainzUserToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'listenBrainzUserToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'listenBrainzUserToken',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      listenBrainzUserTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'listenBrainzUserToken',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyricsAlignment',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lyricsAlignment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lyricsAlignment',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsAlignment',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsAlignmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lyricsAlignment',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyricsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyricsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyricsDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyricsProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyricsProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyricsProvider',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lyricsProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lyricsProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lyricsProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lyricsProvider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      lyricsProviderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lyricsProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      minimizeToTrayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minimizeToTray',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      musicDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'musicDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      musicDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'musicDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      musicDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'musicDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      musicDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'musicDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      nowPlayingFullscreenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nowPlayingFullscreen',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      pauseOnDuckEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pauseOnDuck',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      permanentAudioFocusChangeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permanentAudioFocusChange',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      persistQueueEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'persistQueue',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playPauseStopFadeLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playPauseStopFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playPauseStopFadeLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playPauseStopFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playPauseStopFadeLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playPauseStopFadeLength',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playPauseStopFadeLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playPauseStopFadeLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playbackModeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playbackModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playbackModeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playbackModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playbackModeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playbackModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playbackModeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playbackModeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playlistDetailSortAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistDetailSortAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playlistDetailSortOptionIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playlistDetailSortOptionIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playlistDetailSortOptionIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistDetailSortOptionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      playlistDetailSortOptionIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistDetailSortOptionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      repeatModeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      repeatModeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      repeatModeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      repeatModeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      resumeAfterCallEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resumeAfterCall',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      resumeOnBluetoothConnectEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resumeOnBluetoothConnect',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      resumeOnStartEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resumeOnStart',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      saveDynamicColorEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveDynamicColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      scrobbleThresholdPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scrobbleThresholdPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      scrobbleThresholdPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scrobbleThresholdPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      scrobbleThresholdPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scrobbleThresholdPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      scrobbleThresholdPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scrobbleThresholdPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      seekBarStyleIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seekBarStyleIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      seekBarStyleIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'seekBarStyleIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      seekBarStyleIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'seekBarStyleIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      seekBarStyleIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'seekBarStyleIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      settingsV2EqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsV2',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      settingsV3EqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsV3',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showFullscreenABLooperEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showFullscreenABLooper',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showFullscreenSleepTimerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showFullscreenSleepTimer',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showHomeAlbumsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showHomeAlbums',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showHomeArtistsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showHomeArtists',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showHomeGenresEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showHomeGenres',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showPerformanceOptimizerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showPerformanceOptimizer',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showPlayedSongsInQueueEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showPlayedSongsInQueue',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showQualityBadgeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showQualityBadge',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> shuffleEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shuffle',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      songsDarknessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      songsDarknessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      songsDarknessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songsDarkness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      songsDarknessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songsDarkness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortAscendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortAscending',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortStrategyIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortStrategyIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortStrategyIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortStrategyIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortStrategyIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortStrategyIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      sortStrategyIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortStrategyIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      stopOnTaskRemovedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stopOnTaskRemoved',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      streamingQualityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamingQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      streamingQualityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamingQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      streamingQualityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamingQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      streamingQualityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamingQuality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      uniformLyricsFontSizeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniformLyricsFontSize',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      useAlbumArtistForArtistsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useAlbumArtistForArtists',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      useNewFontEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useNewFont',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      useNewFontLyricsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useNewFontLyrics',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> volumeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      volumeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> volumeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> volumeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volume',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension AppSettingsQueryObject
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQueryLinks
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQuerySortBy
    on QueryBuilder<AppSettings, AppSettings, QSortBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByActiveLyricsFontWeightDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeLyricsFontWeightDelta', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByActiveLyricsFontWeightDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeLyricsFontWeightDelta', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByActiveQueueName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeQueueName', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByActiveQueueNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeQueueName', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAlbumDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumDetailSortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAlbumDetailSortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumDetailSortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAlbumDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumDetailSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAlbumDetailSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumDetailSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAlbumSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAlbumSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByArtistDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistDetailSortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByArtistDetailSortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistDetailSortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByArtistDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistDetailSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByArtistDetailSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistDetailSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByArtistSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByArtistSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioBackCacheSizeMB() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioBackCacheSizeMB', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioBackCacheSizeMBDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioBackCacheSizeMB', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAudioCacheSecs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCacheSecs', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioCacheSecsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCacheSecs', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioCacheSizeMB() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCacheSizeMB', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioCacheSizeMBDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCacheSizeMB', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAudioFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocus', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAudioFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocus', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioFocusReleaseOnPause() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusReleaseOnPause', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioFocusReleaseOnPauseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusReleaseOnPause', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioFocusRequestOnPlay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusRequestOnPlay', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioFocusRequestOnPlayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusRequestOnPlay', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioFocusRestartOnGain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusRestartOnGain', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioFocusRestartOnGainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusRestartOnGain', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioFocusStopOnOtherSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusStopOnOtherSession', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAudioFocusStopOnOtherSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusStopOnOtherSession', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBgBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgBrightness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBgBrightnessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgBrightness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBgOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgOpacity', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBgOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgOpacity', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBlurredArtworkForLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blurredArtworkForLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBlurredArtworkForLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blurredArtworkForLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCacheOnlineStreams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheOnlineStreams', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCacheOnlineStreamsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheOnlineStreams', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCollectionSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionSortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCollectionSortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionSortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCollectionSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCollectionSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCrossfadeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeDuration', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCrossfadeDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeDuration', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByCrossfadeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCrossfadeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomBackgroundImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customBackgroundImagePath', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomBackgroundImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customBackgroundImagePath', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontFamily', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontFamily', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontFamilyLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontFamilyLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontFamilyLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontFamilyLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeight', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeight', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontWeightDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightDelta', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontWeightDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightDelta', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontWeightLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontWeightLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontWeightLyricsDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightLyricsDelta', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomFontWeightLyricsDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightLyricsDelta', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomShortcutsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customShortcutsJson', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByCustomShortcutsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customShortcutsJson', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDarkTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkTheme', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDarkThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkTheme', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDefaultMiniPlayerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultMiniPlayerType', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDefaultMiniPlayerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultMiniPlayerType', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDisableAnimatedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableAnimatedDuration', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDisableAnimatedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableAnimatedDuration', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDisableBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableBlur', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDisableBlurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableBlur', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDisableSquiggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableSquiggle', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDisableSquiggleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableSquiggle', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDownloadArtwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadArtwork', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDownloadArtworkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadArtwork', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicAccentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicAccentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicColorActiveLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorActiveLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicColorActiveLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorActiveLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByDynamicLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByDynamicLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableAudioCache() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAudioCache', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableAudioCacheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAudioCache', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableDiscordRpc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDiscordRpc', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableDiscordRpcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDiscordRpc', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableDynamicTheming() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDynamicTheming', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableDynamicThemingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDynamicTheming', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByEnableInternet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableInternet', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableInternetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableInternet', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableLastFmScrobbling() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableLastFmScrobbling', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableLastFmScrobblingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableLastFmScrobbling', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableListenBrainzScrobbling() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableListenBrainzScrobbling', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableListenBrainzScrobblingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableListenBrainzScrobbling', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnablePlayerGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePlayerGradient', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnablePlayerGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePlayerGradient', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableSlideGesture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableSlideGesture', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEnableSlideGestureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableSlideGesture', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEqualizerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEqualizerEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEqualizerGlobalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerGlobalMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByEqualizerGlobalModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerGlobalMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByExclusiveHardwareMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exclusiveHardwareMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByExclusiveHardwareModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exclusiveHardwareMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByFadePlayPauseStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadePlayPauseStop', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByFadePlayPauseStopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadePlayPauseStop', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByFirstTimeEqualizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstTimeEqualizer', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByFirstTimeEqualizerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstTimeEqualizer', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByFullscreenVisualizerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullscreenVisualizerEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByFullscreenVisualizerEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullscreenVisualizerEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByGaplessPlayback() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gaplessPlayback', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByGaplessPlaybackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gaplessPlayback', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByGenreSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genreSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByGenreSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genreSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByHomeDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByHomeDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByKeepBackgroundGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keepBackgroundGradient', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByKeepBackgroundGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keepBackgroundGradient', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLastFmApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmApiKey', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastFmApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmApiKey', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLastFmSecret() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmSecret', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastFmSecretDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmSecret', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastFmSessionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmSessionKey', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastFmSessionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmSessionKey', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLastFmUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmUsername', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastFmUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmUsername', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastPlayedSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedSongId', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastPlayedSongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedSongId', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLastPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositionMs', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositionMs', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLastQueueIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQueueIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLastQueueIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQueueIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLibraryDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLibraryDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByListenBrainzUserToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listenBrainzUserToken', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByListenBrainzUserTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listenBrainzUserToken', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLyricsAlignment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsAlignment', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLyricsAlignmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsAlignment', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLyricsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLyricsDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLyricsProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsProvider', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLyricsProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsProvider', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByMinimizeToTray() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimizeToTray', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByMinimizeToTrayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimizeToTray', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByMusicDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByMusicDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNowPlayingFullscreen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nowPlayingFullscreen', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNowPlayingFullscreenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nowPlayingFullscreen', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByPauseOnDuck() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseOnDuck', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByPauseOnDuckDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseOnDuck', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPermanentAudioFocusChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanentAudioFocusChange', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPermanentAudioFocusChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanentAudioFocusChange', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByPersistQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistQueue', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPersistQueueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistQueue', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlayPauseStopFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playPauseStopFadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlayPauseStopFadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playPauseStopFadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlaybackModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackModeIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlaybackModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackModeIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlaylistDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistDetailSortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlaylistDetailSortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistDetailSortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlaylistDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistDetailSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPlaylistDetailSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistDetailSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByResumeAfterCall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeAfterCall', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByResumeAfterCallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeAfterCall', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByResumeOnBluetoothConnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnBluetoothConnect', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByResumeOnBluetoothConnectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnBluetoothConnect', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByResumeOnStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnStart', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByResumeOnStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnStart', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySaveDynamicColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDynamicColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySaveDynamicColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDynamicColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByScrobbleThresholdPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrobbleThresholdPercent', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByScrobbleThresholdPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrobbleThresholdPercent', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySeekBarStyleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seekBarStyleIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySeekBarStyleIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seekBarStyleIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySettingsV2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV2', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySettingsV2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV2', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySettingsV3() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV3', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySettingsV3Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV3', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowFullscreenABLooper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFullscreenABLooper', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowFullscreenABLooperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFullscreenABLooper', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowFullscreenSleepTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFullscreenSleepTimer', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowFullscreenSleepTimerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFullscreenSleepTimer', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShowHomeAlbums() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeAlbums', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowHomeAlbumsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeAlbums', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShowHomeArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeArtists', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowHomeArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeArtists', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShowHomeGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeGenres', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowHomeGenresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeGenres', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowPerformanceOptimizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPerformanceOptimizer', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowPerformanceOptimizerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPerformanceOptimizer', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowPlayedSongsInQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPlayedSongsInQueue', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowPlayedSongsInQueueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPlayedSongsInQueue', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowQualityBadge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showQualityBadge', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowQualityBadgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showQualityBadge', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffle', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByShuffleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffle', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySongsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songsDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySongsDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songsDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySortStrategyIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortStrategyIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySortStrategyIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortStrategyIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByStopOnTaskRemoved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOnTaskRemoved', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByStopOnTaskRemovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOnTaskRemoved', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByStreamingQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamingQuality', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByStreamingQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamingQuality', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByUniformLyricsFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniformLyricsFontSize', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByUniformLyricsFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniformLyricsFontSize', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByUseAlbumArtistForArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useAlbumArtistForArtists', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByUseAlbumArtistForArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useAlbumArtistForArtists', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByUseNewFont() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useNewFont', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByUseNewFontDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useNewFont', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByUseNewFontLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useNewFontLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByUseNewFontLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useNewFontLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }
}

extension AppSettingsQuerySortThenBy
    on QueryBuilder<AppSettings, AppSettings, QSortThenBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByActiveLyricsFontWeightDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeLyricsFontWeightDelta', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByActiveLyricsFontWeightDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeLyricsFontWeightDelta', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByActiveQueueName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeQueueName', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByActiveQueueNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeQueueName', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAlbumDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumDetailSortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAlbumDetailSortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumDetailSortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAlbumDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumDetailSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAlbumDetailSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumDetailSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAlbumSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAlbumSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByArtistDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistDetailSortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByArtistDetailSortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistDetailSortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByArtistDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistDetailSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByArtistDetailSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistDetailSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByArtistSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByArtistSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioBackCacheSizeMB() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioBackCacheSizeMB', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioBackCacheSizeMBDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioBackCacheSizeMB', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAudioCacheSecs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCacheSecs', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioCacheSecsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCacheSecs', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioCacheSizeMB() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCacheSizeMB', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioCacheSizeMBDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioCacheSizeMB', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAudioFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocus', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAudioFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocus', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioFocusReleaseOnPause() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusReleaseOnPause', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioFocusReleaseOnPauseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusReleaseOnPause', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioFocusRequestOnPlay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusRequestOnPlay', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioFocusRequestOnPlayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusRequestOnPlay', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioFocusRestartOnGain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusRestartOnGain', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioFocusRestartOnGainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusRestartOnGain', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioFocusStopOnOtherSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusStopOnOtherSession', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAudioFocusStopOnOtherSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioFocusStopOnOtherSession', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBgBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgBrightness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBgBrightnessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgBrightness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBgOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgOpacity', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBgOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bgOpacity', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBlurredArtworkForLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blurredArtworkForLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBlurredArtworkForLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blurredArtworkForLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCacheOnlineStreams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheOnlineStreams', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCacheOnlineStreamsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheOnlineStreams', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCollectionSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionSortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCollectionSortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionSortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCollectionSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCollectionSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCrossfadeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeDuration', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCrossfadeDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeDuration', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByCrossfadeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCrossfadeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomBackgroundImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customBackgroundImagePath', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomBackgroundImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customBackgroundImagePath', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontFamily', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontFamily', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontFamilyLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontFamilyLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontFamilyLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontFamilyLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeight', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeight', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontWeightDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightDelta', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontWeightDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightDelta', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontWeightLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontWeightLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontWeightLyricsDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightLyricsDelta', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomFontWeightLyricsDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFontWeightLyricsDelta', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomShortcutsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customShortcutsJson', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByCustomShortcutsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customShortcutsJson', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDarkTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkTheme', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDarkThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkTheme', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDefaultMiniPlayerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultMiniPlayerType', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDefaultMiniPlayerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultMiniPlayerType', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDisableAnimatedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableAnimatedDuration', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDisableAnimatedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableAnimatedDuration', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDisableBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableBlur', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDisableBlurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableBlur', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDisableSquiggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableSquiggle', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDisableSquiggleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableSquiggle', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDownloadArtwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadArtwork', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDownloadArtworkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadArtwork', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicAccentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicAccentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicColorActiveLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorActiveLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicColorActiveLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicColorActiveLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByDynamicLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByDynamicLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableAudioCache() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAudioCache', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableAudioCacheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAudioCache', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableDiscordRpc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDiscordRpc', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableDiscordRpcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDiscordRpc', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableDynamicTheming() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDynamicTheming', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableDynamicThemingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDynamicTheming', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByEnableInternet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableInternet', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableInternetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableInternet', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableLastFmScrobbling() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableLastFmScrobbling', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableLastFmScrobblingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableLastFmScrobbling', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableListenBrainzScrobbling() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableListenBrainzScrobbling', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableListenBrainzScrobblingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableListenBrainzScrobbling', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnablePlayerGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePlayerGradient', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnablePlayerGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePlayerGradient', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableSlideGesture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableSlideGesture', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEnableSlideGestureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableSlideGesture', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEqualizerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEqualizerEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEqualizerGlobalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerGlobalMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByEqualizerGlobalModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerGlobalMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByExclusiveHardwareMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exclusiveHardwareMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByExclusiveHardwareModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exclusiveHardwareMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByFadePlayPauseStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadePlayPauseStop', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByFadePlayPauseStopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadePlayPauseStop', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByFirstTimeEqualizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstTimeEqualizer', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByFirstTimeEqualizerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstTimeEqualizer', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByFullscreenVisualizerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullscreenVisualizerEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByFullscreenVisualizerEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullscreenVisualizerEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByGaplessPlayback() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gaplessPlayback', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByGaplessPlaybackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gaplessPlayback', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByGenreSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genreSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByGenreSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genreSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByHomeDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByHomeDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByKeepBackgroundGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keepBackgroundGradient', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByKeepBackgroundGradientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keepBackgroundGradient', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLastFmApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmApiKey', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastFmApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmApiKey', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLastFmSecret() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmSecret', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastFmSecretDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmSecret', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastFmSessionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmSessionKey', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastFmSessionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmSessionKey', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLastFmUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmUsername', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastFmUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFmUsername', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastPlayedSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedSongId', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastPlayedSongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedSongId', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLastPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositionMs', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositionMs', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLastQueueIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQueueIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLastQueueIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQueueIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLibraryDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLibraryDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByListenBrainzUserToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listenBrainzUserToken', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByListenBrainzUserTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listenBrainzUserToken', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLyricsAlignment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsAlignment', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLyricsAlignmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsAlignment', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLyricsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLyricsDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLyricsProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsProvider', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLyricsProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsProvider', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByMinimizeToTray() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimizeToTray', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByMinimizeToTrayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimizeToTray', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByMusicDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByMusicDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNowPlayingFullscreen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nowPlayingFullscreen', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNowPlayingFullscreenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nowPlayingFullscreen', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByPauseOnDuck() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseOnDuck', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByPauseOnDuckDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseOnDuck', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPermanentAudioFocusChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanentAudioFocusChange', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPermanentAudioFocusChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanentAudioFocusChange', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByPersistQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistQueue', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPersistQueueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistQueue', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlayPauseStopFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playPauseStopFadeLength', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlayPauseStopFadeLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playPauseStopFadeLength', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlaybackModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackModeIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlaybackModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackModeIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlaylistDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistDetailSortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlaylistDetailSortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistDetailSortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlaylistDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistDetailSortOptionIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPlaylistDetailSortOptionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistDetailSortOptionIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByResumeAfterCall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeAfterCall', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByResumeAfterCallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeAfterCall', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByResumeOnBluetoothConnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnBluetoothConnect', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByResumeOnBluetoothConnectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnBluetoothConnect', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByResumeOnStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnStart', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByResumeOnStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resumeOnStart', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySaveDynamicColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDynamicColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySaveDynamicColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDynamicColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByScrobbleThresholdPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrobbleThresholdPercent', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByScrobbleThresholdPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrobbleThresholdPercent', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySeekBarStyleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seekBarStyleIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySeekBarStyleIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seekBarStyleIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySettingsV2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV2', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySettingsV2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV2', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySettingsV3() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV3', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySettingsV3Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsV3', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowFullscreenABLooper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFullscreenABLooper', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowFullscreenABLooperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFullscreenABLooper', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowFullscreenSleepTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFullscreenSleepTimer', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowFullscreenSleepTimerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFullscreenSleepTimer', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShowHomeAlbums() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeAlbums', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowHomeAlbumsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeAlbums', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShowHomeArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeArtists', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowHomeArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeArtists', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShowHomeGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeGenres', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowHomeGenresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showHomeGenres', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowPerformanceOptimizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPerformanceOptimizer', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowPerformanceOptimizerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPerformanceOptimizer', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowPlayedSongsInQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPlayedSongsInQueue', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowPlayedSongsInQueueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPlayedSongsInQueue', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowQualityBadge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showQualityBadge', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowQualityBadgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showQualityBadge', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffle', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByShuffleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffle', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySongsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songsDarkness', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySongsDarknessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songsDarkness', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortAscending', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySortAscendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortAscending', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySortStrategyIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortStrategyIndex', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySortStrategyIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortStrategyIndex', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByStopOnTaskRemoved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOnTaskRemoved', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByStopOnTaskRemovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopOnTaskRemoved', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByStreamingQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamingQuality', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByStreamingQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamingQuality', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByUniformLyricsFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniformLyricsFontSize', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByUniformLyricsFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniformLyricsFontSize', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByUseAlbumArtistForArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useAlbumArtistForArtists', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByUseAlbumArtistForArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useAlbumArtistForArtists', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByUseNewFont() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useNewFont', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByUseNewFontDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useNewFont', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByUseNewFontLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useNewFontLyrics', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByUseNewFontLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useNewFontLyrics', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }
}

extension AppSettingsQueryWhereDistinct
    on QueryBuilder<AppSettings, AppSettings, QDistinct> {
  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accentColor');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByActiveLyricsFontWeightDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeLyricsFontWeightDelta');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByActiveQueueName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeQueueName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAlbumDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'albumDetailSortAscending');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAlbumDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'albumDetailSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAlbumSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'albumSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByArtistDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistDetailSortAscending');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByArtistDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistDetailSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByArtistSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAudioBackCacheSizeMB() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioBackCacheSizeMB');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByAudioCacheSecs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioCacheSecs');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAudioCacheSizeMB() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioCacheSizeMB');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByAudioFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioFocus');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAudioFocusReleaseOnPause() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioFocusReleaseOnPause');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAudioFocusRequestOnPlay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioFocusRequestOnPlay');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAudioFocusRestartOnGain() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioFocusRestartOnGain');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAudioFocusStopOnOtherSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioFocusStopOnOtherSession');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByBgBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bgBrightness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByBgOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bgOpacity');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByBlurredArtworkForLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blurredArtworkForLyrics');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCacheOnlineStreams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheOnlineStreams');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCollectionSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionSortAscending');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCollectionSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCrossfadeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crossfadeDuration');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByCrossfadeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crossfadeMode');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCustomBackgroundImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customBackgroundImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByCustomFontFamily(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFontFamily',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCustomFontFamilyLyrics({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFontFamilyLyrics',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCustomFontWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFontWeight');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCustomFontWeightDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFontWeightDelta');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCustomFontWeightLyrics({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFontWeightLyrics',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCustomFontWeightLyricsDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFontWeightLyricsDelta');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByCustomShortcutsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customShortcutsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByDarkTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'darkTheme');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDefaultMiniPlayerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultMiniPlayerType');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDisableAnimatedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableAnimatedDuration');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByDisableBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableBlur');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDisableSquiggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableSquiggle');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDownloadArtwork() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadArtwork');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDynamicAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dynamicAccentColor');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByDynamicColorActiveLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dynamicColorActiveLyrics');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByDynamicLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dynamicLyrics');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableAudioCache() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableAudioCache');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableDiscordRpc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableDiscordRpc');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableDynamicTheming() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableDynamicTheming');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByEnableInternet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableInternet');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableLastFmScrobbling() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableLastFmScrobbling');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableListenBrainzScrobbling() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableListenBrainzScrobbling');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnablePlayerGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enablePlayerGradient');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEnableSlideGesture() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableSlideGesture');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEqualizerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'equalizerEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByEqualizerGlobalMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'equalizerGlobalMode');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByExclusiveHardwareMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exclusiveHardwareMode');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByFadePlayPauseStop() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fadePlayPauseStop');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByFirstTimeEqualizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstTimeEqualizer');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByFullscreenVisualizerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullscreenVisualizerEnabled');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByGaplessPlayback() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gaplessPlayback');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByGenreSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genreSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByGlobalEqualizerGains() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'globalEqualizerGains');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByHomeDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'homeDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByHomeSectionOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'homeSectionOrder');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByKeepBackgroundGradient() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keepBackgroundGradient');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLastFmApiKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFmApiKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLastFmSecret(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFmSecret', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLastFmSessionKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFmSessionKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLastFmUsername(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFmUsername',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLastPlayedSongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedSongId');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLastPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPositionMs');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLastQueueIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastQueueIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLastQueueSongIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastQueueSongIds');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLibraryDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'libraryDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLibraryFolders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'libraryFolders');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByListenBrainzUserToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'listenBrainzUserToken',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLyricsAlignment(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyricsAlignment',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLyricsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyricsDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByLyricsProvider(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyricsProvider',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByMinimizeToTray() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minimizeToTray');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByMusicDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'musicDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByNowPlayingFullscreen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nowPlayingFullscreen');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByPauseOnDuck() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pauseOnDuck');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByPermanentAudioFocusChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permanentAudioFocusChange');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByPersistQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'persistQueue');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByPlayPauseStopFadeLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playPauseStopFadeLength');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByPlaybackModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackModeIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByPlaylistDetailSortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistDetailSortAscending');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByPlaylistDetailSortOptionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistDetailSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatMode');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByResumeAfterCall() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resumeAfterCall');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByResumeOnBluetoothConnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resumeOnBluetoothConnect');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByResumeOnStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resumeOnStart');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctBySaveDynamicColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveDynamicColor');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByScrobbleThresholdPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scrobbleThresholdPercent');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctBySeekBarStyleIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seekBarStyleIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySettingsV2() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsV2');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySettingsV3() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsV3');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowFullscreenABLooper() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showFullscreenABLooper');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowFullscreenSleepTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showFullscreenSleepTimer');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByShowHomeAlbums() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showHomeAlbums');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowHomeArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showHomeArtists');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByShowHomeGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showHomeGenres');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowPerformanceOptimizer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showPerformanceOptimizer');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowPlayedSongsInQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showPlayedSongsInQueue');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowQualityBadge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showQualityBadge');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByShuffle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shuffle');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySongsDarkness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songsDarkness');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySortAscending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortAscending');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctBySortStrategyIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortStrategyIndex');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByStopOnTaskRemoved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stopOnTaskRemoved');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByStreamingQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamingQuality');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByUniformLyricsFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniformLyricsFontSize');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByUseAlbumArtistForArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useAlbumArtistForArtists');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByUseNewFont() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useNewFont');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByUseNewFontLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useNewFontLyrics');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volume');
    });
  }
}

extension AppSettingsQueryProperty
    on QueryBuilder<AppSettings, AppSettings, QQueryProperty> {
  QueryBuilder<AppSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> accentColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accentColor');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      activeLyricsFontWeightDeltaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeLyricsFontWeightDelta');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      activeQueueNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeQueueName');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      albumDetailSortAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'albumDetailSortAscending');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      albumDetailSortOptionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'albumDetailSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      albumSortOptionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'albumSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      artistDetailSortAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistDetailSortAscending');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      artistDetailSortOptionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistDetailSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      artistSortOptionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      audioBackCacheSizeMBProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioBackCacheSizeMB');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> audioCacheSecsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioCacheSecs');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> audioCacheSizeMBProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioCacheSizeMB');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> audioFocusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioFocus');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      audioFocusReleaseOnPauseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioFocusReleaseOnPause');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      audioFocusRequestOnPlayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioFocusRequestOnPlay');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      audioFocusRestartOnGainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioFocusRestartOnGain');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      audioFocusStopOnOtherSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioFocusStopOnOtherSession');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> bgBrightnessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bgBrightness');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> bgOpacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bgOpacity');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      blurredArtworkForLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blurredArtworkForLyrics');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      cacheOnlineStreamsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheOnlineStreams');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      collectionSortAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionSortAscending');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      collectionSortOptionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> crossfadeDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crossfadeDuration');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> crossfadeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crossfadeMode');
    });
  }

  QueryBuilder<AppSettings, String?, QQueryOperations>
      customBackgroundImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customBackgroundImagePath');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      customFontFamilyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFontFamily');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      customFontFamilyLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFontFamilyLyrics');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> customFontWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFontWeight');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      customFontWeightDeltaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFontWeightDelta');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      customFontWeightLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFontWeightLyrics');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      customFontWeightLyricsDeltaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFontWeightLyricsDelta');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      customShortcutsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customShortcutsJson');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> darkThemeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'darkTheme');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      defaultMiniPlayerTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultMiniPlayerType');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      disableAnimatedDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableAnimatedDuration');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> disableBlurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableBlur');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> disableSquiggleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableSquiggle');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> downloadArtworkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadArtwork');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      dynamicAccentColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dynamicAccentColor');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      dynamicColorActiveLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dynamicColorActiveLyrics');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> dynamicLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dynamicLyrics');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> enableAudioCacheProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableAudioCache');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> enableDiscordRpcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableDiscordRpc');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      enableDynamicThemingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableDynamicTheming');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> enableInternetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableInternet');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      enableLastFmScrobblingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableLastFmScrobbling');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      enableListenBrainzScrobblingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableListenBrainzScrobbling');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      enablePlayerGradientProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enablePlayerGradient');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      enableSlideGestureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableSlideGesture');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> equalizerEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'equalizerEnabled');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      equalizerGlobalModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'equalizerGlobalMode');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      exclusiveHardwareModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exclusiveHardwareMode');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      fadePlayPauseStopProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fadePlayPauseStop');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      firstTimeEqualizerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstTimeEqualizer');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      fullscreenVisualizerEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullscreenVisualizerEnabled');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> gaplessPlaybackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gaplessPlayback');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      genreSortOptionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genreSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, List<double>, QQueryOperations>
      globalEqualizerGainsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'globalEqualizerGains');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> homeDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'homeDarkness');
    });
  }

  QueryBuilder<AppSettings, List<String>, QQueryOperations>
      homeSectionOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'homeSectionOrder');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      keepBackgroundGradientProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keepBackgroundGradient');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> lastFmApiKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFmApiKey');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> lastFmSecretProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFmSecret');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      lastFmSessionKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFmSessionKey');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> lastFmUsernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFmUsername');
    });
  }

  QueryBuilder<AppSettings, int?, QQueryOperations> lastPlayedSongIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedSongId');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> lastPositionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPositionMs');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> lastQueueIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastQueueIndex');
    });
  }

  QueryBuilder<AppSettings, List<int>, QQueryOperations>
      lastQueueSongIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastQueueSongIds');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations>
      libraryDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'libraryDarkness');
    });
  }

  QueryBuilder<AppSettings, List<String>, QQueryOperations>
      libraryFoldersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'libraryFolders');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      listenBrainzUserTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'listenBrainzUserToken');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations>
      lyricsAlignmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyricsAlignment');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> lyricsDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyricsDarkness');
    });
  }

  QueryBuilder<AppSettings, String, QQueryOperations> lyricsProviderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyricsProvider');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> minimizeToTrayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minimizeToTray');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> musicDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'musicDarkness');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      nowPlayingFullscreenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nowPlayingFullscreen');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> pauseOnDuckProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pauseOnDuck');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      permanentAudioFocusChangeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permanentAudioFocusChange');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> persistQueueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'persistQueue');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      playPauseStopFadeLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playPauseStopFadeLength');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> playbackModeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackModeIndex');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      playlistDetailSortAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistDetailSortAscending');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      playlistDetailSortOptionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistDetailSortOptionIndex');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> repeatModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatMode');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> resumeAfterCallProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resumeAfterCall');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      resumeOnBluetoothConnectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resumeOnBluetoothConnect');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> resumeOnStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resumeOnStart');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> saveDynamicColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveDynamicColor');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations>
      scrobbleThresholdPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scrobbleThresholdPercent');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> seekBarStyleIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seekBarStyleIndex');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> settingsV2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsV2');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> settingsV3Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsV3');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      showFullscreenABLooperProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showFullscreenABLooper');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      showFullscreenSleepTimerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showFullscreenSleepTimer');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> showHomeAlbumsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showHomeAlbums');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> showHomeArtistsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showHomeArtists');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> showHomeGenresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showHomeGenres');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      showPerformanceOptimizerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showPerformanceOptimizer');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      showPlayedSongsInQueueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showPlayedSongsInQueue');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> showQualityBadgeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showQualityBadge');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> shuffleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shuffle');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> songsDarknessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songsDarkness');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> sortAscendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortAscending');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> sortStrategyIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortStrategyIndex');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      stopOnTaskRemovedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stopOnTaskRemoved');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> streamingQualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamingQuality');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      uniformLyricsFontSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniformLyricsFontSize');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      useAlbumArtistForArtistsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useAlbumArtistForArtists');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> useNewFontProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useNewFont');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> useNewFontLyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useNewFontLyrics');
    });
  }

  QueryBuilder<AppSettings, double, QQueryOperations> volumeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volume');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaybackHistoryEntryCollection on Isar {
  IsarCollection<PlaybackHistoryEntry> get playbackHistoryEntrys =>
      this.collection();
}

const PlaybackHistoryEntrySchema = CollectionSchema(
  name: r'PlaybackHistoryEntry',
  id: -8726484737436458415,
  properties: {
    r'album': PropertySchema(
      id: 0,
      name: r'album',
      type: IsarType.string,
    ),
    r'artPath': PropertySchema(
      id: 1,
      name: r'artPath',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 2,
      name: r'artist',
      type: IsarType.string,
    ),
    r'durationMs': PropertySchema(
      id: 3,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'genre': PropertySchema(
      id: 4,
      name: r'genre',
      type: IsarType.string,
    ),
    r'listenedMs': PropertySchema(
      id: 5,
      name: r'listenedMs',
      type: IsarType.long,
    ),
    r'songPath': PropertySchema(
      id: 6,
      name: r'songPath',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 7,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 8,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _playbackHistoryEntryEstimateSize,
  serialize: _playbackHistoryEntrySerialize,
  deserialize: _playbackHistoryEntryDeserialize,
  deserializeProp: _playbackHistoryEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _playbackHistoryEntryGetId,
  getLinks: _playbackHistoryEntryGetLinks,
  attach: _playbackHistoryEntryAttach,
  version: '3.1.0+1',
);

int _playbackHistoryEntryEstimateSize(
  PlaybackHistoryEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.album;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artist;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.genre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.songPath.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _playbackHistoryEntrySerialize(
  PlaybackHistoryEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.album);
  writer.writeString(offsets[1], object.artPath);
  writer.writeString(offsets[2], object.artist);
  writer.writeLong(offsets[3], object.durationMs);
  writer.writeString(offsets[4], object.genre);
  writer.writeLong(offsets[5], object.listenedMs);
  writer.writeString(offsets[6], object.songPath);
  writer.writeDateTime(offsets[7], object.timestamp);
  writer.writeString(offsets[8], object.title);
}

PlaybackHistoryEntry _playbackHistoryEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlaybackHistoryEntry();
  object.album = reader.readStringOrNull(offsets[0]);
  object.artPath = reader.readStringOrNull(offsets[1]);
  object.artist = reader.readStringOrNull(offsets[2]);
  object.durationMs = reader.readLong(offsets[3]);
  object.genre = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.listenedMs = reader.readLong(offsets[5]);
  object.songPath = reader.readString(offsets[6]);
  object.timestamp = reader.readDateTime(offsets[7]);
  object.title = reader.readString(offsets[8]);
  return object;
}

P _playbackHistoryEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playbackHistoryEntryGetId(PlaybackHistoryEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playbackHistoryEntryGetLinks(
    PlaybackHistoryEntry object) {
  return [];
}

void _playbackHistoryEntryAttach(
    IsarCollection<dynamic> col, Id id, PlaybackHistoryEntry object) {
  object.id = id;
}

extension PlaybackHistoryEntryQueryWhereSort
    on QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QWhere> {
  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhere>
      anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension PlaybackHistoryEntryQueryWhere
    on QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QWhereClause> {
  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlaybackHistoryEntryQueryFilter on QueryBuilder<PlaybackHistoryEntry,
    PlaybackHistoryEntry, QFilterCondition> {
  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'album',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      albumContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      albumMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'album',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artPath',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      artPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      artPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artist',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      artistContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      artistMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> durationMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> durationMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> durationMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> durationMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      genreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      genreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> genreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> listenedMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'listenedMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> listenedMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'listenedMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> listenedMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'listenedMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> listenedMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'listenedMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> songPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> songPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> songPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> songPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> songPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'songPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> songPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'songPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      songPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'songPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      songPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'songPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> songPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> songPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'songPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension PlaybackHistoryEntryQueryObject on QueryBuilder<PlaybackHistoryEntry,
    PlaybackHistoryEntry, QFilterCondition> {}

extension PlaybackHistoryEntryQueryLinks on QueryBuilder<PlaybackHistoryEntry,
    PlaybackHistoryEntry, QFilterCondition> {}

extension PlaybackHistoryEntryQuerySortBy
    on QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QSortBy> {
  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByListenedMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listenedMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByListenedMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listenedMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortBySongPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songPath', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortBySongPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songPath', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension PlaybackHistoryEntryQuerySortThenBy
    on QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QSortThenBy> {
  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByArtPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByArtPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artPath', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByListenedMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listenedMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByListenedMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listenedMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenBySongPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songPath', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenBySongPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songPath', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension PlaybackHistoryEntryQueryWhereDistinct
    on QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct> {
  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctByAlbum({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctByArtPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctByArtist({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMs');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctByGenre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctByListenedMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'listenedMs');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctBySongPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, PlaybackHistoryEntry, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension PlaybackHistoryEntryQueryProperty on QueryBuilder<
    PlaybackHistoryEntry, PlaybackHistoryEntry, QQueryProperty> {
  QueryBuilder<PlaybackHistoryEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, String?, QQueryOperations>
      albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, String?, QQueryOperations>
      artPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artPath');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, String?, QQueryOperations>
      artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, int, QQueryOperations>
      durationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMs');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, String?, QQueryOperations>
      genreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genre');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, int, QQueryOperations>
      listenedMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'listenedMs');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, String, QQueryOperations>
      songPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songPath');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<PlaybackHistoryEntry, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
