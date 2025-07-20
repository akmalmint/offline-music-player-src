import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/music_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';
import 'themes/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await DatabaseService.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const OfflineMusicPlayerApp());
}

class OfflineMusicPlayerApp extends StatelessWidget {
  const OfflineMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Offline Music Player',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0, // Prevent text scaling
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final musicProvider = context.read<MusicProvider>();
    
    switch (state) {
      case AppLifecycleState.paused:
        // App is in background
        _saveCurrentState();
        break;
      case AppLifecycleState.resumed:
        // App is back in foreground
        _restoreState();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        _saveCurrentState();
        _cleanup();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., during phone call)
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  void _saveCurrentState() {
    try {
      final musicProvider = context.read<MusicProvider>();
      // Save current playback state
      // This would be implemented in the music provider
    } catch (e) {
      debugPrint('Error saving app state: $e');
    }
  }

  void _restoreState() {
    try {
      final musicProvider = context.read<MusicProvider>();
      // Restore playback state if needed
      // This would be implemented in the music provider
    } catch (e) {
      debugPrint('Error restoring app state: $e');
    }
  }

  void _cleanup() {
    try {
      // Cleanup resources
      DatabaseService.close();
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

