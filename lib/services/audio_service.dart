import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/song.dart';
import '../models/app_settings.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late AudioPlayer _audioPlayer;
  late AudioSession _audioSession;
  ConcatenatingAudioSource? _playlist;
  
  bool _isInitialized = false;
  List<Song> _currentQueue = [];
  int _currentIndex = 0;

  // Getters for streams
  Stream<PlayerState> get playbackStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
  Stream<SequenceState?> get sequenceStateStream => _audioPlayer.sequenceStateStream;

  // Current state getters
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  int? get currentIndex => _audioPlayer.currentIndex;
  PlayerState get playerState => _audioPlayer.playerState;
  ProcessingState get processingState => _audioPlayer.processingState;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _audioPlayer = AudioPlayer();
    _audioSession = await AudioSession.instance;

    // Configure audio session
    await _audioSession.configure(const AudioSessionConfiguration.music());

    // Handle audio interruptions
    _audioSession.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _audioPlayer.setVolume(0.5);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _audioPlayer.pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _audioPlayer.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            _audioPlayer.play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    // Handle becoming noisy (headphones unplugged)
    _audioSession.becomingNoisyEventStream.listen((_) {
      _audioPlayer.pause();
    });

    _isInitialized = true;
  }

  Future<void> setQueue(List<Song> songs, {int initialIndex = 0}) async {
    if (!_isInitialized) await initialize();

    _currentQueue = List.from(songs);
    _currentIndex = initialIndex.clamp(0, songs.length - 1);

    // Create audio sources from songs
    final audioSources = songs.map((song) {
      return AudioSource.uri(
        Uri.parse(song.uri),
        tag: MediaItem(
          id: song.id.toString(),
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: Duration(milliseconds: song.duration),
          artUri: song.albumArt != null ? Uri.parse(song.albumArt!) : null,
        ),
      );
    }).toList();

    _playlist = ConcatenatingAudioSource(children: audioSources);
    
    await _audioPlayer.setAudioSource(
      _playlist!,
      initialIndex: _currentIndex,
      initialPosition: Duration.zero,
    );
  }

  Future<void> play() async {
    if (!_isInitialized) return;
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    if (!_isInitialized) return;
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    if (!_isInitialized) return;
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    if (!_isInitialized) return;
    await _audioPlayer.seek(position);
  }

  Future<void> seekToNext() async {
    if (!_isInitialized || !hasNext) return;
    await _audioPlayer.seekToNext();
  }

  Future<void> seekToPrevious() async {
    if (!_isInitialized || !hasPrevious) return;
    await _audioPlayer.seekToPrevious();
  }

  Future<void> seekToIndex(int index) async {
    if (!_isInitialized || index < 0 || index >= _currentQueue.length) return;
    await _audioPlayer.seek(Duration.zero, index: index);
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSpeed(double speed) async {
    if (!_isInitialized) return;
    await _audioPlayer.setSpeed(speed.clamp(0.25, 3.0));
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    if (!_isInitialized) return;
    
    switch (mode) {
      case RepeatMode.none:
        await _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.one:
        await _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
        await _audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  Future<void> setShuffleMode(bool enabled) async {
    if (!_isInitialized) return;
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  bool get hasNext {
    if (!_isInitialized) return false;
    return _audioPlayer.hasNext;
  }

  bool get hasPrevious {
    if (!_isInitialized) return false;
    return _audioPlayer.hasPrevious;
  }

  Song? get currentSong {
    if (_currentIndex < 0 || _currentIndex >= _currentQueue.length) return null;
    return _currentQueue[_currentIndex];
  }

  List<Song> get queue => List.unmodifiable(_currentQueue);

  // Add song to queue
  Future<void> addToQueue(Song song) async {
    if (!_isInitialized || _playlist == null) return;

    _currentQueue.add(song);
    
    final audioSource = AudioSource.uri(
      Uri.parse(song.uri),
      tag: MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: Duration(milliseconds: song.duration),
        artUri: song.albumArt != null ? Uri.parse(song.albumArt!) : null,
      ),
    );

    await _playlist!.add(audioSource);
  }

  // Insert song at specific position in queue
  Future<void> insertInQueue(int index, Song song) async {
    if (!_isInitialized || _playlist == null) return;
    if (index < 0 || index > _currentQueue.length) return;

    _currentQueue.insert(index, song);
    
    final audioSource = AudioSource.uri(
      Uri.parse(song.uri),
      tag: MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: Duration(milliseconds: song.duration),
        artUri: song.albumArt != null ? Uri.parse(song.albumArt!) : null,
      ),
    );

    await _playlist!.insert(index, audioSource);
  }

  // Remove song from queue
  Future<void> removeFromQueue(int index) async {
    if (!_isInitialized || _playlist == null) return;
    if (index < 0 || index >= _currentQueue.length) return;

    _currentQueue.removeAt(index);
    await _playlist!.removeAt(index);
  }

  // Move song in queue
  Future<void> moveInQueue(int oldIndex, int newIndex) async {
    if (!_isInitialized || _playlist == null) return;
    if (oldIndex < 0 || oldIndex >= _currentQueue.length) return;
    if (newIndex < 0 || newIndex >= _currentQueue.length) return;

    final song = _currentQueue.removeAt(oldIndex);
    _currentQueue.insert(newIndex, song);
    await _playlist!.move(oldIndex, newIndex);
  }

  // Clear queue
  Future<void> clearQueue() async {
    if (!_isInitialized || _playlist == null) return;
    
    _currentQueue.clear();
    await _playlist!.clear();
  }

  // Get queue length
  int get queueLength => _currentQueue.length;

  // Check if queue is empty
  bool get isQueueEmpty => _currentQueue.isEmpty;

  // Audio effects (if supported by the platform)
  Future<void> setEqualizer(List<double> bands) async {
    // This would require platform-specific implementation
    // For now, just a placeholder
  }

  Future<void> setBassBoost(double strength) async {
    // This would require platform-specific implementation
    // For now, just a placeholder
  }

  Future<void> setVirtualizer(double strength) async {
    // This would require platform-specific implementation
    // For now, just a placeholder
  }

  // Crossfade functionality
  Future<void> setCrossfade(bool enabled, {Duration duration = const Duration(seconds: 3)}) async {
    // This would require custom implementation with multiple audio players
    // For now, just a placeholder
  }

  // Get current media item
  MediaItem? get currentMediaItem {
    final sequenceState = _audioPlayer.sequenceState;
    return sequenceState?.currentSource?.tag as MediaItem?;
  }

  // Error handling
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  void dispose() {
    _audioPlayer.dispose();
    _isInitialized = false;
  }
}

// Media item class for metadata
class MediaItem {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final Uri? artUri;

  const MediaItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.artUri,
  });

  @override
  String toString() {
    return 'MediaItem(id: $id, title: $title, artist: $artist, album: $album)';
  }
}

