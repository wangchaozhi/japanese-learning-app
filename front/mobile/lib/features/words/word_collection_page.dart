import 'package:flutter/material.dart';

import 'word_collection.dart';
import 'word_model.dart';
import 'word_repository.dart';

/// 收藏与错题本：分两个标签展示收藏的单词和答错过的单词。
class WordCollectionPage extends StatefulWidget {
  const WordCollectionPage({super.key});

  @override
  State<WordCollectionPage> createState() => _WordCollectionPageState();
}

class _WordCollectionPageState extends State<WordCollectionPage> {
  final WordRepository _repository = WordRepository();
  final WordCollectionService _collection = WordCollectionService();

  bool _loading = true;
  String? _error;
  List<Word> _words = const [];
  Set<int> _favorites = const {};
  Map<int, int> _mistakes = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final words = await _repository.fetchWords();
      final favorites = await _collection.favorites();
      final mistakes = await _collection.mistakes();
      if (!mounted) return;
      setState(() {
        _words = words;
        _favorites = favorites;
        _mistakes = mistakes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败，请检查网络或后端服务';
        _loading = false;
      });
    }
  }

  Future<void> _unfavorite(int id) async {
    await _collection.toggleFavorite(id);
    await _load();
  }

  Future<void> _clearMistake(int id) async {
    await _collection.clearMistake(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteWords = _words
        .where((w) => _favorites.contains(w.id))
        .toList(growable: false);
    final mistakeWords =
        (_words.where((w) => _mistakes.containsKey(w.id)).toList()
          ..sort((a, b) => (_mistakes[b.id] ?? 0).compareTo(_mistakes[a.id] ?? 0)));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('收藏与错题'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          bottom: TabBar(
            labelColor: const Color(0xFF166534),
            unselectedLabelColor: const Color(0xFF9CA3AF),
            indicatorColor: const Color(0xFF166534),
            tabs: [
              Tab(text: '收藏 (${favoriteWords.length})'),
              Tab(text: '错题 (${mistakeWords.length})'),
            ],
          ),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (_loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_error != null) {
                return _EmptyOrError(message: _error!, onRetry: _load);
              }
              return TabBarView(
                children: [
                  _WordList(
                    words: favoriteWords,
                    emptyText: '还没有收藏的单词，去单词卡片点星标收藏吧',
                    trailingBuilder: (word) => _RemoveButton(
                      tooltip: '取消收藏',
                      onPressed: () => _unfavorite(word.id),
                    ),
                  ),
                  _WordList(
                    words: mistakeWords,
                    emptyText: '还没有错题，做单词测验时答错会自动收录',
                    badgeBuilder: (word) => _mistakes[word.id] ?? 0,
                    trailingBuilder: (word) => _RemoveButton(
                      tooltip: '移出错题本',
                      icon: Icons.check_rounded,
                      onPressed: () => _clearMistake(word.id),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  const _WordList({
    required this.words,
    required this.emptyText,
    required this.trailingBuilder,
    this.badgeBuilder,
  });

  final List<Word> words;
  final String emptyText;
  final Widget Function(Word word) trailingBuilder;
  final int Function(Word word)? badgeBuilder;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return _EmptyOrError(message: emptyText);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: words.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final word = words[index];
        final badge = badgeBuilder?.call(word);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          word.headword,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          word.kana,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                        if (badge != null && badge > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDECEC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '错$badge次',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.meaning,
                      style: const TextStyle(color: Color(0xFF374151)),
                    ),
                  ],
                ),
              ),
              trailingBuilder(word),
            ],
          ),
        );
      },
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({
    required this.tooltip,
    required this.onPressed,
    this.icon = Icons.close_rounded,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: const Color(0xFF9CA3AF)),
      onPressed: onPressed,
    );
  }
}

class _EmptyOrError extends StatelessWidget {
  const _EmptyOrError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 48,
            color: Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('重新加载')),
          ],
        ],
      ),
    );
  }
}
