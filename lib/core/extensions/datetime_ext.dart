extension DateTimeExt on DateTime {
  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 5) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  String get short => '${year.toString().substring(2)}/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
  String get iso => toIso8601String().substring(0, 19);
  String get timeOnly => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  bool get isToday => DateTime.now().difference(this).inDays == 0;
  bool get isYesterday => DateTime.now().difference(this).inDays == 1;
  bool get isThisWeek => DateTime.now().difference(this).inDays < 7;
}
