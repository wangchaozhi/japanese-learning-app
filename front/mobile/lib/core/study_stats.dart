import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 学习统计快照，供首页展示。
class StudyStats {
  const StudyStats({
    required this.learnedWords,
    required this.todayReviews,
    required this.streakDays,
    required this.n5Progress,
  });

  static const StudyStats empty = StudyStats(
    learnedWords: 0,
    todayReviews: 0,
    streakDays: 0,
    n5Progress: 0,
  );

  /// 已学单词数（去重）。
  final int learnedWords;

  /// 今日复习次数。
  final int todayReviews;

  /// 连续学习天数。
  final int streakDays;

  /// N5 词库进度，0~1。
  final double n5Progress;

  int get n5Percent => (n5Progress * 100).round();
}

/// 单日复习记录。
class DailyReview {
  const DailyReview({required this.date, required this.count});

  final DateTime date;
  final int count;

  /// 形如 6/14 的短标签。
  String get shortLabel => '${date.month}/${date.day}';
}

/// 本地学习记录：记录已学单词、每日复习次数和连续天数，持久化到设备。
class StudyStatsService {
  static const String _seenWordsKey = 'study_seen_words';
  static const String _reviewsByDateKey = 'study_reviews_by_date';

  /// N5 词库总词数，用于计算进度。
  static const int n5Total = 30;

  /// 每日复习目标次数。
  static const int dailyGoal = 20;

  /// 标记某个单词为已学，并记一次复习。
  Future<void> markWordLearned(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_seenWordsKey) ?? <String>[];
    if (!seen.contains('$wordId')) {
      seen.add('$wordId');
      await prefs.setStringList(_seenWordsKey, seen);
    }
    await _addReview(prefs);
  }

  /// 记一次复习（如答题），不绑定具体单词。
  Future<void> addReview() async {
    final prefs = await SharedPreferences.getInstance();
    await _addReview(prefs);
  }

  Future<void> _addReview(SharedPreferences prefs) async {
    final counts = _readCounts(prefs);
    final key = _dateKey(DateTime.now());
    counts[key] = (counts[key] ?? 0) + 1;
    await prefs.setString(_reviewsByDateKey, jsonEncode(counts));
  }

  Future<StudyStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_seenWordsKey) ?? const <String>[];
    final counts = _readCounts(prefs);

    final today = _dateKey(DateTime.now());
    final learned = seen.length;
    return StudyStats(
      learnedWords: learned,
      todayReviews: counts[today] ?? 0,
      streakDays: _streak(counts),
      n5Progress: n5Total == 0 ? 0 : (learned / n5Total).clamp(0, 1).toDouble(),
    );
  }

  /// 最近 [days] 天的复习次数，按日期升序（最早在前，今天在最后）。
  Future<List<DailyReview>> dailyHistory({int days = 7}) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = _readCounts(prefs);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = days - 1; i >= 0; i--)
        () {
          final date = today.subtract(Duration(days: i));
          return DailyReview(date: date, count: counts[_dateKey(date)] ?? 0);
        }(),
    ];
  }

  Map<String, int> _readCounts(SharedPreferences prefs) {
    final raw = prefs.getString(_reviewsByDateKey);
    if (raw == null || raw.isEmpty) return <String, int>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, int>{};
    return decoded.map((key, value) =>
        MapEntry(key.toString(), (value as num?)?.toInt() ?? 0));
  }

  /// 从今天（或昨天）起向前连续有记录的天数。
  int _streak(Map<String, int> counts) {
    if (counts.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 今天没学时，允许从昨天起算，避免跨午夜瞬间清零。
    var cursor = today;
    if ((counts[_dateKey(today)] ?? 0) == 0) {
      cursor = today.subtract(const Duration(days: 1));
      if ((counts[_dateKey(cursor)] ?? 0) == 0) return 0;
    }

    var streak = 0;
    while ((counts[_dateKey(cursor)] ?? 0) > 0) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  String _dateKey(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
}
