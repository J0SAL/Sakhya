import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final users = controller.allUsers;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
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
                      boxShadow: [BoxShadow(color: AppColors.leafGreen.withAlpha(80), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: const Center(child: Text('🌿', style: TextStyle(fontSize: 44))),
                  ),
                  const SizedBox(height: 20),
                  Text('Sakhya', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.leafGreen, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    'Aapki Arthik Saheli',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Kaun hain aap?', style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
            const SizedBox(height: 16),

            // User list
            Expanded(
              child: users.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: users.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _UserCard(user: users[i]),
                    ),
            ),

            // New User button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: () => context.read<GameController>().goToNewUserFlow(),
                icon: const Icon(Icons.add),
                label: const Text('Naya User Banayein'),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌸', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Koi user nahi mila', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Naya user banane ke liye neeche button dabayein', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
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
              child: Center(child: Text(occupationEmoji, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(user.occupation, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: AppColors.kumkum, size: 16),
                      const SizedBox(width: 4),
                      Text('${user.streakDays} din', style: TextStyle(color: AppColors.kumkum, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.stars, color: AppColors.turmeric, size: 16),
                      const SizedBox(width: 4),
                      Text('${user.lifetimeRewardPoints} pts', style: TextStyle(color: AppColors.turmeric, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.divider, size: 18),
          ],
        ),
      ),
    );
  }

  String _emojiForOccupation(String occupation) {
    switch (occupation.toLowerCase()) {
      case 'tailoring': return '🧵';
      case 'farming': return '🌾';
      case 'shopkeeper': return '🏪';
      case 'domestic worker': return '🏠';
      default: return '👩';
    }
  }
}
