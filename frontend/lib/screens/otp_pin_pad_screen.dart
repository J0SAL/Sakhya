import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../widgets/notification_overlay.dart';

class OtpPinPadScreen extends StatelessWidget {
  const OtpPinPadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Enter OTP'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Please enter the 4-digit code sent to your phone to complete KYC.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _OtpBox(),
                _OtpBox(),
                _OtpBox(),
                _OtpBox(),
              ],
            ),
            const Spacer(),
            // Mock keyboard
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 2,
                children: List.generate(9, (index) {
                  return TextButton(
                    onPressed: () => _handlePinEntry(context),
                    child: Text('${index + 1}', style: const TextStyle(fontSize: 24, color: Colors.black)),
                  );
                })..addAll([
                  const SizedBox.shrink(),
                  TextButton(
                    onPressed: () => _handlePinEntry(context),
                    child: const Text('0', style: TextStyle(fontSize: 24, color: Colors.black)),
                  ),
                  const SizedBox.shrink(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePinEntry(BuildContext context) {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    // Immediate consequences
    context.read<GameController>().completeScamEncounter(false);
    NotificationOverlay.show(context, 'Never share your OTP! Points lost.', isError: true);
    Navigator.of(context).pop();
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Text('X', style: TextStyle(fontSize: 24, color: Colors.black54)),
    );
  }
}
