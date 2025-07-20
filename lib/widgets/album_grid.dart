import 'package:flutter/material.dart';
import '../models/song.dart';

class AlbumGrid extends StatelessWidget {
  final List<Song> songs;
  final Function(String, List<Song>)? onAlbumTap;

  const AlbumGrid({
    super.key,
    required this.songs,
    this.onAlbumTap,
  });

  @override
  Widget build(BuildContext context) {
    final albums = _groupSongsByAlbum(songs);
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums.keys.elementAt(index);
        final albumSongs = albums[album]!;
        
        return AlbumCard(
          album: album,
          songs: albumSongs,
          onTap: () => onAlbumTap?.call(album, albumSongs),
        );
      },
    );
  }

  Map<String, List<Song>> _groupSongsByAlbum(List<Song> songs) {
    final Map<String, List<Song>> albums = {};
    
    for (final song in songs) {
      final album = song.album.isNotEmpty ? song.album : 'Unknown Album';
      albums.putIfAbsent(album, () => []).add(song);
    }
    
    return albums;
  }
}

class AlbumCard extends StatelessWidget {
  final String album;
  final List<Song> songs;
  final VoidCallback? onTap;

  const AlbumCard({
    super.key,
    required this.album,
    required this.songs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.album_rounded,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                album,
                style: theme.textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${songs.length} songs',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

