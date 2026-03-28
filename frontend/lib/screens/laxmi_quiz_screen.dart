import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../services/tts_service.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';

class LaxmiQuizScreen extends StatelessWidget {
  const LaxmiQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final question = s.isHindi
        ? 'क्या बैंक अधिकारी कभी फोन पर OTP माँगते हैं?'
        : 'Do bank officials ever ask for OTP on the phone?';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      TtsService.instance.speakL(
        isHindi: s.isHindi,
        hindi: 'क्या बैंक अधिकारी कभी फोन पर OTP माँगते हैं?',
        english: 'Do bank officials ever ask for OTP on the phone?',
      );
    });

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(
        title: Text(s.isHindi ? 'लक्ष्मी दीदी प्रश्न' : 'Laxmi Didi Quiz'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(color: AppColors.leafGreen, shape: BoxShape.circle),
                child: const Center(child: Text('👩', style: TextStyle(fontSize: 56))),
              ),
              const SizedBox(height: 32),
              Text(
                s.isHindi ? 'सवाल:' : 'Question:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                question,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
                    onPressed: () {
                      context.read<GameController>().completeLesson(0, correct: false, usedHint: false);
                      TtsService.instance.speakL(
                        isHindi: s.isHindi,
                        hindi: 'गलत! बैंक कभी OTP नहीं माँगता। -1 सिक्का।',
                        english: 'Wrong! Banks never ask for OTP. -1 coin.',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(s.isHindi
                            ? 'गलत! बैंक कभी OTP नहीं माँगता।'
                            : 'Wrong! Banks never ask for OTP.'),
                        backgroundColor: AppColors.errorRed,
                      ));
                    },
                    child: Text(
                      s.isHindi ? 'हाँ (Yes)' : 'Yes',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
                    onPressed: () {
                      context.read<GameController>().completeLesson(0, correct: true, usedHint: false);
                      TtsService.instance.speakL(
                        isHindi: s.isHindi,
                        hindi: 'शाबाश! सही जवाब! +1 सिक्का मिला!',
                        english: 'Well done! Correct answer! +1 coin earned!',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(s.isHindi ? 'सही जवाब! +1 सिक्का!' : 'Correct! +1 coin!'),
                        backgroundColor: AppColors.successGreen,
                      ));
                    },
                    child: Text(
                      s.isHindi ? 'नहीं (No)' : 'No',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
