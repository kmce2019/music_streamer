import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/playback/playback_cubit.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: BlocBuilder<PlaybackCubit, PlaybackState>(
        builder: (context, state) {
          final track = state.currentTrack;
          if (track == null) return const Center(child: Text('Nothing playing yet.'));

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Expanded(
                  child: Card(
                    child: Center(
                      child: Icon(Icons.album, size: 96),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(track.title, style: Theme.of(context).textTheme.headlineSmall),
                Slider(
                  value: state.position.inSeconds.toDouble(),
                  min: 0,
                  max: 300,
                  onChanged: (value) => context.read<PlaybackCubit>().seek(Duration(seconds: value.round())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: () => context.read<PlaybackCubit>().previous(), icon: const Icon(Icons.skip_previous)),
                    IconButton(
                      onPressed: state.isPlaying
                          ? () => context.read<PlaybackCubit>().pause()
                          : () => context.read<PlaybackCubit>().play(),
                      icon: Icon(state.isPlaying ? Icons.pause_circle : Icons.play_circle),
                    ),
                    IconButton(onPressed: () => context.read<PlaybackCubit>().next(), icon: const Icon(Icons.skip_next)),
                    IconButton(onPressed: () => context.read<PlaybackCubit>().toggleShuffle(), icon: const Icon(Icons.shuffle)),
                    IconButton(onPressed: () => context.read<PlaybackCubit>().cycleRepeatMode(), icon: const Icon(Icons.repeat)),
                  ],
                ),
                const ListTile(
                  title: Text('Lyrics'),
                  subtitle: Text('Lyrics provider plugin placeholder.'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
