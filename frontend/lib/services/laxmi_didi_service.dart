import 'package:connectivity_plus/connectivity_plus.dart';
import 'llm/llm_provider.dart';
import 'llm/offline_llm_provider.dart';
import 'llm/gemini_llm_provider.dart';
import 'package:flutter/foundation.dart';

class LaxmiDidiService {
  static final LaxmiDidiService instance = LaxmiDidiService._internal();

  LaxmiDidiService._internal() {
    // Read the key from the environment variables, defaulting to the one provided by the user in this workflow session
    const defaultKey = 'XXX';
    const apiKey = String.fromEnvironment(
      'GEMINI_KEY',
      defaultValue: defaultKey,
    );

    _geminiProvider = GeminiLlmProvider(apiKey: apiKey);
    _offlineProvider = OfflineLlmProvider();
  }

  late final LlmProvider _geminiProvider;
  late final LlmProvider _offlineProvider;

  Future<String> getResponse(String prompt, bool isHindi) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

      if (hasInternet) {
        try {
          return await _geminiProvider.generateResponse(prompt, isHindi);
        } catch (e) {
          debugPrint('Gemini failure: $e');
          // If Gemini fails (API issue, rate limit, quota), fallback to offline
          final fallbackResponse = await _offlineProvider.generateResponse(
            prompt,
            isHindi,
          );
          return fallbackResponse +
              (isHindi ? '\\n(Offline Mode)' : '\\n(Offline Mode)');
        }
      } else {
        // No internet connection
        final response = await _offlineProvider.generateResponse(
          prompt,
          isHindi,
        );
        return response + (isHindi ? '\\n(Offline Mode)' : '\\n(Offline Mode)');
      }
    } catch (e) {
      debugPrint('Connectivity/Service failure: $e');
      return isHindi
          ? 'मुझे अभी कुछ तकनीकी समस्या है। कृपया बाद में प्रयास करें।'
          : 'I am experiencing some technical issues right now. Please try again later.';
    }
  }
}
