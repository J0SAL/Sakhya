import 'llm_provider.dart';

class OfflineLlmProvider implements LlmProvider {
  static const Map<String, Map<String, String>> _biResponses = {
    'bachat': {
      'hi':
          'बचत मतलब है आज की कमाई का कुछ हिस्सा कल के लिए रखना। हर रोज़ थोड़ी बचत बड़ी ताकत बनती है! 💰',
      'en':
          'Saving means putting aside some of today\'s earnings for tomorrow. Small daily savings become great strength! 💰',
    },
    'saving': {
      'hi':
          'बचत मतलब है आज की कमाई का कुछ हिस्सा कल के लिए रखना। हर रोज़ थोड़ी बचत बड़ी ताकत बनती है! 💰',
      'en':
          'Saving means putting aside some of today\'s earnings for tomorrow. Small daily savings become great strength! 💰',
    },
    'upi': {
      'hi':
          'UPI से पैसे भेजने के बाद SMS ज़रूर देखो। अपना PIN किसी को मत बताओ — bank वाले भी नहीं! 📱',
      'en':
          'After sending money via UPI, always check your SMS. Never share your PIN with anyone — not even bank employees! 📱',
    },
    'scam': {
      'hi':
          'कोई भी phone पर OTP या PIN माँगे तो KABHI मत दो! यह scam है। Call रख दो और police को बताओ। ⚠️',
      'en':
          'If anyone asks for OTP or PIN on the phone, NEVER give it! That\'s a scam. Hang up and report to police. ⚠️',
    },
    'dhoka': {
      'hi': 'कोई भी phone पर OTP या PIN माँगे तो KABHI मत दो! यह scam है। ⚠️',
      'en':
          'If anyone asks for OTP or PIN on the phone, NEVER give it! That\'s a scam. ⚠️',
    },
    'otp': {
      'hi':
          'OTP सिर्फ आपके लिए होता है — bank, courier, या कोई भी phone पर OTP KABHI नहीं माँगता! 🔒',
      'en':
          'OTP is only for you — banks, courier services, or anyone else will NEVER ask for your OTP on the phone! 🔒',
    },
    'pin': {
      'hi':
          'अपना UPI PIN किसी को मत बताओ — चाहे कोई bank officer क्यों न हो। यह आपकी चाबी है! 🗝️',
      'en':
          'Never share your UPI PIN with anyone — even if they claim to be a bank officer. It\'s your private key! 🗝️',
    },
    'loan': {
      'hi':
          'Loan लेने से पहले interest rate ज़रूर पूछें। Bank या SHG से loan लेना ज़्यादा safe है। Online apps से बचें! 🏦',
      'en':
          'Before taking a loan, always ask about the interest rate. Loans from banks or SHGs are safer. Avoid online apps! 🏦',
    },
    'budget': {
      'hi':
          'Budget का मतलब है पहले से decide करना कि पैसे कहाँ लगाने हैं। घर 60%, धंधा 40% — एक अच्छा rule है! 📊',
      'en':
          'Budget means deciding in advance where to spend money. Home 60%, Business 40% — a good rule! 📊',
    },
    'goal': {
      'hi':
          'Monthly goal set करो! रोज़ थोड़ा-थोड़ा बचत करो। बड़े सपने छोटे कदम से पूरे होते हैं! 🎯',
      'en':
          'Set a monthly goal! Save a little every day. Big dreams come true with small steps! 🎯',
    },
    'bank': {
      'hi':
          'Bank में पैसे रखना safe है। ब्याज भी मिलता है। Jan Dhan account बिल्कुल free है! 🏛️',
      'en':
          'Keeping money in a bank is safe. You also earn interest. Jan Dhan account is completely free! 🏛️',
    },
    'ghar': {
      'hi':
          'घर pot में खाना, बच्चे की school, और बिजली का खर्चा होता है। कमाई की 60% यहाँ रखें! 🏠',
      'en':
          'The home pot covers food, children\'s school, and electricity. Keep 60% of earnings here! 🏠',
    },
    'dhanda': {
      'hi':
          'धंधा pot से कपड़ा, धागा, और काम की चीजें खरीदनी चाहिए। कमाई की 40% यहाँ रखें! 🧵',
      'en':
          'The business pot should be used for cloth, thread, and work supplies. Keep 40% of earnings here! 🧵',
    },
    'kharcha': {
      'hi':
          'खर्चा बचाने के लिए पहले से list बनाओ। ज़रूरी और extra खर्चा अलग-अलग करो! 💡',
      'en':
          'To manage expenses, make a list beforehand. Separate essential and extra spending! 💡',
    },
    'paisa': {
      'hi':
          'पैसा मेहनत का होता है — इसको समझदारी से संभालो। थोड़ा बचत, थोड़ा धंधा, थोड़ा घर! 💰',
      'en':
          'Money is earned through hard work — handle it wisely. A little saving, a little business, a little home! 💰',
    },
    'help': {
      'hi':
          'मैं आपकी मदद के लिए हूँ! बचत, UPI safety, scam, या budget के बारे में पूछें! 🌸',
      'en':
          'I\'m here to help you! Ask about savings, UPI safety, scams, or budgeting! 🌸',
    },
    'namaste': {
      'hi': 'नमस्ते! कैसी हैं आप? पूछें कोई भी सवाल — मैं यहाँ हूँ! 🙏',
      'en': 'Namaste! How are you? Ask me anything — I\'m here! 🙏',
    },
    'hi': {
      'hi': 'नमस्ते! कैसी हैं आप? पूछें कोई भी सवाल — मैं यहाँ हूँ! 🙏',
      'en': 'Hello! How are you? Ask me anything — I\'m here! 🙏',
    },
    'hello': {
      'hi': 'नमस्ते! कैसी हैं आप? पूछें कोई भी सवाल — मैं यहाँ हूँ! 🙏',
      'en': 'Hello! How are you? Ask me anything — I\'m here! 🙏',
    },
  };

  @override
  Future<String> generateResponse(String prompt, bool isHindi) async {
    final lower = prompt.toLowerCase();

    String response = isHindi
        ? 'मैं अभी offline हूँ। मुझे समझ नहीं आया। क्या आप फिर से पूछ सकती हैं? जैसे: "बचत क्या है", "scam से कैसे बचें", "UPI safe है क्या?" 🙏'
        : 'I didn\'t understand. Can you ask again? For example: "what is saving", "how to avoid scams", "is UPI safe?" 🙏';

    for (final key in _biResponses.keys) {
      if (lower.contains(key)) {
        response = _biResponses[key]![isHindi ? 'hi' : 'en']!;
        break;
      }
    }

    return response;
  }
}
