part of '../database.dart';

extension ConversationDaoExt on AppDatabase {
  Future<List<Conversation>> getAllConversations({bool includeArchived = false}) async {
    final query = select(conversations);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]);
    return query.map((row) => Conversation(
      id: row.id, title: row.title, createdAt: row.createdAt,
      updatedAt: row.updatedAt, modelId: row.modelId,
      systemPrompt: row.systemPrompt, pinned: row.pinned,
      isArchived: row.isArchived,
    )).get();
  }

  Future<Conversation?> getConversationById(String id) async {
    final row = await (select(conversations)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Conversation(
      id: row.id, title: row.title, createdAt: row.createdAt,
      updatedAt: row.updatedAt, modelId: row.modelId,
      systemPrompt: row.systemPrompt, pinned: row.pinned,
      isArchived: row.isArchived,
    );
  }

  Future<void> insertConversation(Conversation c) async {
    await into(conversations).insert(ConversationsCompanion(
      id: Value(c.id), title: Value(c.title),
      createdAt: Value(c.createdAt), updatedAt: Value(c.updatedAt),
      modelId: Value(c.modelId), systemPrompt: Value(c.systemPrompt),
      pinned: Value(c.pinned), isArchived: Value(c.isArchived),
    ));
  }

  Future<void> updateConversation(Conversation c) async {
    await (update(conversations)..where((t) => t.id.equals(c.id))).write(
      ConversationsCompanion(
        title: Value(c.title),
        updatedAt: Value(DateTime.now()),
        modelId: Value(c.modelId),
        systemPrompt: Value(c.systemPrompt),
        pinned: Value(c.pinned),
        isArchived: Value(c.isArchived),
      ),
    );
  }

  Future<void> deleteConversation(String id) async {
    await (delete(conversations)..where((t) => t.id.equals(id))).go();
    await (delete(messages)..where((t) => t.conversationId.equals(id))).go();
  }

  Future<int> getConversationCount() async {
    final result = await conversations.count().getSingle();
    return result;
  }
}

extension _ConversationDaoInternal on AppDatabase {
  ConversationDao get convDao => ConversationDao(this);
}

class ConversationDao {
  final AppDatabase _db;
  ConversationDao(this._db);

  Future<List<Conversation>> getAll({bool includeArchived = false}) =>
      _db.getAllConversations(includeArchived: includeArchived);

  Future<Conversation?> getById(String id) => _db.getConversationById(id);
  Future<void> insert(Conversation c) => _db.insertConversation(c);
  Future<void> update(Conversation c) => _db.updateConversation(c);
  Future<void> delete(String id) => _db.deleteConversation(id);
  Future<int> count() => _db.getConversationCount();
}
