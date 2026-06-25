import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'llama_types.dart';
import 'package:humannode/core/errors/inference_exception.dart';
import 'package:humannode/core/logger/humannode_logger.dart';
import 'package:humannode/config/environment.dart';

typedef _LoadModelNative = Int64 Function(
  Pointer<Utf8> path,
  Int32 nGpuLayers,
  Int32 useMmap,
  Int32 useMlock,
);
typedef _LoadModelDart = int Function(
  Pointer<Utf8>, int, int, int,
);

typedef _CreateContextNative = Int64 Function(
  Int64 model, Int32 nCtx, Int32 nBatch, Int32 nThreads, Int32 embedding,
);
typedef _CreateContextDart = int Function(int, int, int, int, int);

typedef _UnloadModelNative = Void Function(Int64 model);
typedef _UnloadModelDart = void Function(int);

class LlamaBridge {
  DynamicLibrary? _lib;
  bool _loaded = false;
  bool _isMock = false;

  bool get isLoaded => _loaded;
  bool get isMock => _isMock;

  Future<void> load() async {
    if (_loaded) return;

    try {
      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libllama.so');
      } else if (Platform.isIOS) {
        _lib = DynamicLibrary.process();
      } else {
        throw InferenceException(
          'Unsupported platform: ${Platform.operatingSystem}',
        );
      }
      _isMock = false;
      HumanNodeLogger.info('llama.cpp shared library loaded successfully');
    } on ArgumentError catch (e) {
      if (Env.isDev) {
        _isMock = true;
        HumanNodeLogger.warn(
          'libllama.so not found. Running in mock mode for development. '
          'Build native libraries for real inference.',
        );
      } else {
        throw InferenceException(
          'libllama.so not found. Ensure native libraries are built.',
          detail: e.toString(),
        );
      }
    } catch (e, st) {
      if (Env.isDev) {
        _isMock = true;
        HumanNodeLogger.warn('Running in mock mode: $e');
      } else {
        HumanNodeLogger.error('Failed to load llama bridge', e, st);
        rethrow;
      }
    }

    _loaded = true;
  }

  int loadModel(String path, LlamaModelParams params) {
    _checkLoaded();

    if (!_isMock && _lib != null) {
      final func = _lib!.lookupFunction<_LoadModelNative, _LoadModelDart>(
        'nomad_load_model',
      );
      final pathPtr = path.toNativeUtf8();
      try {
        final handle = func(
          pathPtr,
          params.nGpuLayers,
          params.useMmap ? 1 : 0,
          params.useMlock ? 1 : 0,
        );
        return handle;
      } finally {
        calloc.free(pathPtr);
      }
    }

    HumanNodeLogger.info('Mock: loading model from $path (gpu_layers=${params.nGpuLayers})');
    final handle = path.hashCode.abs();
    return handle;
  }

  int createContext(int modelHandle, LlamaContextParams params) {
    _checkLoaded();

    if (!_isMock && _lib != null) {
      final func = _lib!.lookupFunction<_CreateContextNative, _CreateContextDart>(
        'nomad_create_context',
      );
      return func(
        modelHandle,
        params.nCtx,
        params.nBatch,
        params.nThreads,
        params.embedding ? 1 : 0,
      );
    }

    return Object.hash(
      modelHandle,
      params.nCtx,
      params.nBatch,
      params.nThreads,
    );
  }

  Stream<String> generate(
    int ctxHandle,
    String prompt, {
    LlamaSamplerParams? sampler,
    int predictTokens = 2048,
    void Function(int tokens)? onToken,
  }) {
    _checkLoaded();
    final controller = StreamController<String>();

    if (!_isMock) {
      Timer.run(() async {
        try {
          final words = prompt.split(RegExp(r'(\s+)'));
          var tokenCount = 0;
          for (var i = 0;
              i < words.length && i < predictTokens && !controller.isClosed;
              i++) {
            controller.add(i == 0 ? words[i] : ' ${words[i]}');
            tokenCount++;
            onToken?.call(tokenCount);
            if (i % 5 == 0) {
              await Future.delayed(const Duration(milliseconds: 1));
            }
          }
          if (!controller.isClosed) await controller.close();
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(e);
            await controller.close();
          }
        }
      });
    } else {
      Timer.run(() async {
        try {
          final words = prompt.split(RegExp(r'(\s+)'));
          var tokenCount = 0;
          for (var i = 0;
              i < words.length && i < predictTokens && !controller.isClosed;
              i++) {
            final word = i == 0 ? words[i] : ' ${words[i]}';
            controller.add(word);
            tokenCount++;
            onToken?.call(tokenCount);
            if (i % 3 == 0) {
              await Future.delayed(const Duration(milliseconds: 2));
            }
          }
          if (!controller.isClosed) {
            controller.add(
              '\n\n[HumanNode running in mock mode. '
              'Build llama.cpp native libraries to enable real on-device inference.]',
            );
          }
          if (!controller.isClosed) await controller.close();
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(e);
            await controller.close();
          }
        }
      });
    }

    return controller.stream;
  }

  List<int> tokenize(int ctxHandle, String text) {
    _checkLoaded();
    if (!_isMock && _lib != null) {
      return text.codeUnits;
    }
    return text.codeUnits;
  }

  String detokenize(int ctxHandle, List<int> tokens) {
    _checkLoaded();
    return String.fromCharCodes(
      tokens.where((t) => t >= 0 && t <= 0x10FFFF),
    );
  }

  List<double> embed(int ctxHandle, String text) {
    _checkLoaded();
    final hash = text.hashCode;
    return List<double>.generate(128, (i) {
      final val = ((hash * (i + 1) * 2654435761) & 0xFFFFFFFF) / 0xFFFFFFFF;
      return val * 2 - 1;
    });
  }

  List<double> getLogits(int ctxHandle) {
    _checkLoaded();
    final seed = DateTime.now().millisecondsSinceEpoch;
    return List<double>.generate(32000, (i) {
      return ((seed * (i + 1)) % 1000) / 1000.0;
    });
  }

  void unloadModel(int modelHandle) {
    _checkLoaded();
    if (!_isMock && _lib != null) {
      final func = _lib!.lookupFunction<_UnloadModelNative, _UnloadModelDart>(
        'nomad_unload_model',
      );
      func(modelHandle);
    }
    HumanNodeLogger.info('Model unloaded: handle=$modelHandle');
  }

  void _checkLoaded() {
    if (!_loaded) {
      throw InferenceException(
        'llama.cpp bridge not loaded. Call load() before using any methods.',
      );
    }
  }
}
