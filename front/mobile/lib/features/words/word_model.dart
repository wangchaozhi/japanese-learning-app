/// 单词卡片数据模型，对应后端 /api/mobile/words 返回。
class Word {
  const Word({
    required this.id,
    required this.kana,
    required this.kanji,
    required this.romaji,
    required this.meaning,
    required this.example,
    required this.exampleMeaning,
    required this.level,
  });

  final int id;
  final String kana;
  final String kanji;
  final String romaji;
  final String meaning;
  final String example;
  final String exampleMeaning;
  final String level;

  /// 卡片正面主词：有汉字优先显示汉字，否则显示假名。
  String get headword => kanji.isNotEmpty ? kanji : kana;

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: (json['id'] as num?)?.toInt() ?? 0,
      kana: json['kana']?.toString() ?? '',
      kanji: json['kanji']?.toString() ?? '',
      romaji: json['romaji']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      example: json['example']?.toString() ?? '',
      exampleMeaning: json['exampleMeaning']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
    );
  }
}
