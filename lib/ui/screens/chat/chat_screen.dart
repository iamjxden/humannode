import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humannode/providers/chat_provider.dart';
import 'package:humannode/providers/agent_provider.dart';
import 'package:humannode/providers/inference_provider.dart';
import 'package:humannode/core/di/service_locator.dart';
import 'chat_message_bubble.dart';
import 'chat_input_bar.dart';
import 'chat_empty_state.dart';
import 'chat_agent_status_bar.dart';
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
    final chatNotifier = ref.read(chatProvider.notifier);
    chatNotifier.sendMessage(text);
    _scrollToBottom();

    final infState = ref.read(inferenceProvider);
    if (infState.modelPath != null) {
      ServiceLocator.agentController.setModel(infState.modelPath!);
    }

    ServiceLocator.agentController
        .start(ref.read(chatProvider).messages);
  }

  void _stopAgent() {
    ServiceLocator.agentController.stop();
    ref.read(chatProvider.notifier).finishStreaming();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final agentState = ref.watch(agentProvider);
    final infState = ref.watch(inferenceProvider);
    final hasModel = infState.isLoaded;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showModelPicker,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasModel ? Colors.green : Colors.grey,
              ),
            ),
            Flexible(
              child: Text(
                infState.modelName ?? 'No Model',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ]),
        ),
        actions: [
          if (agentState.isRunning)
            IconButton(
              icon: const Icon(Icons.stop_circle),
              color: Theme.of(context).colorScheme.error,
              tooltip: 'Stop',
              onPressed: _stopAgent,
            )
          else
            IconButton(
              icon: Icon(Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.tertiary),
              tooltip: 'Agent',
              onPressed: hasModel ? () {} : null,
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/home/conversations'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                ref.read(chatProvider.notifier).newConversation(),
          ),
        ],
      ),
      body: Column(children: [
        if (agentState.isRunning) const ChatAgentStatusBar(),
        Expanded(
          child: chatState.messages.isEmpty
              ? const ChatEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8),
                  itemCount: chatState.messages.length +
                      (chatState.isStreaming ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i >= chatState.messages.length) {
                      return const ChatTypingIndicator();
                    }
                    return ChatMessageBubble(
                        message: chatState.messages[i]);
                  },
                ),
        ),
      ]),
      bottomSheet: ChatInputBar(
        onSend: _sendMessage,
        isEnabled: hasModel || chatState.messages.isNotEmpty,
        onStop: agentState.isRunning ? _stopAgent : null,
      ),
    );
  }

  void _showModelPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
