import 'package:google_generative_ai/google_generative_ai.dart';
import 'llm_provider.dart';

class GeminiLlmProvider implements LlmProvider {
  final String _apiKey;
  GenerativeModel? _model;

  GeminiLlmProvider({required String apiKey}) : _apiKey = apiKey {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system('You are Laxmi Didi, a helpful, polite, and empathetic financial literacy guide for rural Indian women. Keep your answers short (2-3 sentences max) and easy to understand. Always respond in the language the user asks in (Hindi or English). Do not use advanced financial jargon.'),
      );
    }
  }

  @override
  Future<String> generateResponse(String prompt, bool isHindi) async {
    if (_model == null) {
      throw Exception('Gemini API Key is not configured correctly.');
    }
    
    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text?.trim() ?? (isHindi ? 'क्षमा करें, मैं अभी जवाब नहीं दे सकती।' : 'Sorry, I cannot respond right now.');
    } catch (e) {
      // Throw so that LaxmiDidiService can format it and fallback appropriately
      rethrow;
    }
  }
}
