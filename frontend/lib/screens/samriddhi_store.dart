import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../widgets/notification_overlay.dart';

class SamriddhiStoreScreen extends StatelessWidget {
  const SamriddhiStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardPoints = context.watch<GameController>().rewardPoints;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samriddhi Store'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Reward Points: $rewardPoints',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.75,
          children: [
            _buildStoreItem(context, 'School Books', 50, Icons.menu_book),
            _buildStoreItem(context, 'Seeds', 20, Icons.park),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreItem(BuildContext context, String title, int cost, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 64, color: Colors.green),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Cost: $cost pts',
              style: const TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                final success = context.read<GameController>().buyItemWithPoints(cost);
                if (success) {
                  NotificationOverlay.show(context, 'Asset Acquired!', isSuccess: true);
                } else {
                  NotificationOverlay.show(context, 'Not enough points to buy $title!', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Buy Now'),
            ),
          ],
        ),
      ),
    );
  }
}
