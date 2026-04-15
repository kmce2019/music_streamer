import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../services/settings/settings_service.dart';

class SettingsState extends Equatable {
  const SettingsState({this.themeMode = ThemeMode.system});

  final ThemeMode themeMode;

  SettingsState copyWith({ThemeMode? themeMode}) => SettingsState(themeMode: themeMode ?? this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsService) : super(const SettingsState()) {
    emit(state.copyWith(themeMode: _settingsService.getThemeMode()));
  }

  final SettingsService _settingsService;

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsService.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }
}
