# Offline Music Player

A beautiful, feature-rich offline music player built with Flutter, featuring Material 3 design, advanced audio controls, and seamless offline operation.

## Features

### 🎵 Core Music Features
- **Offline Music Playback**: Play local audio files without internet connection
- **Audio Format Support**: MP3, FLAC, AAC, OGG, and more
- **Gapless Playback**: Seamless transitions between tracks
- **Crossfade Support**: Smooth audio transitions
- **High-Quality Audio**: Support for high-resolution audio files

### 🎨 Beautiful UI/UX
- **Material 3 Design**: Modern, clean interface following Google's latest design guidelines
- **Dark/Light Theme**: Automatic system theme detection with manual override
- **Responsive Design**: Optimized for phones and tablets
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Album Art Display**: Beautiful album artwork with rotation animations

### 🎛️ Advanced Controls
- **Play/Pause/Skip**: Standard playback controls
- **Shuffle & Repeat**: Multiple repeat modes (none, one, all)
- **Volume Control**: Precise volume adjustment
- **Seek Control**: Accurate position seeking
- **Sleep Timer**: Auto-stop playback after specified time
- **Equalizer**: 10-band equalizer with presets

### 📱 Smart Features
- **Mini Player**: Persistent playback controls
- **Now Playing Screen**: Full-screen player with album art
- **Queue Management**: Add, remove, and reorder songs
- **Favorites**: Mark and organize favorite tracks
- **Playlists**: Create and manage custom playlists
- **Search**: Fast search across songs, artists, and albums

### 🔧 Technical Features
- **Permission Handling**: Smart Android 13+ permission management
- **Background Playback**: Continue playing when app is minimized
- **Lock Screen Controls**: Media controls on lock screen
- **Headset Support**: Play/pause with headset buttons
- **Auto-Scan**: Automatic music library scanning
- **Local Storage**: All data stored locally with Hive database

## Screenshots

*Screenshots will be added here*

## Installation

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android SDK (API level 21 or higher)
- Android device or emulator

### Setup
1. Clone the repository:
```bash
git clone https://github.com/akmalmint/offline-music-player-src.git
cd offline_music_player
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter packages pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

## Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── song.dart
│   ├── playlist.dart
│   └── app_settings.dart
├── providers/                # State management
│   ├── music_provider.dart
│   ├── playlist_provider.dart
│   └── theme_provider.dart
├── services/                 # Business logic
│   ├── audio_service.dart
│   ├── database_service.dart
│   ├── music_scanner_service.dart
│   └── permission_service.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── favorites_screen.dart
│   ├── settings_screen.dart
│   ├── now_playing_screen.dart
│   └── permission_screen.dart
├── widgets/                  # Reusable components
│   ├── mini_player.dart
│   ├── song_tile.dart
│   ├── album_grid.dart
│   └── artist_list.dart
└── themes/                   # App theming
    └── app_theme.dart
```

### Key Technologies
- **Flutter**: Cross-platform mobile framework
- **Provider**: State management solution
- **Hive**: Local NoSQL database
- **just_audio**: Audio playback engine
- **on_audio_query**: Music file scanning
- **permission_handler**: Runtime permissions
- **lottie**: Vector animations

## Permissions

The app requires the following permissions:

### Android 13+ (API 33+)
- `READ_MEDIA_AUDIO`: Access audio files
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: Background playback
- `WAKE_LOCK`: Prevent device sleep during playback

### Android 12 and below
- `READ_EXTERNAL_STORAGE`: Access audio files
- `WAKE_LOCK`: Prevent device sleep during playback

## Configuration

### Audio Formats
Supported audio formats:
- MP3 (.mp3)
- FLAC (.flac)
- AAC (.aac, .m4a)
- OGG Vorbis (.ogg)
- WAV (.wav)

### Performance Settings
- **Gapless Playback**: Enabled by default
- **Crossfade Duration**: 3 seconds (configurable)
- **Buffer Size**: Optimized for smooth playback
- **Sample Rate**: Up to 192kHz support

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Write tests for new features
- Update documentation for API changes
- Ensure Material 3 design compliance

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- just_audio plugin developers
- on_audio_query plugin developers
- All open-source contributors

## Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/yourusername/offline_music_player/issues) page
2. Create a new issue with detailed information
3. Join our community discussions

## Roadmap

### Upcoming Features
- [ ] Lyrics display and synchronization
- [ ] Audio effects (reverb, echo)
- [ ] Podcast support
- [ ] Cloud backup for playlists
- [ ] Widget support
- [ ] Car mode interface
- [ ] Voice commands
- [ ] Music recommendations

### Version History
- **v1.0.0**: Initial release with core features
- **v1.1.0**: Planned - Enhanced equalizer and effects
- **v1.2.0**: Planned - Lyrics and podcast support

---

Made with ❤️ using Flutter

