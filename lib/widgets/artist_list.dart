import 'package:flutter/material.dart';
import '../models/song.dart';

class ArtistList extends StatelessWidget {
  final List<Song> songs;
  final Function(String, List<Song>)? onArtistTap;

  const ArtistList({
    super.key,
    required this.songs,
    this.onArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    final artists = _groupSongsByArtist(songs);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists.keys.elementAt(index);
        final artistSongs = artists[artist]!;
        
        return ArtistTile(
          artist: artist,
          songs: artistSongs,
          onTap: () => onArtistTap?.call(artist, artistSongs),
        );
      },
    );
  }

  Map<String, List<Song>> _groupSongsByArtist(List<Song> songs) {
    final Map<String, List<Song>> artists = {};
    
    for (final song in songs) {
      final artist = song.artist.isNotEmpty ? song.artist : 'Unknown Artist';
      artists.putIfAbsent(artist, () => []).add(song);
    }
    
    return artists;
  }
}

class ArtistTile extends StatelessWidget {
  final String artist;
  final List<Song> songs;
  final VoidCallback? onTap;

  const ArtistTile({
    super.key,
    required this.artist,
    required this.songs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.person_rounded,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        artist,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        '${songs.length} songs',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

