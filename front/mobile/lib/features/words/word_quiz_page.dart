import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/study_stats.dart';
import 'word_collection.dart';
import 'word_model.dart';

/// 单词测验：展示日语词，从四个中文释义中选出正确项。
class WordQuizPage extends StatefulWidget {
  const WordQuizPage({super.key, required this.words});

  final List<Word> words;

  @override
  State<WordQuizPage> createState() => _WordQuizPageState();
}

class _WordQuizPageState extends State<WordQuizPage> {
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
    final count = min(_maxQuestions, pool.length);
    _questions = pool.take(count).toList();
    _index = 0;
    _correct = 0;
    _selected = null;
    _buildOptions();
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
  }

  void _showResult() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('测验完成'),
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
              backgroundColor: const Color(0xFFDC2626),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('单词测验'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
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
                      color: Color(0xFFDC2626),
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
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFDC2626)),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        question.headword,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.kana,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                    backgroundColor: const Color(0xFFDC2626),
                    disabledBackgroundColor: const Color(0xFFE7B7B7),
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
        ),
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
