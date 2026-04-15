import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/playback/playback_cubit.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackCubit, PlaybackState>(
      builder: (context, state) {
        final current = state.currentTrack;
        if (current == null) return const SizedBox.shrink();

        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.music_note),
              const SizedBox(width: 12),
              Expanded(child: Text(current.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(
                onPressed: state.isPlaying
                    ? () => context.read<PlaybackCubit>().pause()
                    : () => context.read<PlaybackCubit>().play(),
                icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),
        );
      },
    );
  }
}
