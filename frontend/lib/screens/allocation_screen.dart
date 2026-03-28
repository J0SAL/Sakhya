import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';
import 'scam_guard_simulator.dart';

class AllocationScreen extends StatefulWidget {
  const AllocationScreen({super.key});

  @override
  State<AllocationScreen> createState() => _AllocationScreenState();
}

class _AllocationScreenState extends State<AllocationScreen> {
  late TextEditingController _gharCtrl;
  late TextEditingController _dhandaCtrl;
  bool _showHintCard = false;
  bool _submitted = false;
  bool? _lastCorrect;

  @override
  void initState() {
    super.initState();
    final controller = context.read<GameController>();
    _gharCtrl = TextEditingController(text: '');
    _dhandaCtrl = TextEditingController(text: '');
    // Pre-fill with suggested amounts
    _gharCtrl.text = '${controller.suggestedGhar}';
    _dhandaCtrl.text = '${controller.suggestedDhanda}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().setGharAmount(controller.suggestedGhar);
    });
  }

  @override
  void dispose() {
    _gharCtrl.dispose();
    _dhandaCtrl.dispose();
    super.dispose();
  }

  void _onGharChanged(String val) {
    final amount = int.tryParse(val) ?? 0;
    context.read<GameController>().setGharAmount(amount);
    final dhanda = context.read<GameController>().dhandaBalance;
    _dhandaCtrl.text = '$dhanda';
  }

  void _onDhandaChanged(String val) {
    final amount = int.tryParse(val) ?? 0;
    context.read<GameController>().setDhandaAmount(amount);
    final ghar = context.read<GameController>().gharBalance;
    _gharCtrl.text = '$ghar';
  }

  void _showHint() {
    context.read<GameController>().useAllocationHint();
    setState(() => _showHintCard = true);
  }

  void _submit() {
    final controller = context.read<GameController>();
    final correct = controller.validateAllocation();
    setState(() {
      _submitted = true;
      _lastCorrect = correct;
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      controller.submitAllocation();
      // Show scam dojo if triggered
      if (controller.pendingScamEvent) {
        _showScamDojo();
      }
    });
  }

  void _showScamDojo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameController>(),
        child: const ScamGuardDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final income = controller.dailyIncome;
    final ghar = controller.gharBalance;
    final fraction = income > 0 ? (ghar / income).clamp(0.0, 1.0) : 0.5;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Aaj Ki Kamai Baantein'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            // Income banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.turmeric, Color(0xFFE8401C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('💰 Aaj Ki Kamai', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('₹$income', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 48)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Visual split bar
            Container(
              decoration: AppTheme.warmCard(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Paise kaise bantein?', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 20,
                      child: Row(
                        children: [
                          Expanded(flex: (fraction * 100).round(), child: Container(color: AppColors.leafGreen)),
                          Expanded(flex: ((1 - fraction) * 100).round().clamp(0, 100), child: Container(color: AppColors.turmeric)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.leafGreen, shape: BoxShape.circle)), const SizedBox(width: 6), const Text('Ghar', style: TextStyle(fontWeight: FontWeight.w600))]),
                      Row(children: [Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.turmeric, shape: BoxShape.circle)), const SizedBox(width: 6), const Text('Dhanda', style: TextStyle(fontWeight: FontWeight.w600))]),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input fields
            Row(
              children: [
                Expanded(child: _buildPotInput(context, '🏠 Ghar', AppColors.leafGreen, _gharCtrl, _onGharChanged, hint: 'Ghar ka kharcha (${((controller.suggestedGhar/income)*100).round()}% sujhaav)')),
                const SizedBox(width: 16),
                Expanded(child: _buildPotInput(context, '🪡 Dhanda', AppColors.turmeric, _dhandaCtrl, _onDhandaChanged, hint: 'Dhande ka kharcha')),
              ],
            ),
            const SizedBox(height: 16),

            // Hint card
            if (_showHintCard) _buildHintCard(context, controller),
            if (!_showHintCard)
              TextButton.icon(
                onPressed: _showHint,
                icon: const Icon(Icons.support_agent, color: AppColors.turmeric),
                label: const Text('Laxmi Didi se poochein', style: TextStyle(color: AppColors.turmeric, fontWeight: FontWeight.w600)),
              ),

            const SizedBox(height: 20),

            // Result feedback
            if (_submitted && _lastCorrect != null)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _lastCorrect! ? AppColors.successGreen.withAlpha(20) : AppColors.errorRed.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _lastCorrect! ? AppColors.successGreen : AppColors.errorRed),
                  ),
                  child: Row(
                    children: [
                      Text(_lastCorrect! ? '✅' : '❌', style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _lastCorrect!
                            ? 'Sahi baant! +2 sikke mile${controller.usedHintThisAllocation ? "" : " +1 bonus"}! 🎉'
                            : 'Thodi galti hui. Sujhaav tha: Ghar mein 60%, Dhande mein 40%. -1 point. 📖',
                          style: TextStyle(color: _lastCorrect! ? AppColors.successGreen : AppColors.errorRed, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (!_submitted)
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Paise Baant Dein ✓'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotInput(BuildContext context, String label, Color color, TextEditingController ctrl, void Function(String) onChange, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChange,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18),
            hintText: '0',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: color)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: color.withAlpha(80))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: color, width: 2)),
            fillColor: color.withAlpha(10),
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(hint, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ],
    );
  }

  Widget _buildHintCard(BuildContext context, GameController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.turmeric.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.turmeric.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('👩', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text('Laxmi Didi kaehti hain:', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.maatiBrown)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"Aamdani ka 60% ghar ke liye rakho — khana, bacche ki school, bijli ke liye. Baaki 40% dhande mein lagao taaki kapda kharido aur kaam badhe."',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ActionChip(
                label: Text('Ghar: ₹${controller.suggestedGhar}'),
                onPressed: () {
                  _gharCtrl.text = '${controller.suggestedGhar}';
                  _dhandaCtrl.text = '${controller.suggestedDhanda}';
                  _onGharChanged('${controller.suggestedGhar}');
                },
                backgroundColor: AppColors.leafGreen.withAlpha(30),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: Text('Dhanda: ₹${controller.suggestedDhanda}'),
                onPressed: () {
                  _dhandaCtrl.text = '${controller.suggestedDhanda}';
                  _gharCtrl.text = '${controller.suggestedGhar}';
                  _onDhandaChanged('${controller.suggestedDhanda}');
                },
                backgroundColor: AppColors.turmeric.withAlpha(30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
