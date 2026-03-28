import 'package:flutter/material.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';

/// Used within scam dojo — shown in the dark scam dialog context
class OtpPinPadScreen extends StatefulWidget {
  const OtpPinPadScreen({super.key});

  @override
  State<OtpPinPadScreen> createState() => _OtpPinPadScreenState();
}

class _OtpPinPadScreenState extends State<OtpPinPadScreen> {
  String _pin = '';

  void _tap(String digit) {
    if (_pin.length < 4) {
      setState(() => _pin += digit);
      if (_pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  void _delete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A00),
      appBar: AppBar(
        title: Text(
          s.isHindi ? 'OTP दर्ज करें' : 'Enter OTP',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              s.isHindi
                  ? 'कभी भी OTP किसी के साथ Share मत करें — बैंक, पुलिस या कोई भी नहीं!'
                  : 'Never share OTP with anyone — not banks, police, or anyone!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.turmeric,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 32),
          // OTP dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  color: i < _pin.length
                      ? AppColors.errorRed.withAlpha(40)
                      : Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: i < _pin.length
                          ? AppColors.errorRed
                          : Colors.white24),
                ),
                child: Center(
                  child: Text(i < _pin.length ? '●' : '',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 24)),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Numpad
          Container(
            color: Colors.white10,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(
                  9,
                  (i) => TextButton(
                    onPressed: () => _tap('${i + 1}'),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            fontSize: 24, color: Colors.white)),
                  ),
                ),
                const SizedBox.shrink(),
                TextButton(
                  onPressed: () => _tap('0'),
                  child: const Text('0',
                      style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
                TextButton(
                  onPressed: _delete,
                  child:
                      const Icon(Icons.backspace, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
