import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';

class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final users = controller.allUsers;
    final s = AppStrings.of(context);
    final lc = context.watch<LanguageController>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Language toggle (globe button, matches main_shell style) ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showLanguagePicker(context, lc, s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.leafGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.leafGreen.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, color: AppColors.leafGreen, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            lc.isHindi ? 'हिं / EN' : 'EN / हिं',
                            style: const TextStyle(color: AppColors.leafGreen, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.leafGreen, AppColors.deepGreen],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.leafGreen.withAlpha(80),
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: const Center(
                        child: Text('🌿', style: TextStyle(fontSize: 44))),
                  ),
                  const SizedBox(height: 20),
                  Text('Sakhya',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                              color: AppColors.leafGreen,
                              fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    s.appTagline,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(s.selectUserTitle,
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
            const SizedBox(height: 16),

            // User list
            Expanded(
              child: users.isEmpty
                  ? _buildEmptyState(context, s)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: users.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) => _UserCard(user: users[i]),
                    ),
            ),

            // New User button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.read<GameController>().goToNewUserFlow(),
                icon: const Icon(Icons.add),
                label: Text(s.newUserButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turmeric,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LanguageController langCtrl, AppStrings s) {
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
            Text(s.languageLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            _LanguageOption(
              flag: '🇮🇳', label: s.languageHindi, sublabel: 'Hindi',
              selected: langCtrl.isHindi,
              onTap: () { langCtrl.setHindi(); Navigator.pop(context); },
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              flag: '🇬🇧', label: s.languageEnglish, sublabel: 'English',
              selected: !langCtrl.isHindi,
              onTap: () { langCtrl.setEnglish(); Navigator.pop(context); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppStrings s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌸', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(s.noUsersTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(s.noUsersSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
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

class _UserCard extends StatelessWidget {
  final UserProfile user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final occupationEmoji = _emojiForOccupation(user.occupation);
    return InkWell(
      onTap: () => context.read<GameController>().selectUser(user),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.warmCard(),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppColors.lightCream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                  child: Text(occupationEmoji,
                      style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(user.occupation,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: AppColors.kumkum, size: 16),
                      const SizedBox(width: 4),
                      Text('${user.streakDays} din',
                          style: const TextStyle(
                              color: AppColors.kumkum,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.stars,
                          color: AppColors.turmeric, size: 16),
                      const SizedBox(width: 4),
                      Text('${user.lifetimeRewardPoints} pts',
                          style: const TextStyle(
                              color: AppColors.turmeric,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.divider, size: 18),
          ],
        ),
      ),
    );
  }

  String _emojiForOccupation(String occupation) {
    switch (occupation.toLowerCase()) {
      case 'tailoring':
        return '🧵';
      case 'farming':
        return '🌾';
      case 'shopkeeper':
        return '🏪';
      case 'domestic worker':
        return '🏠';
      default:
        return '👩';
    }
  }
}
