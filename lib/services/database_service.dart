import 'package:hive_flutter/hive_flutter.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/app_settings.dart';

class DatabaseService {
  static const String _songsBoxName = 'songs';
  static const String _playlistsBoxName = 'playlists';
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';

  static Box<Song>? _songsBox;
  static Box<Playlist>? _playlistsBox;
  static Box<AppSettings>? _settingsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SongAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PlaylistAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ThemeModeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RepeatModeAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    // Open boxes
    _songsBox = await Hive.openBox<Song>(_songsBoxName);
    _playlistsBox = await Hive.openBox<Playlist>(_playlistsBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
  }

  static Future<void> close() async {
    await _songsBox?.close();
    await _playlistsBox?.close();
    await _settingsBox?.close();
  }

  // Songs operations
  Future<List<Song>> getAllSongs() async {
    final box = _songsBox;
    if (box == null) throw Exception('Songs box not initialized');
    
    return box.values.toList();
  }

  Future<Song?> getSongById(int id) async {
    final box = _songsBox;
    if (box == null) throw Exception('Songs box not initialized');
    
    return box.values.firstWhere(
      (song) => song.id == id,
      orElse: () => throw Exception('Song not found'),
    );
  }

  Future<List<Song>> getSongsByIds(List<int> ids) async {
    final box = _songsBox;
    if (box == null) throw Exception('Songs box not initialized');
    
    final songs = <Song>[];
    for (final id in ids) {
      try {
        final song = box.values.firstWhere((song) => song.id == id);
        songs.add(song);
      } catch (e) {
        // Song not found, skip it
        continue;
      }
    }
    return songs;
  }

  Future<void> saveSong(Song song) async {
    final box = _songsBox;
    if (box == null) throw Exception('Songs box not initialized');
    
    await box.put(song.id, song);
  }

  Future<void> saveSongs(List<Song> songs) async {
    final box = _songsBox;
    if (box == null) throw Exception('Songs box not initialized');
    
    final Map<dynamic, Song> songMap = {};
    for (final song in songs) {
      songMap[song.id] = song;
    }
    await box.putAll(songMap);
  }

  Future<void> updateSong(Song song) async {
    await saveSong(song);
  }

  Future<void> deleteSong(int id) async {
    final box = _songsBox;
    if (box == null) throw Exception('Songs box not initialized');
    
    await box.delete(id);
  }

  Future<void> clearAllSongs() async {
    final box = _songsBox;
    if (box == null) throw Exception('Songs box not initialized');
    
    await box.clear();
  }

  Future<List<Song>> searchSongs(String query) async {
    final songs = await getAllSongs();
    if (query.isEmpty) return songs;
    
    final lowercaseQuery = query.toLowerCase();
    return songs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
             song.artist.toLowerCase().contains(lowercaseQuery) ||
             song.album.toLowerCase().contains(lowercaseQuery) ||
             (song.genre?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<List<Song>> getSongsByArtist(String artist) async {
    final songs = await getAllSongs();
    return songs.where((song) => song.artist == artist).toList();
  }

  Future<List<Song>> getSongsByAlbum(String album) async {
    final songs = await getAllSongs();
    return songs.where((song) => song.album == album).toList();
  }

  Future<List<Song>> getSongsByGenre(String genre) async {
    final songs = await getAllSongs();
    return songs.where((song) => song.genre == genre).toList();
  }

  Future<List<String>> getAllArtists() async {
    final songs = await getAllSongs();
    final artists = songs.map((song) => song.artist).toSet().toList();
    artists.sort();
    return artists;
  }

  Future<List<String>> getAllAlbums() async {
    final songs = await getAllSongs();
    final albums = songs.map((song) => song.album).toSet().toList();
    albums.sort();
    return albums;
  }

  Future<List<String>> getAllGenres() async {
    final songs = await getAllSongs();
    final genres = songs
        .where((song) => song.genre != null && song.genre!.isNotEmpty)
        .map((song) => song.genre!)
        .toSet()
        .toList();
    genres.sort();
    return genres;
  }

  // Playlists operations
  Future<List<Playlist>> getAllPlaylists() async {
    final box = _playlistsBox;
    if (box == null) throw Exception('Playlists box not initialized');
    
    return box.values.toList();
  }

  Future<Playlist?> getPlaylistById(String id) async {
    final box = _playlistsBox;
    if (box == null) throw Exception('Playlists box not initialized');
    
    return box.get(id);
  }

  Future<void> savePlaylist(Playlist playlist) async {
    final box = _playlistsBox;
    if (box == null) throw Exception('Playlists box not initialized');
    
    await box.put(playlist.id, playlist);
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await savePlaylist(playlist);
  }

  Future<void> deletePlaylist(String id) async {
    final box = _playlistsBox;
    if (box == null) throw Exception('Playlists box not initialized');
    
    await box.delete(id);
  }

  Future<void> clearAllPlaylists() async {
    final box = _playlistsBox;
    if (box == null) throw Exception('Playlists box not initialized');
    
    await box.clear();
  }

  Future<List<Playlist>> getUserPlaylists() async {
    final playlists = await getAllPlaylists();
    return playlists.where((playlist) => !playlist.isSystemPlaylist).toList();
  }

  Future<List<Playlist>> getSystemPlaylists() async {
    final playlists = await getAllPlaylists();
    return playlists.where((playlist) => playlist.isSystemPlaylist).toList();
  }

  // Settings operations
  Future<AppSettings> getSettings() async {
    final box = _settingsBox;
    if (box == null) throw Exception('Settings box not initialized');
    
    return box.get(_settingsKey) ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final box = _settingsBox;
    if (box == null) throw Exception('Settings box not initialized');
    
    await box.put(_settingsKey, settings);
  }

  Future<void> resetSettings() async {
    final box = _settingsBox;
    if (box == null) throw Exception('Settings box not initialized');
    
    await box.put(_settingsKey, AppSettings());
  }

  // Database maintenance
  Future<void> compactDatabase() async {
    await _songsBox?.compact();
    await _playlistsBox?.compact();
    await _settingsBox?.compact();
  }

  Future<int> getDatabaseSize() async {
    int size = 0;
    
    if (_songsBox != null) {
      size += _songsBox!.length;
    }
    if (_playlistsBox != null) {
      size += _playlistsBox!.length;
    }
    if (_settingsBox != null) {
      size += _settingsBox!.length;
    }
    
    return size;
  }

  Future<Map<String, int>> getDatabaseStats() async {
    return {
      'songs': _songsBox?.length ?? 0,
      'playlists': _playlistsBox?.length ?? 0,
      'settings': _settingsBox?.length ?? 0,
    };
  }

  // Backup and restore
  Future<Map<String, dynamic>> exportData() async {
    final songs = await getAllSongs();
    final playlists = await getAllPlaylists();
    final settings = await getSettings();

    return {
      'songs': songs.map((song) => song.toString()).toList(),
      'playlists': playlists.map((playlist) => playlist.toString()).toList(),
      'settings': settings.toString(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // This would need proper implementation based on the export format
    // For now, just a placeholder
    throw UnimplementedError('Import functionality not yet implemented');
  }

  Future<void> clearAllData() async {
    await clearAllSongs();
    await clearAllPlaylists();
    await resetSettings();
  }
}

