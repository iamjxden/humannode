import 'package:flutter/material.dart';
import 'note_tile.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});
  @override State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final List<Map<String, String>> _notes = [];

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: _notes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.notes_rounded, size: 72, color: Theme.of(context).colorScheme.primary.withAlpha(80)),
                  const SizedBox(height: 20),
                  Text('No notes yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Create notes to save thoughts, ideas, and quick references',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => _createNote(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Note'),
                  ),
                ]),
              ))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _notes.length,
              itemBuilder: (context, i) => NoteTile(
                title: _notes[i]['title'] ?? '',
                preview: _notes[i]['content'] ?? '',
                date: _notes[i]['date'] ?? '',
                onTap: () => _openNote(i),
                onDelete: () => setState(() => _notes.removeAt(i)),
              ),
            ),
      floatingActionButton: FloatingActionButton(onPressed: _createNote, child: const Icon(Icons.add_rounded)),
    );
  }

  Future<void> _createNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen(title: '', content: '')),
    );
    if (result != null && mounted) {
      setState(() => _notes.insert(0, {
        'title': (result['title'] as String?) ?? 'Untitled',
        'content': (result['content'] as String?) ?? '',
        'date': DateTime.now().toIso8601String().substring(0, 10),
      }));
    }
  }

  Future<void> _openNote(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(
        title: _notes[index]['title'] ?? '',
        content: _notes[index]['content'] ?? '',
      )),
    );
    if (result != null && mounted) {
      setState(() {
        _notes[index]['title'] = (result['title'] as String?) ?? 'Untitled';
        _notes[index]['content'] = (result['content'] as String?) ?? '';
        _notes[index]['date'] = DateTime.now().toIso8601String().substring(0, 10);
      });
    }
  }
}
