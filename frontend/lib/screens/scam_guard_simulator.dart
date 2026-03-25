import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../widgets/notification_overlay.dart';
import 'otp_pin_pad_screen.dart';

class ScamGuardSimulatorScreen extends StatelessWidget {
  const ScamGuardSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '⚠ Potentially fraudulent',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 60),
              // Fake Bank Logo
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'SBI',
                    style: TextStyle(color: Colors.blue, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'KYC MANAGER URGENT',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '+92 300 987 6543',
                style: TextStyle(color: Colors.white70, fontSize: 24),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(Icons.call_end, Colors.red, 'Decline', () {
                    if (ModalRoute.of(context)?.isCurrent != true) return;

                    context.read<GameController>().completeCurrentTask(50);
                    
                    NotificationOverlay.show(context, 'Good job! You avoided a scam.', isSuccess: true);
                    // Only pop if we pushed a route (e.g. from FAB). If inside BottomNav, it doesn't do much.
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }),
                  _buildCallButton(Icons.call, Colors.green, 'Answer', () async {
                    if (ModalRoute.of(context)?.isCurrent != true) return;

                    // Navigate to OTP Screen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OtpPinPadScreen()),
                    );
                    
                    if (context.mounted && Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton(IconData icon, Color color, String label, VoidCallback onPressed) {
    return Column(
      children: [
        FloatingActionButton.large(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}
