import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../services/tts_service.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import 'otp_pin_pad_screen.dart';

/// Shown as a dialog overlay during store/home phases
class ScamGuardDialog extends StatefulWidget {
  const ScamGuardDialog({super.key});

  @override
  State<ScamGuardDialog> createState() => _ScamGuardDialogState();
}

class _ScamGuardDialogState extends State<ScamGuardDialog> {
  bool _showHint = false;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = AppStrings.of(context);
      TtsService.instance.speakL(
        isHindi: s.isHindi,
        hindi: 'सावधान! आपको कॉल आ रहा है। KYC Manager के नाम से। यह Scam हो सकता है!',
        english: 'Warning! You are getting a call from KYC Manager. This could be a scam!',
      );
    });
  }

  void _reject(BuildContext context) {
    final s = AppStrings.of(context);
    TtsService.instance.speakL(
      isHindi: s.isHindi,
      hindi: 'शाबाश! कॉल रिजेक्ट किया! स्कैम से बच गई!',
      english: 'Well done! You rejected the call! You avoided the scam!',
    );
    context.read<GameController>().resolveScam(rejected: true, usedHint: _showHint);
    setState(() => _resolved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  void _answer(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const OtpPinPadScreen()));
    if (!context.mounted) return;
    context.read<GameController>().resolveScam(rejected: false);
    setState(() => _resolved = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final correct = context.read<GameController>().todaySummary?.scamCorrect ?? false;
    Color borderColor = AppColors.kumkum;
    if (_resolved) {
      borderColor = correct ? AppColors.successGreen : AppColors.errorRed;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0A00),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: _resolved ? _buildResult(context) : _buildScamCall(context),
      ),
    );
  }

  Widget _buildScamCall(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Warning badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.kumkum, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                s.isHindi ? '⚠ धोखा हो सकता है!' : '⚠ Possible Scam!',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Fake bank logo
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text('SBI', style: TextStyle(color: Color(0xFF003087), fontWeight: FontWeight.w900, fontSize: 24))),
        ),
        const SizedBox(height: 12),
        const Text('KYC MANAGER URGENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 4),
        const Text('+92 300 987 6543', style: TextStyle(color: Colors.white54, fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          s.isHindi ? '📞 आपको कॉल आ रहा है...' : '📞 Incoming call...',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Laxmi Didi hint
        if (_showHint)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.turmeric.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.turmeric.withAlpha(80)),
            ),
            child: Text(
              s.isHindi
                  ? '👩 लक्ष्मी दीदी: SBI या कोई भी बैंक कभी फोन पर OTP नहीं माँगता। यह SCAM है — कॉल मत उठाओ! ✋'
                  : '👩 Laxmi Didi: SBI or any bank NEVER asks for OTP on the phone. This is a SCAM — Don\'t answer the call! ✋',
              style: const TextStyle(color: AppColors.turmeric, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          )
        else
          TextButton(
            onPressed: () {
              setState(() => _showHint = true);
              TtsService.instance.speakL(
                isHindi: s.isHindi,
                hindi: 'लक्ष्मी दीदी कहती हैं: SBI या कोई भी बैंक कभी फोन पर OTP नहीं माँगता। यह SCAM है। कॉल मत उठाओ!',
                english: 'Laxmi Didi says: SBI or any bank never asks for OTP on the phone. This is a scam. Do not answer the call!',
              );
            },
            child: Text(
              s.isHindi ? '👩 लक्ष्मी दीदी से पूछें' : '👩 Ask Laxmi Didi',
              style: const TextStyle(color: AppColors.turmeric),
            ),
          ),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _reject(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, minimumSize: const Size(0, 52)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.call_end, size: 20),
                    Text(s.isHindi ? 'कॉल काटें' : 'Reject Call', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _answer(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, minimumSize: const Size(0, 52)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.call, size: 20),
                    Text(s.isHindi ? 'कॉल उठाएं' : 'Answer Call', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final controller = context.read<GameController>();
    final correct = controller.todaySummary?.scamCorrect ?? false;
    final s = AppStrings.of(context);

    // Speak result
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TtsService.instance.speakL(
        isHindi: s.isHindi,
        hindi: correct
            ? 'शाबाश! आपने स्कैम पहचाना! +2 सिक्के मिले!'
            : 'ओह नहीं! OTP दे दिया! बैंक वाले कभी OTP नहीं माँगते। -1 सिक्का।',
        english: correct
            ? 'Well done! You identified the scam! +2 coins earned!'
            : 'Oh no! You gave the OTP! Banks never ask for OTP. -1 coin.',
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(correct ? '🎉' : '😱', style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text(
          correct
              ? (s.isHindi ? 'शाबाश! स्कैम से बचीं!' : 'Well done! You avoided the scam!')
              : (s.isHindi ? 'ओह नहीं! OTP दे दिया!' : 'Oh no! You gave the OTP!'),
          style: TextStyle(
            color: correct ? AppColors.successGreen : AppColors.errorRed,
            fontWeight: FontWeight.w800, fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          correct
              ? (s.isHindi ? '+2 सिक्के मिले! आप बहुत समझदार हैं! 💪' : '+2 coins earned! You are very smart! 💪')
              : (s.isHindi ? 'बैंक वाले कभी OTP नहीं माँगते। -1 सिक्का।' : 'Banks never ask for OTP. -1 coin. Learn from Laxmi Didi.'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Keep the old full-screen version for backward compat / direct navigation
class ScamGuardSimulatorScreen extends StatelessWidget {
  const ScamGuardSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A00),
      body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(24), child: const ScamGuardDialog()))),
    );
  }
}
