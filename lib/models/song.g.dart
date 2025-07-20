// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      id: fields[0] as int,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String,
      albumArt: fields[4] as String?,
      uri: fields[5] as String,
      duration: fields[6] as int,
      genre: fields[7] as String?,
      year: fields[8] as int?,
      track: fields[9] as int?,
      displayName: fields[10] as String,
      composer: fields[11] as String?,
      size: fields[12] as int,
      dateAdded: fields[13] as int,
      dateModified: fields[14] as int,
      isFavorite: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.albumArt)
      ..writeByte(5)
      ..write(obj.uri)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.genre)
      ..writeByte(8)
      ..write(obj.year)
      ..writeByte(9)
      ..write(obj.track)
      ..writeByte(10)
      ..write(obj.displayName)
      ..writeByte(11)
      ..write(obj.composer)
      ..writeByte(12)
      ..write(obj.size)
      ..writeByte(13)
      ..write(obj.dateAdded)
      ..writeByte(14)
      ..write(obj.dateModified)
      ..writeByte(15)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

