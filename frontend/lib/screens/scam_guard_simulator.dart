import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';

/// Shown as a dialog overlay during store/home phases
class ScamGuardDialog extends StatefulWidget {
  const ScamGuardDialog({super.key});

  @override
  State<ScamGuardDialog> createState() => _ScamGuardDialogState();
}

class _ScamGuardDialogState extends State<ScamGuardDialog> {
  bool _showHint = false;
  bool _resolved = false;

  void _reject(BuildContext context) {
    context.read<GameController>().resolveScam(rejected: true, usedHint: _showHint);
    setState(() => _resolved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  void _answer(BuildContext context) {
    // Show OTP pad inline
    context.read<GameController>().resolveScam(rejected: false);
    setState(() => _resolved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0A00),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.kumkum, width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: _resolved ? _buildResult() : _buildScamCall(context),
      ),
    );
  }

  Widget _buildScamCall(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Warning badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.kumkum, borderRadius: BorderRadius.circular(20)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('⚠ Dhoka Ho Sakta Hai!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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
        const Text('📞 Aapko call aa raha hai...', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
            child: const Text(
              '👩 Laxmi Didi: SBI ya koi bank kabhi phone par OTP nahi maangta. Yeh SCAM hai — CALL MAT UTHAO! ✋',
              style: TextStyle(color: AppColors.turmeric, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          )
        else
          TextButton(
            onPressed: () => setState(() => _showHint = true),
            child: const Text('👩 Laxmi Didi se poochein', style: TextStyle(color: AppColors.turmeric)),
          ),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _reject(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, minimumSize: const Size(0, 52)),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call_end, size: 20),
                    Text('Call Kaatein', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _answer(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, minimumSize: const Size(0, 52)),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call, size: 20),
                    Text('Call Uthayein', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResult() {
    final controller = context.read<GameController>();
    final correct = controller.todaySummary?.scamCorrect ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(correct ? '🎉' : '😱', style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text(
          correct ? 'Shabash! Scam se bachein!' : 'Oh no! OTP de diya!',
          style: TextStyle(
            color: correct ? AppColors.successGreen : AppColors.errorRed,
            fontWeight: FontWeight.w800, fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          correct
              ? '+2 sikke mile! Aap bahut samajhdaar hain! 💪'
              : 'Bank wale kabhi OTP nahi maangte. -1 sikka. Laxmi Didi se seekhein.',
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
