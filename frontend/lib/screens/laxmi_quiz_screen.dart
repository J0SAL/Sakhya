import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../widgets/notification_overlay.dart';

class LaxmiQuizScreen extends StatelessWidget {
  const LaxmiQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Laxmi Didi Quiz'),
        backgroundColor: Colors.blue.shade100,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Icon(Icons.support_agent, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text(
                'Sawal (Question):',
                style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kya bank officials kabhi aapse phone par OTP ki maang karte hain?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    onPressed: () {
                       context.read<GameController>().completeCurrentTask(0);
                       NotificationOverlay.show(context, 'Galat! Bank kabhi OTP nahi mangta. (Incorrect)', isError: true);
                    },
                    child: const Text('Haan (Yes)'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    onPressed: () {
                       context.read<GameController>().completeCurrentTask(30);
                       NotificationOverlay.show(context, 'Sahi jawab! (Correct!)', isSuccess: true);
                    },
                    child: const Text('Nahi (No)'),
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
