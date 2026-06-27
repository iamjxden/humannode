import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humannode/config/theme.dart';
import 'package:humannode/providers/models_provider.dart';
import 'package:humannode/providers/inference_provider.dart';
import 'package:humannode/core/di/service_locator.dart';
import 'model_registry_browser.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({super.key});

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(modelsProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final models = ref.watch(modelsProvider);
    final inf = ref.watch(inferenceProvider);

    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        title: const Text('Models',
            style: TextStyle(
                color: HumanNodeTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20)),
        leading: const SizedBox(width: 56),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: HumanNodeTheme.textSecondary),
            onPressed: () => _showCatalog(context),
          ),
        ],
      ),
      body: models.installedModels.isEmpty
          ? _Empty(onBrowse: () => _showCatalog(context))
          : RefreshIndicator(
              onRefresh: () => ref.read(modelsProvider.notifier).refresh(),
              color: HumanNodeTheme.primary,
              backgroundColor: HumanNodeTheme.surfaceCard,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: models.installedModels.length,
                itemBuilder: (ctx, i) => _ModelCard(
                  name: models.installedModels[i],
                  isActive: inf.modelName ==
                      models.installedModels[i].replaceAll('.gguf', ''),
                  isLoading: inf.isLoaded == false && inf.modelPath != null,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCatalog(context),
        backgroundColor: HumanNodeTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.download_rounded),
        label: const Text('Get Models',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showCatalog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HumanNodeTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const ModelRegistryBrowser(),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onBrowse;
  const _Empty({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: HumanNodeTheme.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: HumanNodeTheme.border, width: 0.5),
          ),
          child: const Icon(Icons.smart_toy_outlined,
              size: 40, color: HumanNodeTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        const Text('No models installed',
            style: TextStyle(
                color: HumanNodeTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        const SizedBox(height: 8),
        const Text('Download a model to start chatting with HumanNode',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: HumanNodeTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onBrowse,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Browse Catalog'),
        ),
      ]),
    );
  }
}

class _ModelCard extends ConsumerWidget {
  final String name;
  final bool isActive;
  final bool isLoading;

  const _ModelCard({
    required this.name,
    required this.isActive,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanName = name.replaceAll('.gguf', '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HumanNodeTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? HumanNodeTheme.primary.withAlpha(100)
              : HumanNodeTheme.border,
          width: isActive ? 1 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF818CF8), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)
                  : null,
              color: isActive ? null : HumanNodeTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                          color: HumanNodeTheme.primary.withAlpha(80),
                          blurRadius: 12)
                    ]
                  : null,
            ),
            child: Icon(Icons.smart_toy_rounded,
                color: isActive
                    ? Colors.white
                    : HumanNodeTheme.textSecondary,
                size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(cleanName,
                  style: const TextStyle(
                      color: HumanNodeTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Row(children: [
                if (isActive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: HumanNodeTheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Active',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: HumanNodeTheme.primary)),
                  ),
                  const SizedBox(width: 6),
                ],
                const Text('GGUF',
                    style: TextStyle(
                        fontSize: 11,
                        color: HumanNodeTheme.textSecondary)),
              ]),
            ]),
          ),
          GestureDetector(
            onTap: () {
              if (isActive) {
                ref.read(inferenceProvider.notifier).unloadModel();
              } else {
                ServiceLocator.fileCache
                    .getModelPath(name)
                    .then((path) {
                  ref.read(inferenceProvider.notifier).loadModel(path);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.red.withAlpha(20)
                    : HumanNodeTheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? Colors.red.withAlpha(60)
                      : HumanNodeTheme.primary.withAlpha(60),
                  width: 0.5,
                ),
              ),
              child: Text(
                isActive ? 'Unload' : 'Load',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? const Color(0xFFEF4444)
                        : HumanNodeTheme.primary),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
