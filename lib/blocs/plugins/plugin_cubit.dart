import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../plugins/contracts/plugin_contract.dart';
import '../../plugins/runtime/plugin_runtime_service.dart';

class PluginState extends Equatable {
  const PluginState({this.plugins = const [], this.error});

  final List<InstalledPlugin> plugins;
  final String? error;

  PluginState copyWith({List<InstalledPlugin>? plugins, String? error}) {
    return PluginState(
      plugins: plugins ?? this.plugins,
      error: error,
    );
  }

  @override
  List<Object?> get props => [plugins, error];
}

class PluginCubit extends Cubit<PluginState> {
  PluginCubit(this._runtime) : super(const PluginState());

  final PluginRuntimeService _runtime;

  Future<void> loadPlugins() async {
    emit(state.copyWith(plugins: _runtime.listInstalledPlugins(), error: null));
  }

  Future<void> install(Map<String, dynamic> manifestJson) async {
    try {
      await _runtime.installManifest(manifestJson);
      await loadPlugins();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> toggle(String pluginId, bool enabled) async {
    await _runtime.setEnabled(pluginId, enabled);
    await loadPlugins();
  }

  Future<void> saveSettings(String pluginId, Map<String, dynamic> settings) async {
    await _runtime.savePluginSettings(pluginId, settings);
    await loadPlugins();
  }
}
