import 'package:flutter/material.dart';
import 'package:humannode/core/di/service_locator.dart';
import 'note_tile.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});
  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await ServiceLocator.noteDao.getAll();
    if (mounted) setState(() => _notes = notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: _notes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.notes_rounded,
                      size: 72,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha(80)),
                  const SizedBox(height: 20),
                  Text('No notes yet',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                      'Create notes to save thoughts, ideas, and quick references',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(120))),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _createNote,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Note'),
                  ),
                ]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _notes.length,
              itemBuilder: (context, i) => NoteTile(
                title: _notes[i]['title'] as String? ?? '',
                preview: _notes[i]['content'] as String? ?? '',
                date: (_notes[i]['updated_at'] as String? ?? '')
                    .substring(0, 10),
                onTap: () => _openNote(i),
                onDelete: () => _deleteNote(i),
              ),
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: _createNote, child: const Icon(Icons.add_rounded)),
    );
  }

  Future<void> _createNote() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
          builder: (_) => const NoteEditorScreen(title: '', content: '')),
    );
    if (result != null && mounted) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      await ServiceLocator.noteDao.insert(
        id,
        result['title'] ?? 'Untitled',
        result['content'] ?? '',
      );
      await _load();
    }
  }

  Future<void> _openNote(int index) async {
    final note = _notes[index];
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          title: note['title'] as String? ?? '',
          content: note['content'] as String? ?? '',
        ),
      ),
    );
    if (result != null && mounted) {
      await ServiceLocator.noteDao.update(
        note['id'] as String,
        result['title'] ?? 'Untitled',
        result['content'] ?? '',
      );
      await _load();
    }
  }

  Future<void> _deleteNote(int index) async {
    final id = _notes[index]['id'] as String;
    await ServiceLocator.noteDao.delete(id);
    await _load();
  }
}
