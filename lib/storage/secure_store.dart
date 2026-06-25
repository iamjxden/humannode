import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  final FlutterSecureStorage _storage;

  SecureStore(this._storage);

  Future<void> saveApiKey(String provider, String key) async {
    await _storage.write(key: 'api_key_$provider', value: key);
  }

  Future<String?> getApiKey(String provider) async {
    return _storage.read(key: 'api_key_$provider');
  }

  Future<void> deleteApiKey(String provider) async {
    await _storage.delete(key: 'api_key_$provider');
  }

  Future<bool> hasApiKey(String provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }

  Future<List<String>> getConfiguredProviders() async {
    final providers = <String>[];
    for (final p in ['openai', 'anthropic', 'openrouter']) {
      if (await hasApiKey(p)) providers.add(p);
    }
    return providers;
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
