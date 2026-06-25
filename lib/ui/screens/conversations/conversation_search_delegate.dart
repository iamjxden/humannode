import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/conversations_provider.dart';
import '../../../models/conversation.dart';
import 'conversation_tile.dart';

class ConversationSearchDelegate extends SearchDelegate<Conversation?> {
  @override List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
  ];

  @override Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => close(context, null));

  @override Widget buildResults(BuildContext context) => _results(context);
  @override Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(conversationsProvider);
      final results = state.conversations
          .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (results.isEmpty) {
        return Center(child: Text('No conversations match "$query"',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(120))));
      }
      return ListView(children: results.map((c) => ConversationTile(conversation: c)).toList());
    });
  }
}
