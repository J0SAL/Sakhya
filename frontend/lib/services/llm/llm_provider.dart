abstract class LlmProvider {
  Future<String> generateResponse(String prompt, bool isHindi);
}
