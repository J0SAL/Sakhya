import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/game_controller.dart';
import 'theme/app_theme.dart';
import 'screens/user_select_screen.dart';
import 'screens/new_user_flow_screen.dart';
import 'screens/main_shell.dart';
import 'screens/allocation_screen.dart';
import 'screens/store1_screen.dart';
import 'screens/end_of_day_screen.dart';

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
      theme: AppTheme.theme(),
      home: const AppRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Root router — watches GamePhase and renders the correct screen.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final phase = context.watch<GameController>().currentPhase;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _routeForPhase(phase),
    );
  }

  Widget _routeForPhase(GamePhase phase) {
    switch (phase) {
      case GamePhase.userSelect:
        return const UserSelectScreen(key: ValueKey('userSelect'));
      case GamePhase.newUserFlow:
        return const NewUserFlowScreen(key: ValueKey('newUser'));
      case GamePhase.startDay:
        return const MainShell(key: ValueKey('shell_home'));
      case GamePhase.allocation:
        return const AllocationScreen(key: ValueKey('allocation'));
      case GamePhase.store1:
        return const Store1Screen(key: ValueKey('store1'));
      case GamePhase.endOfDay:
        return const EndOfDayScreen(key: ValueKey('endOfDay'));
      case GamePhase.daySummary:
        return const MainShell(key: ValueKey('shell_summary'));
      case GamePhase.scamDojo:
        // Scam dojo is handled as a dialog overlay, never as a root screen
        return const MainShell(key: ValueKey('shell_scam'));
    }
  }
}
