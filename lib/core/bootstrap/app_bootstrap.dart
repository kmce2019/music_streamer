import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import '../../blocs/library/library_cubit.dart';
import '../../blocs/playback/playback_cubit.dart';
import '../../blocs/playlist/playlist_cubit.dart';
import '../../blocs/plugins/plugin_cubit.dart';
import '../../blocs/search/search_cubit.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../plugins/runtime/plugin_runtime_service.dart';
import '../../repository/library_repository.dart';
import '../../repository/playback_repository.dart';
import '../../repository/playlist_repository.dart';
import '../../services/audio/audio_player_service.dart';
import '../../services/import/local_import_service.dart';
import '../../services/persistence/json_export_service.dart';
import '../../services/search/library_search_service.dart';
import '../../services/settings/settings_service.dart';
import '../cache/cache_store.dart';
import '../cache/memory_lru_cache.dart';
import '../events/app_event_bus.dart';
import '../logging/logger.dart';
import '../persistence/in_memory_db.dart';

class AppBootstrap {
  AppBootstrap._(this._di);

  final GetIt _di;

  static Future<AppBootstrap> initialize() async {
    final di = GetIt.asNewInstance();

    di.registerSingleton(AppLogger());
    di.registerSingleton(AppEventBus());
    di.registerSingleton<CacheStore>(MemoryLruCache(maxEntries: 200));
    di.registerSingleton(InMemoryDb());

    di.registerLazySingleton(() => LocalImportService(di<InMemoryDb>(), di<AppLogger>()));
    di.registerLazySingleton(() => SettingsService(di<InMemoryDb>()));
    di.registerLazySingleton(() => LibrarySearchService());
    di.registerLazySingleton(() => JsonExportService(di<InMemoryDb>()));
    di.registerLazySingleton(() => AudioPlayerService(di<AppEventBus>()));
    di.registerLazySingleton(() => PluginRuntimeService(di<InMemoryDb>(), di<AppLogger>()));

    di.registerLazySingleton(() => LibraryRepository(
          db: di<InMemoryDb>(),
          importer: di<LocalImportService>(),
          searchService: di<LibrarySearchService>(),
          exportService: di<JsonExportService>(),
        ));
    di.registerLazySingleton(() => PlaylistRepository(di<InMemoryDb>()));
    di.registerLazySingleton(() => PlaybackRepository(di<AudioPlayerService>()));

    di.registerFactory(() => LibraryCubit(di<LibraryRepository>(), di<AppEventBus>()));
    di.registerFactory(() => SearchCubit(di<LibraryRepository>()));
    di.registerFactory(() => SettingsCubit(di<SettingsService>()));
    di.registerFactory(() => PlaylistCubit(di<PlaylistRepository>()));
    di.registerFactory(() => PlaybackCubit(di<PlaybackRepository>(), di<AppEventBus>()));
    di.registerFactory(() => PluginCubit(di<PluginRuntimeService>()));

    return AppBootstrap._(di);
  }

  T get<T extends Object>() => _di<T>();

  Iterable<LocalizationsDelegate<dynamic>> get localizationDelegates => const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  Iterable<Locale> get supportedLocales => const [Locale('en')];
}
