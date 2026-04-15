import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_cubit.dart';
import '../../blocs/playback/playback_cubit.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Import folder',
            onPressed: () => context.read<LibraryCubit>().importFolder(),
          ),
        ],
      ),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator());
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
        },
      ),
    );
  }
}
