import 'package:flutter/material.dart';

import '../../core/speech_service.dart';
import 'kana_data.dart';
import 'kana_quiz_page.dart';

/// 五十音图：平假名 / 片假名切换浏览，并进入测验。
class KanaPage extends StatefulWidget {
  const KanaPage({super.key});

  @override
  State<KanaPage> createState() => _KanaPageState();
}

class _KanaPageState extends State<KanaPage> {
  KanaType _type = KanaType.hiragana;
  KanaGroup _group = KanaGroup.seion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('五十音练习'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _TypeToggle(
                type: _type,
                onChanged: (value) => setState(() => _type = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: _GroupSelector(
                group: _group,
                onChanged: (value) => setState(() => _group = value),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                child: Column(
                  children: [
                    for (final row in _group.rows)
                      _KanaRowView(row: row, type: _type),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KanaQuizPage(type: _type, group: _group),
          ),
        ),
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.quiz_rounded),
        label: Text('${_group.label}测验'),
      ),
    );
  }
}

class _GroupSelector extends StatelessWidget {
  const _GroupSelector({required this.group, required this.onChanged});

  final KanaGroup group;
  final ValueChanged<KanaGroup> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in KanaGroup.values)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option.label),
              selected: option == group,
              showCheckmark: false,
              selectedColor: const Color(0xFF166534),
              labelStyle: TextStyle(
                color: option == group
                    ? Colors.white
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: const Color(0xFFF1F2F5),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (_) => onChanged(option),
            ),
          ),
      ],
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});

  final KanaType type;
  final ValueChanged<KanaType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final option in KanaType.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: option == type ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: option == type
                        ? const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: option == type
                          ? const Color(0xFF166534)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _KanaRowView extends StatelessWidget {
  const _KanaRowView({required this.row, required this.type});

  final KanaRow row;
  final KanaType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                row.label,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                for (final cell in row.cells)
                  Expanded(child: _KanaCell(kana: cell, type: type)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KanaCell extends StatelessWidget {
  const _KanaCell({required this.kana, required this.type});

  final Kana? kana;
  final KanaType type;

  @override
  Widget build(BuildContext context) {
    final cell = kana;
    if (cell == null) {
      return const SizedBox(height: 64);
    }

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => SpeechService.instance.speak(cell.character(type)),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cell.character(type),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cell.romaji,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
