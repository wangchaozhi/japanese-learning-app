import 'package:flutter_tts/flutter_tts.dart';

/// 日语发音服务，封装 flutter_tts，全局单例，按需初始化。
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.45); // 放慢，便于初学者跟读。
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _ready = true;
  }

  /// 朗读日语文本；空文本忽略。失败时静默，不打断学习流程。
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _ensureReady();
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // 设备不支持日语 TTS 时忽略。
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // ignore
    }
  }
}
