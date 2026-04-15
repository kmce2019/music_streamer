import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_streamer/blocs/settings/settings_cubit.dart';
import 'package:music_streamer/core/persistence/in_memory_db.dart';
import 'package:music_streamer/services/settings/settings_service.dart';

void main() {
  test('setThemeMode updates state', () async {
    final cubit = SettingsCubit(SettingsService(InMemoryDb()));

    await cubit.setThemeMode(ThemeMode.dark);

    expect(cubit.state.themeMode, ThemeMode.dark);
  });
}
