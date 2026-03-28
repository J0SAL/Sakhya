import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class NewUserFlowScreen extends StatefulWidget {
  const NewUserFlowScreen({super.key});

  @override
  State<NewUserFlowScreen> createState() => _NewUserFlowScreenState();
}

class _NewUserFlowScreenState extends State<NewUserFlowScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Form data
  final _nameCtrl = TextEditingController();
  String _selectedOccupation = 'Tailoring';
  final _goalCtrl = TextEditingController(text: '5000');
  int _familySize = 4;
  String _location = 'Rajasthan, India';

  final _occupations = ['Tailoring', 'Farming', 'Shopkeeper', 'Domestic Worker', 'Other'];
  final _locations = ['Rajasthan, India', 'Madhya Pradesh, India', 'Uttar Pradesh, India'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apna naam likhein')));
      return;
    }
    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.read<GameController>().goToUserSelect();
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final profile = UserProfile.fromOnboarding(
      name: _nameCtrl.text.trim(),
      occupation: _selectedOccupation,
      monthlyGoal: int.tryParse(_goalCtrl.text) ?? 5000,
      familySize: _familySize,
      location: _location,
    );
    await context.read<GameController>().createUser(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _prevPage,
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / 4,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('${_currentPage + 1}/4', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildNamePage(),
                  _buildOccupationPage(),
                  _buildGoalPage(),
                  _buildFamilyLocationPage(),
                ],
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.leafGreen)
                  : ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(_currentPage == 3 ? '✅  Sakhya Shuru Karein' : 'Aage Chalein →'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required String emoji, required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return _buildStep(
      emoji: '🙏',
      title: 'Aapka naam?',
      subtitle: 'Apna naam likhein jisse Sakhya aapko jaane',
      child: TextField(
        controller: _nameCtrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: Theme.of(context).textTheme.headlineSmall,
        decoration: const InputDecoration(hintText: 'Jaise: Sunita, Meena, Rani...'),
      ),
    );
  }

  Widget _buildOccupationPage() {
    return _buildStep(
      emoji: '💼',
      title: 'Aap kya kaam karti hain?',
      subtitle: 'Apna peshaa chunein',
      child: Column(
        children: _occupations.map((occ) {
          final emoji = _emojiForOcc(occ);
          final selected = _selectedOccupation == occ;
          return GestureDetector(
            onTap: () => setState(() => _selectedOccupation = occ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.leafGreen.withAlpha(30) : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selected ? AppColors.leafGreen : AppColors.divider, width: selected ? 2 : 1),
                boxShadow: selected ? [BoxShadow(color: AppColors.leafGreen.withAlpha(40), blurRadius: 8)] : [],
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 16),
                  Expanded(child: Text(occ, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: selected ? AppColors.deepGreen : AppColors.textPrimary))),
                  if (selected) const Icon(Icons.check_circle, color: AppColors.leafGreen, size: 24),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalPage() {
    return _buildStep(
      emoji: '🎯',
      title: 'Mahine ka lakshya?',
      subtitle: 'Aap is mahine kitna bachat karna chahti hain?',
      child: Column(
        children: [
          TextField(
            controller: _goalCtrl,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.leafGreen),
            decoration: const InputDecoration(prefixText: '₹ ', hintText: '5000'),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [2000, 3000, 5000, 8000, 10000].map((amt) => ActionChip(
              label: Text('₹$amt'),
              onPressed: () => setState(() => _goalCtrl.text = '$amt'),
              backgroundColor: AppColors.lightCream,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyLocationPage() {
    return _buildStep(
      emoji: '👨‍👩‍👧‍👦',
      title: 'Parivaar ka saath?',
      subtitle: 'Parivaar mein kitne log hain?',
      child: Column(
        children: [
          // Family size selector
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.warmCard(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Parivar ka aakaar', style: Theme.of(context).textTheme.headlineSmall),
                Row(
                  children: [
                    IconButton(
                      onPressed: () { if (_familySize > 1) setState(() => _familySize--); },
                      icon: const Icon(Icons.remove_circle, color: AppColors.kumkum, size: 32),
                    ),
                    Text('$_familySize', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.leafGreen)),
                    IconButton(
                      onPressed: () { if (_familySize < 12) setState(() => _familySize++); },
                      icon: const Icon(Icons.add_circle, color: AppColors.leafGreen, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: AppTheme.warmCard(),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.kumkum, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _location,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                      onChanged: (val) {
                        if (val != null) setState(() => _location = val);
                      },
                      items: _locations.map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Sthaan', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontSize: 11)),
                            Text(loc, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _emojiForOcc(String occ) {
    switch (occ) {
      case 'Tailoring': return '🧵';
      case 'Farming': return '🌾';
      case 'Shopkeeper': return '🏪';
      case 'Domestic Worker': return '🏠';
      default: return '✨';
    }
  }
}
