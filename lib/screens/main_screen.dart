import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'now_playing_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _miniPlayerController;
  late Animation<double> _miniPlayerAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.favorite_outline_rounded),
      activeIcon: Icon(Icons.favorite_rounded),
      label: 'Favorites',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupMiniPlayerAnimation();
  }

  void _setupMiniPlayerAnimation() {
    _miniPlayerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _miniPlayerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _miniPlayerController,
      curve: Curves.easeInOut,
    ));
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // If tapping the same tab, scroll to top or refresh
      _handleSameTabTap(index);
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleSameTabTap(int index) {
    // Handle same tab tap - could scroll to top or refresh content
    switch (index) {
      case 0: // Home
        // Scroll to top or refresh
        break;
      case 1: // Favorites
        // Refresh favorites
        break;
      case 2: // Settings
        // No action needed
        break;
    }
  }

  void _openNowPlaying() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NowPlayingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _miniPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          // Show/hide mini player based on current song
          if (musicProvider.currentSong != null && !_miniPlayerController.isCompleted) {
            _miniPlayerController.forward();
          } else if (musicProvider.currentSong == null && _miniPlayerController.isCompleted) {
            _miniPlayerController.reverse();
          }

          return Column(
            children: [
              // Main content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: _screens,
                ),
              ),

              // Mini Player
              AnimatedBuilder(
                animation: _miniPlayerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      (1 - _miniPlayerAnimation.value) * 100,
                    ),
                    child: Opacity(
                      opacity: _miniPlayerAnimation.value,
                      child: musicProvider.currentSong != null
                          ? MiniPlayer(
                              onTap: _openNowPlaying,
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              ),

              // Bottom Navigation Bar
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  items: _navItems,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Custom page route for smooth transitions
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final AxisDirection direction;

  CustomPageRoute({
    required this.child,
    this.direction = AxisDirection.left,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Offset begin;
    const end = Offset.zero;

    switch (direction) {
      case AxisDirection.up:
        begin = const Offset(0.0, 1.0);
        break;
      case AxisDirection.down:
        begin = const Offset(0.0, -1.0);
        break;
      case AxisDirection.right:
        begin = const Offset(-1.0, 0.0);
        break;
      case AxisDirection.left:
      default:
        begin = const Offset(1.0, 0.0);
        break;
    }

    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}

