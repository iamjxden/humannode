import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humannode/config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: const SizedBox(width: 56),
        title: const Text('Settings'),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _section('Preferences'),
        _tile(context, Icons.tune_rounded, 'General', '/home/settings/general'),
        _tile(context, Icons.smart_toy_rounded, 'Models', '/home/settings/models'),
        _tile(context, Icons.thermostat_rounded, 'Generation', '/home/settings/generation'),
        _tile(context, Icons.auto_awesome_rounded, 'Agent', '/home/settings/agent'),
        _section('Providers'),
        _tile(context, Icons.vpn_key_rounded, 'API Keys', '/home/settings/api-keys'),
        _section('Data'),
        _tile(context, Icons.storage_rounded, 'Storage', '/home/settings/storage'),
        _section('Legal'),
        _tile(context, Icons.policy_rounded, 'Privacy Policy', '/home/settings/about'),
        _tile(context, Icons.gavel_rounded, 'Terms of Service', '/home/settings/about'),
        _section('Info'),
        _tile(context, Icons.info_outline_rounded, 'About', '/home/settings/about'),
        _tile(context, Icons.bug_report_rounded, 'Debug', '/home/settings/debug'),
        const SizedBox(height: 32),
        const Center(
          child: Column(children: [
            Text('HumanNode',
                style: TextStyle(
                    color: HumanNodeTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            SizedBox(height: 2),
            Text('Built by Jaden · v1.0.0',
                style: TextStyle(
                    color: HumanNodeTheme.textSecondary, fontSize: 11)),
          ]),
        ),
      ]),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
        child: Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: HumanNodeTheme.textSecondary,
                letterSpacing: 1.2)),
      );

  Widget _tile(BuildContext ctx, IconData icon, String title, String route) =>
      Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: HumanNodeTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: HumanNodeTheme.border, width: 0.5),
        ),
        child: ListTile(
          leading: Icon(icon, size: 20, color: HumanNodeTheme.textSecondary),
          title: Text(title,
              style: const TextStyle(
                  color: HumanNodeTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right_rounded,
              size: 18, color: HumanNodeTheme.textSecondary),
          onTap: () => ctx.push(route),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}
