import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/game_controller.dart';
import 'screens/home_dashboard.dart';
import 'screens/laxmi_didi_chat.dart';
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
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    LaxmiDidiChatScreen(),
    ScamGuardSimulatorScreen(),
    UPIPracticeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SamriddhiStoreScreen())),
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
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Laxmi Didi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Scam Guard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'UPI Practice',
          ),
        ],
      ),
    );
  }
}
