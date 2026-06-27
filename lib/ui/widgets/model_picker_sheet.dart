import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humannode/config/theme.dart';
import 'package:humannode/providers/models_provider.dart';
import 'package:humannode/providers/inference_provider.dart';
import 'package:humannode/core/di/service_locator.dart';

class ModelPickerSheet extends ConsumerWidget {
  const ModelPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(modelsProvider);
    final inf = ref.watch(inferenceProvider);
    final installed = models.installedModels;

    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: const BoxDecoration(
        color: HumanNodeTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 32,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 16),
          decoration: BoxDecoration(
              color: HumanNodeTheme.border,
              borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('Select Model',
                style: TextStyle(
                    color: HumanNodeTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const Spacer(),
            if (inf.isLoaded)
              TextButton.icon(
                onPressed: () {
                  ref.read(inferenceProvider.notifier).unloadModel();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.eject_rounded,
                    size: 14, color: Colors.red),
                label: const Text('Unload',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        if (installed.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              const Icon(Icons.smart_toy_outlined,
                  size: 48, color: HumanNodeTheme.textSecondary),
              const SizedBox(height: 12),
              const Text('No models installed',
                  style: TextStyle(
                      color: HumanNodeTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/home/models');
                },
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Browse Models'),
              ),
            ]),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              itemCount: installed.length,
              itemBuilder: (ctx, i) {
                final raw = installed[i];
                final clean = raw.replaceAll('.gguf', '');
                final isActive = inf.modelName == clean;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? HumanNodeTheme.primary.withAlpha(15)
                        : HumanNodeTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? HumanNodeTheme.primary.withAlpha(80)
                          : HumanNodeTheme.border,
                      width: 0.5,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? const LinearGradient(colors: [
                                Color(0xFF818CF8),
                                Color(0xFF4338CA)
                              ])
                            : null,
                        color:
                            isActive ? null : HumanNodeTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.smart_toy_rounded,
                          size: 18,
                          color: isActive
                              ? Colors.white
                              : HumanNodeTheme.textSecondary),
                    ),
                    title: Text(clean,
                        style: TextStyle(
                            color: isActive
                                ? HumanNodeTheme.textPrimary
                                : HumanNodeTheme.textSecondary,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13)),
                    trailing: isActive
                        ? const Icon(Icons.check_circle_rounded,
                            color: HumanNodeTheme.primary, size: 18)
                        : null,
                    onTap: () {
                      if (!isActive) {
                        ServiceLocator.fileCache
                            .getModelPath(raw)
                            .then((path) => ref
                                .read(inferenceProvider.notifier)
                                .loadModel(path));
                      }
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                );
              },
            ),
          ),
      ]),
    );
  }
}
