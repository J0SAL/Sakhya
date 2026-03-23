import 'package:flutter/material.dart';

import 'screens/home_dashboard.dart';
import 'screens/laxmi_didi_chat.dart';
import 'screens/samriddhi_store.dart';
import 'screens/scam_guard_simulator.dart';

void main() {
  runApp(const SakhyaApp());
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
        // Optional global styles to enhance "large tap target" intuitive look
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
    SamriddhiStoreScreen(),
    ScamGuardSimulatorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Scam Guard',
          ),
        ],
      ),
    );
  }
}
