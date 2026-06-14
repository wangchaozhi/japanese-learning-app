import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/speech_service.dart';
import '../../core/study_stats.dart';
import 'word_collection.dart';
import 'word_model.dart';
import 'word_repository.dart';

/// 听力练习：播放单词读音，从四个中文释义中选出正确项。
class WordListeningPage extends StatefulWidget {
  const WordListeningPage({super.key});

  @override
  State<WordListeningPage> createState() => _WordListeningPageState();
}

class _WordListeningPageState extends State<WordListeningPage> {
  final WordRepository _repository = WordRepository();

  late Future<List<Word>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('听力跟读'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Word>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final words = snapshot.data ?? const [];
            if (snapshot.hasError || words.length < 4) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    snapshot.hasError ? '加载失败，请检查网络或后端服务' : '单词数量不足，无法开始听力练习',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              );
            }
            return _ListeningQuiz(words: words);
          },
        ),
      ),
    );
  }
}

class _ListeningQuiz extends StatefulWidget {
  const _ListeningQuiz({required this.words});

  final List<Word> words;

  @override
  State<_ListeningQuiz> createState() => _ListeningQuizState();
}

class _ListeningQuizState extends State<_ListeningQuiz> {
  static const int _maxQuestions = 10;

  final Random _random = Random();
  final StudyStatsService _stats = StudyStatsService();
  final WordCollectionService _collection = WordCollectionService();

  late List<Word> _questions;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  List<String> _options = const [];

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    final pool = List<Word>.from(widget.words)..shuffle(_random);
    _questions = pool.take(min(_maxQuestions, pool.length)).toList();
    _index = 0;
    _correct = 0;
    _selected = null;
    _buildOptions();
    _play();
  }

  void _buildOptions() {
    final answer = _questions[_index].meaning;
    final choices = <String>{answer};
    final distractors = List<Word>.from(widget.words)..shuffle(_random);
    for (final word in distractors) {
      if (choices.length >= 4) break;
      choices.add(word.meaning);
    }
    _options = choices.toList()..shuffle(_random);
  }

  void _play() {
    SpeechService.instance.speak(_questions[_index].kana);
  }

  void _select(String option) {
    if (_selected != null) return;
    final question = _questions[_index];
    final correct = option == question.meaning;
    setState(() {
      _selected = option;
      if (correct) _correct++;
    });
    _stats.addReview();
    if (correct) {
      _collection.clearMistake(question.id);
    } else {
      _collection.recordMistake(question.id);
    }
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      _showResult();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _buildOptions();
    });
    _play();
  }

  void _showResult() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('练习完成'),
        content: Text(
          '本轮共 ${_questions.length} 题，答对 $_correct 题。',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(_start);
            },
            child: const Text('再来一轮'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    final answer = question.meaning;
    final revealed = _selected != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 ${_index + 1} / ${_questions.length} 题',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '答对 $_correct',
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _play,
                    child: Container(
                      width: 132,
                      height: 132,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFDC2626)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33F59E0B),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    revealed ? '${question.headword}（${question.kana}）' : '点按喇叭重听',
                    style: TextStyle(
                      color: revealed
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                      fontSize: revealed ? 20 : 14,
                      fontWeight: revealed ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final option in _options)
            _OptionTile(
              label: option,
              state: _optionState(option, answer),
              onTap: () => _select(option),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                disabledBackgroundColor: const Color(0xFFF1D9A8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _selected == null ? null : _next,
              child: Text(
                _index + 1 >= _questions.length ? '查看结果' : '下一题',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _OptionState _optionState(String option, String answer) {
    if (_selected == null) return _OptionState.idle;
    if (option == answer) return _OptionState.correct;
    if (option == _selected) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color border;
    late final Color foreground;
    switch (state) {
      case _OptionState.correct:
        background = const Color(0xFFE8F5EC);
        border = const Color(0xFF166534);
        foreground = const Color(0xFF166534);
      case _OptionState.wrong:
        background = const Color(0xFFFDECEC);
        border = const Color(0xFFDC2626);
        foreground = const Color(0xFFDC2626);
      case _OptionState.idle:
        background = Colors.white;
        border = const Color(0xFFE5E7EB);
        foreground = const Color(0xFF111827);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
                if (state == _OptionState.correct)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF166534))
                else if (state == _OptionState.wrong)
                  const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
