import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _editing = false;
  late TextEditingController _goalCtrl;
  late TextEditingController _incomeMinCtrl;
  late TextEditingController _incomeMaxCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<GameController>().currentUser;
    _goalCtrl = TextEditingController(text: '${user?.monthlyGoal ?? 5000}');
    _incomeMinCtrl = TextEditingController(text: '${user?.dailyIncomeMin ?? 300}');
    _incomeMaxCtrl = TextEditingController(text: '${user?.dailyIncomeMax ?? 700}');
  }

  @override
  void dispose() {
    _goalCtrl.dispose();
    _incomeMinCtrl.dispose();
    _incomeMaxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final user = controller.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Mera Profile'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_editing) _saveEdits(context, user);
              setState(() => _editing = !_editing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.turmeric, AppColors.kumkum]),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user.name, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.lightCream, borderRadius: BorderRadius.circular(20)),
                    child: Text('${_emojiForOcc(user.occupation)} ${user.occupation}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 4),
                  Text('📍 ${user.location}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Monthly goal progress
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.warmCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mahiney Ka Lakshya 🎯', style: Theme.of(context).textTheme.headlineSmall),
                      if (_editing)
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _goalCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(prefixText: '₹', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        Text('₹${user.monthlyGoal}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.leafGreen)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: controller.monthlyGoalProgress,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
                      minHeight: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${user.totalSavings} bachat', style: const TextStyle(color: AppColors.leafGreen, fontWeight: FontWeight.w600)),
                      Text('${(controller.monthlyGoalProgress * 100).toStringAsFixed(0)}% poora', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Income range
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.warmCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rojana Ki Kamai Range 💰', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  if (_editing)
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _incomeMinCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Min ₹', prefixText: '₹'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _incomeMaxCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Max ₹', prefixText: '₹'))),
                      ],
                    )
                  else
                    Text('₹${user.dailyIncomeMin} – ₹${user.dailyIncomeMax} per day', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.turmeric)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.warmCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stats 📊', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _statRow('🔥 Streak', '${user.streakDays} din'),
                  _statRow('⭐ Total Points', '${user.lifetimeRewardPoints}'),
                  _statRow('📚 Lessons Complete', '${user.lessonsCompleted}'),
                  _statRow('💰 Total Bachat', '₹${user.totalSavings}'),
                  _statRow('👨‍👩‍👧 Parivaar', '${user.familySize} log'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _saveEdits(BuildContext context, UserProfile user) {
    user.monthlyGoal = int.tryParse(_goalCtrl.text) ?? user.monthlyGoal;
    user.dailyIncomeMin = int.tryParse(_incomeMinCtrl.text) ?? user.dailyIncomeMin;
    user.dailyIncomeMax = int.tryParse(_incomeMaxCtrl.text) ?? user.dailyIncomeMax;
    context.read<GameController>().goToStartDay(); // triggers rebuild
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile save ho gaya ✅'), backgroundColor: AppColors.successGreen));
  }

  String _emojiForOcc(String occ) {
    switch (occ.toLowerCase()) {
      case 'tailoring': return '🧵';
      case 'farming': return '🌾';
      case 'shopkeeper': return '🏪';
      default: return '👩';
    }
  }
}
