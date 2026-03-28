import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../services/tts_service.dart';
import '../theme/app_strings.dart';
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
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    final controller = context.read<GameController>();
    _gharCtrl = TextEditingController(text: '${controller.suggestedGhar}');
    _dhandaCtrl = TextEditingController(text: '${controller.suggestedDhanda}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().setGharAmount(controller.suggestedGhar);
      final s = AppStrings.of(context);
      TtsService.instance.speakL(
        isHindi: s.isHindi,
        hindi: 'आज की कमाई बाँटें। घर और धंधे में।',
        english: 'Split today\'s earnings between home and business.',
      );
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
    final s = AppStrings.of(context);
    context.read<GameController>().useAllocationHint();
    setState(() => _showHintCard = true);
    TtsService.instance.speakL(
      isHindi: s.isHindi,
      hindi: 'आमदनी का 60% घर के लिए रखो। 40% धंधे में लगाओ।',
      english: 'Keep 60% of income for home. Put 40% into business.',
    );
  }

  void _submit() {
    final controller = context.read<GameController>();
    final s = AppStrings.of(context);
    final ghar = controller.gharBalance;
    final gharBelowMin = ghar < GameController.minGhar;
    final correct = controller.validateAllocation();
    setState(() {
      _submitted = true;
      _lastCorrect = correct;
    });

    if (correct) {
      TtsService.instance.speakL(
        isHindi: s.isHindi,
        hindi: 'सही बाँट! ${controller.usedHintThisAllocation ? "" : "+1 बोनस!"} 🎉',
        english: 'Correct split! ${controller.usedHintThisAllocation ? "" : "+1 bonus!"} 🎉',
      );
    } else {
      final hint = gharBelowMin
          ? (s.isHindi
              ? 'घर के लिए कम से कम ₹${GameController.minGhar} जरूरी है।'
              : 'At least ₹${GameController.minGhar} needed for home.')
          : (s.isHindi
              ? 'धंधे के लिए कम से कम ₹${GameController.minDhanda} जरूरी है।'
              : 'At least ₹${GameController.minDhanda} needed for business.');
      TtsService.instance.speakL(isHindi: s.isHindi, hindi: hint, english: hint);
    }

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      controller.submitAllocation();
      if (correct && controller.pendingScamEvent) {
        _showScamDojo();
      }
      if (!correct) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() => _submitted = false);
        });
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

  void _onSliderDrag(double dx, double totalWidth, int income) {
    if (income <= 0) return;
    final frac = (dx / totalWidth).clamp(0.0, 1.0);
    int newGhar = ((frac * income) / 50).round() * 50;
    newGhar = newGhar.clamp(0, income);
    context.read<GameController>().setGharAmount(newGhar);
    _gharCtrl.text = '$newGhar';
    _dhandaCtrl.text = '${income - newGhar}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final s = AppStrings.of(context);
    final income = controller.dailyIncome;
    final ghar = controller.gharBalance;
    final dhanda = controller.dhandaBalance;
    final fraction = income > 0 ? (ghar / income).clamp(0.0, 1.0) : 0.5;

    final gharBelowMin = ghar < GameController.minGhar;
    final dhandaBelowMin = dhanda < GameController.minDhanda;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(s.isHindi ? 'आज की कमाई बाँटें' : 'Split Today\'s Earnings'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            // Income banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.turmeric, Color(0xFFE8401C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    s.isHindi ? '💰 आज की कमाई' : '💰 Today\'s Earnings',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text('₹$income',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 48)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Draggable split bar card ─────────────────────────────────
            Container(
              decoration: AppTheme.warmCard(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.isHindi ? 'पैसे कैसे बाँटें?' : 'How to split money?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),

                  // Amount labels above bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.isHindi ? '🏠 घर' : '🏠 Home',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.leafGreen,
                                fontSize: 13),
                          ),
                          Text('₹$ghar',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: gharBelowMin
                                      ? AppColors.errorRed
                                      : AppColors.leafGreen)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            s.isHindi ? '🪡 धंधा' : '🪡 Business',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.turmeric,
                                fontSize: 13),
                          ),
                          Text('₹$dhanda',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: dhandaBelowMin
                                      ? AppColors.errorRed
                                      : AppColors.turmeric)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Draggable bar ─────────────────────────────────────
                  LayoutBuilder(builder: (ctx, constraints) {
                    final totalW = constraints.maxWidth;
                    return GestureDetector(
                      onHorizontalDragUpdate: (det) {
                        final localX =
                            (det.localPosition.dx).clamp(0.0, totalW);
                        _onSliderDrag(localX, totalW, income);
                        HapticFeedback.selectionClick();
                      },
                      onHorizontalDragStart: (_) =>
                          setState(() => _isDragging = true),
                      onHorizontalDragEnd: (_) =>
                          setState(() => _isDragging = false),
                      onTapDown: (det) {
                        final localX =
                            (det.localPosition.dx).clamp(0.0, totalW);
                        _onSliderDrag(localX, totalW, income);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              height: 36,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: (fraction * 1000).round(),
                                    child: Container(color: AppColors.leafGreen),
                                  ),
                                  Expanded(
                                    flex: ((1 - fraction) * 1000)
                                        .round()
                                        .clamp(0, 1000),
                                    child: Container(color: AppColors.turmeric),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: (fraction * totalW - 18).clamp(-4.0, totalW - 32),
                            top: -4,
                            child: AnimatedContainer(
                              duration: _isDragging
                                  ? Duration.zero
                                  : const Duration(milliseconds: 150),
                              width: 36,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(60),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ],
                                border: Border.all(
                                    color: AppColors.divider, width: 1),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.drag_indicator,
                                      size: 20, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),

                  // ── Minimum labels ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Row(children: [
                          Icon(
                            gharBelowMin ? Icons.warning_amber : Icons.check_circle,
                            size: 14,
                            color: gharBelowMin
                                ? AppColors.errorRed
                                : AppColors.successGreen,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              s.isHindi
                                  ? 'न्यूनतम ₹${GameController.minGhar} घर के लिए'
                                  : 'Min ₹${GameController.minGhar} for home',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: gharBelowMin
                                      ? AppColors.errorRed
                                      : AppColors.successGreen,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                s.isHindi
                                    ? 'न्यूनतम ₹${GameController.minDhanda} धंधे के लिए'
                                    : 'Min ₹${GameController.minDhanda} for business',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: dhandaBelowMin
                                        ? AppColors.errorRed
                                        : AppColors.successGreen,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              dhandaBelowMin
                                  ? Icons.warning_amber
                                  : Icons.check_circle,
                              size: 14,
                              color: dhandaBelowMin
                                  ? AppColors.errorRed
                                  : AppColors.successGreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Input fields ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                    child: _buildPotInput(
                  context,
                  s.isHindi ? '🏠 घर' : '🏠 Home',
                  AppColors.leafGreen,
                  _gharCtrl,
                  _onGharChanged,
                  hint: s.isHindi
                      ? 'सुझाव: ${((controller.suggestedGhar / (income > 0 ? income : 1)) * 100).round()}%'
                      : 'Suggested: ${((controller.suggestedGhar / (income > 0 ? income : 1)) * 100).round()}%',
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildPotInput(
                  context,
                  s.isHindi ? '🪡 धंधा' : '🪡 Business',
                  AppColors.turmeric,
                  _dhandaCtrl,
                  _onDhandaChanged,
                  hint: s.isHindi ? 'धंधे का खर्चा' : 'Business expense',
                )),
              ],
            ),
            const SizedBox(height: 16),

            // Hint card / button
            if (_showHintCard)
              _buildHintCard(context, controller, s)
            else
              TextButton.icon(
                onPressed: _showHint,
                icon: const Icon(Icons.support_agent, color: AppColors.turmeric),
                label: Text(
                  s.isHindi ? 'लक्ष्मी दीदी से पूछें 💡' : 'Ask Laxmi Didi 💡',
                  style: const TextStyle(
                      color: AppColors.turmeric,
                      fontWeight: FontWeight.w600),
                ),
              ),

            const SizedBox(height: 16),

            // Result feedback / submit button
            if (_submitted && _lastCorrect != null)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _lastCorrect!
                        ? AppColors.successGreen.withAlpha(20)
                        : AppColors.errorRed.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _lastCorrect!
                            ? AppColors.successGreen
                            : AppColors.errorRed),
                  ),
                  child: Row(
                    children: [
                      Text(_lastCorrect! ? '✅' : '❌',
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _lastCorrect!
                              ? (s.isHindi
                                  ? 'सही बाँट! +2 सिक्के${controller.usedHintThisAllocation ? "" : " +1 बोनस"}! 🎉'
                                  : 'Correct split! +2 coins${controller.usedHintThisAllocation ? "" : " +1 bonus"}! 🎉')
                              : (gharBelowMin
                                  ? (s.isHindi
                                      ? 'घर के लिए ₹${GameController.minGhar} जरूरी! लक्ष्मी दीदी से मदद लो। -1 अंक'
                                      : 'Home needs ₹${GameController.minGhar}! Ask Laxmi Didi. -1 point')
                                  : (s.isHindi
                                      ? 'धंधे के लिए ₹${GameController.minDhanda} जरूरी! सुझाव: घर 60%, धंधा 40%. -1 अंक'
                                      : 'Business needs ₹${GameController.minDhanda}! Suggested: Home 60%, Business 40%. -1 point')),
                          style: TextStyle(
                              color: _lastCorrect!
                                  ? AppColors.successGreen
                                  : AppColors.errorRed,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (!_submitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(s.isHindi ? 'पैसे बाँट दें ✓' : 'Split Money ✓'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotInput(BuildContext context, String label, Color color,
      TextEditingController ctrl, void Function(String) onChange,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChange,
          style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle:
                TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18),
            hintText: '0',
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color.withAlpha(80))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color, width: 2)),
            fillColor: color.withAlpha(10),
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(hint,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ],
    );
  }

  Widget _buildHintCard(BuildContext context, GameController controller, AppStrings s) {
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
          Row(
            children: [
              const Text('👩', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                s.isHindi ? 'लक्ष्मी दीदी कहती हैं:' : 'Laxmi Didi says:',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.maatiBrown),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.isHindi
                ? '"आमदनी का 60% घर के लिए रखो — खाना, बच्चे की स्कूल, बिजली के लिए। बाकी 40% धंधे में लगाओ ताकि कपड़ा खरीदो और काम बढ़े।"'
                : '"Keep 60% of income for home — food, children\'s school, electricity. Put the remaining 40% into business so you can buy stock and grow."',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ActionChip(
                label: Text(s.isHindi
                    ? 'घर: ₹${controller.suggestedGhar}'
                    : 'Home: ₹${controller.suggestedGhar}'),
                onPressed: () {
                  _gharCtrl.text = '${controller.suggestedGhar}';
                  _dhandaCtrl.text = '${controller.suggestedDhanda}';
                  _onGharChanged('${controller.suggestedGhar}');
                },
                backgroundColor: AppColors.leafGreen.withAlpha(30),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: Text(s.isHindi
                    ? 'धंधा: ₹${controller.suggestedDhanda}'
                    : 'Business: ₹${controller.suggestedDhanda}'),
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
