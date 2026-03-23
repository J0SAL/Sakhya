import 'package:flutter/material.dart';

class SamriddhiStoreScreen extends StatelessWidget {
  const SamriddhiStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.account_balance_wallet, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Wallet: 800',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
            _buildStoreItem('School Books', 500, Icons.menu_book),
            _buildStoreItem('Seeds', 200, Icons.park),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreItem(String title, int cost, IconData icon) {
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
              'Cost: $cost',
              style: const TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {},
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
