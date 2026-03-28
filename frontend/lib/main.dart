import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/game_controller.dart';
import 'theme/app_theme.dart';
import 'theme/app_strings.dart';
import 'screens/user_select_screen.dart';
import 'screens/new_user_flow_screen.dart';
import 'screens/main_shell.dart';
import 'screens/allocation_screen.dart';
import 'screens/store1_screen.dart';
import 'screens/end_of_day_screen.dart';

final LanguageController languageController = LanguageController();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
        ChangeNotifierProvider.value(value: languageController),
      ],
      child: const SakhyaApp(),
    ),
  );
}

class SakhyaApp extends StatelessWidget {
  const SakhyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild MaterialApp when language changes to update title
    context.watch<LanguageController>();
    return LanguageControllerProvider(
      controller: languageController,
      child: MaterialApp(
        title: 'Sakhya',
        theme: AppTheme.theme(),
        home: const AppRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Root router — watches GamePhase and renders the correct screen.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final phase = context.watch<GameController>().currentPhase;
    return _routeForPhase(phase);
  }

  Widget _routeForPhase(GamePhase phase) {
    switch (phase) {
      case GamePhase.userSelect:
        return const UserSelectScreen(key: ValueKey('userSelect'));
      case GamePhase.newUserFlow:
        return const NewUserFlowScreen(key: ValueKey('newUser'));
      case GamePhase.startDay:
      case GamePhase.daySummary:
      case GamePhase.scamDojo:
        // All phases that show the main shell share the same key so the
        // widget is NOT rebuilt and the currentTabIndex in GameController
        // is respected (e.g. navigating to Summary tab on daySummary).
        return const MainShell(key: ValueKey('main_shell'));
      case GamePhase.allocation:
        return const AllocationScreen(key: ValueKey('allocation'));
      case GamePhase.store1:
        return const Store1Screen(key: ValueKey('store1'));
      case GamePhase.endOfDay:
        return const EndOfDayScreen(key: ValueKey('endOfDay'));
    }
  }
}
