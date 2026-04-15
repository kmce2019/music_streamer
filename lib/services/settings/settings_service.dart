import 'package:flutter/material.dart';

import '../../core/persistence/in_memory_db.dart';

class SettingsService {
  SettingsService(this._db);

  final InMemoryDb _db;

  ThemeMode getThemeMode() {
    final value = _db.settings['themeMode'] as String?;
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _db.settings['themeMode'] = mode.name;
  }
}
