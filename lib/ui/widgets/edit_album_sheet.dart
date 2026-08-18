import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/core/artwork_save_helper.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

void showEditAlbumSheet(
  BuildContext context,
  Album album,
  List<Song> songs,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => EditAlbumSheet(album: album, songs: songs),
  );
}

class EditAlbumSheet extends ConsumerStatefulWidget {
  final Album album;
  final List<Song> songs;

  const EditAlbumSheet({
    super.key,
    required this.album,
    required this.songs,
  });

  @override
  ConsumerState<EditAlbumSheet> createState() => _EditAlbumSheetState();
}

class _EditAlbumSheetState extends ConsumerState<EditAlbumSheet> {
  late TextEditingController _albumTitleCtrl;
  late TextEditingController _albumArtistCtrl;
  late TextEditingController _artistCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _genreCtrl;
  late TextEditingController _trackTotalCtrl;
  late TextEditingController _discTotalCtrl;

  String? _pickedArtPath; // null = unchanged, '' = cleared, non-empty = new path
  bool _isSaving = false;
  int _progressCurrent = 0;
  int _progressTotal = 0;

  @override
  void initState() {
    super.initState();
    _albumTitleCtrl = TextEditingController(text: widget.album.name);
    _albumArtistCtrl = TextEditingController(text: widget.album.artist ?? '');
    _artistCtrl = TextEditingController(); // Empty means keep individual track artists

    // Find representative values from album songs
    int? commonYear;
    String? commonGenre;
    int? commonTrackTotal;
    int? commonDiscTotal;

    for (final song in widget.songs) {
      if (commonYear == null && song.year != null && song.year! > 0) {
        commonYear = song.year;
      }
      if (commonGenre == null && song.genre != null && song.genre!.isNotEmpty) {
        commonGenre = song.genre;
      }
      if (commonTrackTotal == null && song.trackTotal != null && song.trackTotal! > 0) {
        commonTrackTotal = song.trackTotal;
      }
      if (commonDiscTotal == null && song.discTotal != null && song.discTotal! > 0) {
        commonDiscTotal = song.discTotal;
      }
    }

    _yearCtrl = TextEditingController(text: commonYear != null ? commonYear.toString() : '');
    _genreCtrl = TextEditingController(text: commonGenre ?? '');
    _trackTotalCtrl = TextEditingController(
      text: commonTrackTotal != null ? commonTrackTotal.toString() : widget.songs.length.toString(),
    );
    _discTotalCtrl = TextEditingController(text: commonDiscTotal != null ? commonDiscTotal.toString() : '1');
  }

  @override
  void dispose() {
    _albumTitleCtrl.dispose();
    _albumArtistCtrl.dispose();
    _artistCtrl.dispose();
    _yearCtrl.dispose();
    _genreCtrl.dispose();
    _trackTotalCtrl.dispose();
    _discTotalCtrl.dispose();
    super.dispose();
  }

  String get _currentArtPath => _pickedArtPath ?? widget.album.artPath ?? '';

  Future<void> _pickArtwork() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _pickedArtPath = result.files.single.path!);
      }
    } catch (_) {}
  }

  void _clearArtwork() => setState(() => _pickedArtPath = '');

  Future<void> _save() async {
    if (_albumTitleCtrl.text.trim().isEmpty) return;
    setState(() {
      _isSaving = true;
      _progressCurrent = 0;
      _progressTotal = widget.songs.length;
    });

    final notifier = ref.read(playbackProvider.notifier);
    final success = await notifier.editAlbumMetadata(
      widget.album,
      newAlbumTitle: _albumTitleCtrl.text.trim(),
      newAlbumArtist: _albumArtistCtrl.text.trim(),
      newArtist: _artistCtrl.text.trim().isNotEmpty ? _artistCtrl.text.trim() : null,
      year: int.tryParse(_yearCtrl.text.trim()) ?? 0,
      genre: _genreCtrl.text.trim(),
      trackTotal: int.tryParse(_trackTotalCtrl.text.trim()),
      discTotal: int.tryParse(_discTotalCtrl.text.trim()),
      artPath: _pickedArtPath,
      onProgress: (cur, tot) {
        if (mounted) {
          setState(() {
            _progressCurrent = cur;
            _progressTotal = tot;
          });
        }
      },
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Album and ${widget.songs.length} tracks updated!' : 'Failed to update album.'),
          backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accentColor = Color(settings.accentColor);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: bottomInset),
          decoration: const BoxDecoration(
            color: Color(0xFF161616),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _isSaving ? null : () => Navigator.pop(context),
                          icon: const Icon(LucideIcons.x, color: Colors.white70, size: 20),
                          tooltip: 'Cancel',
                        ),
                        Column(
                          children: [
                            Text(
                              'Edit Album Info',
                              style: AppFonts.jostStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.songs.length} tracks',
                              style: AppFonts.jostStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(LucideIcons.check, color: accentColor, size: 22),
                          tooltip: 'Save Album Info',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10, height: 1),

                  // Scrollable Content
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Artwork Picker
                          Center(
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: _currentArtPath.isNotEmpty
                                            ? (_pickedArtPath != null && _pickedArtPath!.isNotEmpty
                                                ? Image.file(
                                                    File(_pickedArtPath!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : OptimizedImage(
                                                    imagePath: _currentArtPath,
                                                    fit: BoxFit.cover,
                                                  ))
                                            : const Center(
                                                child: Icon(
                                                  LucideIcons.disc,
                                                  size: 52,
                                                  color: Colors.white24,
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Change art camera button at bottom-right
                                    Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: _pickArtwork,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: accentColor,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.4),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            LucideIcons.camera,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Save art button at top-right
                                    if (_currentArtPath.isNotEmpty)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Tooltip(
                                          message: 'Save artwork to file',
                                          child: GestureDetector(
                                            onTap: () => ArtworkSaveHelper.saveArtworkToFile(
                                              context: context,
                                              sourceArtPath: _currentArtPath,
                                              defaultFileName: _albumTitleCtrl.text.trim().isNotEmpty
                                                  ? _albumTitleCtrl.text.trim()
                                                  : widget.album.name,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.65),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white24),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.4),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                LucideIcons.download,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      onPressed: _pickArtwork,
                                      icon: const Icon(LucideIcons.imagePlus, size: 14),
                                      label: const Text('Change Art', style: TextStyle(fontSize: 12)),
                                      style: TextButton.styleFrom(
                                        foregroundColor: accentColor,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    if (_currentArtPath.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: _clearArtwork,
                                        icon: const Icon(LucideIcons.trash2, size: 14),
                                        label: const Text('Remove Art', style: TextStyle(fontSize: 12)),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.redAccent,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Common Album Fields
                          _buildField(
                            label: 'Album Title',
                            controller: _albumTitleCtrl,
                            icon: LucideIcons.disc,
                            hint: 'Album name',
                          ),
                          const SizedBox(height: 14),

                          _buildField(
                            label: 'Album Artist',
                            controller: _albumArtistCtrl,
                            icon: LucideIcons.userCheck,
                            hint: 'Main album artist',
                          ),
                          const SizedBox(height: 14),

                          _buildField(
                            label: 'Track Artist (Optional override for all tracks)',
                            controller: _artistCtrl,
                            icon: LucideIcons.user,
                            hint: 'Leave empty to keep individual track artists',
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  label: 'Year',
                                  controller: _yearCtrl,
                                  icon: LucideIcons.calendar,
                                  hint: 'e.g. 2024',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  label: 'Genre',
                                  controller: _genreCtrl,
                                  icon: LucideIcons.tag,
                                  hint: 'e.g. Pop / Rock',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  label: 'Track Total',
                                  controller: _trackTotalCtrl,
                                  icon: LucideIcons.listOrdered,
                                  hint: 'e.g. 12',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  label: 'Disc Total',
                                  controller: _discTotalCtrl,
                                  icon: LucideIcons.layers,
                                  hint: 'e.g. 1',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isSaving
                                  ? Text(
                                      'Updating $_progressCurrent of $_progressTotal...',
                                      style: AppFonts.jostStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : Text(
                                      'Save Album Info (${widget.songs.length} tracks)',
                                      style: AppFonts.jostStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Saving Overlay
              if (_isSaving)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppLoadingIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Updating files on disk...',
                            style: AppFonts.jostStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Processed $_progressCurrent of $_progressTotal tracks',
                            style: AppFonts.jostStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: AppFonts.jostStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppFonts.jostStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white38, size: 18),
              hintText: hint,
              hintStyle: AppFonts.jostStyle(
                color: Colors.white24,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
