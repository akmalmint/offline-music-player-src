import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/theme_provider.dart';

class MiniPlayer extends StatefulWidget {
  final VoidCallback? onTap;

  const MiniPlayer({
    super.key,
    this.onTap,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with TickerProviderStateMixin {
  late AnimationController _playPauseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _playPauseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<MusicProvider, ThemeProvider>(
      builder: (context, musicProvider, themeProvider, child) {
        final currentSong = musicProvider.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        // Update play/pause animation
        if (musicProvider.isPlaying) {
          _playPauseController.forward();
        } else {
          _playPauseController.reverse();
        }

        return Container(
          height: 72,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.getMiniPlayerGradient(context),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  // Progress bar
                  Container(
                    height: 2,
                    child: LinearProgressIndicator(
                      value: musicProvider.progress,
                      backgroundColor: colorScheme.outline.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Album art
                          _buildAlbumArt(context, currentSong),

                          const SizedBox(width: 12),

                          // Song info
                          Expanded(
                            child: _buildSongInfo(context, currentSong),
                          ),

                          const SizedBox(width: 12),

                          // Controls
                          _buildControls(context, musicProvider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(BuildContext context, song) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceVariant,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.albumArt != null
            ? Image.memory(
                // This would need proper base64 decoding
                // For now, show placeholder
                gaplessPlayback: true,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAlbumArtPlaceholder(context);
                },
              )
            : _buildAlbumArtPlaceholder(context),
      ),
    );
  }

  Widget _buildAlbumArtPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.3),
            colorScheme.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, song) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          song.title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          song.artistAlbum,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, MusicProvider musicProvider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        IconButton(
          onPressed: musicProvider.hasPrevious
              ? () => musicProvider.seekToPrevious()
              : null,
          icon: Icon(
            Icons.skip_previous_rounded,
            color: musicProvider.hasPrevious
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          iconSize: 24,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),

        // Play/Pause button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              if (musicProvider.isPlaying) {
                musicProvider.pause();
              } else {
                musicProvider.play();
              }
            },
            icon: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _playPauseController,
              color: colorScheme.onPrimary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
          ),
        ),

        // Next button
        IconButton(
          onPressed: musicProvider.hasNext
              ? () => musicProvider.seekToNext()
              : null,
          icon: Icon(
            Icons.skip_next_rounded,
            color: musicProvider.hasNext
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          iconSize: 24,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ],
    );
  }
}

// Custom progress indicator for mini player
class MiniPlayerProgressIndicator extends StatelessWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;

  const MiniPlayerProgressIndicator({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 2,
      child: CustomPaint(
        painter: _ProgressPainter(
          progress: progress,
          color: color ?? colorScheme.primary,
          backgroundColor: backgroundColor ?? colorScheme.outline.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw progress
    final progressWidth = size.width * progress.clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, progressWidth, size.height),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}

