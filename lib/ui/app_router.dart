import 'package:go_router/go_router.dart';
import 'package:humannode/ui/screens/splash_screen.dart';
import 'package:humannode/ui/screens/main_shell.dart';
import 'package:humannode/ui/screens/chat/chat_screen.dart';
import 'package:humannode/ui/screens/models/models_screen.dart';
import 'package:humannode/ui/screens/notes/notes_list_screen.dart';
import 'package:humannode/ui/screens/notes/note_editor_screen.dart';
import 'package:humannode/ui/screens/settings/settings_screen.dart';
import 'package:humannode/ui/screens/settings/general_settings.dart';
import 'package:humannode/ui/screens/settings/models_settings.dart';
import 'package:humannode/ui/screens/settings/generation_settings.dart';
import 'package:humannode/ui/screens/settings/agent_settings.dart';
import 'package:humannode/ui/screens/settings/api_keys_screen.dart';
import 'package:humannode/ui/screens/settings/storage_settings.dart';
import 'package:humannode/ui/screens/settings/about_screen.dart';
import 'package:humannode/ui/screens/settings/debug_screen.dart';
import 'package:humannode/ui/screens/onboarding/onboarding_screen.dart';
import 'package:humannode/ui/screens/conversations/conversations_list_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const ChatScreen(),
            routes: [
              GoRoute(path: 'conversations', builder: (_, __) => const ConversationsListScreen()),
              GoRoute(path: 'models', builder: (_, __) => const ModelsScreen()),
              GoRoute(path: 'notes', builder: (_, __) => const NotesListScreen()),
              GoRoute(
                path: 'note/:noteId',
                builder: (_, state) => NoteEditorScreen(
                  noteId: state.pathParameters['noteId'] ?? '',
                  title: state.uri.queryParameters['title'] ?? '',
                  content: state.uri.queryParameters['content'] ?? '',
                ),
              ),
              GoRoute(
                path: 'settings',
                builder: (_, __) => const SettingsScreen(),
                routes: [
                  GoRoute(path: 'general', builder: (_, __) => const GeneralSettings()),
                  GoRoute(path: 'models', builder: (_, __) => const ModelsSettings()),
                  GoRoute(path: 'generation', builder: (_, __) => const GenerationSettings()),
                  GoRoute(path: 'agent', builder: (_, __) => const AgentSettings()),
                  GoRoute(path: 'api-keys', builder: (_, __) => const ApiKeysScreen()),
                  GoRoute(path: 'storage', builder: (_, __) => const StorageSettings()),
                  GoRoute(path: 'about', builder: (_, __) => const AboutScreen()),
                  GoRoute(path: 'debug', builder: (_, __) => const DebugScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
