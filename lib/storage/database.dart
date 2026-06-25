import 'package:humannode/models/conversation.dart';
import 'package:humannode/models/message.dart';
import 'package:humannode/models/model_preset.dart';

class AppDatabase {
  final List<Conversation> _convs = [];
  final List<Message> _msgs = [];
  final List<Map<String, dynamic>> _notes = [];
  final List<ModelPreset> _presets = [];
  final Map<String, String> _settings = {};

  ConversationDao get conversationDao => ConversationDao(this);
  MessageDao get messageDao => MessageDao(this);
  NoteDao get noteDao => NoteDao(this);
  PresetDao get presetDao => PresetDao(this);
  SettingsDao get settingsDao => SettingsDao(this);

  List<Conversation> get conversations => _convs;
  List<Message> get messages => _msgs;
  List<Map<String, dynamic>> get notes => _notes;
  List<ModelPreset> get presets => _presets;
  Map<String, String> get settings => _settings;

  Future<void> close() async {}
}

class ConversationDao {
  final AppDatabase db;
  ConversationDao(this.db);
  Future<List<Conversation>> getAll({bool includeArchived = false}) async {
    final filtered = db.conversations.where((c) => includeArchived || !c.isArchived).toList();
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }
  Future<Conversation?> getById(String id) async {
    try { return db.conversations.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }
  Future<void> insert(Conversation c) async => db.conversations.add(c);
  Future<void> update(Conversation c) async {
    final i = db.conversations.indexWhere((x) => x.id == c.id);
    if (i >= 0) db.conversations[i] = c;
  }
  Future<void> delete(String id) async {
    db.conversations.removeWhere((c) => c.id == id);
    db.messages.removeWhere((m) => m.conversationId == id);
  }
}

class MessageDao {
  final AppDatabase db;
  MessageDao(this.db);
  Future<List<Message>> getByConversation(String convId, {int? limit}) async {
    var msgs = db.messages.where((m) => m.conversationId == convId).toList();
    msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (limit != null) msgs = msgs.take(limit).toList();
    return msgs;
  }
  Future<void> insert(Message m) async => db.messages.add(m);
  Future<void> deleteByConversation(String convId) async => db.messages.removeWhere((m) => m.conversationId == convId);
  Future<int> count(String convId) async => db.messages.where((m) => m.conversationId == convId).length;
}

class NoteDao {
  final AppDatabase db;
  NoteDao(this.db);
  Future<List<Map<String, dynamic>>> getAll() async => db.notes;
  Future<void> insert(String id, String title, String content) async {
    db.notes.insert(0, {'id': id, 'title': title, 'content': content, 'created_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String()});
  }
  Future<void> update(String id, String title, String content) async {
    final i = db.notes.indexWhere((n) => n['id'] == id);
    if (i >= 0) { db.notes[i]['title'] = title; db.notes[i]['content'] = content; db.notes[i]['updated_at'] = DateTime.now().toIso8601String(); }
  }
  Future<void> delete(String id) async => db.notes.removeWhere((n) => n['id'] == id);
}

class PresetDao {
  final AppDatabase db;
  PresetDao(this.db);
  Future<List<ModelPreset>> getAll() async => db.presets;
  Future<void> insert(ModelPreset p) async => db.presets.add(p);
  Future<void> delete(String id) async => db.presets.removeWhere((p) => p.id == id);
}

class SettingsDao {
  final AppDatabase db;
  SettingsDao(this.db);
  Future<String?> get(String key) async => db.settings[key];
  Future<void> set(String key, String value) async => db.settings[key] = value;
  Future<void> delete(String key) async => db.settings.remove(key);
  Future<Map<String, String>> getAll() async => Map.unmodifiable(db.settings);
}
