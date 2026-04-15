enum PluginCapability { search, homeSections, resolvePlayableMedia, lyricsLookup, recommendations }

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

abstract interface class MusicSourcePlugin {
  PluginManifest get manifest;

  Future<List<Map<String, String>>> search(String query);
  Future<List<Map<String, String>>> homeSections();
  Future<Uri?> resolvePlayableMedia(String contentId);
}
