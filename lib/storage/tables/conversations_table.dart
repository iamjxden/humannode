import 'package:drift/drift.dart';

class Conversations extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();
  TextColumn get title => text().withLength(min: 1, max: 256)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get modelId => text().withDefault(const Constant(''))();
  TextColumn get systemPrompt => text().withDefault(const Constant(''))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
