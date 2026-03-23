import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Section: Dainik Kamai
            Card(
              color: Colors.green.shade50,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.grass, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Bumper Harvest!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dainik Kamai (Daily Income)',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '₹450',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Middle Section: Do-Pote (Two-Pot) Wallet
            const Text(
              'Do-Pote (Two-Pot) Wallet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Drag and drop money to allocate funds',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPot(context, 'Ghar (Home)', Icons.home, Colors.blue),
                const Icon(Icons.compare_arrows, size: 40, color: Colors.grey),
                _buildPot(context, 'Dhanda (Business)', Icons.store, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPot(BuildContext context, String title, IconData icon, Color color) {
    return Container(
      width: 140,
      height: 160,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            '₹0',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
