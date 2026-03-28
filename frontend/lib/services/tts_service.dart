/// TtsService — singleton for Text-to-Speech throughout Sakhya.
/// Works offline (uses device TTS engine).
/// Usage: TtsService.instance.speak('Namaste!');
///        TtsService.instance.toggleMute();

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    _initialized = true;
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.45);   // slightly slower for rural users
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Strips emojis and special symbols so TTS does not read them aloud.
  static String _clean(String text) {
    // Remove emoji ranges and common decoration chars
    return text
        .replaceAll(RegExp(
          r'[\u{1F300}-\u{1FAFF}'      // Misc symbols, emoticons, transport, etc.
          r'\u{2600}-\u{26FF}'          // Misc symbols
          r'\u{2700}-\u{27BF}'          // Dingbats
          r'\u{FE00}-\u{FE0F}'          // Variation selectors
          r'\u{1F900}-\u{1F9FF}'
          r'\u{1FA00}-\u{1FA6F}'
          r'\u{1FA70}-\u{1FAFF}'
          r'\u{231A}-\u{231B}'
          r'\u{23E9}-\u{23F3}'
          r'\u{23F8}-\u{23FA}'
          r'\u{25AA}-\u{25AB}'
          r'\u{25B6}\u{25C0}'
          r'\u{25FB}-\u{25FE}'
          r'\u{2600}-\u{2604}'
          r'\u{260E}\u{2611}'
          r'\u{2614}-\u{2615}'
          r'\u{2618}\u{261D}'
          r'\u{2620}\u{2622}-\u{2623}'
          r'\u{2626}\u{262A}'
          r'\u{262E}-\u{262F}'
          r'\u{2638}-\u{263A}'
          r'\u{2640}\u{2642}'
          r']',
          unicode: true,
        ), '')
        .replaceAll(RegExp(r'[⭐🎉✅❌📞💰🏠🪡👩🎁✨📊📚📝🧨🔄🌟🌇☀️🌸📐📓✏️🎒🫙🌱🌼💡✋]'), '')
        .replaceAll(RegExp(r'[!?✓~•]'), ' ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  Future<void> speak(String text, {String? langCode}) async {
    if (_isMuted || text.isEmpty) return;
    await _ensureInit();
    if (langCode != null) {
      await _tts.setLanguage(langCode == 'en' ? 'en-IN' : 'hi-IN');
    }
    await _tts.stop();
    await _tts.speak(_clean(text));
  }

  /// Speak using current app language from LanguageController.
  Future<void> speakL({required bool isHindi, required String hindi, required String english}) async {
    final text = _clean(isHindi ? hindi : english);
    final lang = isHindi ? 'hi' : 'en';
    await speak(text, langCode: lang);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) _tts.stop();
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    await _ensureInit();
    await _tts.setLanguage(langCode == 'en' ? 'en-IN' : 'hi-IN');
  }
}
