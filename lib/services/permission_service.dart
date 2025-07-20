import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Check if we have the necessary audio permissions
  Future<bool> hasAudioPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidVersion = await _getAndroidVersion();
      
      if (androidVersion >= 33) {
        // Android 13+ - Check READ_MEDIA_AUDIO
        return await Permission.audio.isGranted;
      } else {
        // Android 12 and below - Check READ_EXTERNAL_STORAGE
        return await Permission.storage.isGranted;
      }
    } catch (e) {
      debugPrint('Error checking audio permission: $e');
      return false;
    }
  }

  // Request audio permissions
  Future<PermissionResult> requestAudioPermission() async {
    if (!Platform.isAndroid) {
      return PermissionResult.granted;
    }

    try {
      final androidVersion = await _getAndroidVersion();
      PermissionStatus status;
      
      if (androidVersion >= 33) {
        // Android 13+ - Request READ_MEDIA_AUDIO
        status = await Permission.audio.request();
      } else {
        // Android 12 and below - Request READ_EXTERNAL_STORAGE
        status = await Permission.storage.request();
      }

      return _mapPermissionStatus(status);
    } catch (e) {
      debugPrint('Error requesting audio permission: $e');
      return PermissionResult.error;
    }
  }

  // Check notification permission (for media controls)
  Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      return await Permission.notification.isGranted;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  // Request notification permission
  Future<PermissionResult> requestNotificationPermission() async {
    if (!Platform.isAndroid) {
      return PermissionResult.granted;
    }

    try {
      final status = await Permission.notification.request();
      return _mapPermissionStatus(status);
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return PermissionResult.error;
    }
  }

  // Check if we can manage external storage (for Android 11+)
  Future<bool> hasManageExternalStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidVersion = await _getAndroidVersion();
      
      if (androidVersion >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      }
      
      return true; // Not needed for older versions
    } catch (e) {
      debugPrint('Error checking manage external storage permission: $e');
      return false;
    }
  }

  // Request manage external storage permission
  Future<PermissionResult> requestManageExternalStoragePermission() async {
    if (!Platform.isAndroid) {
      return PermissionResult.granted;
    }

    try {
      final androidVersion = await _getAndroidVersion();
      
      if (androidVersion >= 30) {
        final status = await Permission.manageExternalStorage.request();
        return _mapPermissionStatus(status);
      }
      
      return PermissionResult.granted;
    } catch (e) {
      debugPrint('Error requesting manage external storage permission: $e');
      return PermissionResult.error;
    }
  }

  // Request all necessary permissions
  Future<Map<String, PermissionResult>> requestAllPermissions() async {
    final results = <String, PermissionResult>{};

    // Audio permission (required)
    results['audio'] = await requestAudioPermission();

    // Notification permission (optional but recommended)
    results['notification'] = await requestNotificationPermission();

    // Manage external storage (optional, for Android 11+)
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      if (androidVersion >= 30) {
        results['manageExternalStorage'] = await requestManageExternalStoragePermission();
      }
    }

    return results;
  }

  // Check all permissions status
  Future<Map<String, bool>> checkAllPermissions() async {
    final results = <String, bool>{};

    results['audio'] = await hasAudioPermission();
    results['notification'] = await hasNotificationPermission();
    
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      if (androidVersion >= 30) {
        results['manageExternalStorage'] = await hasManageExternalStoragePermission();
      }
    }

    return results;
  }

  // Check if permission was permanently denied
  Future<bool> isAudioPermissionPermanentlyDenied() async {
    if (!Platform.isAndroid) return false;

    try {
      final androidVersion = await _getAndroidVersion();
      
      if (androidVersion >= 33) {
        return await Permission.audio.isPermanentlyDenied;
      } else {
        return await Permission.storage.isPermanentlyDenied;
      }
    } catch (e) {
      debugPrint('Error checking if audio permission is permanently denied: $e');
      return false;
    }
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  // Get permission rationale message
  String getAudioPermissionRationale() {
    return 'This app needs access to your device\'s audio files to scan and play your music. '
           'Without this permission, the app cannot function properly.';
  }

  String getNotificationPermissionRationale() {
    return 'This app needs notification permission to show media controls and playback information. '
           'This allows you to control music playback from the notification panel and lock screen.';
  }

  String getManageExternalStorageRationale() {
    return 'This app needs access to manage external storage to provide better music scanning capabilities. '
           'This permission is optional but recommended for the best experience.';
  }

  // Helper methods
  Future<int> _getAndroidVersion() async {
    // In a real app, you would use device_info_plus to get the actual Android version
    // For this example, we'll assume Android 13+
    return 33;
  }

  PermissionResult _mapPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResult.granted;
      case PermissionStatus.denied:
        return PermissionResult.denied;
      case PermissionStatus.restricted:
        return PermissionResult.restricted;
      case PermissionStatus.limited:
        return PermissionResult.limited;
      case PermissionStatus.permanentlyDenied:
        return PermissionResult.permanentlyDenied;
      case PermissionStatus.provisional:
        return PermissionResult.provisional;
    }
  }

  // Get user-friendly permission status message
  String getPermissionStatusMessage(PermissionResult result) {
    switch (result) {
      case PermissionResult.granted:
        return 'Permission granted';
      case PermissionResult.denied:
        return 'Permission denied';
      case PermissionResult.restricted:
        return 'Permission restricted';
      case PermissionResult.limited:
        return 'Permission limited';
      case PermissionResult.permanentlyDenied:
        return 'Permission permanently denied. Please enable it in app settings.';
      case PermissionResult.provisional:
        return 'Permission granted provisionally';
      case PermissionResult.error:
        return 'Error occurred while requesting permission';
    }
  }

  // Check if the app can function with current permissions
  Future<bool> canAppFunction() async {
    return await hasAudioPermission();
  }

  // Get missing critical permissions
  Future<List<String>> getMissingCriticalPermissions() async {
    final missing = <String>[];

    if (!await hasAudioPermission()) {
      missing.add('audio');
    }

    return missing;
  }
}

enum PermissionResult {
  granted,
  denied,
  restricted,
  limited,
  permanentlyDenied,
  provisional,
  error,
}

