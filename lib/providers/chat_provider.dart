import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/model_preset.dart';
import '../core/di/service_locator.dart';

class ChatState {
  final Conversation? conversation;
  final List<Message> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? error;
  final ModelPreset? activePreset;

  const ChatState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
    this.activePreset,
  });

  ChatState copyWith({
    Conversation? conversation, List<Message>? messages,
    bool? isLoading, bool? isStreaming, String? error, ModelPreset? activePreset,
  }) => ChatState(
    conversation: conversation ?? this.conversation,
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    isStreaming: isStreaming ?? this.isStreaming,
    error: error,
    activePreset: activePreset ?? this.activePreset,
  );
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  void newConversation() {
    final convo = Conversation.create();
    state = ChatState(conversation: convo);
  }

  void selectConversation(Conversation convo) {
    state = ChatState(conversation: convo, messages: convo.messages);
  }

  void sendMessage(String content) {
    if (state.conversation == null) newConversation();
    final msg = Message.user(content, conversationId: state.conversation!.id);
    state.conversation!.addMessage(msg);
    state = state.copyWith(
      messages: List.from(state.messages)..add(msg),
      isLoading: true,
      error: null,
    );
    ServiceLocator.messageDao.insert(msg);
  }

  void receiveAssistantStream(String chunk) {
    if (state.messages.isEmpty || state.conversation == null) return;
    if (!state.isStreaming) {
      final msg = Message.assistant(chunk, conversationId: state.conversation!.id);
      state.conversation!.addMessage(msg);
      state = state.copyWith(
        messages: List.from(state.messages)..add(msg),
        isStreaming: true,
      );
      return;
    }
    final lastIndex = state.messages.length - 1;
    final last = state.messages[lastIndex];
    if (last.role != 'assistant') {
      final msg = Message.assistant(chunk, conversationId: state.conversation!.id);
      state.conversation!.addMessage(msg);
      state = state.copyWith(messages: List.from(state.messages)..add(msg));
      return;
    }
    final updated = Message(
      id: last.id, conversationId: last.conversationId,
      role: 'assistant', content: last.content + chunk,
      createdAt: last.createdAt,
    );
    state.conversation!.messages[state.conversation!.messages.length - 1] = updated;
    final newMessages = List<Message>.from(state.messages);
    newMessages[newMessages.length - 1] = updated;
    state = state.copyWith(messages: newMessages);
  }

  void finishStreaming() {
    if (state.conversation != null && state.messages.isNotEmpty) {
      final last = state.messages.last;
      if (last.role == 'assistant') {
        ServiceLocator.messageDao.insert(last);
      }
    }
    state = state.copyWith(isLoading: false, isStreaming: false);
  }

  void setError(String error) => state = state.copyWith(error: error, isLoading: false);
  void clearError() => state = state.copyWith(error: null);
  void setPreset(ModelPreset preset) => state = state.copyWith(activePreset: preset);
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier());
