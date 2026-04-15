import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_cubit.dart';
import '../../blocs/plugins/plugin_cubit.dart';
import '../../blocs/settings/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return ListTile(
                title: const Text('Theme'),
                subtitle: const Text('System / Light / Dark'),
                trailing: DropdownButton<ThemeMode>(
                  value: state.themeMode,
                  onChanged: (mode) {
                    if (mode != null) context.read<SettingsCubit>().setThemeMode(mode);
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Export library metadata'),
            subtitle: const Text('Exports tracks/albums/artists JSON to clipboard-ready dialog'),
            onTap: () {
              final json = context.read<LibraryCubit>().exportAsJson();
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Library JSON'),
                  content: SingleChildScrollView(child: SelectableText(json)),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Plugins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<PluginCubit>().install(const {
                  'id': 'safe.external.manifest.demo',
                  'name': 'Safe Manifest Demo',
                  'version': '1.0.0',
                  'capabilities': ['search'],
                  'permissions': ['network:readonly_api'],
                  'checksum': 'sha256:demo-safe-manifest',
                  'enabledByDefault': false,
                });
              },
              icon: const Icon(Icons.extension),
              label: const Text('Install demo manifest'),
            ),
          ),
          BlocBuilder<PluginCubit, PluginState>(
            builder: (context, state) {
              return Column(
                children: [
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  ...state.plugins.map(
                    (p) => SwitchListTile(
                      title: Text(p.manifest.name),
                      subtitle: Text('Capabilities: ${p.manifest.capabilities.map((c) => c.name).join(', ')}'),
                      value: p.enabled,
                      onChanged: (v) => context.read<PluginCubit>().toggle(p.manifest.id, v),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
