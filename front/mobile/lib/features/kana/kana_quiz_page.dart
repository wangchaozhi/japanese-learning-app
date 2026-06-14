import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/speech_service.dart';
import '../../core/study_stats.dart';
import 'kana_data.dart';

/// 五十音选择题测验：给出假名，从四个罗马音中选择正确读音。
class KanaQuizPage extends StatefulWidget {
  const KanaQuizPage({super.key, required this.type, required this.group});

  final KanaType type;
  final KanaGroup group;

  @override
  State<KanaQuizPage> createState() => _KanaQuizPageState();
}

class _KanaQuizPageState extends State<KanaQuizPage> {
  static const int _totalQuestions = 10;

  final Random _random = Random();
  final StudyStatsService _stats = StudyStatsService();
  late final List<Kana> _pool = widget.group.kana;
  late List<Kana> _questions;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  List<String> _options = const [];

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    final pool = List<Kana>.from(_pool)..shuffle(_random);
    _questions = pool.take(min(_totalQuestions, pool.length)).toList();
    _index = 0;
    _correct = 0;
    _selected = null;
    _buildOptions();
  }

  void _buildOptions() {
    final answer = _questions[_index].romaji;
    final choices = <String>{answer};
    final distractors = List<Kana>.from(_pool)..shuffle(_random);
    for (final kana in distractors) {
      if (choices.length >= 4) break;
      choices.add(kana.romaji);
    }
    _options = choices.toList()..shuffle(_random);
  }

  void _onSelect(String option) {
    if (_selected != null) return;
    setState(() {
      _selected = option;
      if (option == _questions[_index].romaji) _correct++;
    });
    _stats.addReview();
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
              backgroundColor: const Color(0xFF166534),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(_startQuiz);
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
    final answer = question.romaji;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.group.label}·${widget.type.label}测验'),
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
              _ProgressBar(
                current: _index + 1,
                total: _questions.length,
                correct: _correct,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => SpeechService.instance.speak(
                      question.character(widget.type),
                    ),
                    child: Container(
                      width: 168,
                      height: 168,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F0F172A),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              question.character(widget.type),
                              style: const TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 10,
                            bottom: 10,
                            child: Icon(
                              Icons.volume_up_rounded,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final option in _options)
                _OptionTile(
                  label: option,
                  state: _optionState(option, answer),
                  onTap: () => _onSelect(option),
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    disabledBackgroundColor: const Color(0xFFC7D2CB),
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

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.current,
    required this.total,
    required this.correct,
  });

  final int current;
  final int total;
  final int correct;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '第 $current / $total 题',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '答对 $correct',
              style: const TextStyle(
                color: Color(0xFF166534),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF166534)),
          ),
        ),
      ],
    );
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: foreground,
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
