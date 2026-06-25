import 'package:flutter/material.dart';
import '../../../config/environment.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        _section(context, 'Preferences'),
        _tile(context, Icons.tune_rounded, 'General', '/home/settings/general'),
        _tile(context, Icons.smart_toy_rounded, 'Models', '/home/settings/models'),
        _tile(context, Icons.thermostat_rounded, 'Generation', '/home/settings/generation'),
        _tile(context, Icons.auto_awesome_rounded, 'Agent', '/home/settings/agent'),
        _section(context, 'Providers'),
        _tile(context, Icons.key_rounded, 'API Keys', '/home/settings/api-keys'),
        _section(context, 'Data'),
        _tile(context, Icons.storage_rounded, 'Storage', '/home/settings/storage'),
        _section(context, 'Info'),
        _tile(context, Icons.info_outline_rounded, 'About', '/home/settings/about'),
        if (Env.enableDebugScreen)
          _tile(context, Icons.bug_report_rounded, 'Debug', '/home/settings/debug'),
      ]),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
    child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary, letterSpacing: 1.0)),
  );

  Widget _tile(BuildContext context, IconData icon, String title, String route) => ListTile(
    leading: Icon(icon, size: 22),
    title: Text(title, style: const TextStyle(fontSize: 15)),
    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    onTap: () => Navigator.pushNamed(context, route),
  );
}
