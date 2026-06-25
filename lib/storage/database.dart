import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/conversations_table.dart';
import 'tables/messages_table.dart';
import 'tables/notes_table.dart';
import 'tables/model_presets_table.dart';
import 'tables/settings_table.dart';
import 'daos/conversation_dao.dart';
import 'daos/message_dao.dart';
import 'daos/note_dao.dart';
import 'daos/preset_dao.dart';
import 'daos/settings_dao.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Conversations, Messages, Notes, ModelPresets, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static QueryExecutor _openConnection() => driftDatabase(name: 'humannode.db');

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAllTables();
        },
        onUpgrade: (migrator, from, to) async {},
        beforeOpen: (details) async {},
      );

  ConversationDao get conversationDao => ConversationDao(this);
  MessageDao get messageDao => MessageDao(this);
  NoteDao get noteDao => NoteDao(this);
  PresetDao get presetDao => PresetDao(this);
  SettingsDao get settingsDao => SettingsDao(this);
}
