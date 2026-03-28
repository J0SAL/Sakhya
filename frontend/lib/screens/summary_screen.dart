import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final summary = controller.todaySummary;
    final strings = AppStrings.of(context);

    if (summary == null || !summary.hasActivity) {
      return _buildEmptyState(context, strings);
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
                    Text(strings.summaryHeader, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
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
            title: strings.gameStats,
            points: summary.rewardDelta,
            children: [
              _StatRow(strings.kamai, '₹${summary.incomeEarned}', AppColors.leafGreen),
              _StatRow(strings.gharAlloc, '₹${summary.gharAllocation}', AppColors.leafGreen),
              _StatRow(strings.dhandaAlloc, '₹${summary.dhandaAllocation}', AppColors.turmeric),
              _StatRow(strings.gharKharcha, '₹${summary.householdExpense}', AppColors.kumkum),
              _StatRow(strings.aajKiBachat, '₹${summary.savings}', AppColors.successGreen, large: true),
              _StatRow(strings.allocation, summary.allocationCorrect ? strings.allocationCorrect : strings.allocationWrong,
                  summary.allocationCorrect ? AppColors.successGreen : AppColors.errorRed),
            ],
          ),

          const SizedBox(height: 12),

          // Learning card
          _SummaryCard(
            emoji: '📚',
            title: strings.learningTitle,
            points: summary.learningRewardDelta,
            children: summary.lessonsAttempted == 0
                ? [_StatRow(strings.noLesson, '—', AppColors.textSecondary)]
                : [
                    _StatRow(strings.lessonsTriedLabel, '${summary.lessonsAttempted}', AppColors.leafGreen),
                    _StatRow(strings.correctAnswers, '${summary.lessonsCorrect}', AppColors.successGreen),
                    _StatRow(strings.wrongAnswers, '${summary.lessonsAttempted - summary.lessonsCorrect}', AppColors.errorRed),
                  ],
          ),

          const SizedBox(height: 12),

          // Scam card
          _SummaryCard(
            emoji: '📞',
            title: strings.scamDojo,
            points: summary.scamRewardDelta,
            children: !summary.scamCompleted
                ? [_StatRow(strings.noScamToday, '—', AppColors.textSecondary)]
                : [
                    _StatRow('Scam call', summary.scamCorrect ? strings.scamRejected : strings.scamOtpGiven,
                        summary.scamCorrect ? AppColors.successGreen : AppColors.errorRed),
                    if (summary.usedLaxmiDidiHelp) _StatRow(strings.laxmiHelp, '✓', AppColors.turmeric),
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
                  Row(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(strings.tasksTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
                Text(strings.totalReward, style: Theme.of(context).textTheme.headlineSmall),
                Text('${summary.totalRewardDelta}', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.turmeric)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Finish Day Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.finalizeDayAndSleep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.leafGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: Text(strings.endDayButton, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              strings.endDayNote,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppStrings strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌸', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text(strings.emptyStatTitle, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(
              strings.emptyStatSub,
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
