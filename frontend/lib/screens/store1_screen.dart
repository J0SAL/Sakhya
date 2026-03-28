import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../services/tts_service.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import 'scam_guard_simulator.dart';
import 'upi_practice_screen.dart';

class Store1Screen extends StatelessWidget {
  const Store1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final s = AppStrings.of(context);
    final items = controller.storeItems;
    final cart = controller.cartTotal;
    final dhanda = controller.dhandaBalance;
    final isOverBudget = cart > dhanda;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(s.isHindi ? 'सिलाई सामग्री 🧵' : 'Tailoring Supplies 🧵'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Dhanda balance banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.turmeric.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.turmeric.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: AppColors.turmeric, size: 22),
                const SizedBox(width: 8),
                Text(
                  s.isHindi ? 'धंधा बजट: ' : 'Business budget: ',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                Text('₹$dhanda', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.turmeric)),
                const Spacer(),
                if (cart > 0) ...[
                  const Icon(Icons.shopping_cart, color: AppColors.kumkum, size: 18),
                  const SizedBox(width: 4),
                  Text('₹$cart', style: const TextStyle(color: AppColors.kumkum, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ],
            ),
          ),

          // Laxmi Didi over-budget warning — bilingual + voice
          if (isOverBudget)
            _OverBudgetWarning(cart: cart, dhanda: dhanda),

          // Items grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _StoreItemCard(item: items[i]),
            ),
          ),

          // Bottom checkout bar
          _buildCheckoutBar(context, controller, cart, dhanda, s),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, GameController controller, int cart, int dhanda, AppStrings s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.hasItemsInCart && cart <= dhanda
                  ? () => _checkout(context, controller)
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.turmeric),
              child: Text(
                cart > 0
                    ? (s.isHindi ? 'खरीदें ₹$cart 💳' : 'Checkout ₹$cart 💳')
                    : (s.isHindi ? 'कार्ट खाली है' : 'Cart is empty'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _doneShoppingWithScam(context, controller),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.divider),
              minimumSize: const Size(0, 52),
            ),
            child: Text(
              dhanda > 10
                  ? (s.isHindi ? 'बचत करें (Done)' : 'Save & Finish')
                  : (s.isHindi ? 'खरीदना खत्म' : 'Done Shopping'),
            ),
          ),
        ],
      ),
    );
  }

  void _checkout(BuildContext context, GameController controller) {
    final s = AppStrings.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UPIPracticeScreen(
          amount: controller.cartTotal,
          recipient: s.isHindi ? 'स्थानीय थोक व्यापारी' : 'Local Wholesaler',
          onSuccess: () {
            controller.checkout();
          },
        ),
      ),
    );
  }

  void _doneShoppingWithScam(BuildContext context, GameController controller) {
    controller.doneShoppingGoEndOfDay();
    if (controller.pendingScamEvent) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: const ScamGuardDialog(),
            ),
          );
        }
      });
    }
  }
}

// ── Over-budget warning with TTS ──────────────────────────────────────────────
class _OverBudgetWarning extends StatefulWidget {
  final int cart;
  final int dhanda;
  const _OverBudgetWarning({required this.cart, required this.dhanda});

  @override
  State<_OverBudgetWarning> createState() => _OverBudgetWarningState();
}

class _OverBudgetWarningState extends State<_OverBudgetWarning> {
  bool _spoken = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_spoken) {
        _spoken = true;
        final s = AppStrings.of(context);
        TtsService.instance.speakL(
          isHindi: s.isHindi,
          hindi: 'लक्ष्मी दीदी: बजट से ज़्यादा खर्चा हो रहा है! कुछ सामान हटाएं।',
          english: 'Laxmi Didi: You are spending over your budget! Remove some items.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorRed.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Text('👩', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s.isHindi
                  ? 'लक्ष्मी दीदी: बजट से ज़्यादा खर्चा हो रहा है! कुछ सामान कार्ट से हटाएं।'
                  : 'Laxmi Didi: You are spending over your budget! Remove some items from the cart.',
              style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Store Item Card ────────────────────────────────────────────────────────────
class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  const _StoreItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final s = AppStrings.of(context);
    final inCart = item.quantity > 0;
    final budget = controller.dhandaBalance;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: inCart ? AppColors.leafGreen : (item.isRecommended ? AppColors.turmeric.withAlpha(60) : AppColors.divider),
          width: inCart ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Badge
            if (item.isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.turmeric.withAlpha(30), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  s.isHindi ? '✨ ज़रूरी' : '✨ Essential',
                  style: const TextStyle(color: AppColors.turmeric, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              )
            else
              const SizedBox(height: 22),
            // Emoji
            Text(item.emoji, style: const TextStyle(fontSize: 40)),
            // Name
            Text(
              s.isHindi ? item.nameHindi : item.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 15),
            ),
            Text('₹${item.price}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: item.price > budget && item.quantity == 0 ? AppColors.errorRed : AppColors.leafGreen)),
            // Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: item.quantity > 0 ? () => context.read<GameController>().removeFromCart(item) : null,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: item.quantity > 0 ? AppColors.errorRed.withAlpha(20) : AppColors.divider.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.remove, color: item.quantity > 0 ? AppColors.errorRed : AppColors.divider, size: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ),
                GestureDetector(
                  onTap: () => context.read<GameController>().addToCart(item),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppColors.leafGreen.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add, color: AppColors.leafGreen, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
