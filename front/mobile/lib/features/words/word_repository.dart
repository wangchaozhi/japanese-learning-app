import '../../core/api_client.dart';
import 'word_model.dart';

/// 负责从后端拉取单词卡片数据。
class WordRepository {
  WordRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Word>> fetchWords({String level = 'N5'}) async {
    final resp = await _client.get('/api/mobile/words', query: {'level': level});
    if (resp['code'] != 0) {
      throw Exception(resp['msg']?.toString() ?? '加载单词失败');
    }
    final data = resp['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Word.fromJson)
        .toList(growable: false);
  }
}
