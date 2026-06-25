import 'package:flutter/material.dart';
import '../../animations/thinking_pulse.dart';

class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key});
  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: const ThinkingPulse(),
        ),
        const SizedBox(width: 10),
        Text('Thinking', style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(120), fontStyle: FontStyle.italic)),
      ]),
    );
  }
}
