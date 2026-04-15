import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../plugins/runtime/plugin_runtime_service.dart';

class PluginState extends Equatable {
  const PluginState({this.plugins = const []});

  final List<Map<String, dynamic>> plugins;

  PluginState copyWith({List<Map<String, dynamic>>? plugins}) => PluginState(plugins: plugins ?? this.plugins);

  @override
  List<Object?> get props => [plugins];
}

class PluginCubit extends Cubit<PluginState> {
  PluginCubit(this._runtime) : super(const PluginState());

  final PluginRuntimeService _runtime;

  Future<void> loadPlugins() async => emit(state.copyWith(plugins: _runtime.listInstalledPlugins()));

  Future<void> toggle(String pluginId, bool enabled) async {
    await _runtime.setEnabled(pluginId, enabled);
    await loadPlugins();
  }
}
