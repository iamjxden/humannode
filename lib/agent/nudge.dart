class Nudge {
  static const int maxNudges = 2;
  int _nudgeCount = 0;
  final List<String> _nudgeHistory = [];

  static final List<RegExp> _intentPatterns = [
    RegExp(r'(?i)\b(let me|i will|i\'ll|i shall)\s+\w+'),
    RegExp(r'(?i)\b(i should|i need to|i must|i have to|going to)\s+\w+'),
    RegExp(r'(?i)\b(i can|i could)\s+\w+\s+(that|this|the|for)'),
    RegExp(r'(?i)\b(let\'s|we can|we should|we need to)\s+\w+'),
  ];

  bool detectsIntent(String text) {
    return _intentPatterns.any((pattern) => pattern.hasMatch(text));
  }

  String? nudge(String text) {
    if (_nudgeCount >= maxNudges) return null;
    if (!detectsIntent(text)) return null;
    _nudgeCount++;
    final nudgeMsg = 'You said you would take action — do it now. '
        'Use a tool call or provide your answer directly.';
    _nudgeHistory.add(nudgeMsg);
    return nudgeMsg;
  }

  void recordNudge(String text) {
    _nudgeCount++;
    _nudgeHistory.add(text);
  }

  int get nudgeCount => _nudgeCount;
  List<String> get nudgeHistory => List.unmodifiable(_nudgeHistory);

  void reset() {
    _nudgeCount = 0;
    _nudgeHistory.clear();
  }
}
