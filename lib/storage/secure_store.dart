class SecureStore {
  final Map<String, String> _data = {};

  SecureStore();

  Future<void> saveApiKey(String provider, String key) async => _data['api_key_$provider'] = key;
  Future<String?> getApiKey(String provider) async => _data['api_key_$provider'];
  Future<void> deleteApiKey(String provider) async => _data.remove('api_key_$provider');
  Future<bool> hasApiKey(String provider) async => _data.containsKey('api_key_$provider') && (_data['api_key_$provider']?.isNotEmpty == true);
  Future<List<String>> getConfiguredProviders() async => ['openai', 'anthropic', 'openrouter'].where((p) => _data.containsKey('api_key_$p')).toList();
  Future<void> write(String key, String value) async => _data[key] = value;
  Future<String?> read(String key) async => _data[key];
  Future<void> delete(String key) async => _data.remove(key);
  Future<void> clearAll() async => _data.clear();
}
