import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/service_locator.dart';
import '../inference/model_loader.dart';

class InferenceState {
  final bool isLoaded;
  final bool isGenerating;
  final String? modelPath;
  final String? modelName;
  final int? contextSize;
  final double? tokensPerSecond;
  final int? totalTokens;
  final String? error;

  const InferenceState({
    this.isLoaded = false, this.isGenerating = false,
    this.modelPath, this.modelName, this.contextSize,
    this.tokensPerSecond, this.totalTokens, this.error,
  });

  InferenceState copyWith({
    bool? isLoaded, bool? isGenerating, String? modelPath,
    String? modelName, int? contextSize, double? tokensPerSecond,
    int? totalTokens, String? error,
  }) => InferenceState(
    isLoaded: isLoaded ?? this.isLoaded,
    isGenerating: isGenerating ?? this.isGenerating,
    modelPath: modelPath ?? this.modelPath,
    modelName: modelName ?? this.modelName,
    contextSize: contextSize ?? this.contextSize,
    tokensPerSecond: tokensPerSecond ?? this.tokensPerSecond,
    totalTokens: totalTokens ?? this.totalTokens,
    error: error,
  );
}

class InferenceNotifier extends StateNotifier<InferenceState> {
  InferenceNotifier() : super(const InferenceState());

  Future<void> loadModel(String path) async {
    state = state.copyWith(isLoaded: false, modelPath: path,
        modelName: path.split('/').last, error: null);
    try {
      final result = await ServiceLocator.modelLoader.load(path);
      state = state.copyWith(
        isLoaded: true,
        modelName: result.info.name,
        contextSize: result.info.contextSize,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setGenerating(bool generating) => state = state.copyWith(isGenerating: generating);

  void updateStats(int totalTokens, double tps) {
    state = state.copyWith(totalTokens: totalTokens, tokensPerSecond: tps);
  }

  void unloadModel() {
    if (state.modelPath != null) {
      ServiceLocator.modelLoader.unload(state.modelPath!);
    }
    state = const InferenceState();
  }

  void clearError() => state = state.copyWith(error: null);
}

final inferenceProvider = StateNotifierProvider<InferenceNotifier, InferenceState>((ref) => InferenceNotifier());
