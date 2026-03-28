import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UPIPracticeScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  final int amount;
  final String recipient;
  
  const UPIPracticeScreen({
    super.key, 
    this.onSuccess, 
    this.amount = 0, 
    this.recipient = 'Local Wholesaler'
  });

  @override
  State<UPIPracticeScreen> createState() => _UPIPracticeScreenState();
}

class _UPIPracticeScreenState extends State<UPIPracticeScreen> {
  String _pin = '';
  bool _isProcessing = false;
  bool _isSuccess = false;

  void _handlePinPress(String digit) {
    if (_isProcessing || _isSuccess || _pin.length >= 6) return;
    setState(() => _pin += digit);
    if (_pin.length == 6) _processPayment();
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    setState(() { 
      _isProcessing = false; 
      _isSuccess = true; 
    });

    if (widget.onSuccess != null) {
      widget.onSuccess!();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔊 "Payment Saphal (Success)! sikka mil gaya"'), backgroundColor: AppColors.successGreen),
    );

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) Navigator.pop(context);
  }

  void _handleDelete() {
    if (_isProcessing || _isSuccess || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('UPI Payment'),
        backgroundColor: AppColors.leafGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            color: Colors.black87,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent, width: 2))),
                const Text('Scan QR', style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Payment To: ${widget.recipient}', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('₹${widget.amount}', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          if (_isProcessing) const CircularProgressIndicator(color: AppColors.leafGreen)
          else if (_isSuccess) const Icon(Icons.check_circle, color: AppColors.successGreen, size: 64)
          else Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 18, height: 18,
              decoration: BoxDecoration(
                color: i < _pin.length ? AppColors.textPrimary : AppColors.divider,
                shape: BoxShape.circle,
              ),
            )),
          ),
          const Spacer(),
          Container(
            color: AppColors.lightCream,
            child: GridView.count(
              shrinkWrap: true, crossAxisCount: 3, childAspectRatio: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(9, (i) => TextButton(
                  onPressed: () => _handlePinPress('${i + 1}'),
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 24, color: AppColors.textPrimary)),
                )),
                const SizedBox.shrink(),
                TextButton(onPressed: () => _handlePinPress('0'), child: const Text('0', style: TextStyle(fontSize: 24, color: AppColors.textPrimary))),
                TextButton(onPressed: _handleDelete, child: const Icon(Icons.backspace, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
