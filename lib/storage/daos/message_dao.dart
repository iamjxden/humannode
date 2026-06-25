part of '../database.dart';

extension MessageDaoExt on AppDatabase {
  Future<List<Message>> getMessagesByConversation(String conversationId, {int? limit}) async {
    var query = select(messages)..where((t) => t.conversationId.equals(conversationId));
    query.orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]);
    if (limit != null) query = query..limit(limit);
    return query.map((row) => Message(
      id: row.id, conversationId: row.conversationId,
      role: row.role, content: row.content,
      toolCallJson: row.toolCallsJson != null
          ? {'raw': row.toolCallsJson} : null,
      parentId: row.parentId, createdAt: row.createdAt,
    )).get();
  }

  Future<void> insertMessage(Message m) async {
    await into(messages).insert(MessagesCompanion(
      id: Value(m.id),
      conversationId: Value(m.conversationId),
      role: Value(m.role),
      content: Value(m.content),
      toolCallsJson: Value.absent(),
      parentId: Value(m.parentId ?? ''),
      createdAt: Value(m.createdAt),
    ));
  }

  Future<void> deleteMessagesByConversation(String conversationId) async {
    await (delete(messages)..where((t) => t.conversationId.equals(conversationId))).go();
  }

  Future<int> countMessages(String conversationId) async {
    final result = await (selectOnly(messages)
      ..addColumns([messages.id.count()])
      ..where(messages.conversationId.equals(conversationId))).getSingle();
    return result.read(messages.id.count()) ?? 0;
  }

  Future<Message?> getLastMessage(String conversationId) async {
    final row = await (select(messages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(1)).getSingleOrNull();
    if (row == null) return null;
    return Message(
      id: row.id, conversationId: row.conversationId,
      role: row.role, content: row.content,
      createdAt: row.createdAt,
    );
  }
}

class MessageDao {
  final AppDatabase _db;
  MessageDao(this._db);

  Future<List<Message>> getByConversation(String id, {int? limit}) =>
      _db.getMessagesByConversation(id, limit: limit);
  Future<void> insert(Message m) => _db.insertMessage(m);
  Future<void> deleteByConversation(String id) => _db.deleteMessagesByConversation(id);
  Future<int> count(String id) => _db.countMessages(id);
  Future<Message?> getLast(String id) => _db.getLastMessage(id);
}
