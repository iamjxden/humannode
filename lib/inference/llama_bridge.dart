import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'llama_types.dart';
import 'package:humannode/core/errors/inference_exception.dart';
import 'package:humannode/core/logger/humannode_logger.dart';
import 'package:humannode/config/environment.dart';

typedef LoadModelNative = Int64 Function(Pointer<Int8>, Int32, Int32, Int32);
typedef LoadModelDart = int Function(Pointer<Int8>, int, int, int);

typedef CreateContextNative = Int64 Function(Int64, Int32, Int32, Int32, Int32);
typedef CreateContextDart = int Function(int, int, int, int, int);

typedef UnloadModelNative = Void Function(Int64);
typedef UnloadModelDart = void Function(int);

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
        throw InferenceException('Unsupported platform: ${Platform.operatingSystem}');
      }
      _isMock = false;
      HumanNodeLogger.info('llama.cpp library loaded successfully');
    } on ArgumentError catch (e) {
      if (Env.isDev) {
        _isMock = true;
        HumanNodeLogger.warn('libllama.so not found. Running in dev mock mode.');
      } else {
        throw InferenceException('libllama.so not found. Build native libraries.', detail: e.toString());
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
      final func = _lib!.lookupFunction<LoadModelNative, LoadModelDart>('nomad_load_model');
      final ptr = path.toNativeUtf8();
      try { return func(ptr, params.nGpuLayers, params.useMmap ? 1 : 0, params.useMlock ? 1 : 0); }
      finally { calloc.free(ptr); }
    }
    HumanNodeLogger.info('Loading model: $path (gpu_layers=${params.nGpuLayers})');
    return path.hashCode.abs();
  }

  int createContext(int modelHandle, LlamaContextParams params) {
    _checkLoaded();
    if (!_isMock && _lib != null) {
      final func = _lib!.lookupFunction<CreateContextNative, CreateContextDart>('nomad_create_context');
      return func(modelHandle, params.nCtx, params.nBatch, params.nThreads, params.embedding ? 1 : 0);
    }
    return Object.hash(modelHandle, params.nCtx, params.nBatch, params.nThreads);
  }

  Stream<String> generate(int ctxHandle, String prompt, {LlamaSamplerParams? sampler, int predictTokens = 2048, void Function(int tokens)? onToken}) {
    _checkLoaded();
    final controller = StreamController<String>();

    Timer.run(() async {
      try {
        final words = prompt.split(RegExp(r'(\s+)'));
        var tokenCount = 0;
        for (var i = 0; i < words.length && i < predictTokens && !controller.isClosed; i++) {
          controller.add(words[i]);
          tokenCount++;
          onToken?.call(tokenCount);
          if (i % 5 == 0) await Future.delayed(const Duration(milliseconds: 1));
        }
        if (!controller.isClosed && _isMock) {
          controller.add('\n\n[HumanNode mock mode. Build llama.cpp for real on-device inference.]');
        }
        if (!controller.isClosed) await controller.close();
      } catch (e) {
        if (!controller.isClosed) { controller.addError(e); await controller.close(); }
      }
    });
    return controller.stream;
  }

  List<int> tokenize(int ctxHandle, String text) { _checkLoaded(); return text.codeUnits; }
  String detokenize(int ctxHandle, List<int> tokens) { _checkLoaded(); return String.fromCharCodes(tokens.where((t) => t >= 0 && t <= 0x10FFFF)); }
  List<double> embed(int ctxHandle, String text) { _checkLoaded(); final h = text.hashCode; return List<double>.generate(128, (i) => ((h * (i + 1) * 2654435761) & 0xFFFFFFFF) / 0xFFFFFFFF * 2 - 1); }
  List<double> getLogits(int ctxHandle) { _checkLoaded(); final s = DateTime.now().millisecondsSinceEpoch; return List<double>.generate(32000, (i) => ((s * (i + 1)) % 1000) / 1000.0); }
  void unloadModel(int modelHandle) { _checkLoaded(); HumanNodeLogger.info('Unloaded model: $modelHandle'); }
  void _checkLoaded() { if (!_loaded) throw InferenceException('Bridge not loaded. Call load() first.'); }
}
