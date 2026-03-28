import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
  final List<_ChatMessage> _messages = [
    _ChatMessage('Namaste! Main Laxmi Didi hoon. Aap mujhse koi bhi sawal pooch sakti hain — bachat, UPI, ya scam ke baare mein! 🙏', false),
  ];

  static const Map<String, String> _responses = {
    'bachat': 'Bachat matlab hai aaj ki kamai ka kuch hissa kal ke liye rakhna. Har roz thodi bachat badi taakat banti hai! 💰',
    'saving': 'Bachat matlab hai aaj ki kamai ka kuch hissa kal ke liye rakhna. Har roz thodi bachat badi taakat banti hai! 💰',
    'upi': 'UPI se paise bhejne ke baad SMS zaroor dekho. Apna PIN kisi ko mat batao — bank wale bhi nahi! 📱',
    'scam': 'Koi bhi phone par OTP ya PIN maange toh KABHI mat do! Yeh scam hai. Call rakh do aur police ko batao. ⚠️',
    'dhoka': 'Koi bhi phone par OTP ya PIN maange toh KABHI mat do! Yeh scam hai. Call rakh do aur police ko batao. ⚠️',
    'otp': 'OTP sirf aapke liye hota hai — bank, courier, ya koi bhi phone par OTP KABHI nahi maangta! 🔒',
    'pin': 'Apna UPI PIN kisi ko mat batao — chahe koi bank officer kyon na ho. Yeh aapki chabi hai! 🗝️',
    'loan': 'Loan lene se pehle interest rate zaroor poochein. Bank ya SHG se loan lena zyada safe hai. Online apps se bacheein! 🏦',
    'budget': 'Budget ka matlab hai pehle se decide karna ki paise kahan lagane hain. Ghar 60%, Dhanda 40% — ek achha rule hai! 📊',
    'goal': 'Monthly goal set karo! Roz thoda-thoda bachat karo. Bade sapne chote kadam se poore hote hain! 🎯',
    'bank': 'Bank mein paise rakhna safe hai. Byaaj bhi milta hai. Jan Dhan account bilkul free hai! 🏛️',
    'ghar': 'Ghar pot mein khana, bacche ki school, aur bijli ka kharcha hota hai. Kaami ki 60% yahan rakhein! 🏠',
    'dhanda': 'Dhanda pot se kapda, dhaga, aur kaam ki cheezein kharidni chahiye. Kaami ki 40% yahan rakhein! 🧵',
    'kharcha': 'Kharcha bachane ke liye pehle se list banao. Zaroori aur extra kharcha alag-alag karo! 💡',
    'paisa': 'Paisa mehnat ka hota hai — isko samajhdari se sambhalo. Thoda bachat, thoda dhanda, thoda ghar! 💰',
    'help': 'Main aapki madad ke liye hoon! Bachat, UPI safety, scam, ya budget ke baare mein poochein! 🌸',
    'namaste': 'Namaste! Kaisi hain aap? Poochein koi bhi sawal — main yahan hoon! 🙏',
    'hi': 'Namaste! Kaisi hain aap? Poochein koi bhi sawal — main yahan hoon! 🙏',
  };

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, true));
    });
    _inputCtrl.clear();

    // Find matching response
    final lower = text.toLowerCase();
    String response = 'Mujhe samajh nahi aaya. Kya aap phir se poochh sakti hain? Jaise: "bachat kya hai", "scam se kaise bachein", "UPI safe hai kya?" 🙏';
    for (final key in _responses.keys) {
      if (lower.contains(key)) {
        response = _responses[key]!;
        break;
      }
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _messages.add(_ChatMessage(response, false)));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Laxmi Didi header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.leafGreen,
          child: const Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: Text('👩', style: TextStyle(fontSize: 24)),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Laxmi Didi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  Text('Aapki Arthik Saheli 🌿', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
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
              'Bachat kya hai?', 'Scam se kaise bachein?', 'UPI safe hai?', 'Budget kaise banayein?', 'Loan lena theek hai?',
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
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Sawal poochein...', contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
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
    );
  }
}
