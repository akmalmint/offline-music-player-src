import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import '../services/database_service.dart';

class MusicScannerService {
  static final MusicScannerService _instance = MusicScannerService._internal();
  factory MusicScannerService() => _instance;
  MusicScannerService._internal();

  final OnAudioQuery _audioQuery = OnAudioQuery();
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isScanning = false;
  int _totalSongs = 0;
  int _scannedSongs = 0;
  
  final StreamController<ScanProgress> _scanProgressController = 
      StreamController<ScanProgress>.broadcast();
  
  Stream<ScanProgress> get scanProgressStream => _scanProgressController.stream;
  
  bool get isScanning => _isScanning;
  double get scanProgress => _totalSongs > 0 ? _scannedSongs / _totalSongs : 0.0;

  Future<bool> requestPermissions() async {
    try {
      // Check Android version and request appropriate permissions
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        
        if (androidInfo >= 33) {
          // Android 13+ - Request READ_MEDIA_AUDIO
          final status = await Permission.audio.request();
          return status.isGranted;
        } else {
          // Android 12 and below - Request READ_EXTERNAL_STORAGE
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      }
      
      return true; // For other platforms
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  Future<int> _getAndroidVersion() async {
    // This is a simplified version - in a real app you'd use device_info_plus
    return 33; // Assume Android 13+ for this example
  }

  Future<bool> checkPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        
        if (androidInfo >= 33) {
          return await Permission.audio.isGranted;
        } else {
          return await Permission.storage.isGranted;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  Future<List<Song>> scanForMusic({
    List<String>? excludedFolders,
    bool saveToDatabase = true,
  }) async {
    if (_isScanning) {
      throw Exception('Scan already in progress');
    }

    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      throw Exception('Storage permission not granted');
    }

    _isScanning = true;
    _scannedSongs = 0;
    _totalSongs = 0;

    try {
      _scanProgressController.add(ScanProgress(
        isScanning: true,
        totalSongs: 0,
        scannedSongs: 0,
        currentSong: 'Initializing scan...',
      ));

      // Get all audio files
      final List<SongModel> audioFiles = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _totalSongs = audioFiles.length;
      
      _scanProgressController.add(ScanProgress(
        isScanning: true,
        totalSongs: _totalSongs,
        scannedSongs: 0,
        currentSong: 'Found $_totalSongs audio files',
      ));

      final List<Song> songs = [];
      
      for (int i = 0; i < audioFiles.length; i++) {
        final audioFile = audioFiles[i];
        
        try {
          // Skip files in excluded folders
          if (excludedFolders != null && _isInExcludedFolder(audioFile.data, excludedFolders)) {
            _scannedSongs++;
            continue;
          }

          // Convert SongModel to our Song model
          final song = await _convertToSong(audioFile);
          if (song != null) {
            songs.add(song);
          }

          _scannedSongs++;
          
          // Update progress every 10 songs or on last song
          if (_scannedSongs % 10 == 0 || _scannedSongs == _totalSongs) {
            _scanProgressController.add(ScanProgress(
              isScanning: true,
              totalSongs: _totalSongs,
              scannedSongs: _scannedSongs,
              currentSong: song?.title ?? 'Processing...',
            ));
          }
        } catch (e) {
          debugPrint('Error processing song ${audioFile.title}: $e');
          _scannedSongs++;
        }
      }

      // Save to database if requested
      if (saveToDatabase && songs.isNotEmpty) {
        _scanProgressController.add(ScanProgress(
          isScanning: true,
          totalSongs: _totalSongs,
          scannedSongs: _scannedSongs,
          currentSong: 'Saving to database...',
        ));

        await _databaseService.saveSongs(songs);
      }

      _scanProgressController.add(ScanProgress(
        isScanning: false,
        totalSongs: _totalSongs,
        scannedSongs: _scannedSongs,
        currentSong: 'Scan completed',
      ));

      return songs;
    } catch (e) {
      _scanProgressController.add(ScanProgress(
        isScanning: false,
        totalSongs: _totalSongs,
        scannedSongs: _scannedSongs,
        currentSong: 'Scan failed: $e',
        error: e.toString(),
      ));
      rethrow;
    } finally {
      _isScanning = false;
    }
  }

  bool _isInExcludedFolder(String filePath, List<String> excludedFolders) {
    for (final excludedFolder in excludedFolders) {
      if (filePath.startsWith(excludedFolder)) {
        return true;
      }
    }
    return false;
  }

  Future<Song?> _convertToSong(SongModel songModel) async {
    try {
      // Get album art
      String? albumArt;
      try {
        final artworkData = await _audioQuery.queryArtwork(
          songModel.id,
          ArtworkType.AUDIO,
          format: ArtworkFormat.JPEG,
          size: 512,
        );
        if (artworkData != null && artworkData.isNotEmpty) {
          // Convert to base64 or save to file and get path
          albumArt = 'data:image/jpeg;base64,${base64Encode(artworkData)}';
        }
      } catch (e) {
        // Album art not available
        albumArt = null;
      }

      return Song(
        id: songModel.id,
        title: songModel.title.isNotEmpty ? songModel.title : 'Unknown Title',
        artist: songModel.artist ?? 'Unknown Artist',
        album: songModel.album ?? 'Unknown Album',
        albumArt: albumArt,
        uri: songModel.uri ?? songModel.data,
        duration: songModel.duration ?? 0,
        genre: songModel.genre,
        year: songModel.year,
        track: songModel.track,
        displayName: songModel.displayNameWOExt.isNotEmpty 
            ? songModel.displayNameWOExt 
            : songModel.title,
        composer: songModel.composer,
        size: songModel.size,
        dateAdded: songModel.dateAdded ?? DateTime.now().millisecondsSinceEpoch,
        dateModified: songModel.dateModified ?? DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error converting song ${songModel.title}: $e');
      return null;
    }
  }

  Future<List<String>> getAudioFolders() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return [];

      final songs = await _audioQuery.querySongs();
      final folders = <String>{};

      for (final song in songs) {
        final file = File(song.data);
        final folder = file.parent.path;
        folders.add(folder);
      }

      return folders.toList()..sort();
    } catch (e) {
      debugPrint('Error getting audio folders: $e');
      return [];
    }
  }

  Future<List<String>> getAllArtists() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return [];

      final artists = await _audioQuery.queryArtists();
      return artists.map((artist) => artist.artist).toList();
    } catch (e) {
      debugPrint('Error getting artists: $e');
      return [];
    }
  }

  Future<List<String>> getAllAlbums() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return [];

      final albums = await _audioQuery.queryAlbums();
      return albums.map((album) => album.album).toList();
    } catch (e) {
      debugPrint('Error getting albums: $e');
      return [];
    }
  }

  Future<List<String>> getAllGenres() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return [];

      final genres = await _audioQuery.queryGenres();
      return genres.map((genre) => genre.genre).toList();
    } catch (e) {
      debugPrint('Error getting genres: $e');
      return [];
    }
  }

  Future<int> getAudioFileCount() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return 0;

      final songs = await _audioQuery.querySongs();
      return songs.length;
    } catch (e) {
      debugPrint('Error getting audio file count: $e');
      return 0;
    }
  }

  Future<void> refreshMediaStore() async {
    try {
      // This would trigger a media store refresh on Android
      // Implementation depends on platform-specific code
      debugPrint('Refreshing media store...');
    } catch (e) {
      debugPrint('Error refreshing media store: $e');
    }
  }

  void dispose() {
    _scanProgressController.close();
  }
}

class ScanProgress {
  final bool isScanning;
  final int totalSongs;
  final int scannedSongs;
  final String currentSong;
  final String? error;

  ScanProgress({
    required this.isScanning,
    required this.totalSongs,
    required this.scannedSongs,
    required this.currentSong,
    this.error,
  });

  double get progress => totalSongs > 0 ? scannedSongs / totalSongs : 0.0;
  
  @override
  String toString() {
    return 'ScanProgress(isScanning: $isScanning, progress: ${(progress * 100).toStringAsFixed(1)}%, currentSong: $currentSong)';
  }
}

// Helper function to encode bytes to base64
String base64Encode(List<int> bytes) {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  String result = '';
  
  for (int i = 0; i < bytes.length; i += 3) {
    int byte1 = bytes[i];
    int byte2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
    int byte3 = i + 2 < bytes.length ? bytes[i + 2] : 0;
    
    int combined = (byte1 << 16) | (byte2 << 8) | byte3;
    
    result += chars[(combined >> 18) & 63];
    result += chars[(combined >> 12) & 63];
    result += i + 1 < bytes.length ? chars[(combined >> 6) & 63] : '=';
    result += i + 2 < bytes.length ? chars[combined & 63] : '=';
  }
  
  return result;
}

