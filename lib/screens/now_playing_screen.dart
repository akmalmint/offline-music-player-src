import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_settings.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  late AnimationController _albumArtController;
  late AnimationController _playPauseController;
  late Animation<double> _albumArtAnimation;

  bool _isDraggingSlider = false;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _albumArtController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _playPauseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _albumArtAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_albumArtController);

    // Start rotation animation
    _albumArtController.repeat();
  }

  @override
  void dispose() {
    _albumArtController.dispose();
    _playPauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<MusicProvider, ThemeProvider>(
      builder: (context, musicProvider, themeProvider, child) {
        final currentSong = musicProvider.currentSong;
        
        // Update play/pause animation
        if (musicProvider.isPlaying) {
          _playPauseController.forward();
          if (!_albumArtController.isAnimating) {
            _albumArtController.repeat();
          }
        } else {
          _playPauseController.reverse();
          _albumArtController.stop();
        }

        return Scaffold(
          backgroundColor: colorScheme.background,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: themeProvider.getNowPlayingGradient(context),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  _buildAppBar(context),

                  // Main Content
                  Expanded(
                    child: currentSong != null
                        ? _buildNowPlayingContent(context, currentSong, musicProvider)
                        : _buildNoSongContent(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurface,
              size: 32,
            ),
          ),
          Expanded(
            child: Text(
              'Now Playing',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => _showOptionsMenu(context),
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingContent(BuildContext context, song, MusicProvider musicProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Album Art
          Expanded(
            flex: 3,
            child: _buildAlbumArt(context, song, musicProvider.isPlaying),
          ),

          const SizedBox(height: 32),

          // Song Info
          _buildSongInfo(context, song),

          const SizedBox(height: 32),

          // Progress Bar
          _buildProgressBar(context, musicProvider),

          const SizedBox(height: 24),

          // Controls
          _buildControls(context, musicProvider),

          const SizedBox(height: 32),

          // Volume Control
          _buildVolumeControl(context, musicProvider),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, song, bool isPlaying) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _albumArtAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _albumArtAnimation.value * 2 * 3.14159,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceVariant,
                ),
                child: ClipOval(
                  child: song.albumArt != null
                      ? Image.memory(
                          // This would need proper base64 decoding
                          gaplessPlayback: true,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAlbumArtPlaceholder(context);
                          },
                        )
                      : _buildAlbumArtPlaceholder(context),
                ),
              ),
            );
          },
        ),
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
        size: 120,
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, song) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          song.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          song.artistAlbum,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, MusicProvider musicProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: _isDraggingSlider
                ? _sliderValue
                : musicProvider.progress.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() {
                _isDraggingSlider = true;
                _sliderValue = value;
              });
            },
            onChangeEnd: (value) {
              final duration = musicProvider.totalDuration;
              final position = Duration(
                milliseconds: (duration.inMilliseconds * value).round(),
              );
              musicProvider.seek(position);
              setState(() {
                _isDraggingSlider = false;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(musicProvider.currentPosition),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatDuration(musicProvider.totalDuration),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, MusicProvider musicProvider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          onPressed: () => musicProvider.toggleShuffle(),
          icon: Icon(
            Icons.shuffle_rounded,
            color: musicProvider.isShuffleEnabled
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          iconSize: 28,
        ),

        // Previous
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
          iconSize: 36,
        ),

        // Play/Pause
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
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
              size: 32,
            ),
          ),
        ),

        // Next
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
          iconSize: 36,
        ),

        // Repeat
        IconButton(
          onPressed: () => musicProvider.toggleRepeatMode(),
          icon: Icon(
            musicProvider.repeatMode == RepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: musicProvider.repeatMode != RepeatMode.none
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          iconSize: 28,
        ),
      ],
    );
  }

  Widget _buildVolumeControl(BuildContext context, MusicProvider musicProvider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.volume_down_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: musicProvider.volume,
              onChanged: (value) => musicProvider.setVolume(value),
            ),
          ),
        ),
        Icon(
          Icons.volume_up_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildNoSongContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off_rounded,
            size: 80,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No song playing',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a song to start playing',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Add to Favorites'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

