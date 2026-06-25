class MemoryEstimate {
  final int modelSizeBytes;
  final int kvCacheBytes;
  final int activationBufferBytes;
  final int overheadBytes;

  const MemoryEstimate({
    required this.modelSizeBytes,
    required this.kvCacheBytes,
    required this.activationBufferBytes,
    required this.overheadBytes,
  });

  int get totalBytes => modelSizeBytes + kvCacheBytes + activationBufferBytes + overheadBytes;
  int get totalMB => (totalBytes / (1024 * 1024)).round();
  double get totalGB => totalBytes / (1024 * 1024 * 1024);

  String get summary => '${totalGB.toStringAsFixed(1)} GB '
      '(model: ${(modelSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB, '
      'KV cache: ${(kvCacheBytes / (1024 * 1024)).round()} MB)';

  static MemoryEstimate forModel({
    required int parameterCount,
    required String quantization,
    required int contextSize,
    int numLayers = 32,
    int hiddenSize = 4096,
    int numKvHeads = 32,
  }) {
    final bitsPerWeight = _bitsPerWeight(quantization);
    final modelSize = (parameterCount * bitsPerWeight / 8).ceil();
    final kvSize = 2 * numLayers * contextSize * hiddenSize * (bitsPerWeight / 8).ceil();
    final activationBuffer = hiddenSize * 1024;
    final overhead = 128 * 1024 * 1024;
    return MemoryEstimate(
      modelSizeBytes: modelSize,
      kvCacheBytes: kvSize,
      activationBufferBytes: activationBuffer,
      overheadBytes: overhead,
    );
  }

  static double _bitsPerWeight(String quantization) {
    return switch (quantization) {
      'Q2_K' => 2.5625,
      'Q3_K' => 3.4375,
      'Q3_K_S' => 3.4375,
      'Q3_K_M' => 3.4375,
      'Q3_K_L' => 3.4375,
      'Q4_0' => 4.5,
      'Q4_K' => 4.5,
      'Q4_K_S' => 4.5,
      'Q4_K_M' => 4.5,
      'Q5_0' => 5.5,
      'Q5_K' => 5.5,
      'Q5_K_S' => 5.5,
      'Q5_K_M' => 5.5,
      'Q6_K' => 6.5625,
      'Q8_0' => 8.5,
      'F16' => 16.0,
      'F32' => 32.0,
      _ => 4.5,
    };
  }
}
