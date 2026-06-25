import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/extensions/num_ext.dart';

class StorageSettings extends StatefulWidget {
  const StorageSettings({super.key});
  @override State<StorageSettings> createState() => _StorageSettingsState();
}

class _StorageSettingsState extends State<StorageSettings> {
  int _cacheSize = 0;
  int _modelCount = 0;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final size = await ServiceLocator.fileCache.getCacheSize();
    final models = await ServiceLocator.fileCache.listCachedModels();
    if (mounted) setState(() { _cacheSize = size; _modelCount = models.length; });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage')),
      body: ListView(children: [
        ListTile(title: const Text('Cached Models'), trailing: Text('$_modelCount')),
        ListTile(title: const Text('Cache Size'), trailing: Text(_cacheSize.fileSizeFormatted)),
        ListTile(
          title: const Text('Clear Model Cache'),
          subtitle: const Text('Remove all downloaded model files'),
          trailing: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onTap: () async {
            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
              title: const Text('Clear Cache'),
              content: Text('This will remove all $_modelCount downloaded models (${_cacheSize.fileSizeFormatted}). Continue?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                    child: const Text('Clear')),
              ],
            ));
            if (confirm == true) {
              await ServiceLocator.fileCache.clear();
              await _load();
            }
          },
        ),
        ListTile(title: const Text('Export All Data'), subtitle: const Text('Export conversations and notes'),
            trailing: const Icon(Icons.ios_share_rounded), onTap: () {}),
      ]),
    );
  }
}
