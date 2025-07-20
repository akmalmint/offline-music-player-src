import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool showIndex;
  final int? index;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMoreTap,
    this.showIndex = false,
    this.index,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final isCurrentSong = musicProvider.currentSong?.id == song.id;
        final isCurrentlyPlaying = isCurrentSong && musicProvider.isPlaying;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isCurrentSong
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: _buildLeading(context, isCurrentSong, isCurrentlyPlaying),
            title: Text(
              song.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isCurrentSong
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                fontWeight: isCurrentSong ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.artistAlbum,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isCurrentSong
                        ? colorScheme.primary.withOpacity(0.8)
                        : colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (song.duration > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    song.formattedDuration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (song.isFavorite)
                  Icon(
                    Icons.favorite,
                    color: colorScheme.error,
                    size: 16,
                  ),
                if (isCurrentlyPlaying) ...[
                  const SizedBox(width: 8),
                  _buildPlayingIndicator(context),
                ],
                IconButton(
                  onPressed: onMoreTap,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  iconSize: 20,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeading(BuildContext context, bool isCurrentSong, bool isPlaying) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (showIndex && index != null) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: isCurrentSong && isPlaying
            ? _buildPlayingIndicator(context)
            : Text(
                '${index! + 1}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isCurrentSong
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
      );
    }

    return _buildAlbumArt(context, isCurrentSong);
  }

  Widget _buildAlbumArt(BuildContext context, bool isCurrentSong) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceVariant,
        border: isCurrentSong
            ? Border.all(
                color: colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: song.albumArt != null
            ? Image.memory(
                // This would need proper base64 decoding
                // For now, show placeholder
                gaplessPlayback: true,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAlbumArtPlaceholder(context, isCurrentSong);
                },
              )
            : _buildAlbumArtPlaceholder(context, isCurrentSong),
      ),
    );
  }

  Widget _buildAlbumArtPlaceholder(BuildContext context, bool isCurrentSong) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentSong
              ? [
                  colorScheme.primary.withOpacity(0.3),
                  colorScheme.secondary.withOpacity(0.3),
                ]
              : [
                  colorScheme.surfaceVariant,
                  colorScheme.surfaceVariant.withOpacity(0.7),
                ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: isCurrentSong
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
        size: 24,
      ),
    );
  }

  Widget _buildPlayingIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(
        painter: _PlayingIndicatorPainter(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _PlayingIndicatorPainter extends CustomPainter {
  final Color color;
  final Animation<double>? animation;

  _PlayingIndicatorPainter({
    required this.color,
    this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 5;
    final maxHeight = size.height;

    // Draw 3 animated bars
    for (int i = 0; i < 3; i++) {
      final x = i * barWidth * 1.5;
      final animationValue = animation?.value ?? 0.5;
      final height = maxHeight * (0.3 + 0.7 * (0.5 + 0.5 * 
          (i == 0 ? animationValue : 
           i == 1 ? (animationValue + 0.3) % 1.0 :
           (animationValue + 0.6) % 1.0)));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, maxHeight - height, barWidth, height),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlayingIndicatorPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// Animated playing indicator widget
class AnimatedPlayingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const AnimatedPlayingIndicator({
    super.key,
    required this.color,
    this.size = 16,
  });

  @override
  State<AnimatedPlayingIndicator> createState() => _AnimatedPlayingIndicatorState();
}

class _AnimatedPlayingIndicatorState extends State<AnimatedPlayingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _PlayingIndicatorPainter(
          color: widget.color,
          animation: _controller,
        ),
      ),
    );
  }
}

