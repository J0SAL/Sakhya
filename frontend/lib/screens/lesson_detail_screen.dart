import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/learning_lesson.dart';
import '../theme/app_theme.dart';

class LessonDetailScreen extends StatefulWidget {
  final LearningLesson lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool _showQuiz = false;
  int? _selectedOption;
  bool _answered = false;
  bool _usedHint = false;
  bool _showHint = false;

  void _answer(int idx) {
    if (_answered) return;
    setState(() {
      _selectedOption = idx;
      _answered = true;
    });
    final correct = idx == widget.lesson.correctIndex;
    context.read<GameController>().completeLesson(
      widget.lesson.id,
      correct: correct,
      usedHint: _usedHint,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Concept card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.warmCard(color: const Color(0xFFF3E8FF)),
              child: Column(
                children: [
                  Text(widget.lesson.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(widget.lesson.titleHindi, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF5E3A8A))),
                  const SizedBox(height: 16),
                  Text(widget.lesson.concept, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_showQuiz)
              ElevatedButton(
                onPressed: () => setState(() => _showQuiz = true),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B5EA7)),
                child: const Text('Quiz Try Karein 📝'),
              )
            else ...[
              Text('Sawal:', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              Text(widget.lesson.quizQuestion, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.4)),
              const SizedBox(height: 20),

              // Options
              ...List.generate(widget.lesson.options.length, (i) {
                Color? bg;
                Color border = AppColors.divider;
                if (_answered) {
                  if (i == widget.lesson.correctIndex) {
                    bg = AppColors.successGreen.withAlpha(20); border = AppColors.successGreen;
                  } else if (i == _selectedOption) {
                    bg = AppColors.errorRed.withAlpha(20); border = AppColors.errorRed;
                  }
                } else if (i == _selectedOption) {
                  bg = AppColors.leafGreen.withAlpha(15); border = AppColors.leafGreen;
                }

                return GestureDetector(
                  onTap: _answered ? null : () => _answer(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bg ?? AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: border.withAlpha(25), shape: BoxShape.circle),
                          child: Center(child: Text(String.fromCharCode(65 + i), style: TextStyle(fontWeight: FontWeight.w700, color: border, fontSize: 14))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(widget.lesson.options[i], style: Theme.of(context).textTheme.bodyLarge)),
                        if (_answered && i == widget.lesson.correctIndex)
                          const Icon(Icons.check_circle, color: AppColors.successGreen, size: 22),
                        if (_answered && i == _selectedOption && i != widget.lesson.correctIndex)
                          const Icon(Icons.cancel, color: AppColors.errorRed, size: 22),
                      ],
                    ),
                  ),
                );
              }),

              // Hint / result
              if (!_answered && !_showHint)
                TextButton.icon(
                  onPressed: () { setState(() { _showHint = true; _usedHint = true; }); },
                  icon: const Icon(Icons.support_agent, color: AppColors.turmeric),
                  label: const Text('Laxmi Didi se hint lo', style: TextStyle(color: AppColors.turmeric)),
                ),

              if (_showHint && !_answered)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.turmeric.withAlpha(15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.turmeric.withAlpha(60))),
                  child: Text('👩 Hint: ${widget.lesson.options[widget.lesson.correctIndex]} — dhyan se socho!', style: const TextStyle(color: AppColors.maatiBrown, fontWeight: FontWeight.w600)),
                ),

              if (_answered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (_selectedOption == widget.lesson.correctIndex ? AppColors.successGreen : AppColors.errorRed).withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selectedOption == widget.lesson.correctIndex ? AppColors.successGreen : AppColors.errorRed),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedOption == widget.lesson.correctIndex ? '🎉 Sahi jawab! +${_usedHint ? 1 : 2} sikke!' : '❌ Galat. -1 sikka.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16,
                          color: _selectedOption == widget.lesson.correctIndex ? AppColors.successGreen : AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Wapas Jaayein'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
