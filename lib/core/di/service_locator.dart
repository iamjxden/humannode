import 'package:humannode/storage/database.dart';
import 'package:humannode/storage/file_cache.dart';
import 'package:humannode/storage/secure_store.dart';
import 'package:humannode/inference/llama_bridge.dart';
import 'package:humannode/inference/model_loader.dart';
import 'package:humannode/inference/inference_engine.dart';
import 'package:humannode/inference/tokenizer.dart';
import 'package:humannode/agent/tools/tool_registry.dart';
import 'package:humannode/agent/agent_loop.dart';
import 'package:humannode/agent/agent_controller.dart';
import 'package:humannode/agent/agent_memory.dart';
import 'package:humannode/agent/agent_prompt_builder.dart';
import 'package:humannode/core/logger/humannode_logger.dart';

class ServiceLocator {
  static late AppDatabase db;
  static late SecureStore secureStore;
  static late ConversationDao conversationDao;
  static late MessageDao messageDao;
  static late NoteDao noteDao;
  static late PresetDao presetDao;
  static late SettingsDao settingsDao;
  static late FileCache fileCache;
  static late LlamaBridge llamaBridge;
  static late HumanNodeTokenizer tokenizer;
  static late ModelLoader modelLoader;
  static late InferenceEngine inferenceEngine;
  static late ToolRegistry toolRegistry;
  static late AgentMemory agentMemory;
  static late AgentPromptBuilder agentPromptBuilder;
  static late AgentLoop agentLoop;
  static late AgentController agentController;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await _bootstrap();
    _initialized = true;
    HumanNodeLogger.info('ServiceLocator initialized');
  }

  static Future<void> _bootstrap() async {
    db = AppDatabase();
    conversationDao = db.conversationDao;
    messageDao = db.messageDao;
    noteDao = db.noteDao;
    presetDao = db.presetDao;
    settingsDao = db.settingsDao;

    try {
      secureStore = SecureStore();
    } catch (e) {
      HumanNodeLogger.warn('SecureStore init failed, using fallback: $e');
      secureStore = SecureStore();
    }

    fileCache = FileCache();
    try {
      await fileCache.init();
    } catch (e) {
      HumanNodeLogger.warn('FileCache init failed: $e');
    }

    llamaBridge = LlamaBridge();
    try {
      await llamaBridge.load();
    } catch (e) {
      HumanNodeLogger.warn('LlamaBridge load failed (expected in mock mode): $e');
    }

    tokenizer = HumanNodeTokenizer();
    modelLoader = ModelLoader(llamaBridge: llamaBridge, fileCache: fileCache);
    inferenceEngine = InferenceEngine(
      llamaBridge: llamaBridge,
      modelLoader: modelLoader,
      tokenizer: tokenizer,
    );

    toolRegistry = ToolRegistry(presetDao: presetDao);
    try {
      await toolRegistry.init();
    } catch (e) {
      HumanNodeLogger.warn('ToolRegistry init failed: $e');
    }

    agentMemory = AgentMemory(messageDao: messageDao);
    agentPromptBuilder = AgentPromptBuilder(
      toolRegistry: toolRegistry,
      agentMemory: agentMemory,
    );

    try {
      await agentPromptBuilder.loadDefaultPrompt();
    } catch (e) {
      HumanNodeLogger.warn('AgentPromptBuilder prompt load failed: $e');
    }

    agentLoop = AgentLoop(
      inferenceEngine: inferenceEngine,
      toolRegistry: toolRegistry,
      agentMemory: agentMemory,
      agentPromptBuilder: agentPromptBuilder,
    );
    agentController = AgentController(agentLoop: agentLoop);
  }

  static Future<void> reset() async {
    if (!_initialized) return;
    agentController.dispose();
    agentLoop.dispose();
    modelLoader.unloadAll();
    await db.close();
    _initialized = false;
  }
}
