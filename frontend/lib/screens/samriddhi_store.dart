import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';

class SamriddhiStoreScreen extends StatelessWidget {
  const SamriddhiStoreScreen({super.key});

  static const _items = [
    {'name': 'Pencil Box', 'nameH': 'Pencil Box', 'cost': 30, 'emoji': '✏️', 'desc': 'Bacchon ke liye'},
    {'name': 'Notebook', 'nameH': 'Notebook', 'cost': 50, 'emoji': '📓', 'desc': 'Bacchon ke liye'},
    {'name': 'Geometry Box', 'nameH': 'Geometry Box', 'cost': 80, 'emoji': '📐', 'desc': 'School ke liye'},
    {'name': 'Seeds Packet', 'nameH': 'Beej Packet', 'cost': 20, 'emoji': '🌱', 'desc': 'Baag ke liye'},
    {'name': 'School Bag', 'nameH': 'School Bag', 'cost': 150, 'emoji': '🎒', 'desc': 'Bacchon ke liye'},
    {'name': 'Water Bottle', 'nameH': 'Paani Bottle', 'cost': 40, 'emoji': '🫙', 'desc': 'Roz kaam aati hai'},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final points = controller.rewardPoints;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.turmeric, Color(0xFFFF8F00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                const Text('Inaam Bhandar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26)),
                const Text('Apne sikke kharchein, asal cheezein paaein!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text('$points sikke', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final item = _items[i];
                final cost = item['cost'] as int;
                final canBuy = points >= cost;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: canBuy ? AppColors.turmeric.withAlpha(60) : AppColors.divider),
                    boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['emoji'] as String, style: const TextStyle(fontSize: 40)),
                        Column(
                          children: [
                            Text(item['nameH'] as String, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(item['desc'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.turmeric.withAlpha(20), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: AppColors.turmeric, size: 14),
                              const SizedBox(width: 4),
                              Text('$cost', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.turmeric)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: canBuy ? () => _confirmRedeem(context, controller, item) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canBuy ? AppColors.turmeric : AppColors.divider,
                            minimumSize: const Size(double.infinity, 36),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(canBuy ? 'Redeem' : 'Kam Sikke', style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRedeem(BuildContext context, GameController controller, Map item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${item['emoji']} ${item['nameH']} Redeem Karein?'),
        content: Text('${item['cost']} sikke kharch honge. Kya aap sure hain?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final success = controller.buyItemWithPoints(item['cost'] as int);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(success ? '🎉 ${item['name']} redeem hua! School mein dikhao!' : 'Sikke kam hain!'),
                backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.turmeric),
            child: const Text('Haan, Redeem'),
          ),
        ],
      ),
    );
  }
}
