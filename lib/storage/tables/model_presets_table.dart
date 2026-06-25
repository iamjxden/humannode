import 'package:drift/drift.dart';

class ModelPresets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get modelId => text().named('model_id')();
  RealColumn get temperature => real().withDefault(const Constant(0.7))();
  RealColumn get topP => real().named('top_p').withDefault(const Constant(0.9))();
  IntColumn get topK => integer().named('top_k').withDefault(const Constant(40))();
  RealColumn get repetitionPenalty => real().named('repetition_penalty').withDefault(const Constant(1.1))();
  IntColumn get maxTokens => integer().named('max_tokens').withDefault(const Constant(4096))();
  TextColumn get systemPrompt => text().named('system_prompt').withDefault(const Constant(''))();
  BoolColumn get isDefault => boolean().named('is_default').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
