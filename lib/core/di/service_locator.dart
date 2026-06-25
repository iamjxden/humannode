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
  static late final AppDatabase db;
  static late final SecureStore secureStore;
  static late final ConversationDao conversationDao;
  static late final MessageDao messageDao;
  static late final NoteDao noteDao;
  static late final PresetDao presetDao;
  static late final SettingsDao settingsDao;
  static late final FileCache fileCache;
  static late final LlamaBridge llamaBridge;
  static late final NomadTokenizer tokenizer;
  static late final ModelLoader modelLoader;
  static late final InferenceEngine inferenceEngine;
  static late final ToolRegistry toolRegistry;
  static late final AgentMemory agentMemory;
  static late final AgentPromptBuilder agentPromptBuilder;
  static late final AgentLoop agentLoop;
  static late final AgentController agentController;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    secureStore = SecureStore();
    fileCache = FileCache();
    await fileCache.init();
    db = AppDatabase();
    conversationDao = db.conversationDao;
    messageDao = db.messageDao;
    noteDao = db.noteDao;
    presetDao = db.presetDao;
    settingsDao = db.settingsDao;
    llamaBridge = LlamaBridge();
    await llamaBridge.load();
    tokenizer = NomadTokenizer();
    modelLoader = ModelLoader(llamaBridge: llamaBridge, fileCache: fileCache);
    inferenceEngine = InferenceEngine(llamaBridge: llamaBridge, modelLoader: modelLoader, tokenizer: tokenizer);
    toolRegistry = ToolRegistry(presetDao: presetDao);
    await toolRegistry.init();
    agentMemory = AgentMemory(messageDao: messageDao);
    agentPromptBuilder = AgentPromptBuilder(toolRegistry: toolRegistry, agentMemory: agentMemory);
    await agentPromptBuilder.loadDefaultPrompt();
    agentLoop = AgentLoop(inferenceEngine: inferenceEngine, toolRegistry: toolRegistry, agentMemory: agentMemory, agentPromptBuilder: agentPromptBuilder);
    agentController = AgentController(agentLoop: agentLoop);
    _initialized = true;
    HumanNodeLogger.info('ServiceLocator initialized');
  }
}
