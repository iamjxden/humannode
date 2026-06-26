import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../models/message.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  const ChatMessageBubble({super.key, required this.message});

  @override Widget build(BuildContext context) {
    if (message.isSystem) return const SizedBox.shrink();
    final isUser = message.isUser;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.isToolResult)
            _ToolResultBubble(result: message.content),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? cs.primaryContainer : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            child: isUser
                ? SelectableText(message.content, style: Theme.of(context).textTheme.bodyMedium)
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                    onTapLink: (text, href, title) {},
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyMedium,
                      code: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 13,
                        backgroundColor: cs.surfaceContainerHighest,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(left: BorderSide(color: cs.primary, width: 3)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ToolResultBubble extends StatelessWidget {
  final String result;
  const _ToolResultBubble({required this.result});
  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withAlpha(60),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.build_circle, size: 14, color: cs.tertiary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            result.length > 100 ? '${result.substring(0, 100)}...' : result,
            style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(160)),
          ),
        ),
      ]),
    );
  }
}
