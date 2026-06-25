import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/service_locator.dart';

class ModelsState {
  final List<String> installedModels;
  final Map<String, double> downloadProgress;
  final bool isLoadingCatalog;
  final String? error;

  const ModelsState({
    this.installedModels = const [],
    this.downloadProgress = const {},
    this.isLoadingCatalog = false,
    this.error,
  });

  ModelsState copyWith({
    List<String>? installedModels, Map<String, double>? downloadProgress,
    bool? isLoadingCatalog, String? error,
  }) => ModelsState(
    installedModels: installedModels ?? this.installedModels,
    downloadProgress: downloadProgress ?? this.downloadProgress,
    isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
    error: error,
  );
}

class ModelsNotifier extends StateNotifier<ModelsState> {
  ModelsNotifier() : super(const ModelsState());

  Future<void> refresh() async {
    final models = await ServiceLocator.fileCache.listCachedModels();
    state = state.copyWith(installedModels: models);
  }

  void updateDownload(String modelName, double progress) {
    final newProgress = Map<String, double>.from(state.downloadProgress);
    newProgress[modelName] = progress;
    if (progress >= 1.0) {
      final installed = List<String>.from(state.installedModels);
      if (!installed.contains(modelName)) {
        installed.add(modelName);
      }
      newProgress.remove(modelName);
      state = state.copyWith(installedModels: installed, downloadProgress: newProgress);
    } else {
      state = state.copyWith(downloadProgress: newProgress);
    }
  }

  Future<void> remove(String modelName) async {
    await ServiceLocator.fileCache.remove(modelName);
    await refresh();
  }

  Future<int> getCacheSize() async => ServiceLocator.fileCache.getCacheSize();
}

final modelsProvider = StateNotifierProvider<ModelsNotifier, ModelsState>((ref) => ModelsNotifier());
