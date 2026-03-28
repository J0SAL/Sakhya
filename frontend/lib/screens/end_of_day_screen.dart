import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';

class EndOfDayScreen extends StatefulWidget {
  const EndOfDayScreen({super.key});

  @override
  State<EndOfDayScreen> createState() => _EndOfDayScreenState();
}

class _EndOfDayScreenState extends State<EndOfDayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _complete(BuildContext context) {
    setState(() => _completed = true);
    context.read<GameController>().completeEndOfDay();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final s = AppStrings.of(context);
    final income = controller.dailyIncome;
    final ghar = controller.gharBalance;
    final dhanda = controller.dhandaBalance;
    final totalSavings = controller.totalSavings;
    final progress = controller.monthlyGoalProgress;

    final user = controller.currentUser;
    final estExpense = user != null ? ((user.dailyExpenseMin + user.dailyExpenseMax) ~/ 2 ~/ 50) * 50 : 150;
    final estSavings = (ghar - estExpense).clamp(0, ghar);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
            child: Column(
              children: [
                const Text('🌇', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                Text(
                  s.isHindi ? 'दिन खत्म हुआ!' : 'Day Complete!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.deepGreen),
                ),
                const SizedBox(height: 4),
                Text(
                  s.isHindi ? 'आज आपने कितना संभाला?' : 'How did you manage today?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // Income breakdown
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.warmCard(),
                  child: Column(
                    children: [
                      _buildRow(context, s.isHindi ? '💰 आज की कमाई' : '💰 Today\'s Income', '₹$income', AppColors.leafGreen),
                      const Divider(height: 24, color: AppColors.divider),
                      _buildRow(context, s.isHindi ? '🏠 घर (शुरुआत)' : '🏠 Home (start)', '₹$ghar', AppColors.leafGreen),
                      const SizedBox(height: 8),
                      _buildRow(context, s.isHindi ? '🍚 घर का खर्चा (अनुमान)' : '🍚 Home expense (est.)', '-₹$estExpense', AppColors.kumkum),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.leafGreen.withAlpha(30), AppColors.turmeric.withAlpha(20)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.isHindi ? '🌟 आज की बचत' : '🌟 Today\'s Savings',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.deepGreen),
                            ),
                            Text('≈₹$estSavings',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.leafGreen)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRow(context, s.isHindi ? '🪡 धंधा बाकी' : '🪡 Business balance', '₹$dhanda', AppColors.turmeric),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Monthly progress
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.warmCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.isHindi ? 'महीने का लक्ष्य' : 'Monthly Goal',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '₹${totalSavings + estSavings} / ₹${controller.monthlyGoal}',
                            style: const TextStyle(color: AppColors.leafGreen, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ((totalSavings + estSavings) / controller.monthlyGoal).clamp(0.0, 1.0),
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
                          minHeight: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.isHindi
                            ? '${(progress * 100).toStringAsFixed(0)}% लक्ष्य पूरा!'
                            : '${(progress * 100).toStringAsFixed(0)}% of goal reached!',
                        style: const TextStyle(color: AppColors.deepGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // CTA
                if (!_completed)
                  ElevatedButton(
                    onPressed: () => _complete(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.leafGreen),
                    child: Text(
                      s.isHindi ? 'बचत जमा करें और Summary देखें' : 'Save & View Summary',
                    ),
                  )
                else
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      const CircularProgressIndicator(color: AppColors.leafGreen),
                      const SizedBox(height: 12),
                      Text(
                        s.isHindi ? 'Summary खुल रही है...' : 'Opening summary...',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: color)),
      ],
    );
  }
}
