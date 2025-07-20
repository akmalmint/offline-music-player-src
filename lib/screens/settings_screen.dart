import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/music_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              _buildThemeTile(context),
            ],
          ),
          _buildSection(
            context,
            'Playback',
            [
              _buildSleepTimerTile(context),
              _buildEqualizerTile(context),
            ],
          ),
          _buildSection(
            context,
            'Library',
            [
              _buildScanMusicTile(context),
              _buildStorageTile(context),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              _buildAboutTile(context),
              _buildVersionTile(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: Icon(themeProvider.themeModeIcon),
          title: const Text('Theme'),
          subtitle: Text(themeProvider.themeModeString),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showThemeDialog(context),
        );
      },
    );
  }

  Widget _buildSleepTimerTile(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return ListTile(
          leading: const Icon(Icons.bedtime_rounded),
          title: const Text('Sleep Timer'),
          subtitle: Text(
            musicProvider.isSleepTimerActive
                ? 'Active'
                : 'Off',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showSleepTimerDialog(context),
        );
      },
    );
  }

  Widget _buildEqualizerTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.equalizer_rounded),
      title: const Text('Equalizer'),
      subtitle: const Text('Adjust sound settings'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showEqualizerDialog(context),
    );
  }

  Widget _buildScanMusicTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.refresh_rounded),
      title: const Text('Scan for Music'),
      subtitle: const Text('Refresh music library'),
      onTap: () => _scanForMusic(context),
    );
  }

  Widget _buildStorageTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.storage_rounded),
      title: const Text('Storage'),
      subtitle: const Text('Manage app data'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showStorageDialog(context),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline_rounded),
      title: const Text('About'),
      subtitle: const Text('App information'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showAboutDialog(context),
    );
  }

  Widget _buildVersionTile(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.code_rounded),
      title: Text('Version'),
      subtitle: Text('1.0.0'),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Timer'),
        content: const Text('Sleep timer functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEqualizerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equalizer'),
        content: const Text('Equalizer functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _scanForMusic(BuildContext context) {
    final musicProvider = context.read<MusicProvider>();
    musicProvider.loadMusic();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanning for music...'),
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage'),
        content: const Text('Storage management functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Offline Music Player',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.music_note_rounded, size: 48),
      children: [
        const Text('A beautiful offline music player built with Flutter.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Offline music playback'),
        const Text('• Beautiful Material 3 design'),
        const Text('• Playlist management'),
        const Text('• Sleep timer'),
        const Text('• Equalizer'),
      ],
    );
  }
}

