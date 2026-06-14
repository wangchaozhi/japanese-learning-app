/// 五十音数据：平假名、片假名和罗马音。
enum KanaType { hiragana, katakana }

extension KanaTypeLabel on KanaType {
  String get label => this == KanaType.hiragana ? '平假名' : '片假名';
}

class Kana {
  const Kana({
    required this.hiragana,
    required this.katakana,
    required this.romaji,
  });

  final String hiragana;
  final String katakana;
  final String romaji;

  String character(KanaType type) =>
      type == KanaType.hiragana ? hiragana : katakana;
}

class KanaRow {
  const KanaRow({required this.label, required this.cells});

  /// 行标签，例如「あ行」。
  final String label;

  /// 五列，空位用 null 占位（如 や 行的 yi、ye）。
  final List<Kana?> cells;
}

/// 清音五十音图，按行组织，方便表格展示。
const List<KanaRow> gojuonRows = [
  KanaRow(
    label: 'あ行',
    cells: [
      Kana(hiragana: 'あ', katakana: 'ア', romaji: 'a'),
      Kana(hiragana: 'い', katakana: 'イ', romaji: 'i'),
      Kana(hiragana: 'う', katakana: 'ウ', romaji: 'u'),
      Kana(hiragana: 'え', katakana: 'エ', romaji: 'e'),
      Kana(hiragana: 'お', katakana: 'オ', romaji: 'o'),
    ],
  ),
  KanaRow(
    label: 'か行',
    cells: [
      Kana(hiragana: 'か', katakana: 'カ', romaji: 'ka'),
      Kana(hiragana: 'き', katakana: 'キ', romaji: 'ki'),
      Kana(hiragana: 'く', katakana: 'ク', romaji: 'ku'),
      Kana(hiragana: 'け', katakana: 'ケ', romaji: 'ke'),
      Kana(hiragana: 'こ', katakana: 'コ', romaji: 'ko'),
    ],
  ),
  KanaRow(
    label: 'さ行',
    cells: [
      Kana(hiragana: 'さ', katakana: 'サ', romaji: 'sa'),
      Kana(hiragana: 'し', katakana: 'シ', romaji: 'shi'),
      Kana(hiragana: 'す', katakana: 'ス', romaji: 'su'),
      Kana(hiragana: 'せ', katakana: 'セ', romaji: 'se'),
      Kana(hiragana: 'そ', katakana: 'ソ', romaji: 'so'),
    ],
  ),
  KanaRow(
    label: 'た行',
    cells: [
      Kana(hiragana: 'た', katakana: 'タ', romaji: 'ta'),
      Kana(hiragana: 'ち', katakana: 'チ', romaji: 'chi'),
      Kana(hiragana: 'つ', katakana: 'ツ', romaji: 'tsu'),
      Kana(hiragana: 'て', katakana: 'テ', romaji: 'te'),
      Kana(hiragana: 'と', katakana: 'ト', romaji: 'to'),
    ],
  ),
  KanaRow(
    label: 'な行',
    cells: [
      Kana(hiragana: 'な', katakana: 'ナ', romaji: 'na'),
      Kana(hiragana: 'に', katakana: 'ニ', romaji: 'ni'),
      Kana(hiragana: 'ぬ', katakana: 'ヌ', romaji: 'nu'),
      Kana(hiragana: 'ね', katakana: 'ネ', romaji: 'ne'),
      Kana(hiragana: 'の', katakana: 'ノ', romaji: 'no'),
    ],
  ),
  KanaRow(
    label: 'は行',
    cells: [
      Kana(hiragana: 'は', katakana: 'ハ', romaji: 'ha'),
      Kana(hiragana: 'ひ', katakana: 'ヒ', romaji: 'hi'),
      Kana(hiragana: 'ふ', katakana: 'フ', romaji: 'fu'),
      Kana(hiragana: 'へ', katakana: 'ヘ', romaji: 'he'),
      Kana(hiragana: 'ほ', katakana: 'ホ', romaji: 'ho'),
    ],
  ),
  KanaRow(
    label: 'ま行',
    cells: [
      Kana(hiragana: 'ま', katakana: 'マ', romaji: 'ma'),
      Kana(hiragana: 'み', katakana: 'ミ', romaji: 'mi'),
      Kana(hiragana: 'む', katakana: 'ム', romaji: 'mu'),
      Kana(hiragana: 'め', katakana: 'メ', romaji: 'me'),
      Kana(hiragana: 'も', katakana: 'モ', romaji: 'mo'),
    ],
  ),
  KanaRow(
    label: 'や行',
    cells: [
      Kana(hiragana: 'や', katakana: 'ヤ', romaji: 'ya'),
      null,
      Kana(hiragana: 'ゆ', katakana: 'ユ', romaji: 'yu'),
      null,
      Kana(hiragana: 'よ', katakana: 'ヨ', romaji: 'yo'),
    ],
  ),
  KanaRow(
    label: 'ら行',
    cells: [
      Kana(hiragana: 'ら', katakana: 'ラ', romaji: 'ra'),
      Kana(hiragana: 'り', katakana: 'リ', romaji: 'ri'),
      Kana(hiragana: 'る', katakana: 'ル', romaji: 'ru'),
      Kana(hiragana: 'れ', katakana: 'レ', romaji: 're'),
      Kana(hiragana: 'ろ', katakana: 'ロ', romaji: 'ro'),
    ],
  ),
  KanaRow(
    label: 'わ行',
    cells: [
      Kana(hiragana: 'わ', katakana: 'ワ', romaji: 'wa'),
      null,
      null,
      null,
      Kana(hiragana: 'を', katakana: 'ヲ', romaji: 'wo'),
    ],
  ),
  KanaRow(
    label: '撥音',
    cells: [
      Kana(hiragana: 'ん', katakana: 'ン', romaji: 'n'),
      null,
      null,
      null,
      null,
    ],
  ),
];

/// 浊音和半浊音。
const List<KanaRow> dakuonRows = [
  KanaRow(
    label: 'が行',
    cells: [
      Kana(hiragana: 'が', katakana: 'ガ', romaji: 'ga'),
      Kana(hiragana: 'ぎ', katakana: 'ギ', romaji: 'gi'),
      Kana(hiragana: 'ぐ', katakana: 'グ', romaji: 'gu'),
      Kana(hiragana: 'げ', katakana: 'ゲ', romaji: 'ge'),
      Kana(hiragana: 'ご', katakana: 'ゴ', romaji: 'go'),
    ],
  ),
  KanaRow(
    label: 'ざ行',
    cells: [
      Kana(hiragana: 'ざ', katakana: 'ザ', romaji: 'za'),
      Kana(hiragana: 'じ', katakana: 'ジ', romaji: 'ji'),
      Kana(hiragana: 'ず', katakana: 'ズ', romaji: 'zu'),
      Kana(hiragana: 'ぜ', katakana: 'ゼ', romaji: 'ze'),
      Kana(hiragana: 'ぞ', katakana: 'ゾ', romaji: 'zo'),
    ],
  ),
  KanaRow(
    label: 'だ行',
    cells: [
      Kana(hiragana: 'だ', katakana: 'ダ', romaji: 'da'),
      Kana(hiragana: 'ぢ', katakana: 'ヂ', romaji: 'ji'),
      Kana(hiragana: 'づ', katakana: 'ヅ', romaji: 'zu'),
      Kana(hiragana: 'で', katakana: 'デ', romaji: 'de'),
      Kana(hiragana: 'ど', katakana: 'ド', romaji: 'do'),
    ],
  ),
  KanaRow(
    label: 'ば行',
    cells: [
      Kana(hiragana: 'ば', katakana: 'バ', romaji: 'ba'),
      Kana(hiragana: 'び', katakana: 'ビ', romaji: 'bi'),
      Kana(hiragana: 'ぶ', katakana: 'ブ', romaji: 'bu'),
      Kana(hiragana: 'べ', katakana: 'ベ', romaji: 'be'),
      Kana(hiragana: 'ぼ', katakana: 'ボ', romaji: 'bo'),
    ],
  ),
  KanaRow(
    label: 'ぱ行',
    cells: [
      Kana(hiragana: 'ぱ', katakana: 'パ', romaji: 'pa'),
      Kana(hiragana: 'ぴ', katakana: 'ピ', romaji: 'pi'),
      Kana(hiragana: 'ぷ', katakana: 'プ', romaji: 'pu'),
      Kana(hiragana: 'ぺ', katakana: 'ペ', romaji: 'pe'),
      Kana(hiragana: 'ぽ', katakana: 'ポ', romaji: 'po'),
    ],
  ),
];

/// 拗音（与 ゃゅょ 拼合），每行三个，右侧用 null 补齐成五列对齐。
const List<KanaRow> yoonRows = [
  KanaRow(
    label: 'きゃ',
    cells: [
      Kana(hiragana: 'きゃ', katakana: 'キャ', romaji: 'kya'),
      Kana(hiragana: 'きゅ', katakana: 'キュ', romaji: 'kyu'),
      Kana(hiragana: 'きょ', katakana: 'キョ', romaji: 'kyo'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'しゃ',
    cells: [
      Kana(hiragana: 'しゃ', katakana: 'シャ', romaji: 'sha'),
      Kana(hiragana: 'しゅ', katakana: 'シュ', romaji: 'shu'),
      Kana(hiragana: 'しょ', katakana: 'ショ', romaji: 'sho'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'ちゃ',
    cells: [
      Kana(hiragana: 'ちゃ', katakana: 'チャ', romaji: 'cha'),
      Kana(hiragana: 'ちゅ', katakana: 'チュ', romaji: 'chu'),
      Kana(hiragana: 'ちょ', katakana: 'チョ', romaji: 'cho'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'にゃ',
    cells: [
      Kana(hiragana: 'にゃ', katakana: 'ニャ', romaji: 'nya'),
      Kana(hiragana: 'にゅ', katakana: 'ニュ', romaji: 'nyu'),
      Kana(hiragana: 'にょ', katakana: 'ニョ', romaji: 'nyo'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'ひゃ',
    cells: [
      Kana(hiragana: 'ひゃ', katakana: 'ヒャ', romaji: 'hya'),
      Kana(hiragana: 'ひゅ', katakana: 'ヒュ', romaji: 'hyu'),
      Kana(hiragana: 'ひょ', katakana: 'ヒョ', romaji: 'hyo'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'みゃ',
    cells: [
      Kana(hiragana: 'みゃ', katakana: 'ミャ', romaji: 'mya'),
      Kana(hiragana: 'みゅ', katakana: 'ミュ', romaji: 'myu'),
      Kana(hiragana: 'みょ', katakana: 'ミョ', romaji: 'myo'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'りゃ',
    cells: [
      Kana(hiragana: 'りゃ', katakana: 'リャ', romaji: 'rya'),
      Kana(hiragana: 'りゅ', katakana: 'リュ', romaji: 'ryu'),
      Kana(hiragana: 'りょ', katakana: 'リョ', romaji: 'ryo'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'ぎゃ',
    cells: [
      Kana(hiragana: 'ぎゃ', katakana: 'ギャ', romaji: 'gya'),
      Kana(hiragana: 'ぎゅ', katakana: 'ギュ', romaji: 'gyu'),
      Kana(hiragana: 'ぎょ', katakana: 'ギョ', romaji: 'gyo'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'じゃ',
    cells: [
      Kana(hiragana: 'じゃ', katakana: 'ジャ', romaji: 'ja'),
      Kana(hiragana: 'じゅ', katakana: 'ジュ', romaji: 'ju'),
      Kana(hiragana: 'じょ', katakana: 'ジョ', romaji: 'jo'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'びゃ',
    cells: [
      Kana(hiragana: 'びゃ', katakana: 'ビャ', romaji: 'bya'),
      Kana(hiragana: 'びゅ', katakana: 'ビュ', romaji: 'byu'),
      Kana(hiragana: 'びょ', katakana: 'ビョ', romaji: 'byo'),
      null,
      null,
    ],
  ),
  KanaRow(
    label: 'ぴゃ',
    cells: [
      Kana(hiragana: 'ぴゃ', katakana: 'ピャ', romaji: 'pya'),
      Kana(hiragana: 'ぴゅ', katakana: 'ピュ', romaji: 'pyu'),
      Kana(hiragana: 'ぴょ', katakana: 'ピョ', romaji: 'pyo'),
      null,
      null,
    ],
  ),
];

/// 假名分组，用于切换图表和限定测验范围。
enum KanaGroup { seion, dakuon, yoon }

extension KanaGroupInfo on KanaGroup {
  String get label => switch (this) {
    KanaGroup.seion => '清音',
    KanaGroup.dakuon => '浊音',
    KanaGroup.yoon => '拗音',
  };

  List<KanaRow> get rows => switch (this) {
    KanaGroup.seion => gojuonRows,
    KanaGroup.dakuon => dakuonRows,
    KanaGroup.yoon => yoonRows,
  };

  List<Kana> get kana => kanaInRows(rows);
}

/// 取出若干行中的有效假名（去掉占位 null）。
List<Kana> kanaInRows(List<KanaRow> rows) => [
  for (final row in rows)
    for (final cell in row.cells) ?cell,
];

/// 清音的扁平列表，保留给默认测验使用。
final List<Kana> allKana = kanaInRows(gojuonRows);
