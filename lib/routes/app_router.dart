import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/now_playing/now_playing_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/shared/app_shell.dart';

final appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/search', builder: (context, state) => const SearchScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/library', builder: (context, state) => const LibraryScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/now-playing', builder: (context, state) => const NowPlayingScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen())]),
      ],
    ),
  ],
);
