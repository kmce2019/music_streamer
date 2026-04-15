import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_cubit.dart';
import '../../blocs/playback/playback_cubit.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Import folder',
              onPressed: () => context.read<LibraryCubit>().importFolder(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tracks'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
            ],
          ),
        ),
        body: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator());
            return Column(
              children: [
                if (state.lastImportMessage != null)
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    padding: const EdgeInsets.all(12),
                    child: Text(state.lastImportMessage!),
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _TracksList(state: state),
                      _AlbumsList(state: state),
                      _ArtistsList(state: state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TracksList extends StatelessWidget {
  const _TracksList({required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    if (state.tracks.isEmpty) {
      return const Center(child: Text('No tracks imported yet. Use folder import to begin.'));
    }
    return ListView.builder(
      itemCount: state.tracks.length,
      itemBuilder: (context, index) {
        final track = state.tracks[index];
        return ListTile(
          leading: Icon(track.isFavorite ? Icons.favorite : Icons.music_note_outlined),
          title: Text(track.title),
          subtitle: Text(track.source),
          onTap: () async {
            await context.read<PlaybackCubit>().loadQueue(state.tracks, startIndex: index);
            await context.read<PlaybackCubit>().play();
          },
          trailing: IconButton(
            icon: Icon(track.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => context.read<LibraryCubit>().toggleFavorite(track.id),
          ),
        );
      },
    );
  }
}

class _AlbumsList extends StatelessWidget {
  const _AlbumsList({required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    if (state.albums.isEmpty) return const Center(child: Text('No albums yet.'));
    return ListView(
      children: state.albums
          .map((album) => ListTile(
                leading: const Icon(Icons.album_outlined),
                title: Text(album.title),
                subtitle: Text(_artistName(state, album.artistId)),
              ))
          .toList(),
    );
  }
}


String _artistName(LibraryState state, String artistId) {
  for (final artist in state.artists) {
    if (artist.id == artistId) return artist.name;
  }
  return 'Unknown Artist';
}

class _ArtistsList extends StatelessWidget {
  const _ArtistsList({required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    if (state.artists.isEmpty) return const Center(child: Text('No artists yet.'));
    return ListView(
      children: state.artists
          .map((artist) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(artist.name),
                subtitle: Text('${state.tracks.where((t) => t.artistId == artist.id).length} tracks'),
              ))
          .toList(),
    );
  }
}
