import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/core/app_fonts.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/data/artist_repository.dart';
import 'package:looper_player/ui/widgets/app_loading_indicator.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

void showEditArtistSheet(
  BuildContext context,
  Artist artist,
  List<Song> songs,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => EditArtistSheet(artist: artist, songs: songs),
  );
}

class EditArtistSheet extends ConsumerStatefulWidget {
  final Artist artist;
  final List<Song> songs;

  const EditArtistSheet({
    super.key,
    required this.artist,
    required this.songs,
  });

  @override
  ConsumerState<EditArtistSheet> createState() => _EditArtistSheetState();
}

class _EditArtistSheetState extends ConsumerState<EditArtistSheet> {
  late TextEditingController _artistNameCtrl;
  String? _pickedImagePath;
  bool _isSaving = false;
  int _progressCurrent = 0;
  int _progressTotal = 0;

  @override
  void initState() {
    super.initState();
    _artistNameCtrl = TextEditingController(text: widget.artist.name);
  }

  @override
  void dispose() {
    _artistNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      dialogTitle: 'Select Artist Avatar Image',
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedImagePath = result.files.single.path;
      });
    }
  }

  Future<void> _save() async {
    final newName = _artistNameCtrl.text.trim();
    if (newName.isEmpty) return;

    setState(() {
      _isSaving = true;
      _progressCurrent = 0;
      _progressTotal = widget.songs.length;
    });

    try {
      await ArtistRepository.renameArtist(
        artist: widget.artist,
        newName: newName,
        songs: widget.songs,
        newImageUrl: _pickedImagePath,
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artist updated to "$newName" across ${widget.songs.length} tracks'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating artist: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final currentImage = _pickedImagePath ?? widget.artist.artistImageUrl ?? widget.artist.artPath;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 16,
            right: 16,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.userPen, color: accent, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Artist',
                            style: AppFonts.jostStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.songs.length} song${widget.songs.length == 1 ? '' : 's'} in library',
                            style: AppFonts.jostStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white54, size: 20),
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // Content Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar Image Picker
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: currentImage != null && currentImage.isNotEmpty
                                  ? (currentImage.startsWith('http')
                                      ? OptimizedImage(
                                          imagePath: currentImage,
                                          width: 140,
                                          height: 140,
                                          cacheWidth: 256,
                                          fit: BoxFit.cover,
                                        )
                                      : Image(
                                          image: ResizeImage(
                                            FileImage(File(currentImage)),
                                            width: 280,
                                            height: 280,
                                          ),
                                          fit: BoxFit.cover,
                                        ))
                                  : const Icon(
                                      LucideIcons.user,
                                      size: 48,
                                      color: Colors.white38,
                                    ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _isSaving ? null : _pickImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.35),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.camera,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Click to change artist picture',
                      style: AppFonts.jostStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Artist Name Field
                    TextField(
                      controller: _artistNameCtrl,
                      enabled: !_isSaving,
                      style: AppFonts.jostStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Artist Name',
                        labelStyle: AppFonts.jostStyle(color: Colors.white70),
                        prefixIcon: const Icon(LucideIcons.type, color: Colors.white54, size: 18),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                      ),
                    ),

                    if (_isSaving) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const AppLoadingIndicator(size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Writing tags... ($_progressCurrent/$_progressTotal)',
                              style: AppFonts.jostStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _progressTotal > 0 ? _progressCurrent / _progressTotal : null,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions Bottom Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Cancel', style: AppFonts.jostStyle(fontSize: 14)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Save Changes',
                        style: AppFonts.jostStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
