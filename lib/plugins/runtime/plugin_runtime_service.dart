import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/logging/logger.dart';
import '../../core/persistence/in_memory_db.dart';
import '../contracts/plugin_contract.dart';
import '../example_radio/radio_directory_plugin.dart';

class PluginRuntimeService {
  PluginRuntimeService(this._db, this._logger) {
    _registerBuiltin(RadioDirectoryPlugin());
  }

  final InMemoryDb _db;
  final AppLogger _logger;

  final Map<String, MusicSourcePlugin> _plugins = {};

  static const _dangerousPermissions = {
    'filesystem:write_all',
    'process:exec',
    'network:arbitrary_proxy',
  };

  void _registerBuiltin(MusicSourcePlugin plugin) {
    final installed = InstalledPlugin(
      manifest: plugin.manifest,
      enabled: plugin.manifest.enabledByDefault,
      isBuiltin: true,
    );
    if (!_validateManifest(installed.manifest)) {
      _logger.warning('Builtin plugin ${installed.manifest.id} rejected by policy');
      return;
    }
    _plugins[installed.manifest.id] = plugin;
    _upsertInstalled(installed);
  }

  void _upsertInstalled(InstalledPlugin plugin) {
    final i = _db.pluginManifests.indexWhere((m) => m['id'] == plugin.manifest.id);
    if (i == -1) {
      _db.pluginManifests.add(plugin.toJson());
    } else {
      _db.pluginManifests[i] = plugin.toJson();
    }
  }

  // MVP checksum gate only.
  static const _dangerousPermissions = {'filesystem:write_all', 'process:exec', 'network:arbitrary_proxy'};

  void _registerBuiltin(MusicSourcePlugin plugin) {
    final manifest = plugin.manifest;
    final trusted = _validateManifest(manifest);
    if (!trusted) {
      _logger.warning('Plugin ${manifest.id} rejected by policy');
      return;
    }

    _plugins[manifest.id] = plugin;
    final existing = _db.pluginManifests.where((m) => m['id'] == manifest.id).isNotEmpty;
    if (!existing) {
      _db.pluginManifests.add({...manifest.toJson(), 'enabled': manifest.enabledByDefault});
    }
  }


  // Future Rust helper slot: verify detached signatures using native crypto.
  bool _validateManifest(PluginManifest manifest) {
    final requestsDangerous = manifest.permissions.any(_dangerousPermissions.contains);
    if (requestsDangerous) return false;

    final fingerprint = sha256.convert(
      utf8.encode('${manifest.id}:${manifest.version}:${manifest.capabilities.length}'),
    );
    return manifest.checksum.startsWith('sha256:') && fingerprint.bytes.isNotEmpty;
  }

  List<InstalledPlugin> listInstalledPlugins() {
    return _db.pluginManifests.map(InstalledPlugin.fromJson).toList(growable: false);
  }

  Future<void> installManifest(Map<String, dynamic> manifestJson) async {
    final manifest = PluginManifest.fromJson(manifestJson);
    if (!_validateManifest(manifest)) {
      throw ArgumentError('Plugin manifest validation failed for ${manifest.id}');
    }

    final installed = InstalledPlugin(
      manifest: manifest,
      enabled: manifest.enabledByDefault,
      isBuiltin: false,
    );
    _upsertInstalled(installed);
    _logger.info('Installed plugin manifest: ${manifest.id}');
  }

  Future<void> setEnabled(String pluginId, bool enabled) async {
    final installed = listInstalledPlugins();
    InstalledPlugin? plugin;
    for (final candidate in installed) {
      if (candidate.manifest.id == pluginId) {
        plugin = candidate;
        break;
      }
    }
    if (plugin == null) return;
    _upsertInstalled(plugin.copyWith(enabled: enabled));
  }

  Future<void> uninstall(String pluginId) async {
    final i = _db.pluginManifests.indexWhere((m) => m['id'] == pluginId);
    if (i < 0) return;
    if ((_db.pluginManifests[i]['isBuiltin'] as bool?) ?? false) {
      throw StateError('Builtin plugins cannot be uninstalled.');
    }
    _db.pluginManifests.removeAt(i);
    _db.pluginSettings.remove(pluginId);
    final fingerprint = sha256.convert(utf8.encode('${manifest.id}:${manifest.version}:${manifest.capabilities.length}'));
    return manifest.checksum.startsWith('sha256:') && fingerprint.bytes.isNotEmpty;
  }

  List<Map<String, dynamic>> listInstalledPlugins() => List.unmodifiable(_db.pluginManifests);

  Future<void> setEnabled(String pluginId, bool enabled) async {
    final i = _db.pluginManifests.indexWhere((m) => m['id'] == pluginId);
    if (i < 0) return;
    _db.pluginManifests[i]['enabled'] = enabled;
  }

  Future<void> savePluginSettings(String pluginId, Map<String, dynamic> settings) async {
    _db.pluginSettings[pluginId] = settings;
  }

  Map<String, dynamic> getPluginSettings(String pluginId) => _db.pluginSettings[pluginId] ?? {};
}
