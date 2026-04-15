import '../contracts/plugin_contract.dart';

class RadioDirectoryPlugin implements MusicSourcePlugin {
  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'safe.radio.directory',
        name: 'Safe Radio Directory',
        version: '1.0.0',
        capabilities: {
          PluginCapability.search,
          PluginCapability.homeSections,
          PluginCapability.resolvePlayableMedia,
        },
        permissions: {'network:radio_streams'},
        checksum: 'sha256:demo-safe-plugin-checksum',
        enabledByDefault: true,
      );

  static const _stations = [
    {
      'id': 'bbc-world-service',
      'title': 'BBC World Service',
      'streamUrl': 'https://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
    },
    {
      'id': 'nasa-third-rock',
      'title': 'NASA Third Rock Radio',
      'streamUrl': 'https://nasatv-lh.akamaihd.net/i/NASA_101@319270/master.m3u8',
    },
  ];

  @override
  Future<List<Map<String, String>>> homeSections() async => _stations
      .map((station) => {'id': station['id']!, 'title': station['title']!, 'type': 'station'})
      .toList();

  @override
  Future<Uri?> resolvePlayableMedia(String contentId) async {
    Map<String, String>? station;
    for (final item in _stations) {
      if (item['id'] == contentId) {
        station = item;
        break;
      }
    }
    if (station == null) return null;
    return Uri.parse(station['streamUrl']!);
  }

  @override
  Future<List<Map<String, String>>> search(String query) async {
    final q = query.toLowerCase();
    return _stations
        .where((s) => s['title']!.toLowerCase().contains(q))
        .map((s) => {'id': s['id']!, 'title': s['title']!, 'type': 'station'})
        .toList();
  }
}
