import 'package:flutter/material.dart';

class LaxmiDidiChatScreen extends StatelessWidget {
  const LaxmiDidiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laxmi Didi - Aapki Vishwasniya Sahayak', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildBubble('Kya yeh loan app safe hai?', isUser: true),
                _buildBubble('Nahi, rindata suchi ki jaanch kar rahi hoon...', isUser: false),
              ],
            ),
          ),
          // Suggestions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSuggestionChip('Scam Check'),
                const SizedBox(width: 8),
                _buildSuggestionChip('Save Money'),
                const SizedBox(width: 8),
                _buildSuggestionChip('Market Price'),
              ],
            ),
          ),
          // Microphone
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
            child: FloatingActionButton.large(
              onPressed: () {},
              backgroundColor: Colors.orange,
              child: const Icon(Icons.mic, size: 48, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.green.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {},
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.green.shade300),
      ),
    );
  }
}
