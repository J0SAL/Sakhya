import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';

class SamriddhiStoreScreen extends StatelessWidget {
  const SamriddhiStoreScreen({super.key});

  static const _items = [
    {'name': 'Pencil Box',    'nameH': 'पेंसिल बॉक्स',   'cost': 30,  'emoji': '✏️', 'descH': 'बच्चों के लिए',   'descE': 'For children'},
    {'name': 'Notebook',      'nameH': 'नोटबुक',          'cost': 50,  'emoji': '📓', 'descH': 'बच्चों के लिए',   'descE': 'For children'},
    {'name': 'Geometry Box',  'nameH': 'ज्योमेट्री बॉक्स','cost': 80,  'emoji': '📐', 'descH': 'स्कूल के लिए',    'descE': 'For school'},
    {'name': 'Seeds Packet',  'nameH': 'बीज पैकेट',       'cost': 20,  'emoji': '🌱', 'descH': 'बगीचे के लिए',   'descE': 'For garden'},
    {'name': 'School Bag',    'nameH': 'स्कूल बैग',       'cost': 150, 'emoji': '🎒', 'descH': 'बच्चों के लिए',   'descE': 'For children'},
    {'name': 'Water Bottle',  'nameH': 'पानी की बोतल',    'cost': 40,  'emoji': '🫙', 'descH': 'रोज़ काम आती है',  'descE': 'Everyday use'},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final s = AppStrings.of(context);
    final points = controller.rewardPoints;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.turmeric, Color(0xFFFF8F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  s.isHindi ? 'इनाम भंडार' : 'Rewards Store',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26),
                ),
                Text(
                  s.isHindi
                      ? 'अपने सिक्के खर्च करें, असली चीज़ें पाएं!'
                      : 'Spend your coins, earn real rewards!',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        s.isHindi ? '$points सिक्के' : '$points coins',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                      ),
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final item = _items[i];
                final cost = item['cost'] as int;
                final canBuy = points >= cost;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: canBuy ? AppColors.turmeric.withAlpha(60) : AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['emoji'] as String,
                            style: const TextStyle(fontSize: 40)),
                        Column(
                          children: [
                            Text(
                              s.isHindi ? item['nameH'] as String : item['name'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.isHindi ? item['descH'] as String : item['descE'] as String,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.turmeric.withAlpha(20),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: AppColors.turmeric, size: 14),
                              const SizedBox(width: 4),
                              Text('$cost',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, color: AppColors.turmeric)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              canBuy ? () => _confirmRedeem(context, controller, item, s) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canBuy ? AppColors.turmeric : AppColors.divider,
                            minimumSize: const Size(double.infinity, 36),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            canBuy
                                ? (s.isHindi ? 'Redeem करें' : 'Redeem')
                                : (s.isHindi ? 'सिक्के कम' : 'Not enough'),
                            style: const TextStyle(fontSize: 13),
                          ),
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

  void _confirmRedeem(
      BuildContext context, GameController controller, Map item, AppStrings s) {
    final name = s.isHindi ? item['nameH'] as String : item['name'] as String;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${item['emoji']} $name'),
        content: Text(
          s.isHindi
              ? '${item['cost']} सिक्के खर्च होंगे। क्या आप sure हैं?'
              : '${item['cost']} coins will be spent. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final success = controller.buyItemWithPoints(item['cost'] as int);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(success
                    ? (s.isHindi
                        ? '$name redeem हुआ! स्कूल में दिखाएं!'
                        : '$name redeemed! Show it at school!')
                    : (s.isHindi ? 'सिक्के कम हैं!' : 'Not enough coins!')),
                backgroundColor:
                    success ? AppColors.successGreen : AppColors.errorRed,
              ));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.turmeric),
            child: Text(s.isHindi ? 'हाँ, Redeem' : 'Yes, Redeem'),
          ),
        ],
      ),
    );
  }
}
