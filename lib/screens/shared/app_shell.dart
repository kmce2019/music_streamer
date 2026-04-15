import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/playback/playback_cubit.dart';
import 'mini_player.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space): _PlayPauseIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight, control: true): _NextIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft, control: true): _PrevIntent(),
      },
      child: Actions(
        actions: {
          _PlayPauseIntent: CallbackAction<_PlayPauseIntent>(onInvoke: (_) {
            final cubit = context.read<PlaybackCubit>();
            return cubit.state.isPlaying ? cubit.pause() : cubit.play();
          }),
          _NextIntent: CallbackAction<_NextIntent>(onInvoke: (_) => context.read<PlaybackCubit>().next()),
          _PrevIntent: CallbackAction<_PrevIntent>(onInvoke: (_) => context.read<PlaybackCubit>().previous()),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Column(
              children: [
                Expanded(child: navigationShell),
                const MiniPlayer(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                NavigationDestination(icon: Icon(Icons.library_music_outlined), label: 'Library'),
                NavigationDestination(icon: Icon(Icons.play_circle_outline), label: 'Now Playing'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayPauseIntent extends Intent {
  const _PlayPauseIntent();
}

class _NextIntent extends Intent {
  const _NextIntent();
}

class _PrevIntent extends Intent {
  const _PrevIntent();
}
