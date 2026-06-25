import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});
  @override State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final _openaiCtrl = TextEditingController();
  final _anthropicCtrl = TextEditingController();
  final _openrouterCtrl = TextEditingController();

  @override void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _openaiCtrl.text = await ServiceLocator.secureStore.getApiKey('openai') ?? '';
    _anthropicCtrl.text = await ServiceLocator.secureStore.getApiKey('anthropic') ?? '';
    _openrouterCtrl.text = await ServiceLocator.secureStore.getApiKey('openrouter') ?? '';
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    await ServiceLocator.secureStore.saveApiKey('openai', _openaiCtrl.text);
    await ServiceLocator.secureStore.saveApiKey('anthropic', _anthropicCtrl.text);
    await ServiceLocator.secureStore.saveApiKey('openrouter', _openrouterCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API keys saved securely')));
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Keys')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('These keys are stored encrypted in the device keystore. They are never sent to any server except the API provider you choose.',
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
        const SizedBox(height: 20),
        TextField(
          controller: _openaiCtrl, obscureText: true,
          decoration: InputDecoration(
            labelText: 'OpenAI API Key', hintText: 'sk-...',
            prefixIcon: const Icon(Icons.key_rounded, size: 20),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _anthropicCtrl, obscureText: true,
          decoration: InputDecoration(
            labelText: 'Anthropic API Key', hintText: 'sk-ant-...',
            prefixIcon: const Icon(Icons.key_rounded, size: 20),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _openrouterCtrl, obscureText: true,
          decoration: InputDecoration(
            labelText: 'OpenRouter API Key', hintText: 'sk-or-...',
            prefixIcon: const Icon(Icons.key_rounded, size: 20),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Save Keys'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            await ServiceLocator.secureStore.clearAll();
            _openaiCtrl.clear();
            _anthropicCtrl.clear();
            _openrouterCtrl.clear();
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All keys cleared')));
          },
          icon: const Icon(Icons.delete_sweep_rounded),
          label: const Text('Clear All Keys'),
          style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
        ),
      ]),
    );
  }

  @override void dispose() {
    _openaiCtrl.dispose();
    _anthropicCtrl.dispose();
    _openrouterCtrl.dispose();
    super.dispose();
  }
}
