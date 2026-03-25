import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/game_controller.dart';
import 'screens/home_dashboard.dart';
import 'screens/laxmi_didi_chat.dart';
import 'screens/laxmi_quiz_screen.dart';
import 'screens/samriddhi_store.dart';
import 'screens/scam_guard_simulator.dart';
import 'screens/streak_calendar_screen.dart';
import 'screens/upi_practice_screen.dart';
import 'screens/user_profile_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController(),
      child: const SakhyaApp(),
    ),
  );
}

class SakhyaApp extends StatelessWidget {
  const SakhyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakhya',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      home: const DailyLoopRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DailyLoopRouter extends StatelessWidget {
  const DailyLoopRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameController>().currentState;
    
    Widget bodyContent;
    switch (state) {
      case GameState.startDay:
         bodyContent = const HomeDashboardScreen(key: ValueKey('home'));
         break;
      case GameState.playingTask:
         final task = context.watch<GameController>().currentTask;
         if (task == EventTask.scamCall) {
            bodyContent = const ScamGuardSimulatorScreen(key: ValueKey('scam'));
         } else if (task == EventTask.buySupplies) {
            bodyContent = const UPIPracticeScreen(key: ValueKey('upi'));
         } else {
            bodyContent = const LaxmiQuizScreen(key: ValueKey('quiz'));
         }
         break;
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: bodyContent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                child: LaxmiDidiChatScreen(),
              ),
            ),
          );
        },
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.support_agent, color: Colors.white, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen())),
            child: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.person, color: Colors.white)),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StreakCalendarScreen())),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                const SizedBox(width: 4),
                Text('${context.watch<GameController>().streakDays}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 24)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: const ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    child: SamriddhiStoreScreen(),
                  ),
                ),
              );
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    Text('${context.watch<GameController>().rewardPoints}', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }
}
