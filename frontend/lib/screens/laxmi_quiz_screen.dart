import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';

class LaxmiQuizScreen extends StatelessWidget {
  const LaxmiQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(
        title: const Text('Laxmi Didi Quiz'),
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
              Text('Sawal (Question):', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                'Kya bank officials kabhi aapse phone par OTP ki maang karte hain?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
                    onPressed: () {
                      context.read<GameController>().completeLesson(0, correct: false, usedHint: false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Galat! Bank kabhi OTP nahi mangta.'), backgroundColor: AppColors.errorRed));
                    },
                    child: const Text('Haan (Yes)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
                    onPressed: () {
                      context.read<GameController>().completeLesson(0, correct: true, usedHint: false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sahi jawab! +1 sikka!'), backgroundColor: AppColors.successGreen));
                    },
                    child: const Text('Nahi (No)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
