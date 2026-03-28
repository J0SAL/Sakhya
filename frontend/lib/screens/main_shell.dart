import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import 'home_dashboard.dart';
import 'learn_screen.dart';
import 'laxmi_didi_chat.dart';
import 'summary_screen.dart';
import 'samriddhi_store.dart';
import 'user_profile_screen.dart';
import 'streak_calendar_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int get _currentIndex => context.watch<GameController>().currentTabIndex;

  final _pages = const [
    HomeDashboardScreen(),
    LearnScreen(),
    LaxmiDidiChatScreen(),
    SummaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _buildTopBar(context, controller),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(context, controller),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context, GameController controller) {
    final strings = AppStrings.of(context);
    final langCtrl = context.watch<LanguageController>();

    return AppBar(
      backgroundColor: AppColors.leafGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Profile avatar
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
              if (result == true && context.mounted) {
                context.read<GameController>().logout();
              }
            },
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
              ),
              child: Center(
                child: Text(
                  controller.currentUser?.name.isNotEmpty == true ? controller.currentUser!.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/sakhya_logo.png', height: 24, fit: BoxFit.contain),
              if (controller.currentUser != null)
                Text(
                  '${strings.namaste}, ${controller.currentUser!.name.split(' ').first}!',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
      actions: [
        // Language toggle
        GestureDetector(
          onTap: () => _showLanguagePicker(context, langCtrl, strings),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    langCtrl.isHindi ? 'हि' : 'EN',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Streak
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StreakCalendarScreen())),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.softGold, size: 20),
                  const SizedBox(width: 4),
                  Text('${controller.streakDays}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
        // Rewards pill
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<GameController>(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: const SamriddhiStoreScreen(),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.turmeric, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text('${controller.rewardPoints}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker(BuildContext context, LanguageController langCtrl, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(strings.languageLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            // Hindi option
            _LanguageOption(
              flag: '🇮🇳',
              label: strings.languageHindi,
              sublabel: 'Hindi',
              selected: langCtrl.isHindi,
              onTap: () { langCtrl.setHindi(); Navigator.pop(context); },
            ),
            const SizedBox(height: 12),
            // English option
            _LanguageOption(
              flag: '🇬🇧',
              label: strings.languageEnglish,
              sublabel: 'English',
              selected: !langCtrl.isHindi,
              onTap: () { langCtrl.setEnglish(); Navigator.pop(context); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, GameController controller) {
    final strings = AppStrings.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: strings.navHome, index: 0, currentIndex: _currentIndex, onTap: (i) => controller.setTabIndex(i)),
              _NavItem(icon: Icons.menu_book_rounded, label: strings.navLearn, index: 1, currentIndex: _currentIndex, onTap: (i) => controller.setTabIndex(i)),
              _NavItem(icon: Icons.support_agent, label: strings.navLaxmiDidi, index: 2, currentIndex: _currentIndex, onTap: (i) => controller.setTabIndex(i)),
              _NavItem(
                label: strings.navSummary,
                index: 3,
                currentIndex: _currentIndex,
                onTap: (i) => controller.setTabIndex(i),
                icon: Icons.bar_chart_rounded,
                badge: controller.todaySummary?.hasActivity == true ? '✓' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag, required this.label, required this.sublabel,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.leafGreen.withAlpha(20) : AppColors.lightCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.leafGreen : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: selected ? AppColors.deepGreen : AppColors.textPrimary)),
                Text(sublabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.leafGreen, size: 24),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;
  final String? badge;

  const _NavItem({
    required this.icon, required this.label, required this.index,
    required this.currentIndex, required this.onTap, this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.leafGreen.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: selected ? AppColors.leafGreen : AppColors.warmGrey, size: 26),
                if (badge != null)
                  Positioned(
                    top: -4, right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.leafGreen, shape: BoxShape.circle),
                      child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 8)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.leafGreen : AppColors.warmGrey,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
