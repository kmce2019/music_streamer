enum PluginCapability {
  search,
  homeSections,
  resolvePlayableMedia,
  lyricsLookup,
  recommendations,
}

class PluginManifest {
  const PluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.capabilities,
    required this.permissions,
    required this.checksum,
    this.enabledByDefault = false,
  });

  final String id;
  final String name;
  final String version;
  final Set<PluginCapability> capabilities;
  final Set<String> permissions;
  final String checksum;
  final bool enabledByDefault;

  factory PluginManifest.fromJson(Map<String, dynamic> json) {
    return PluginManifest(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      capabilities: (json['capabilities'] as List<dynamic>)
          .map((cap) => PluginCapability.values.firstWhere((e) => e.name == cap))
          .toSet(),
      permissions: (json['permissions'] as List<dynamic>).cast<String>().toSet(),
      checksum: json['checksum'] as String,
      enabledByDefault: (json['enabledByDefault'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'version': version,
        'capabilities': capabilities.map((e) => e.name).toList(),
        'permissions': permissions.toList(),
        'checksum': checksum,
        'enabledByDefault': enabledByDefault,
      };
}

class InstalledPlugin {
  const InstalledPlugin({
    required this.manifest,
    required this.enabled,
    this.isBuiltin = false,
  });

  final PluginManifest manifest;
  final bool enabled;
  final bool isBuiltin;

  InstalledPlugin copyWith({bool? enabled}) {
    return InstalledPlugin(
      manifest: manifest,
      enabled: enabled ?? this.enabled,
      isBuiltin: isBuiltin,
    );
  }

  factory InstalledPlugin.fromJson(Map<String, dynamic> json) {
    return InstalledPlugin(
      manifest: PluginManifest.fromJson(json),
      enabled: (json['enabled'] as bool?) ?? false,
      isBuiltin: (json['isBuiltin'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        ...manifest.toJson(),
        'enabled': enabled,
        'isBuiltin': isBuiltin,
      };
}

abstract interface class MusicSourcePlugin {
  PluginManifest get manifest;

  Future<List<Map<String, String>>> search(String query);
  Future<List<Map<String, String>>> homeSections();
  Future<Uri?> resolvePlayableMedia(String contentId);
}
