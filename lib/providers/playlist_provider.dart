import 'package:flutter/foundation.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/database_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Playlist> _playlists = [];
  bool _isLoading = false;

  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;

  List<Playlist> get userPlaylists => 
      _playlists.where((playlist) => !playlist.isSystemPlaylist).toList();

  List<Playlist> get systemPlaylists => 
      _playlists.where((playlist) => playlist.isSystemPlaylist).toList();

  PlaylistProvider() {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    _isLoading = true;
    notifyListeners();

    try {
      _playlists = await _databaseService.getAllPlaylists();
      
      // Ensure system playlists exist
      await _ensureSystemPlaylistsExist();
    } catch (e) {
      debugPrint('Error loading playlists: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureSystemPlaylistsExist() async {
    final systemPlaylistIds = ['favorites', 'recently_played', 'most_played'];
    
    for (final id in systemPlaylistIds) {
      if (!_playlists.any((p) => p.id == id)) {
        Playlist systemPlaylist;
        switch (id) {
          case 'favorites':
            systemPlaylist = Playlist.favorites;
            break;
          case 'recently_played':
            systemPlaylist = Playlist.recentlyPlayed;
            break;
          case 'most_played':
            systemPlaylist = Playlist.mostPlayed;
            break;
          default:
            continue;
        }
        
        await _databaseService.savePlaylist(systemPlaylist);
        _playlists.add(systemPlaylist);
      }
    }
  }

  Future<Playlist> createPlaylist(String name, {String? description}) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
    );

    await _databaseService.savePlaylist(playlist);
    _playlists.add(playlist);
    notifyListeners();

    return playlist;
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await _databaseService.savePlaylist(playlist);
    
    final index = _playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      _playlists[index] = playlist;
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    // Don't allow deletion of system playlists
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    if (playlist.isSystemPlaylist) return;

    await _databaseService.deletePlaylist(playlistId);
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.addSong(song);
    await _databaseService.savePlaylist(playlist);
    notifyListeners();
  }

  Future<void> removeSongFromPlaylist(String playlistId, Song song) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.removeSong(song);
    await _databaseService.savePlaylist(playlist);
    notifyListeners();
  }

  Future<void> addSongsToPlaylist(String playlistId, List<Song> songs) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.addSongs(songs);
    await _databaseService.savePlaylist(playlist);
    notifyListeners();
  }

  Future<void> removeSongsFromPlaylist(String playlistId, List<Song> songs) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.removeSongs(songs);
    await _databaseService.savePlaylist(playlist);
    notifyListeners();
  }

  Future<void> reorderSongsInPlaylist(String playlistId, int oldIndex, int newIndex) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.reorderSongs(oldIndex, newIndex);
    await _databaseService.savePlaylist(playlist);
    notifyListeners();
  }

  Future<void> clearPlaylist(String playlistId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.clearSongs();
    await _databaseService.savePlaylist(playlist);
    notifyListeners();
  }

  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    return await _databaseService.getSongsByIds(playlist.songIds);
  }

  Future<void> addToFavorites(Song song) async {
    await addSongToPlaylist('favorites', song);
    
    // Also update the song's favorite status
    final updatedSong = song.copyWith(isFavorite: true);
    await _databaseService.updateSong(updatedSong);
  }

  Future<void> removeFromFavorites(Song song) async {
    await removeSongFromPlaylist('favorites', song);
    
    // Also update the song's favorite status
    final updatedSong = song.copyWith(isFavorite: false);
    await _databaseService.updateSong(updatedSong);
  }

  Future<void> addToRecentlyPlayed(Song song) async {
    final recentlyPlayedPlaylist = _playlists.firstWhere((p) => p.id == 'recently_played');
    
    // Remove if already exists to avoid duplicates
    if (recentlyPlayedPlaylist.containsSong(song)) {
      recentlyPlayedPlaylist.removeSong(song);
    }
    
    // Add to the beginning
    recentlyPlayedPlaylist.songIds.insert(0, song.id);
    
    // Keep only the last 50 songs
    if (recentlyPlayedPlaylist.songIds.length > 50) {
      recentlyPlayedPlaylist.songIds = recentlyPlayedPlaylist.songIds.take(50).toList();
    }
    
    recentlyPlayedPlaylist.updatedAt = DateTime.now();
    await _databaseService.savePlaylist(recentlyPlayedPlaylist);
    notifyListeners();
  }

  Future<void> updateMostPlayed(Song song) async {
    // This would typically involve tracking play counts
    // For now, we'll just add to most played if not already there
    final mostPlayedPlaylist = _playlists.firstWhere((p) => p.id == 'most_played');
    
    if (!mostPlayedPlaylist.containsSong(song)) {
      mostPlayedPlaylist.addSong(song);
      await _databaseService.savePlaylist(mostPlayedPlaylist);
      notifyListeners();
    }
  }

  Playlist? getPlaylistById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isSongInPlaylist(String playlistId, Song song) {
    final playlist = getPlaylistById(playlistId);
    return playlist?.containsSong(song) ?? false;
  }

  Future<void> duplicatePlaylist(String playlistId, String newName) async {
    final originalPlaylist = _playlists.firstWhere((p) => p.id == playlistId);
    
    final duplicatedPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      description: '${originalPlaylist.description ?? ''} (Copy)',
      songIds: List<int>.from(originalPlaylist.songIds),
    );

    await _databaseService.savePlaylist(duplicatedPlaylist);
    _playlists.add(duplicatedPlaylist);
    notifyListeners();
  }

  Future<void> exportPlaylist(String playlistId) async {
    // This would export playlist to a file format like M3U
    // Implementation depends on requirements
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    debugPrint('Exporting playlist: ${playlist.name}');
  }

  Future<void> importPlaylist(String filePath) async {
    // This would import playlist from a file format like M3U
    // Implementation depends on requirements
    debugPrint('Importing playlist from: $filePath');
  }

  List<Playlist> searchPlaylists(String query) {
    if (query.isEmpty) return _playlists;
    
    final lowercaseQuery = query.toLowerCase();
    return _playlists.where((playlist) {
      return playlist.name.toLowerCase().contains(lowercaseQuery) ||
             (playlist.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<void> refreshPlaylists() async {
    await loadPlaylists();
  }
}

