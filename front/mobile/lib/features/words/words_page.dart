import 'package:flutter/material.dart';

import '../../core/speech_service.dart';
import '../../core/study_stats.dart';
import 'word_collection.dart';
import 'word_collection_page.dart';
import 'word_model.dart';
import 'word_quiz_page.dart';
import 'word_repository.dart';

/// 单词卡片：从后端拉取 N5 词库，点按卡片翻面，前后切换学习。
class WordsPage extends StatefulWidget {
  const WordsPage({super.key});

  @override
  State<WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  final WordRepository _repository = WordRepository();

  late Future<List<Word>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchWords();
  }

  void _reload() {
    setState(() {
      _future = _repository.fetchWords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('单词卡片'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: '收藏与错题',
            icon: const Icon(Icons.collections_bookmark_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WordCollectionPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Word>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(
                message: '加载失败，请检查网络或后端服务',
                onRetry: _reload,
              );
            }
            final words = snapshot.data ?? const [];
            if (words.isEmpty) {
              return _ErrorView(message: '暂无单词数据', onRetry: _reload);
            }
            return _WordDeck(words: words);
          },
        ),
      ),
    );
  }
}

class _WordDeck extends StatefulWidget {
  const _WordDeck({required this.words});

  final List<Word> words;

  @override
  State<_WordDeck> createState() => _WordDeckState();
}

class _WordDeckState extends State<_WordDeck> {
  late final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.words.length) return;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.words.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.words[_index].level} 词库 · ${_index + 1}/$total',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordQuizPage(words: widget.words),
                      ),
                    ),
                    icon: const Icon(Icons.quiz_rounded, size: 18),
                    label: const Text('测验'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_index + 1) / total,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF166534)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (value) => setState(() => _index = value),
            itemCount: total,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _FlipCard(word: widget.words[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _index > 0 ? () => _go(-1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('上一个'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: const Color(0xFF166534),
                    side: const BorderSide(color: Color(0xFFC7D2CB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _index < total - 1 ? () => _go(1) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: const Text('下一个'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(0xFF166534),
                    disabledBackgroundColor: const Color(0xFFC7D2CB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 点按翻面的单词卡：正面词 + 假名，背面释义 + 例句。
class _FlipCard extends StatefulWidget {
  const _FlipCard({required this.word});

  final Word word;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  final StudyStatsService _stats = StudyStatsService();
  final WordCollectionService _collection = WordCollectionService();
  bool _favorite = false;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final fav = await _collection.isFavorite(widget.word.id);
    if (!mounted) return;
    setState(() => _favorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final next = await _collection.toggleFavorite(widget.word.id);
    if (!mounted) return;
    setState(() => _favorite = next);
  }

  @override
  void didUpdateWidget(covariant _FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 切换到新单词时回到正面，并刷新收藏态。
    if (oldWidget.word.id != widget.word.id) {
      _controller.value = 0;
      _loadFavorite();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isAnimating) return;
    if (_controller.value >= 0.5) {
      _controller.reverse();
    } else {
      _controller.forward();
      // 翻到背面查看释义即视为学过该词。
      _stats.markWordLearned(widget.word.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = _controller.value * 3.1415926;
          final showBack = _controller.value > 0.5;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle);
          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.1415926),
                    child: _CardBack(word: widget.word),
                  )
                : _CardFront(
                    word: widget.word,
                    favorite: _favorite,
                    onToggleFavorite: _toggleFavorite,
                  ),
          );
        },
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.word,
    required this.favorite,
    required this.onToggleFavorite,
  });

  final Word word;
  final bool favorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return _CardSurface(
      gradient: const [Color(0xFFFFFFFF), Color(0xFFF1F8F3)],
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              tooltip: '朗读',
              icon: const Icon(
                Icons.volume_up_rounded,
                color: Color(0xFF166534),
              ),
              onPressed: () => SpeechService.instance.speak(word.kana),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              tooltip: favorite ? '取消收藏' : '收藏',
              icon: Icon(
                favorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: favorite
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF9CA3AF),
              ),
              onPressed: onToggleFavorite,
            ),
          ),
          Center(child: _frontContent()),
        ],
      ),
    );
  }

  Widget _frontContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          Text(
            word.headword,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            word.kana,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF166534),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (word.romaji.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              word.romaji,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
            ),
          ],
          const SizedBox(height: 24),
          const _FlipHint(text: '点按卡片查看释义'),
        ],
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    return _CardSurface(
      gradient: const [Color(0xFF111827), Color(0xFF166534)],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${word.headword}（${word.kana}）',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              word.meaning,
              style: const TextStyle(
                color: Color(0xFFE8F5EC),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            if (word.example.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(color: Color(0x33FFFFFF), height: 1),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      word.example,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '朗读例句',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => SpeechService.instance.speak(word.example),
                  ),
                ],
              ),
              if (word.exampleMeaning.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  word.exampleMeaning,
                  style: const TextStyle(
                    color: Color(0xFFB9D9C4),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.gradient, required this.child});

  final List<Color> gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FlipHint extends StatelessWidget {
  const _FlipHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: const Text('重新加载')),
        ],
      ),
    );
  }
}
