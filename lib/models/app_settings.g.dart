// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 2;

  @override
  ThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    switch (obj) {
      case ThemeMode.light:
        writer.writeByte(0);
        break;
      case ThemeMode.dark:
        writer.writeByte(1);
        break;
      case ThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatModeAdapter extends TypeAdapter<RepeatMode> {
  @override
  final int typeId = 3;

  @override
  RepeatMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatMode.none;
      case 1:
        return RepeatMode.one;
      case 2:
        return RepeatMode.all;
      default:
        return RepeatMode.none;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatMode obj) {
    switch (obj) {
      case RepeatMode.none:
        writer.writeByte(0);
        break;
      case RepeatMode.one:
        writer.writeByte(1);
        break;
      case RepeatMode.all:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as ThemeMode,
      volume: fields[1] as double,
      isShuffleEnabled: fields[2] as bool,
      repeatMode: fields[3] as RepeatMode,
      showLyrics: fields[4] as bool,
      enableEqualizer: fields[5] as bool,
      equalizerSettings: (fields[6] as List?)?.cast<double>(),
      enableSleepTimer: fields[7] as bool,
      sleepTimerMinutes: fields[8] as int,
      enableCrossfade: fields[9] as bool,
      crossfadeDuration: fields[10] as double,
      enableGaplessPlayback: fields[11] as bool,
      enableReplayGain: fields[12] as bool,
      enableBassBoost: fields[13] as bool,
      bassBoostStrength: fields[14] as double,
      enableVirtualizer: fields[15] as bool,
      virtualizerStrength: fields[16] as double,
      enableLoudnessEnhancer: fields[17] as bool,
      loudnessGain: fields[18] as double,
      autoScanMusic: fields[19] as bool,
      excludedFolders: (fields[20] as List?)?.cast<String>(),
      enableNotifications: fields[21] as bool,
      enableLockScreenControls: fields[22] as bool,
      enableHeadsetControls: fields[23] as bool,
      pauseOnHeadsetDisconnect: fields[24] as bool,
      resumeOnHeadsetConnect: fields[25] as bool,
      enableShakeToSkip: fields[26] as bool,
      shakeThreshold: fields[27] as double,
      enableProximityPause: fields[28] as bool,
      lastPlayedSongId: fields[29] as String,
      lastPlayedPosition: fields[30] as int,
      lastPlayedPlaylistId: fields[31] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(32)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.volume)
      ..writeByte(2)
      ..write(obj.isShuffleEnabled)
      ..writeByte(3)
      ..write(obj.repeatMode)
      ..writeByte(4)
      ..write(obj.showLyrics)
      ..writeByte(5)
      ..write(obj.enableEqualizer)
      ..writeByte(6)
      ..write(obj.equalizerSettings)
      ..writeByte(7)
      ..write(obj.enableSleepTimer)
      ..writeByte(8)
      ..write(obj.sleepTimerMinutes)
      ..writeByte(9)
      ..write(obj.enableCrossfade)
      ..writeByte(10)
      ..write(obj.crossfadeDuration)
      ..writeByte(11)
      ..write(obj.enableGaplessPlayback)
      ..writeByte(12)
      ..write(obj.enableReplayGain)
      ..writeByte(13)
      ..write(obj.enableBassBoost)
      ..writeByte(14)
      ..write(obj.bassBoostStrength)
      ..writeByte(15)
      ..write(obj.enableVirtualizer)
      ..writeByte(16)
      ..write(obj.virtualizerStrength)
      ..writeByte(17)
      ..write(obj.enableLoudnessEnhancer)
      ..writeByte(18)
      ..write(obj.loudnessGain)
      ..writeByte(19)
      ..write(obj.autoScanMusic)
      ..writeByte(20)
      ..write(obj.excludedFolders)
      ..writeByte(21)
      ..write(obj.enableNotifications)
      ..writeByte(22)
      ..write(obj.enableLockScreenControls)
      ..writeByte(23)
      ..write(obj.enableHeadsetControls)
      ..writeByte(24)
      ..write(obj.pauseOnHeadsetDisconnect)
      ..writeByte(25)
      ..write(obj.resumeOnHeadsetConnect)
      ..writeByte(26)
      ..write(obj.enableShakeToSkip)
      ..writeByte(27)
      ..write(obj.shakeThreshold)
      ..writeByte(28)
      ..write(obj.enableProximityPause)
      ..writeByte(29)
      ..write(obj.lastPlayedSongId)
      ..writeByte(30)
      ..write(obj.lastPlayedPosition)
      ..writeByte(31)
      ..write(obj.lastPlayedPlaylistId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

