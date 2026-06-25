import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '1.0.0';
  String _build = '1';

  @override void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() { _version = info.version; _build = info.buildNumber; });
    });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 42),
            ),
            const SizedBox(height: 20),
            Text('HumanNode', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Version $_version (build $_build)', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
            const SizedBox(height: 20),
            Text('Local-first AI workspace.\nYour data, your device, your rules.',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                  Scaffold(appBar: AppBar(title: const Text('Licenses')), body: const LicensePage()))),
              child: const Text('Licenses'),
            ),
            const SizedBox(height: 6),
            TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
          ]),
        ),
      ),
    );
  }
}
