import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final summary = controller.todaySummary;

    if (summary == null || !summary.hasActivity) {
      return _buildEmptyState(context, controller);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.leafGreen, AppColors.deepGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aaj Ka Haal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                    Text(summary.date, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      summary.totalRewardDelta >= 0 ? '+${summary.totalRewardDelta}' : '${summary.totalRewardDelta}',
                      style: TextStyle(
                        color: summary.totalRewardDelta >= 0 ? AppColors.softGold : AppColors.errorRed,
                        fontWeight: FontWeight.w900, fontSize: 24,
                      ),
                    ),
                    const Text('⭐ aaj ke', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Game stats card
          _SummaryCard(
            emoji: '💰',
            title: 'Game Stats',
            points: summary.rewardDelta,
            children: [
              _StatRow('Kamai', '₹${summary.incomeEarned}', AppColors.leafGreen),
              _StatRow('Ghar Baant', '₹${summary.gharAllocation}', AppColors.leafGreen),
              _StatRow('Dhanda Baant', '₹${summary.dhandaAllocation}', AppColors.turmeric),
              _StatRow('Ghar Kharcha', '₹${summary.householdExpense}', AppColors.kumkum),
              _StatRow('Aaj Ki Bachat 🌟', '₹${summary.savings}', AppColors.successGreen, large: true),
              _StatRow('Allocation', summary.allocationCorrect ? '✅ Sahi' : '❌ Galat', summary.allocationCorrect ? AppColors.successGreen : AppColors.errorRed),
            ],
          ),

          const SizedBox(height: 12),

          // Learning card
          _SummaryCard(
            emoji: '📚',
            title: 'Seekhna (Learning)',
            points: summary.learningRewardDelta,
            children: summary.lessonsAttempted == 0
                ? [const _StatRow('Koi lesson nahi', '—', AppColors.textSecondary)]
                : [
                    _StatRow('Lessons try kiye', '${summary.lessonsAttempted}', AppColors.leafGreen),
                    _StatRow('Sahi jawab', '${summary.lessonsCorrect}', AppColors.successGreen),
                    _StatRow('Galat jawab', '${summary.lessonsAttempted - summary.lessonsCorrect}', AppColors.errorRed),
                  ],
          ),

          const SizedBox(height: 12),

          // Scam card
          _SummaryCard(
            emoji: '📞',
            title: 'Scam Dojo',
            points: summary.scamRewardDelta,
            children: !summary.scamCompleted
                ? [const _StatRow('Aaj scam event nahi aaya', '—', AppColors.textSecondary)]
                : [
                    _StatRow('Scam call', summary.scamCorrect ? '✅ Reject kiya!' : '❌ OTP de diya', summary.scamCorrect ? AppColors.successGreen : AppColors.errorRed),
                    if (summary.usedLaxmiDidiHelp) const _StatRow('Laxmi Didi madad li', '✓', AppColors.turmeric),
                  ],
          ),

          const SizedBox(height: 12),

          // Tasks card
          if (summary.tasksCompleted.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.warmCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('✅', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('Kaam Jo Hue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...summary.tasksCompleted.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(task, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15)),
                  )),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Total reward summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: controller.rewardPoints > 0 ? AppColors.turmeric.withAlpha(20) : AppColors.errorRed.withAlpha(10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.turmeric.withAlpha(60)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aaj Ke Kul Reward 🏆', style: Theme.of(context).textTheme.headlineSmall),
                Text('${summary.totalRewardDelta}', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.turmeric)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Finish Day Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.finalizeDayAndSleep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.leafGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('🌙', style: TextStyle(fontSize: 24)),
                   SizedBox(width: 12),
                   Text('Sona Jaiye (End Day)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Aaj ki bachat aur rewards 12 baje update honge.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, GameController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌸', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text('Aaj ka haal khaali hai', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(
              'Khel shuru karein ya koi lesson seekhein — sab yahan dikhega!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final int points;
  final List<Widget> children;

  const _SummaryCard({required this.emoji, required this.title, required this.points, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.warmCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: points >= 0 ? AppColors.leafGreen.withAlpha(20) : AppColors.errorRed.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  points >= 0 ? '+$points ⭐' : '$points ⭐',
                  style: TextStyle(color: points >= 0 ? AppColors.successGreen : AppColors.errorRed, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool large;

  const _StatRow(this.label, this.value, this.valueColor, {this.large = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: large ? 16 : 14)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: large ? FontWeight.w800 : FontWeight.w600, fontSize: large ? 18 : 14)),
        ],
      ),
    );
  }
}
