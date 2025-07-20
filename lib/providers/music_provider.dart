import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive/hive.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/app_settings.dart';
import '../services/audio_service.dart';
import '../services/database_service.dart';

class MusicProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final DatabaseService _databaseService = DatabaseService();

  // Current state
  List<Song> _allSongs = [];
  List<Song> _currentQueue = [];
  Song? _currentSong;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.none;
  double _volume = 0.7;
  List<int> _shuffleIndices = [];
  int _shuffleIndex = 0;

  // Sleep timer
  Timer? _sleepTimer;
  Duration? _sleepTimerDuration;

  // Getters
  List<Song> get allSongs => _allSongs;
  List<Song> get currentQueue => _currentQueue;
  Song? get currentSong => _currentSong;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  double get volume => _volume;
  bool get hasPrevious => _currentIndex > 0 || (_isShuffleEnabled && _shuffleIndex > 0);
  bool get hasNext => _currentIndex < _currentQueue.length - 1 || 
                     (_isShuffleEnabled && _shuffleIndex < _shuffleIndices.length - 1);
  Duration? get sleepTimerDuration => _sleepTimerDuration;
  bool get isSleepTimerActive => _sleepTimer?.isActive ?? false;

  // Progress as percentage (0.0 to 1.0)
  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  MusicProvider() {
    _initializeAudioService();
  }

  Future<void> _initializeAudioService() async {
    await _audioService.initialize();
    
    // Listen to audio service streams
    _audioService.playbackStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading ||
                   state.processingState == ProcessingState.buffering;
      notifyListeners();
    });

    _audioService.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioService.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    _audioService.currentIndexStream.listen((index) {
      if (index != null && index != _currentIndex) {
        _updateCurrentIndex(index);
      }
    });

    // Load saved settings
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _databaseService.getSettings();
    _volume = settings.volume;
    _isShuffleEnabled = settings.isShuffleEnabled;
    _repeatMode = settings.repeatMode;
    await _audioService.setVolume(_volume);
    await _audioService.setRepeatMode(_repeatMode);
    notifyListeners();
  }

  Future<void> loadMusic() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSongs = await _databaseService.getAllSongs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading music: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playQueue(List<Song> queue, {int startIndex = 0}) async {
    if (queue.isEmpty) return;

    _currentQueue = List.from(queue);
    _currentIndex = startIndex.clamp(0, queue.length - 1);
    _currentSong = queue[_currentIndex];

    if (_isShuffleEnabled) {
      _generateShuffleIndices();
      _shuffleIndex = _shuffleIndices.indexOf(_currentIndex);
    }

    await _audioService.setQueue(queue, initialIndex: _currentIndex);
    await play();
  }

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    final playQueue = queue ?? _allSongs;
    final index = playQueue.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      await playQueue(playQueue, startIndex: index);
    }
  }

  Future<void> play() async {
    await _audioService.play();
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> stop() async {
    await _audioService.stop();
    _currentSong = null;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    notifyListeners();
  }

  Future<void> seekToNext() async {
    if (!hasNext) return;

    if (_isShuffleEnabled) {
      _shuffleIndex = (_shuffleIndex + 1).clamp(0, _shuffleIndices.length - 1);
      _currentIndex = _shuffleIndices[_shuffleIndex];
    } else {
      _currentIndex = (_currentIndex + 1).clamp(0, _currentQueue.length - 1);
    }

    await _audioService.seekToNext();
  }

  Future<void> seekToPrevious() async {
    if (!hasPrevious) return;

    if (_isShuffleEnabled) {
      _shuffleIndex = (_shuffleIndex - 1).clamp(0, _shuffleIndices.length - 1);
      _currentIndex = _shuffleIndices[_shuffleIndex];
    } else {
      _currentIndex = (_currentIndex - 1).clamp(0, _currentQueue.length - 1);
    }

    await _audioService.seekToPrevious();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    await _saveVolumeSettings();
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    
    if (_isShuffleEnabled) {
      _generateShuffleIndices();
      _shuffleIndex = _shuffleIndices.indexOf(_currentIndex);
    }

    await _saveShuffleSettings();
    notifyListeners();
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    _repeatMode = mode;
    await _audioService.setRepeatMode(mode);
    await _saveRepeatSettings();
    notifyListeners();
  }

  Future<void> toggleRepeatMode() async {
    switch (_repeatMode) {
      case RepeatMode.none:
        await setRepeatMode(RepeatMode.all);
        break;
      case RepeatMode.all:
        await setRepeatMode(RepeatMode.one);
        break;
      case RepeatMode.one:
        await setRepeatMode(RepeatMode.none);
        break;
    }
  }

  void _generateShuffleIndices() {
    _shuffleIndices = List.generate(_currentQueue.length, (index) => index);
    _shuffleIndices.shuffle(Random());
  }

  void _updateCurrentIndex(int index) {
    _currentIndex = index;
    if (index < _currentQueue.length) {
      _currentSong = _currentQueue[index];
      
      if (_isShuffleEnabled) {
        _shuffleIndex = _shuffleIndices.indexOf(index);
      }
    }
    notifyListeners();
  }

  // Sleep timer functionality
  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimerDuration = duration;
    
    _sleepTimer = Timer(duration, () {
      pause();
      _sleepTimerDuration = null;
      notifyListeners();
    });
    
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDuration = null;
    notifyListeners();
  }

  Duration? getRemainingTimerDuration() {
    if (_sleepTimer == null || !_sleepTimer!.isActive) return null;
    
    // This is an approximation since Timer doesn't provide remaining time
    return _sleepTimerDuration;
  }

  // Favorites management
  Future<void> toggleFavorite(Song song) async {
    final updatedSong = song.copyWith(isFavorite: !song.isFavorite);
    await _databaseService.updateSong(updatedSong);
    
    // Update in current lists
    final allIndex = _allSongs.indexWhere((s) => s.id == song.id);
    if (allIndex != -1) {
      _allSongs[allIndex] = updatedSong;
    }
    
    final queueIndex = _currentQueue.indexWhere((s) => s.id == song.id);
    if (queueIndex != -1) {
      _currentQueue[queueIndex] = updatedSong;
    }
    
    if (_currentSong?.id == song.id) {
      _currentSong = updatedSong;
    }
    
    notifyListeners();
  }

  Future<List<Song>> getFavorites() async {
    return _allSongs.where((song) => song.isFavorite).toList();
  }

  // Settings persistence
  Future<void> _saveVolumeSettings() async {
    final settings = await _databaseService.getSettings();
    final updatedSettings = settings.copyWith(volume: _volume);
    await _databaseService.saveSettings(updatedSettings);
  }

  Future<void> _saveShuffleSettings() async {
    final settings = await _databaseService.getSettings();
    final updatedSettings = settings.copyWith(isShuffleEnabled: _isShuffleEnabled);
    await _databaseService.saveSettings(updatedSettings);
  }

  Future<void> _saveRepeatSettings() async {
    final settings = await _databaseService.getSettings();
    final updatedSettings = settings.copyWith(repeatMode: _repeatMode);
    await _databaseService.saveSettings(updatedSettings);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

