import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humannode/providers/chat_provider.dart';
import 'package:humannode/providers/inference_provider.dart';
import 'package:humannode/core/di/service_locator.dart';
import 'chat_message_bubble.dart';
import 'chat_input_bar.dart';
import 'chat_typing_indicator.dart';
import 'package:humannode/ui/widgets/model_picker_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  StreamSubscription<String>? _outputSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();
    final agentCtrl = ServiceLocator.agentController;
    _outputSub = agentCtrl.outputStream.listen((chunk) {
      ref.read(chatProvider.notifier).receiveAssistantStream(chunk);
      _scrollToBottom();
    });
    _stateSub = agentCtrl.stateStream.listen((agentState) {
      if (!agentState.isRunning) {
        ref.read(chatProvider.notifier).finishStreaming();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    final infState = ref.read(inferenceProvider);
    if (!infState.isLoaded) {
      _showModelPicker();
      return;
    }
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
    if (infState.modelPath != null) {
      ServiceLocator.agentController.setModel(infState.modelPath!);
    }
    ServiceLocator.agentController.start(ref.read(chatProvider).messages);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final infState = ref.watch(inferenceProvider);
    final cs = Theme.of(context).colorScheme;
    final hasModel = infState.isLoaded;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primaryContainer.withAlpha(40),
              cs.surface,
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _TopBar(
              modelName: infState.modelName,
              hasModel: hasModel,
              onModelTap: _showModelPicker,
              onHistoryTap: () => context.push('/home/conversations'),
              onNewChat: () => ref.read(chatProvider.notifier).newConversation(),
            ),
            Expanded(
              child: chatState.messages.isEmpty
                  ? _EmptyState(onBrowseModels: () => context.push('/home/models'))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      itemCount: chatState.messages.length + (chatState.isStreaming ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i >= chatState.messages.length) return const ChatTypingIndicator();
                        return ChatMessageBubble(message: chatState.messages[i]);
                      },
                    ),
            ),
            ChatInputBar(
              onSend: _sendMessage,
              isEnabled: true,
              onStop: null,
            ),
          ]),
        ),
      ),
    );
  }

  void _showModelPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const ModelPickerSheet(),
    );
  }

  @override
  void dispose() {
    _outputSub?.cancel();
    _stateSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}

class _TopBar extends StatelessWidget {
  final String? modelName;
  final bool hasModel;
  final VoidCallback onModelTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onNewChat;

  const _TopBar({
    required this.modelName,
    required this.hasModel,
    required this.onModelTap,
    required this.onHistoryTap,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 8, 8, 0),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: onModelTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: hasModel ? cs.primary.withAlpha(60) : cs.outlineVariant,
                    width: 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasModel ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    modelName ?? 'Select Model',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasModel ? cs.onSurface : cs.onSurface.withAlpha(140),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.expand_more_rounded, size: 16, color: cs.onSurface.withAlpha(120)),
              ]),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: onHistoryTap,
          iconSize: 22,
        ),
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: onNewChat,
          iconSize: 22,
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBrowseModels;
  const _EmptyState({required this.onBrowseModels});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [
                cs.primary.withAlpha(200),
                cs.tertiary.withAlpha(160),
              ]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withAlpha(80),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.travel_explore_rounded,
                color: Colors.white, size: 48),
          ),
          const SizedBox(height: 28),
          Text('Welcome to HumanNode',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5)),
          const SizedBox(height: 10),
          Text('Your local AI workspace. Download a model to start chatting.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: cs.onSurface.withAlpha(140))),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onBrowseModels,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Browse Models'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _SuggestionChip('Create an image'),
              _SuggestionChip('Give me ideas'),
              _SuggestionChip('Do the task'),
              _SuggestionChip('Translate the text'),
            ],
          ),
        ]),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  const _SuggestionChip(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(160))),
    );
  }
}
