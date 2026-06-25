part of '../database.dart';

extension PresetDaoExt on AppDatabase {
  Future<List<ModelPreset>> getAllPresets() async {
    final rows = await select(modelPresets).get();
    return rows.map(ModelPreset.fromJson).toList();
  }

  Future<ModelPreset?> getPresetById(String id) async {
    final row = await (select(modelPresets)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return ModelPreset.fromJson(row.toJson());
  }

  Future<void> insertPreset(ModelPreset p) async {
    await into(modelPresets).insert(ModelPresetsCompanion(
      id: Value(p.id), name: Value(p.name), modelId: Value(p.modelId),
      temperature: Value(p.temperature), topP: Value(p.topP),
      topK: Value(p.topK), repetitionPenalty: Value(p.repetitionPenalty),
      maxTokens: Value(p.maxTokens), systemPrompt: Value(p.systemPrompt),
      isDefault: Value(p.isDefault),
    ));
  }

  Future<void> deletePreset(String id) async {
    await (delete(modelPresets)..where((t) => t.id.equals(id))).go();
  }
}

class PresetDao {
  final AppDatabase _db;
  PresetDao(this._db);

  Future<List<ModelPreset>> getAll() => _db.getAllPresets();
  Future<ModelPreset?> getById(String id) => _db.getPresetById(id);
  Future<void> insert(ModelPreset p) => _db.insertPreset(p);
  Future<void> delete(String id) => _db.deletePreset(id);
}
