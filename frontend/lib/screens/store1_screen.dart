import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';
import 'scam_guard_simulator.dart';

class Store1Screen extends StatelessWidget {
  const Store1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final items = controller.storeItems;
    final cart = controller.cartTotal;
    final dhanda = controller.dhandaBalance;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Tailoring Supplies 🧵'),
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
                Text('Dhanda budget: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                Text('₹$dhanda', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.turmeric)),
                const Spacer(),
                if (cart > 0) ...[
                  const Icon(Icons.shopping_cart, color: AppColors.kumkum, size: 18),
                  const SizedBox(width: 4),
                  Text('₹$cart', style: TextStyle(color: AppColors.kumkum, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ],
            ),
          ),

          // Laxmi Didi warning
          if (cart > dhanda)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorRed.withAlpha(60)),
              ),
              child: const Row(
                children: [
                  Text('👩', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Laxmi Didi: Budget se zyada kharcha ho raha hai! Kuch item cart se hatayein.',
                      style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

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
          _buildCheckoutBar(context, controller, cart, dhanda),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, GameController controller, int cart, int dhanda) {
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
              child: Text(cart > 0 ? 'Checkout ₹$cart 💳' : 'Cart Khali Hai', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
            child: const Text('Khareedna Khatam'),
          ),
        ],
      ),
    );
  }

  void _checkout(BuildContext context, GameController controller) {
    final success = controller.checkout();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? '✅ Khareedari safal! +1 sikka mila' : '❌ Paisa kam pada! -1 sikka'),
      backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
    ));
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

class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  const _StoreItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
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
                child: const Text('✨ Zaroori', style: TextStyle(color: AppColors.turmeric, fontSize: 11, fontWeight: FontWeight.w600)),
              )
            else
              const SizedBox(height: 22),
            // Emoji
            Text(item.emoji, style: const TextStyle(fontSize: 40)),
            // Name
            Text(item.nameHindi, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 15)),
            Text('₹${item.price}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: item.price > budget && item.quantity == 0 ? AppColors.errorRed : AppColors.leafGreen)),
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
