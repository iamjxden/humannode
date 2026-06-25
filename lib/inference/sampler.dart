import 'dart:math';
import 'llama_types.dart';

class Sampler {
  final int? seed;

  Sampler({this.seed});

  Random _getRandom() {
    return Random(seed ?? DateTime.now().microsecondsSinceEpoch);
  }

  List<int> sample(List<double> logits, {LlamaSamplerParams? params}) {
    final p = params ?? const LlamaSamplerParams();
    final random = _getRandom();
    final filtered = _applyPenalties(logits, p);
    final topKResult = _applyTopK(filtered, p.topK);
    final topPResult = _applyTopP(topKResult, p.topP);
    final tempResult = _applyTemperature(topPResult, p.temperature);
    final probs = _softmax(tempResult);
    final sampledIndex = _categoricalSample(probs, random);
    return [sampledIndex];
  }

  List<int> sampleBatch(List<List<double>> logitsBatch, {LlamaSamplerParams? params}) {
    return logitsBatch.map((logits) => sample(logits, params: params).first).toList();
  }

  List<double> _applyPenalties(List<double> logits, LlamaSamplerParams params) {
    if (params.repetitionPenalty == 1.0 && params.minP == 0.0) return logits;
    return logits.toList();
  }

  List<double> _applyTopK(List<double> logits, int k) {
    if (k <= 0 || k >= logits.length) return logits;
    final indexed = logits.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (k >= indexed.length) return logits;
    final threshold = indexed[k].value;
    return logits.map((v) => v >= threshold ? v : double.negativeInfinity).toList();
  }

  List<double> _applyTopP(List<double> logits, double p) {
    if (p >= 1.0) return logits;
    if (p <= 0.0) return logits.map((_) => double.negativeInfinity).toList();
    final sorted = logits.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    double cumulative = 0;
    double totalSum = 0;
    final maxLogit = logits.reduce(max);
    for (final val in logits) {
      if (val != double.negativeInfinity) {
        totalSum += exp(val - maxLogit);
      }
    }
    final topPIndices = <int>{};
    for (final entry in sorted) {
      if (entry.value == double.negativeInfinity) break;
      cumulative += exp(entry.value - maxLogit);
      topPIndices.add(entry.key);
      if (totalSum > 0 && cumulative / totalSum >= p) break;
    }
    return logits.asMap().entries
        .map((e) => topPIndices.contains(e.key) ? e.value : double.negativeInfinity)
        .toList();
  }

  List<double> _applyTemperature(List<double> logits, double temp) {
    if (temp <= 0 || temp.isNaN) temp = 0.01;
    if (temp == 1.0) return logits;
    return logits.map((v) => v == double.negativeInfinity ? v : v / temp).toList();
  }

  List<double> _softmax(List<double> xs) {
    final xMax = xs.where((x) => x != double.negativeInfinity).reduce(max);
    final exps = xs.map((x) => x == double.negativeInfinity ? 0.0 : exp(x - xMax)).toList();
    final sum = exps.reduce((a, b) => a + b);
    if (sum == 0) return xs.map((_) => 1.0 / xs.length).toList();
    return exps.map((e) => e / sum).toList();
  }

  int _categoricalSample(List<double> probs, Random random) {
    final r = random.nextDouble();
    double cumulative = 0;
    for (int i = 0; i < probs.length; i++) {
      cumulative += probs[i];
      if (r <= cumulative) return i;
    }
    return probs.length - 1;
  }
}
