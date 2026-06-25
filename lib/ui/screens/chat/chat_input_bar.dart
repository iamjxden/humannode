import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onStop;
  final bool isEnabled;

  const ChatInputBar({super.key, required this.onSend, this.onStop, this.isEnabled = true});

  @override State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();

  @override void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: SafeArea(
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          IconButton(
            icon: const Icon(Icons.attach_file_rounded, size: 22),
            onPressed: widget.isEnabled ? () {} : null,
            padding: const EdgeInsets.all(10),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 5,
              minLines: 1,
              enabled: widget.isEnabled,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Message HumanNode...',
                filled: true,
                fillColor: cs.surfaceContainerHighest.withAlpha(60),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 4),
          if (widget.onStop != null)
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(color: cs.error, borderRadius: BorderRadius.circular(20)),
              child: IconButton(
                icon: const Icon(Icons.stop, color: Colors.white, size: 20),
                onPressed: widget.onStop,
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _hasText
                  ? Container(
                      key: const ValueKey('send'),
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(20)),
                      child: IconButton(
                          icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                          onPressed: _handleSend),
                    )
                  : IconButton(
                      key: const ValueKey('mic'),
                      icon: const Icon(Icons.mic_rounded, size: 22),
                      onPressed: widget.isEnabled ? () {} : null,
                    ),
            ),
        ]),
      ),
    );
  }

  @override void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
