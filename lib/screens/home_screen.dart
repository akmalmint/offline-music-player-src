import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/playlist_provider.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';
import '../widgets/album_grid.dart';
import '../widgets/artist_list.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Song> _filteredSongs = [];
  bool _isSearching = false;
  String _searchQuery = '';

  final List<Tab> _tabs = [
    const Tab(text: 'Songs'),
    const Tab(text: 'Albums'),
    const Tab(text: 'Artists'),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _performSearch(query);
    }
  }

  void _performSearch(String query) {
    final musicProvider = context.read<MusicProvider>();
    final allSongs = musicProvider.allSongs;
    
    setState(() {
      _filteredSongs = allSongs.where((song) {
        final searchLower = query.toLowerCase();
        return song.title.toLowerCase().contains(searchLower) ||
               song.artist.toLowerCase().contains(searchLower) ||
               song.album.toLowerCase().contains(searchLower) ||
               (song.genre?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _filteredSongs.clear();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              title: _isSearching
                  ? null
                  : Text(
                      'Music Library',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              actions: [
                if (!_isSearching) ...[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                    icon: const Icon(Icons.search_rounded),
                  ),
                  PopupMenuButton<String>(
                    onSelected: _handleMenuAction,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'scan',
                        child: ListTile(
                          leading: Icon(Icons.refresh_rounded),
                          title: Text('Scan for Music'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'sort',
                        child: ListTile(
                          leading: Icon(Icons.sort_rounded),
                          title: Text('Sort Options'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              flexibleSpace: _isSearching
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: SafeArea(
                        child: CustomSearchBar(
                          controller: _searchController,
                          hintText: 'Search songs, artists, albums...',
                          onClear: _clearSearch,
                          autofocus: true,
                        ),
                      ),
                    )
                  : null,
              bottom: _isSearching
                  ? null
                  : TabBar(
                      controller: _tabController,
                      tabs: _tabs,
                      indicatorColor: colorScheme.primary,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      labelStyle: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: theme.textTheme.titleSmall,
                    ),
            ),
          ];
        },
        body: _isSearching ? _buildSearchResults() : _buildTabContent(),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_filteredSongs.isEmpty) {
      return _buildNoResults();
    }

    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _filteredSongs.length,
          itemBuilder: (context, index) {
            final song = _filteredSongs[index];
            return SongTile(
              song: song,
              onTap: () => _playSong(song, _filteredSongs),
              onMoreTap: () => _showSongOptions(song),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Search your music library',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find songs, artists, albums, and more',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSongsTab(),
        _buildAlbumsTab(),
        _buildArtistsTab(),
      ],
    );
  }

  Widget _buildSongsTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final songs = musicProvider.allSongs;

        if (songs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.library_music_rounded,
            title: 'No music found',
            subtitle: 'Add some music to your device to get started',
            actionText: 'Scan for Music',
            onAction: _scanForMusic,
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshMusic,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                onTap: () => _playSong(song, songs),
                onMoreTap: () => _showSongOptions(song),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final songs = musicProvider.allSongs;

        if (songs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.album_rounded,
            title: 'No albums found',
            subtitle: 'Add some music to your device to see albums',
            actionText: 'Scan for Music',
            onAction: _scanForMusic,
          );
        }

        return AlbumGrid(
          songs: songs,
          onAlbumTap: _playAlbum,
        );
      },
    );
  }

  Widget _buildArtistsTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final songs = musicProvider.allSongs;

        if (songs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_rounded,
            title: 'No artists found',
            subtitle: 'Add some music to your device to see artists',
            actionText: 'Scan for Music',
            onAction: _scanForMusic,
          );
        }

        return ArtistList(
          songs: songs,
          onArtistTap: _playArtist,
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  void _playSong(Song song, List<Song> queue) {
    final musicProvider = context.read<MusicProvider>();
    musicProvider.playSong(song, queue: queue);
  }

  void _playAlbum(String album, List<Song> songs) {
    final albumSongs = songs.where((song) => song.album == album).toList();
    if (albumSongs.isNotEmpty) {
      final musicProvider = context.read<MusicProvider>();
      musicProvider.playQueue(albumSongs);
    }
  }

  void _playArtist(String artist, List<Song> songs) {
    final artistSongs = songs.where((song) => song.artist == artist).toList();
    if (artistSongs.isNotEmpty) {
      final musicProvider = context.read<MusicProvider>();
      musicProvider.playQueue(artistSongs);
    }
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SongOptionsBottomSheet(song: song),
    );
  }

  Future<void> _refreshMusic() async {
    final musicProvider = context.read<MusicProvider>();
    await musicProvider.loadMusic();
  }

  void _scanForMusic() {
    // Implement music scanning
    _refreshMusic();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'scan':
        _scanForMusic();
        break;
      case 'sort':
        _showSortOptions();
        break;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SortOptionsBottomSheet(),
    );
  }
}

// Placeholder widgets - these would be implemented separately
class SongOptionsBottomSheet extends StatelessWidget {
  final Song song;

  const SongOptionsBottomSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: const Text('Add to Favorites'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to Playlist'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class SortOptionsBottomSheet extends StatelessWidget {
  const SortOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Sort by Title'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Sort by Artist'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

