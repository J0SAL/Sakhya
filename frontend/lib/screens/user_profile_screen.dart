import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 64,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rural Entrepreneur',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Member since March 2026',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Financial Stats',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatCard(Icons.home, 'Home Pot Total', '₹${controller.homePotBalance}', Colors.blue),
            const SizedBox(height: 12),
            _buildStatCard(Icons.store, 'Business Total', '₹${controller.businessPotBalance}', Colors.orange),
            const SizedBox(height: 12),
            _buildStatCard(Icons.stars, 'Lifetime Points', '${controller.rewardPoints} pts', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
