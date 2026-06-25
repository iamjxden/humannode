import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../../storage/database.dart';
import '../../storage/daos/conversation_dao.dart';
import '../../storage/daos/message_dao.dart';
import '../../storage/daos/note_dao.dart';
import '../../storage/daos/preset_dao.dart';
import '../../storage/daos/settings_dao.dart';
import '../../storage/file_cache.dart';
import '../../storage/secure_store.dart';
import '../../inference/llama_bridge.dart';
import '../../inference/model_loader.dart';
import '../../inference/inference_engine.dart';
import '../../inference/tokenizer.dart';
import '../../agent/tools/tool_registry.dart';
import '../../agent/agent_loop.dart';
import '../../agent/agent_controller.dart';
import '../../agent/agent_memory.dart';
import '../../agent/agent_prompt_builder.dart';
import '../logger/humannode_logger.dart';

class ServiceLocator {
  static late final AppDatabase db;
  static late final FlutterSecureStorage secureStorage;
  static late final SecureStore secureStore;
  static late final ConversationDao conversationDao;
  static late final MessageDao messageDao;
  static late final NoteDao noteDao;
  static late final PresetDao presetDao;
  static late final SettingsDao settingsDao;
  static late final FileCache fileCache;
  static late final LlamaBridge llamaBridge;
  static late final HumanNodeTokenizer tokenizer;
  static late final ModelLoader modelLoader;
  static late final InferenceEngine inferenceEngine;
  static late final ToolRegistry toolRegistry;
  static late final AgentMemory agentMemory;
  static late final AgentPromptBuilder agentPromptBuilder;
  static late final AgentLoop agentLoop;
  static late final AgentController agentController;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> init() async {
    if (_initialized) return;
    secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    );
    secureStore = SecureStore(secureStorage);
    fileCache = FileCache();
    await fileCache.init();
    db = AppDatabase();
    conversationDao = ConversationDao(db);
    messageDao = MessageDao(db);
    noteDao = NoteDao(db);
    presetDao = PresetDao(db);
    settingsDao = SettingsDao(db);
    llamaBridge = LlamaBridge();
    await llamaBridge.load();
    tokenizer = HumanNodeTokenizer();
    modelLoader = ModelLoader(llamaBridge: llamaBridge, fileCache: fileCache);
    inferenceEngine = InferenceEngine(
      llamaBridge: llamaBridge, modelLoader: modelLoader, tokenizer: tokenizer);
    toolRegistry = ToolRegistry(presetDao: presetDao);
    await toolRegistry.init();
    agentMemory = AgentMemory(messageDao: messageDao);
    agentPromptBuilder = AgentPromptBuilder(toolRegistry: toolRegistry, agentMemory: agentMemory);
    await agentPromptBuilder.loadDefaultPrompt();
    agentLoop = AgentLoop(
      inferenceEngine: inferenceEngine, toolRegistry: toolRegistry,
      agentMemory: agentMemory, agentPromptBuilder: agentPromptBuilder);
    agentController = AgentController(agentLoop: agentLoop);
    _initialized = true;
    HumanNodeLogger.info('ServiceLocator initialized successfully');
  }

  static Future<void> dispose() async {
    modelLoader.unloadAll();
    agentController.stop();
    await db.close();
    _initialized = false;
  }
}
