import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../widgets/notification_overlay.dart';

class UPIPracticeScreen extends StatefulWidget {
  const UPIPracticeScreen({super.key});

  @override
  State<UPIPracticeScreen> createState() => _UPIPracticeScreenState();
}

class _UPIPracticeScreenState extends State<UPIPracticeScreen> {
  String _pin = '';
  bool _isProcessing = false;
  bool _isSuccess = false;

  void _handlePinPress(String digit) {
    if (_isProcessing || _isSuccess || _pin.length >= 6) return;
    setState(() {
      _pin += digit;
    });
    if (_pin.length == 6) {
      _processPayment();
    }
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });

    context.read<GameController>().completeUpiPayment();
    NotificationOverlay.show(context, '🔊 Audio plays: "Ek sau rupaye prapt hue"', isSuccess: true);
    
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleDelete() {
    if (_isProcessing || _isSuccess || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('UPI Payment'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Viewfinder
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.black87,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                ),
                const Text('Scan QR', style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Paying: Local Wholesaler', style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('₹100', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          if (_isProcessing)
            const CircularProgressIndicator()
          else if (_isSuccess)
            const Icon(Icons.check_circle, color: Colors.green, size: 64)
          else ...[
            // Pin dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: index < _pin.length ? Colors.black : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
          
          const Spacer(),
          // Pin Pad
          Container(
            color: Colors.grey.shade100,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(9, (index) {
                  return TextButton(
                    onPressed: () => _handlePinPress('${index + 1}'),
                    child: Text('${index + 1}', style: const TextStyle(fontSize: 24, color: Colors.black)),
                  );
                }),
                const SizedBox.shrink(),
                TextButton(
                  onPressed: () => _handlePinPress('0'),
                  child: const Text('0', style: TextStyle(fontSize: 24, color: Colors.black)),
                ),
                TextButton(
                  onPressed: _handleDelete,
                  child: const Icon(Icons.backspace, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
