import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/models_provider.dart';
import '../../../providers/inference_provider.dart';
import 'model_card.dart';
import 'model_registry_browser.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({super.key});
  @override ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  @override void initState() {
    super.initState();
    Future.microtask(() => ref.read(modelsProvider.notifier).refresh());
  }

  @override Widget build(BuildContext context) {
    final state = ref.watch(modelsProvider);
    final infState = ref.watch(inferenceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Models'),
        actions: [
          IconButton(icon: const Icon(Icons.cloud_download_rounded), tooltip: 'Browse Catalog', onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => const ModelRegistryBrowser(),
            );
          }),
        ],
      ),
      body: state.installedModels.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.smart_toy_outlined, size: 72, color: Theme.of(context).colorScheme.primary.withAlpha(80)),
                  const SizedBox(height: 20),
                  Text('No models installed', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Download a model to start chatting with HumanNode',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context, isScrollControlled: true,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => const ModelRegistryBrowser(),
                    ),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Browse Catalog'),
                  ),
                ]),
              ))
          : RefreshIndicator(
              onRefresh: () => ref.read(modelsProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.installedModels.length,
                itemBuilder: (context, i) => ModelCard(modelName: state.installedModels[i]),
              ),
            ),
    );
  }
}
