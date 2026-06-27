import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/models_provider.dart';
import '../../providers/inference_provider.dart';
import '../../core/di/service_locator.dart';

class ModelPickerSheet extends ConsumerWidget {
  const ModelPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(modelsProvider);
    final inf = ref.watch(inferenceProvider);
    final installed = models.installedModels;

    return SizedBox(
      height: 320,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Text('Select Model',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            if (inf.isLoaded)
              TextButton.icon(
                onPressed: () {
                  ref.read(inferenceProvider.notifier).unloadModel();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.eject_rounded,
                    size: 16, color: Colors.red),
                label: const Text('Unload',
                    style: TextStyle(color: Colors.red)),
              ),
          ]),
        ),
        if (installed.isEmpty)
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.smart_toy_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No models installed',
                      style: TextStyle(fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Download from the catalog',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ]),
              ),
            ),
          ),
        if (installed.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: installed.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, i) {
                final rawName = installed[i];
                final cleanName = rawName.replaceAll('.gguf', '');
                final isActive = inf.modelName == cleanName;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isActive
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isActive
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: Icon(Icons.smart_toy_rounded,
                          size: 20,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : null),
                    ),
                    title: Text(cleanName,
                        style: TextStyle(
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500)),
                    trailing: isActive
                        ? Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20)
                        : null,
                    onTap: () {
                      if (!isActive) {
                        ServiceLocator.fileCache
                            .getModelPath(rawName)
                            .then((path) {
                          ref
                              .read(inferenceProvider.notifier)
                              .loadModel(path);
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
            ),
          ),
      ]),
    );
  }
}
