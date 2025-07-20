import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';

class ThemeProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _isLoading = true;
    notifyListeners();

    try {
      final settings = await _databaseService.getSettings();
      _themeMode = settings.themeMode;
      _updateSystemUIOverlay();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    _updateSystemUIOverlay();
    notifyListeners();

    try {
      final settings = await _databaseService.getSettings();
      final updatedSettings = settings.copyWith(themeMode: mode);
      await _databaseService.saveSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }

  void _updateSystemUIOverlay() {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    final statusBarBrightness = isDarkMode ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: statusBarBrightness,
      statusBarIconBrightness: statusBarBrightness,
      systemNavigationBarColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      systemNavigationBarIconBrightness: statusBarBrightness,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }

  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_7;
      case ThemeMode.dark:
        return Icons.brightness_2;
    }
  }

  // Get theme-aware colors
  Color getBackgroundColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF121212) : Colors.white;
  }

  Color getSurfaceColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
  }

  Color getCardColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
  }

  Color getPrimaryTextColor(BuildContext context) {
    return isDarkMode ? Colors.white : Colors.black87;
  }

  Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode ? Colors.white70 : Colors.black54;
  }

  Color getDividerColor(BuildContext context) {
    return isDarkMode ? Colors.white12 : Colors.black12;
  }

  Color getIconColor(BuildContext context) {
    return isDarkMode ? Colors.white70 : Colors.black54;
  }

  Color getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  // Gradient colors for now playing screen
  List<Color> getNowPlayingGradient(BuildContext context) {
    if (isDarkMode) {
      return [
        const Color(0xFF1A1A1A),
        const Color(0xFF2D2D2D),
        const Color(0xFF1A1A1A),
      ];
    } else {
      return [
        const Color(0xFFF8F9FA),
        const Color(0xFFE9ECEF),
        const Color(0xFFF8F9FA),
      ];
    }
  }

  // Mini player gradient
  List<Color> getMiniPlayerGradient(BuildContext context) {
    if (isDarkMode) {
      return [
        const Color(0xFF2C2C2C),
        const Color(0xFF1E1E1E),
      ];
    } else {
      return [
        Colors.white,
        const Color(0xFFF5F5F5),
      ];
    }
  }

  // Shimmer colors for loading states
  Color getShimmerBaseColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
  }

  Color getShimmerHighlightColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF3C3C3C) : const Color(0xFFF5F5F5);
  }

  // Button colors
  Color getButtonColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  Color getButtonTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  // Error colors
  Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  Color getSuccessColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
  }

  Color getWarningColor(BuildContext context) {
    return isDarkMode ? const Color(0xFFFF9800) : const Color(0xFFE65100);
  }
}

