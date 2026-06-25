class ModelInfo {
  final String name;
  final String architecture;
  final String quantization;
  final int contextLength;
  final int parameterCount;
  final int sizeBytes;
  final String downloadUrl;
  final double? benchmarkTokPerSec;

  const ModelInfo({
    required this.name,
    required this.architecture,
    required this.quantization,
    required this.contextLength,
    required this.parameterCount,
    required this.sizeBytes,
    required this.downloadUrl,
    this.benchmarkTokPerSec,
  });

  String get parameterLabel {
    if (parameterCount >= 1000000000) {
      return '${(parameterCount / 1000000000).toStringAsFixed(1)}B';
    }
    if (parameterCount >= 1000000) {
      return '${(parameterCount / 1000000).round()}M';
    }
    return '$parameterCount';
  }

  String get sizeLabel {
    if (sizeBytes >= 1073741824) {
      return '${(sizeBytes / 1073741824).toStringAsFixed(1)} GB';
    }
    return '${(sizeBytes / 1048576).round()} MB';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'architecture': architecture,
        'quantization': quantization,
        'context_length': contextLength,
        'parameter_count': parameterCount,
        'size_bytes': sizeBytes,
        'download_url': downloadUrl,
        if (benchmarkTokPerSec != null) 'benchmark_tok_per_sec': benchmarkTokPerSec,
      };

  factory ModelInfo.fromJson(Map<String, dynamic> json) => ModelInfo(
        name: json['name'] as String,
        architecture: json['architecture'] as String? ?? 'llama',
        quantization: json['quantization'] as String? ?? 'Q4_K_M',
        contextLength: json['context_length'] as int? ?? 8192,
        parameterCount: json['parameter_count'] as int? ?? 7000,
        sizeBytes: json['size_bytes'] as int? ?? 4000000000,
        downloadUrl: json['download_url'] as String? ?? '',
        benchmarkTokPerSec: (json['benchmark_tok_per_sec'] as num?)?.toDouble(),
      );
}
