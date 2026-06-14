import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 单词收藏与错题本：本地持久化收藏的单词 id 和答错的单词及次数。
class WordCollectionService {
  static const String _favoritesKey = 'word_favorites';
  static const String _mistakesKey = 'word_mistakes';

  Future<Set<int>> favorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? const <String>[];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<bool> isFavorite(int wordId) async {
    return (await favorites()).contains(wordId);
  }

  /// 切换收藏状态，返回切换后的新状态。
  Future<bool> toggleFavorite(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? <String>[];
    final key = '$wordId';
    final added = !raw.contains(key);
    if (added) {
      raw.add(key);
    } else {
      raw.remove(key);
    }
    await prefs.setStringList(_favoritesKey, raw);
    return added;
  }

  /// 答错一次，错题次数 +1。
  Future<void> recordMistake(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = _readMistakes(prefs);
    counts[wordId] = (counts[wordId] ?? 0) + 1;
    await prefs.setString(_mistakesKey, jsonEncode(_encodeKeys(counts)));
  }

  /// 从错题本移除某个单词（例如已掌握）。
  Future<void> clearMistake(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = _readMistakes(prefs);
    if (counts.remove(wordId) != null) {
      await prefs.setString(_mistakesKey, jsonEncode(_encodeKeys(counts)));
    }
  }

  /// 错题 id -> 答错次数。
  Future<Map<int, int>> mistakes() async {
    final prefs = await SharedPreferences.getInstance();
    return _readMistakes(prefs);
  }

  Map<int, int> _readMistakes(SharedPreferences prefs) {
    final raw = prefs.getString(_mistakesKey);
    if (raw == null || raw.isEmpty) return <int, int>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <int, int>{};
    final result = <int, int>{};
    decoded.forEach((key, value) {
      final id = int.tryParse(key.toString());
      if (id != null) result[id] = (value as num?)?.toInt() ?? 0;
    });
    return result;
  }

  Map<String, int> _encodeKeys(Map<int, int> counts) =>
      counts.map((key, value) => MapEntry('$key', value));
}
