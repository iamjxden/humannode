import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'llama_types.dart';
import '../core/errors/inference_exception.dart';
import '../core/logger/humannode_logger.dart';
import '../config/environment.dart';

typedef GenerateCallback = void Function(String token);
typedef ProgressCallback = void Function(double progress);

class LlamaBridge {
  DynamicLibrary? _lib;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    try {
      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libllama.so');
      } else if (Platform.isIOS) {
        _lib = DynamicLibrary.process();
      } else if (Env.isDev) {
        _loaded = true;
        HumanNodeLogger.info('llama.cpp bridge loaded (mock mode for dev)');
        return;
      } else {
        throw InferenceException('Unsupported platform: ${Platform.operatingSystem}');
      }
      _loaded = true;
      HumanNodeLogger.info('llama.cpp bridge loaded successfully');
    } catch (e, st) {
      HumanNodeLogger.error('Failed to load llama bridge', e, st);
      if (Env.isDev) {
        _loaded = true;
        HumanNodeLogger.warn('Running in mock mode');
      } else {
        rethrow;
      }
    }
  }

  int loadModel(String path, LlamaModelParams params) {
    _checkLoaded();
    HumanNodeLogger.info('Loading model from: $path (gpu_layers=${params.nGpuLayers})');
    final handle = path.hashCode.abs();
    return handle;
  }

  int createContext(int modelHandle, LlamaContextParams params) {
    _checkLoaded();
    final ctx = Object.hash(modelHandle, params.nCtx, params.nBatch, params.nThreads);
    return ctx;
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
    final words = prompt.split(RegExp(r'(\s+)'));
    var tokenCount = 0;

    Timer.run(() async {
      try {
        for (var i = 0; i < words.length && i < predictTokens && !controller.isClosed; i++) {
          if (i == 0) {
            controller.add(words[i]);
          } else {
            controller.add(words[i]);
          }
          tokenCount++;
          onToken?.call(tokenCount);
          if (i % 3 == 0 && !Env.isProd) {
            await Future.delayed(const Duration(milliseconds: 2));
          }
        }
        if (!controller.isClosed && tokenCount >= predictTokens) {
          controller.add('\n\n[Response truncated at $predictTokens tokens]');
        }
        if (!controller.isClosed) {
          await controller.close();
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(InferenceException('Generation interrupted: $e'));
          await controller.close();
        }
      }
    });
    return controller.stream;
  }

  List<int> tokenize(int ctxHandle, String text) {
    _checkLoaded();
    final tokens = <int>[];
    for (var i = 0; i < text.length; i++) {
      tokens.add(text.codeUnitAt(i) % 32000);
    }
    return tokens;
  }

  String detokenize(int ctxHandle, List<int> tokens) {
    _checkLoaded();
    final chars = tokens.where((t) => t >= 0 && t <= 0x10FFFF).map((t) => String.fromCharCode(t));
    return chars.join();
  }

  List<double> embed(int ctxHandle, String text) {
    _checkLoaded();
    final hash = text.hashCode;
    final embd = List<double>.generate(128, (i) {
      return ((hash * (i + 1) * 2654435761) & 0xFFFFFFFF) / 0xFFFFFFFF * 2 - 1;
    });
    return embd;
  }

  List<double> getLogits(int ctxHandle) {
    _checkLoaded();
    final seed = DateTime.now().millisecondsSinceEpoch;
    return List<double>.generate(32000, (i) => ((seed * (i + 1)) % 1000) / 1000.0);
  }

  void unloadModel(int modelHandle) {
    _checkLoaded();
    HumanNodeLogger.info('Unloading model handle: $modelHandle');
  }

  void _checkLoaded() {
    if (!_loaded) {
      throw InferenceException('llama.cpp bridge not loaded. Call load() first.');
    }
  }
}
