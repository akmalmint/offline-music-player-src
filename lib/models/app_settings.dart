import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
enum ThemeMode {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}

@HiveType(typeId: 3)
enum RepeatMode {
  @HiveField(0)
  none,
  @HiveField(1)
  one,
  @HiveField(2)
  all,
}

@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  ThemeMode themeMode;

  @HiveField(1)
  double volume;

  @HiveField(2)
  bool isShuffleEnabled;

  @HiveField(3)
  RepeatMode repeatMode;

  @HiveField(4)
  bool showLyrics;

  @HiveField(5)
  bool enableEqualizer;

  @HiveField(6)
  List<double> equalizerSettings;

  @HiveField(7)
  bool enableSleepTimer;

  @HiveField(8)
  int sleepTimerMinutes;

  @HiveField(9)
  bool enableCrossfade;

  @HiveField(10)
  double crossfadeDuration;

  @HiveField(11)
  bool enableGaplessPlayback;

  @HiveField(12)
  bool enableReplayGain;

  @HiveField(13)
  bool enableBassBoost;

  @HiveField(14)
  double bassBoostStrength;

  @HiveField(15)
  bool enableVirtualizer;

  @HiveField(16)
  double virtualizerStrength;

  @HiveField(17)
  bool enableLoudnessEnhancer;

  @HiveField(18)
  double loudnessGain;

  @HiveField(19)
  bool autoScanMusic;

  @HiveField(20)
  List<String> excludedFolders;

  @HiveField(21)
  bool enableNotifications;

  @HiveField(22)
  bool enableLockScreenControls;

  @HiveField(23)
  bool enableHeadsetControls;

  @HiveField(24)
  bool pauseOnHeadsetDisconnect;

  @HiveField(25)
  bool resumeOnHeadsetConnect;

  @HiveField(26)
  bool enableShakeToSkip;

  @HiveField(27)
  double shakeThreshold;

  @HiveField(28)
  bool enableProximityPause;

  @HiveField(29)
  String lastPlayedSongId;

  @HiveField(30)
  int lastPlayedPosition;

  @HiveField(31)
  String lastPlayedPlaylistId;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.volume = 0.7,
    this.isShuffleEnabled = false,
    this.repeatMode = RepeatMode.none,
    this.showLyrics = true,
    this.enableEqualizer = false,
    List<double>? equalizerSettings,
    this.enableSleepTimer = false,
    this.sleepTimerMinutes = 30,
    this.enableCrossfade = false,
    this.crossfadeDuration = 3.0,
    this.enableGaplessPlayback = true,
    this.enableReplayGain = false,
    this.enableBassBoost = false,
    this.bassBoostStrength = 0.5,
    this.enableVirtualizer = false,
    this.virtualizerStrength = 0.5,
    this.enableLoudnessEnhancer = false,
    this.loudnessGain = 0.0,
    this.autoScanMusic = true,
    List<String>? excludedFolders,
    this.enableNotifications = true,
    this.enableLockScreenControls = true,
    this.enableHeadsetControls = true,
    this.pauseOnHeadsetDisconnect = true,
    this.resumeOnHeadsetConnect = false,
    this.enableShakeToSkip = false,
    this.shakeThreshold = 2.5,
    this.enableProximityPause = false,
    this.lastPlayedSongId = '',
    this.lastPlayedPosition = 0,
    this.lastPlayedPlaylistId = '',
  })  : equalizerSettings = equalizerSettings ?? List.filled(10, 0.0),
        excludedFolders = excludedFolders ?? [];

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? volume,
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
    bool? showLyrics,
    bool? enableEqualizer,
    List<double>? equalizerSettings,
    bool? enableSleepTimer,
    int? sleepTimerMinutes,
    bool? enableCrossfade,
    double? crossfadeDuration,
    bool? enableGaplessPlayback,
    bool? enableReplayGain,
    bool? enableBassBoost,
    double? bassBoostStrength,
    bool? enableVirtualizer,
    double? virtualizerStrength,
    bool? enableLoudnessEnhancer,
    double? loudnessGain,
    bool? autoScanMusic,
    List<String>? excludedFolders,
    bool? enableNotifications,
    bool? enableLockScreenControls,
    bool? enableHeadsetControls,
    bool? pauseOnHeadsetDisconnect,
    bool? resumeOnHeadsetConnect,
    bool? enableShakeToSkip,
    double? shakeThreshold,
    bool? enableProximityPause,
    String? lastPlayedSongId,
    int? lastPlayedPosition,
    String? lastPlayedPlaylistId,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      volume: volume ?? this.volume,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      showLyrics: showLyrics ?? this.showLyrics,
      enableEqualizer: enableEqualizer ?? this.enableEqualizer,
      equalizerSettings: equalizerSettings ?? List<double>.from(this.equalizerSettings),
      enableSleepTimer: enableSleepTimer ?? this.enableSleepTimer,
      sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
      enableCrossfade: enableCrossfade ?? this.enableCrossfade,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      enableGaplessPlayback: enableGaplessPlayback ?? this.enableGaplessPlayback,
      enableReplayGain: enableReplayGain ?? this.enableReplayGain,
      enableBassBoost: enableBassBoost ?? this.enableBassBoost,
      bassBoostStrength: bassBoostStrength ?? this.bassBoostStrength,
      enableVirtualizer: enableVirtualizer ?? this.enableVirtualizer,
      virtualizerStrength: virtualizerStrength ?? this.virtualizerStrength,
      enableLoudnessEnhancer: enableLoudnessEnhancer ?? this.enableLoudnessEnhancer,
      loudnessGain: loudnessGain ?? this.loudnessGain,
      autoScanMusic: autoScanMusic ?? this.autoScanMusic,
      excludedFolders: excludedFolders ?? List<String>.from(this.excludedFolders),
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableLockScreenControls: enableLockScreenControls ?? this.enableLockScreenControls,
      enableHeadsetControls: enableHeadsetControls ?? this.enableHeadsetControls,
      pauseOnHeadsetDisconnect: pauseOnHeadsetDisconnect ?? this.pauseOnHeadsetDisconnect,
      resumeOnHeadsetConnect: resumeOnHeadsetConnect ?? this.resumeOnHeadsetConnect,
      enableShakeToSkip: enableShakeToSkip ?? this.enableShakeToSkip,
      shakeThreshold: shakeThreshold ?? this.shakeThreshold,
      enableProximityPause: enableProximityPause ?? this.enableProximityPause,
      lastPlayedSongId: lastPlayedSongId ?? this.lastPlayedSongId,
      lastPlayedPosition: lastPlayedPosition ?? this.lastPlayedPosition,
      lastPlayedPlaylistId: lastPlayedPlaylistId ?? this.lastPlayedPlaylistId,
    );
  }

  void updateLastPlayed(String songId, int position, String playlistId) {
    lastPlayedSongId = songId;
    lastPlayedPosition = position;
    lastPlayedPlaylistId = playlistId;
    save();
  }

  void resetEqualizer() {
    equalizerSettings = List.filled(10, 0.0);
    save();
  }

  void addExcludedFolder(String folderPath) {
    if (!excludedFolders.contains(folderPath)) {
      excludedFolders.add(folderPath);
      save();
    }
  }

  void removeExcludedFolder(String folderPath) {
    if (excludedFolders.contains(folderPath)) {
      excludedFolders.remove(folderPath);
      save();
    }
  }

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, volume: $volume, shuffle: $isShuffleEnabled, repeat: $repeatMode)';
  }
}

