import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final user = controller.currentUser;
    final today = controller.todaySummary;
    final alreadyPlayed = today?.incomeEarned != null && today!.incomeEarned > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly goal progress
          if (user != null) _buildGoalCard(context, controller, user),
          const SizedBox(height: 20),

          // Start day CTA
          if (!alreadyPlayed) _buildStartDayCard(context, controller)
          else _buildDayCompletedCard(context, controller),

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              Expanded(child: _buildStatMini(context, '🏠 Ghar', '₹${controller.gharBalance}', AppColors.leafGreen)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatMini(context, '🪡 Dhanda', '₹${controller.dhandaBalance}', AppColors.turmeric)),
            ],
          ),
          const SizedBox(height: 20),

          // Scam Dojo schedule ghost button (for demo)
          _buildScamScheduleButton(context),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, GameController controller, user) {
    final progress = controller.monthlyGoalProgress;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.leafGreen, AppColors.deepGreen],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.leafGreen.withAlpha(80), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mahiney ka Lakshya 🎯', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text('₹${controller.totalSavings} / ₹${controller.monthlyGoal}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.softGold),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% poora ho gaya!',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStartDayCard(BuildContext context, GameController controller) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.warmCard(),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Text('☀️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('Aaj ka naya din!', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Shuru karein aur aaj ki kamai sambhalein',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<GameController>().startDay(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.turmeric,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Din Shuru Karein 🌅', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCompletedCard(BuildContext context, GameController controller) {
    final summary = controller.todaySummary;
    return Container(
      width: double.infinity,
      decoration: AppTheme.warmCard(color: AppColors.leafGreen.withAlpha(15)),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Aaj ka din poora hua!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.deepGreen)),
          const SizedBox(height: 8),
          if (summary != null) ...[
            Text('Kamai: ₹${summary.incomeEarned}', style: Theme.of(context).textTheme.bodyLarge),
            Text('Bachat: ₹${summary.savings}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.leafGreen, fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.read<GameController>().goToStartDay(),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.leafGreen, side: const BorderSide(color: AppColors.leafGreen)),
            child: const Text('Kal ke liye taiyar rahein'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMini(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildScamScheduleButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scam Dojo call scheduled for demo 📞'), backgroundColor: AppColors.maatiBrown),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary.withAlpha(60),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: const Text('Schedule Scam Dojo Demo', style: TextStyle(fontSize: 12)),
      ),
    );
  }
}
