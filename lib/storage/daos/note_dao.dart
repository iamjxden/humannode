part of '../database.dart';

extension NoteDaoExt on AppDatabase {
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final rows = await select(notes)
      ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)])
      ..get();
    return rows.map((r) => {
      'id': r.id, 'title': r.title, 'content': r.content,
      'created_at': r.createdAt.toIso8601String(),
      'updated_at': r.updatedAt.toIso8601String(),
    }).toList();
  }

  Future<Map<String, dynamic>?> getNoteById(String id) async {
    final row = await (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return {
      'id': row.id, 'title': row.title, 'content': row.content,
      'created_at': row.createdAt.toIso8601String(),
      'updated_at': row.updatedAt.toIso8601String(),
    };
  }

  Future<void> insertNote(String id, String title, String content) async {
    final now = DateTime.now();
    await into(notes).insert(NotesCompanion(
      id: Value(id), title: Value(title), content: Value(content),
      createdAt: Value(now), updatedAt: Value(now),
    ));
  }

  Future<void> updateNote(String id, String title, String content) async {
    await (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(title: Value(title), content: Value(content), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> deleteNote(String id) async {
    await (delete(notes)..where((t) => t.id.equals(id))).go();
  }
}

class NoteDao {
  final AppDatabase _db;
  NoteDao(this._db);

  Future<List<Map<String, dynamic>>> getAll() => _db.getAllNotes();
  Future<Map<String, dynamic>?> getById(String id) => _db.getNoteById(id);
  Future<void> insert(String id, String title, String content) => _db.insertNote(id, title, content);
  Future<void> update(String id, String title, String content) => _db.updateNote(id, title, content);
  Future<void> delete(String id) => _db.deleteNote(id);
}
