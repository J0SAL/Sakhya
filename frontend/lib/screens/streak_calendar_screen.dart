import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';

class StreakCalendarScreen extends StatelessWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final streak = controller.streakDays;
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: Text(strings.streakTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          children: [
            // Flame + count
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFE65100)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 64)),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 56)),
                      Text(strings.streakDaysLabel, style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Last 7 days
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.warmCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.last7Days, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final daysAgo = 6 - i;
                      final date = DateTime.now().subtract(Duration(days: daysAgo));
                      final dayName = strings.weekDaysShort[date.weekday % 7];
                      // Mark "completed" for demo — last `streak` days
                      final completed = daysAgo < streak;
                      final isToday = daysAgo == 0;
                      return Column(
                        children: [
                          Text(dayName, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
                          const SizedBox(height: 8),
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: completed ? AppColors.kumkum : AppColors.divider.withAlpha(80),
                              shape: BoxShape.circle,
                              border: isToday ? Border.all(color: AppColors.kumkum, width: 2) : null,
                            ),
                            child: Center(child: Text(completed ? '🔥' : '○', style: TextStyle(fontSize: completed ? 18 : 16, color: completed ? Colors.white : AppColors.textSecondary))),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Motivation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.leafGreen.withAlpha(15), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.leafGreen.withAlpha(40))),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: AppColors.leafGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      streak >= 7
                          ? strings.streakMsg7Plus
                          : streak >= 3
                              ? strings.streakMsg3Plus
                              : strings.streakMsg0Plus,
                      style: const TextStyle(color: AppColors.deepGreen, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Full calendar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.warmCard(),
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                onDateChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
