import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import 'main_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with TickerProviderStateMixin {
  final PermissionService _permissionService = PermissionService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isRequesting = false;
  String _statusMessage = '';
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequesting = true;
      _statusMessage = 'Requesting permissions...';
      _showRetry = false;
    });

    try {
      final result = await _permissionService.requestAudioPermission();
      
      switch (result) {
        case PermissionResult.granted:
          setState(() {
            _statusMessage = 'Permission granted! Redirecting...';
          });
          
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ),
            );
          }
          break;
          
        case PermissionResult.denied:
          setState(() {
            _statusMessage = 'Permission denied. Please grant access to continue.';
            _showRetry = true;
          });
          break;
          
        case PermissionResult.permanentlyDenied:
          setState(() {
            _statusMessage = 'Permission permanently denied. Please enable it in app settings.';
            _showRetry = false;
          });
          break;
          
        default:
          setState(() {
            _statusMessage = 'Permission request failed. Please try again.';
            _showRetry = true;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error requesting permissions: ${e.toString()}';
        _showRetry = true;
      });
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }
  }

  Future<void> _openAppSettings() async {
    await _permissionService.openAppSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Permission Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.folder_open_rounded,
                              size: 60,
                              color: colorScheme.onPrimary,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Title
                          Text(
                            'Storage Permission Required',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text(
                            _permissionService.getAudioPermissionRationale(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Permission Features
                          _buildFeatureList(context),

                          const SizedBox(height: 32),

                          // Status Message
                          if (_statusMessage.isNotEmpty) ...[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _statusMessage.contains('granted')
                                    ? colorScheme.primaryContainer
                                    : _statusMessage.contains('denied') || _statusMessage.contains('Error')
                                        ? colorScheme.errorContainer
                                        : colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _statusMessage.contains('granted')
                                        ? Icons.check_circle
                                        : _statusMessage.contains('denied') || _statusMessage.contains('Error')
                                            ? Icons.error
                                            : Icons.info,
                                    color: _statusMessage.contains('granted')
                                        ? colorScheme.onPrimaryContainer
                                        : _statusMessage.contains('denied') || _statusMessage.contains('Error')
                                            ? colorScheme.onErrorContainer
                                            : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _statusMessage,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: _statusMessage.contains('granted')
                                            ? colorScheme.onPrimaryContainer
                                            : _statusMessage.contains('denied') || _statusMessage.contains('Error')
                                                ? colorScheme.onErrorContainer
                                                : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),

                    // Action Buttons
                    Column(
                      children: [
                        if (_isRequesting) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                        ],

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isRequesting ? null : _requestPermissions,
                            child: Text(
                              _showRetry ? 'Try Again' : 'Grant Permission',
                            ),
                          ),
                        ),

                        if (_statusMessage.contains('permanently denied')) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _openAppSettings,
                              child: const Text('Open App Settings'),
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () {
                            // Show explanation dialog
                            _showPermissionExplanationDialog(context);
                          },
                          child: const Text('Why do we need this permission?'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final features = [
      {
        'icon': Icons.library_music_rounded,
        'title': 'Scan Music Library',
        'description': 'Find and organize all your music files',
      },
      {
        'icon': Icons.album_rounded,
        'title': 'Album Artwork',
        'description': 'Display beautiful album covers',
      },
      {
        'icon': Icons.playlist_play_rounded,
        'title': 'Create Playlists',
        'description': 'Organize your favorite songs',
      },
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      feature['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showPermissionExplanationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Explanation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app needs storage permission to:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildExplanationItem(
              context,
              Icons.search,
              'Scan your device for music files',
            ),
            _buildExplanationItem(
              context,
              Icons.image,
              'Access album artwork and metadata',
            ),
            _buildExplanationItem(
              context,
              Icons.security,
              'Keep your music library private and offline',
            ),
            const SizedBox(height: 12),
            Text(
              'We only access audio files and never collect or share your personal data.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

