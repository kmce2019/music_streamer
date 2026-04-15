import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/bootstrap/app_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'blocs/library/library_cubit.dart';
import 'blocs/playback/playback_cubit.dart';
import 'blocs/search/search_cubit.dart';
import 'blocs/settings/settings_cubit.dart';
import 'blocs/playlist/playlist_cubit.dart';
import 'blocs/plugins/plugin_cubit.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppBootstrap.initialize();
  runApp(BloomeeSafeApp(bootstrap: bootstrap));
}

class BloomeeSafeApp extends StatelessWidget {
  const BloomeeSafeApp({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => bootstrap.get<LibraryCubit>()..loadLibrary()),
        BlocProvider(create: (_) => bootstrap.get<PlaybackCubit>()),
        BlocProvider(create: (_) => bootstrap.get<SearchCubit>()),
        BlocProvider(create: (_) => bootstrap.get<SettingsCubit>()),
        BlocProvider(create: (_) => bootstrap.get<PlaylistCubit>()..loadPlaylists()),
        BlocProvider(create: (_) => bootstrap.get<PluginCubit>()..loadPlugins()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Music Streamer',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            routerConfig: appRouter,
            localizationsDelegates: bootstrap.localizationDelegates,
            supportedLocales: bootstrap.supportedLocales,
          );
        },
      ),
    );
  }
}
