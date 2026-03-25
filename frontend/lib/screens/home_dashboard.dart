import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../widgets/notification_overlay.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
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
                      '₹${controller.unallocatedIncome}',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final amounts = [200, 450];
                        final newIncome = amounts[Random().nextInt(amounts.length)];
                        context.read<GameController>().startNewDay(newIncome);
                        NotificationOverlay.show(
                          context, 
                          'Naya din, naya faisla. Aaj ki kamai dekhein?', 
                          isSuccess: true
                        );
                      },
                      child: const Text('Start New Day'),
                    ),
                    const SizedBox(height: 16),
                     // Draggable income part
                    if (controller.unallocatedIncome > 0)
                      Draggable<int>(
                        data: 100, // Dragging fixed chunks 
                        feedback: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                            child: const Text('₹100', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: _buildIncomeChip('Dragging ₹100...'),
                        ),
                        child: _buildIncomeChip('Drag ₹100 to allocate'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDragTargetPot(context, 'Home', Icons.home, Colors.blue, controller.homePotBalance),
                const Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: Icon(Icons.compare_arrows, size: 40, color: Colors.grey),
                ),
                _buildDragTargetPot(context, 'Business', Icons.store, Colors.orange, controller.businessPotBalance),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Text(text, style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDragTargetPot(BuildContext context, String title, IconData icon, Color color, int balance) {
    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        final amount = details.data;
        context.read<GameController>().allocateIncome(title, amount);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return Column(
          children: [
            Container(
              width: 140,
              height: 160,
              decoration: BoxDecoration(
                color: isHovered ? color.withAlpha(76) : color.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isHovered ? color : color.withAlpha(128), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: color),
                  const SizedBox(height: 16),
                  Text(
                    title == 'Home' ? 'Ghar (Home)' : 'Dhanda (Business)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹$balance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
