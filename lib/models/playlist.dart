import 'package:hive/hive.dart';
import 'song.dart';

part 'playlist.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<int> songIds;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  String? coverArt;

  @HiveField(7)
  bool isSystemPlaylist;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    List<int>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.coverArt,
    this.isSystemPlaylist = false,
  })  : songIds = songIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get songCount => songIds.length;

  String get formattedSongCount {
    if (songCount == 1) {
      return '1 song';
    }
    return '$songCount songs';
  }

  void addSong(Song song) {
    if (!songIds.contains(song.id)) {
      songIds.add(song.id);
      updatedAt = DateTime.now();
      save();
    }
  }

  void removeSong(Song song) {
    if (songIds.contains(song.id)) {
      songIds.remove(song.id);
      updatedAt = DateTime.now();
      save();
    }
  }

  void addSongs(List<Song> songs) {
    bool changed = false;
    for (final song in songs) {
      if (!songIds.contains(song.id)) {
        songIds.add(song.id);
        changed = true;
      }
    }
    if (changed) {
      updatedAt = DateTime.now();
      save();
    }
  }

  void removeSongs(List<Song> songs) {
    bool changed = false;
    for (final song in songs) {
      if (songIds.contains(song.id)) {
        songIds.remove(song.id);
        changed = true;
      }
    }
    if (changed) {
      updatedAt = DateTime.now();
      save();
    }
  }

  void reorderSongs(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final songId = songIds.removeAt(oldIndex);
    songIds.insert(newIndex, songId);
    updatedAt = DateTime.now();
    save();
  }

  void clearSongs() {
    if (songIds.isNotEmpty) {
      songIds.clear();
      updatedAt = DateTime.now();
      save();
    }
  }

  bool containsSong(Song song) {
    return songIds.contains(song.id);
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    List<int>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverArt,
    bool? isSystemPlaylist,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songIds: songIds ?? List<int>.from(this.songIds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverArt: coverArt ?? this.coverArt,
      isSystemPlaylist: isSystemPlaylist ?? this.isSystemPlaylist,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, songCount: $songCount)';
  }

  // Predefined system playlists
  static Playlist get favorites => Playlist(
        id: 'favorites',
        name: 'Favorites',
        description: 'Your favorite songs',
        isSystemPlaylist: true,
      );

  static Playlist get recentlyPlayed => Playlist(
        id: 'recently_played',
        name: 'Recently Played',
        description: 'Songs you\'ve played recently',
        isSystemPlaylist: true,
      );

  static Playlist get mostPlayed => Playlist(
        id: 'most_played',
        name: 'Most Played',
        description: 'Your most played songs',
        isSystemPlaylist: true,
      );
}

