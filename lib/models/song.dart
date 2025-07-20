import 'package:hive/hive.dart';

part 'song.g.dart';

@HiveType(typeId: 0)
class Song extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String album;

  @HiveField(4)
  final String? albumArt;

  @HiveField(5)
  final String uri;

  @HiveField(6)
  final int duration;

  @HiveField(7)
  final String? genre;

  @HiveField(8)
  final int? year;

  @HiveField(9)
  final int? track;

  @HiveField(10)
  final String displayName;

  @HiveField(11)
  final String? composer;

  @HiveField(12)
  final int size;

  @HiveField(13)
  final int dateAdded;

  @HiveField(14)
  final int dateModified;

  @HiveField(15)
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArt,
    required this.uri,
    required this.duration,
    this.genre,
    this.year,
    this.track,
    required this.displayName,
    this.composer,
    required this.size,
    required this.dateAdded,
    required this.dateModified,
    this.isFavorite = false,
  });

  String get formattedDuration {
    final minutes = duration ~/ 60000;
    final seconds = (duration % 60000) ~/ 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get artistAlbum {
    if (artist.isNotEmpty && album.isNotEmpty) {
      return '$artist • $album';
    } else if (artist.isNotEmpty) {
      return artist;
    } else if (album.isNotEmpty) {
      return album;
    }
    return 'Unknown';
  }

  Song copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    String? uri,
    int? duration,
    String? genre,
    int? year,
    int? track,
    String? displayName,
    String? composer,
    int? size,
    int? dateAdded,
    int? dateModified,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      uri: uri ?? this.uri,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      track: track ?? this.track,
      displayName: displayName ?? this.displayName,
      composer: composer ?? this.composer,
      size: size ?? this.size,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, album: $album)';
  }
}

