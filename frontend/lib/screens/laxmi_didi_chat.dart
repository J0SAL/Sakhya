import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../services/tts_service.dart';
import '../services/laxmi_didi_service.dart';

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
      _messages = [
        _ChatMessage(AppStrings.of(context).laxmiDidiGreeting, false),
      ];
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
        localeId: context.read<LanguageController>().isHindi
            ? 'hi_IN'
            : 'en_IN',
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _messages.add(_ChatMessage(text, true)));
    _inputCtrl.clear();

    final isHindi = context.read<LanguageController>().isHindi;

    // Show a temporary typing thought from Didi
    setState(() => _messages.add(_ChatMessage(isHindi ? '...' : '...', false)));

    // Future delay to allow UI to scroll down to the "..." smoothly
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final finalResponse = await LaxmiDidiService.instance.getResponse(
      text,
      isHindi,
    );

    if (mounted) {
      // Remove typing indicator and add actual response
      setState(() {
        // remove the "..." message
        _messages.removeLast();
        _messages.add(_ChatMessage(finalResponse, false));
      });
      // Auto-speak Laxmi Didi response
      TtsService.instance.speak(finalResponse, langCode: isHindi ? 'hi' : 'en');
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
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
                  Text(
                    strings.laxmiDidiTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    strings.laxmiDidiSubtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              // TTS toggle
              GestureDetector(
                onTap: () => TtsService.instance.toggleMute(),
                child: ListenableBuilder(
                  listenable: TtsService.instance,
                  builder: (_, __) => Icon(
                    TtsService.instance.isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white70,
                    size: 22,
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
            children:
                [
                      strings.laxmiDidiChip1,
                      strings.laxmiDidiChip2,
                      strings.laxmiDidiChip3,
                      strings.laxmiDidiChip4,
                      strings.laxmiDidiChip5,
                    ]
                    .map(
                      (chip) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(
                            chip,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () => _sendMessage(chip),
                          backgroundColor: AppColors.cardSurface,
                        ),
                      ),
                    )
                    .toList(),
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
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
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
                    color: _isListening
                        ? AppColors.errorRed
                        : AppColors.warmGrey,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
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
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
