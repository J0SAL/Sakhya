import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';

class StreakCalendarScreen extends StatelessWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<GameController>().streakDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Calendar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 64),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streak',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    const Text(
                      'Day Streak!',
                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onDateChanged: (DateTime value) { 
                    // Visual only - picking dates does nothing
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Complete an activity tomorrow to keep your streak alive and earn bonus reward points!',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
