import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../services/tts_service.dart';

class LaxmiDidiChatScreen extends StatefulWidget {
  const LaxmiDidiChatScreen({super.key});

  @override
  State<LaxmiDidiChatScreen> createState() => _LaxmiDidiChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage(this.text, this.isUser);
}

class _LaxmiDidiChatScreenState extends State<LaxmiDidiChatScreen> {
  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  List<_ChatMessage> _messages = [];

  // Bilingual response map: key -> {hi, en}
  static const Map<String, Map<String, String>> _biResponses = {
    'bachat': {
      'hi': 'बचत मतलब है आज की कमाई का कुछ हिस्सा कल के लिए रखना। हर रोज़ थोड़ी बचत बड़ी ताकत बनती है! 💰',
      'en': 'Saving means putting aside some of today\'s earnings for tomorrow. Small daily savings become great strength! 💰',
    },
    'saving': {
      'hi': 'बचत मतलब है आज की कमाई का कुछ हिस्सा कल के लिए रखना। हर रोज़ थोड़ी बचत बड़ी ताकत बनती है! 💰',
      'en': 'Saving means putting aside some of today\'s earnings for tomorrow. Small daily savings become great strength! 💰',
    },
    'upi': {
      'hi': 'UPI से पैसे भेजने के बाद SMS ज़रूर देखो। अपना PIN किसी को मत बताओ — bank वाले भी नहीं! 📱',
      'en': 'After sending money via UPI, always check your SMS. Never share your PIN with anyone — not even bank employees! 📱',
    },
    'scam': {
      'hi': 'कोई भी phone पर OTP या PIN माँगे तो KABHI मत दो! यह scam है। Call रख दो और police को बताओ। ⚠️',
      'en': 'If anyone asks for OTP or PIN on the phone, NEVER give it! That\'s a scam. Hang up and report to police. ⚠️',
    },
    'dhoka': {
      'hi': 'कोई भी phone पर OTP या PIN माँगे तो KABHI मत दो! यह scam है। ⚠️',
      'en': 'If anyone asks for OTP or PIN on the phone, NEVER give it! That\'s a scam. ⚠️',
    },
    'otp': {
      'hi': 'OTP सिर्फ आपके लिए होता है — bank, courier, या कोई भी phone पर OTP KABHI नहीं माँगता! 🔒',
      'en': 'OTP is only for you — banks, courier services, or anyone else will NEVER ask for your OTP on the phone! 🔒',
    },
    'pin': {
      'hi': 'अपना UPI PIN किसी को मत बताओ — चाहे कोई bank officer क्यों न हो। यह आपकी चाबी है! 🗝️',
      'en': 'Never share your UPI PIN with anyone — even if they claim to be a bank officer. It\'s your private key! 🗝️',
    },
    'loan': {
      'hi': 'Loan लेने से पहले interest rate ज़रूर पूछें। Bank या SHG से loan लेना ज़्यादा safe है। Online apps से बचें! 🏦',
      'en': 'Before taking a loan, always ask about the interest rate. Loans from banks or SHGs are safer. Avoid online apps! 🏦',
    },
    'budget': {
      'hi': 'Budget का मतलब है पहले से decide करना कि पैसे कहाँ लगाने हैं। घर 60%, धंधा 40% — एक अच्छा rule है! 📊',
      'en': 'Budget means deciding in advance where to spend money. Home 60%, Business 40% — a good rule! 📊',
    },
    'goal': {
      'hi': 'Monthly goal set करो! रोज़ थोड़ा-थोड़ा बचत करो। बड़े सपने छोटे कदम से पूरे होते हैं! 🎯',
      'en': 'Set a monthly goal! Save a little every day. Big dreams come true with small steps! 🎯',
    },
    'bank': {
      'hi': 'Bank में पैसे रखना safe है। ब्याज भी मिलता है। Jan Dhan account बिल्कुल free है! 🏛️',
      'en': 'Keeping money in a bank is safe. You also earn interest. Jan Dhan account is completely free! 🏛️',
    },
    'ghar': {
      'hi': 'घर pot में खाना, बच्चे की school, और बिजली का खर्चा होता है। कमाई की 60% यहाँ रखें! 🏠',
      'en': 'The home pot covers food, children\'s school, and electricity. Keep 60% of earnings here! 🏠',
    },
    'dhanda': {
      'hi': 'धंधा pot से कपड़ा, धागा, और काम की चीजें खरीदनी चाहिए। कमाई की 40% यहाँ रखें! 🧵',
      'en': 'The business pot should be used for cloth, thread, and work supplies. Keep 40% of earnings here! 🧵',
    },
    'kharcha': {
      'hi': 'खर्चा बचाने के लिए पहले से list बनाओ। ज़रूरी और extra खर्चा अलग-अलग करो! 💡',
      'en': 'To manage expenses, make a list beforehand. Separate essential and extra spending! 💡',
    },
    'paisa': {
      'hi': 'पैसा मेहनत का होता है — इसको समझदारी से संभालो। थोड़ा बचत, थोड़ा धंधा, थोड़ा घर! 💰',
      'en': 'Money is earned through hard work — handle it wisely. A little saving, a little business, a little home! 💰',
    },
    'help': {
      'hi': 'मैं आपकी मदद के लिए हूँ! बचत, UPI safety, scam, या budget के बारे में पूछें! 🌸',
      'en': 'I\'m here to help you! Ask about savings, UPI safety, scams, or budgeting! 🌸',
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
  void initState() {
    super.initState();
    _initSpeech();
    // Greeting will be set in didChangeDependencies once we have context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      _messages = [_ChatMessage(AppStrings.of(context).laxmiDidiGreeting, false)];
    }
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) => debugPrint('STT error: $e'),
    );
    if (mounted) setState(() {});
  }

  void _toggleListening() async {
    if (!_speechAvailable) return;
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() => _inputCtrl.text = result.recognizedWords);
          if (result.finalResult) {
            setState(() => _isListening = false);
            _sendMessage(_inputCtrl.text);
          }
        },
        localeId: context.read<LanguageController>().isHindi ? 'hi_IN' : 'en_IN',
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _messages.add(_ChatMessage(text, true)));
    _inputCtrl.clear();

    final lower = text.toLowerCase();
    final isHindi = context.read<LanguageController>().isHindi;
    String response = isHindi
        ? 'मुझे समझ नहीं आया। क्या आप फिर से पूछ सकती हैं? जैसे: "बचत क्या है", "scam से कैसे बचें", "UPI safe है क्या?" 🙏'
        : 'I didn\'t understand. Can you ask again? For example: "what is saving", "how to avoid scams", "is UPI safe?" 🙏';

    for (final key in _biResponses.keys) {
      if (lower.contains(key)) {
        response = _biResponses[key]![isHindi ? 'hi' : 'en']!;
        break;
      }
    }

    final finalResponse = response;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _messages.add(_ChatMessage(finalResponse, false)));
        // Auto-speak Laxmi Didi response
        TtsService.instance.speak(finalResponse);
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    // Rebuild when language changes
    context.watch<LanguageController>();

    return Column(
      children: [
        // Laxmi Didi header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.leafGreen,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: Text('👩', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.laxmiDidiTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  Text(strings.laxmiDidiSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              const Spacer(),
              // TTS toggle
              GestureDetector(
                onTap: () => TtsService.instance.toggleMute(),
                child: ListenableBuilder(
                  listenable: TtsService.instance,
                  builder: (_, __) => Icon(
                    TtsService.instance.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white70, size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Suggestion chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: AppColors.lightCream,
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              strings.laxmiDidiChip1, strings.laxmiDidiChip2, strings.laxmiDidiChip3,
              strings.laxmiDidiChip4, strings.laxmiDidiChip5,
            ].map((chip) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(chip, style: const TextStyle(fontSize: 12)),
                onPressed: () => _sendMessage(chip),
                backgroundColor: AppColors.cardSurface,
              ),
            )).toList(),
          ),
        ),

        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, i) => _buildBubble(_messages[i]),
          ),
        ),

        // Input row
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: Row(
            children: [
              // Mic button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  onPressed: _speechAvailable ? _toggleListening : null,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: _isListening ? AppColors.errorRed : AppColors.warmGrey,
                    size: 28,
                  ),
                  tooltip: strings.laxmiDidiMicHint,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: strings.laxmiDidiHint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _sendMessage(_inputCtrl.text),
                icon: const Icon(Icons.send_rounded),
                color: AppColors.leafGreen,
                iconSize: 28,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => TtsService.instance.speak(msg.text),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: msg.isUser ? AppColors.leafGreen : AppColors.cardSurface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
              bottomRight: Radius.circular(msg.isUser ? 4 : 16),
            ),
            boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 6)],
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              color: msg.isUser ? Colors.white : AppColors.textPrimary,
              fontSize: 15, height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}


