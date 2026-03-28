import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/learning_lesson.dart';
import '../theme/app_theme.dart';
import 'lesson_detail_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final lessons = controller.lessons;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7B5EA7), Color(0xFF5E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('📚', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Seekhne Ka Safar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    Text(
                      '${lessons.where((l) => l.isCompleted).length}/${lessons.length} lessons poore',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Duolingo-style lesson path
          _buildLessonPath(context, lessons),
        ],
      ),
    );
  }

  Widget _buildLessonPath(BuildContext context, List<LearningLesson> lessons) {
    return Column(
      children: List.generate(lessons.length, (i) {
        final lesson = lessons[i];
        final isLeft = i.isEven;
        // Zigzag layout
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  if (!isLeft) const Spacer(),
                  _LessonNode(lesson: lesson, index: i),
                  if (isLeft) const Spacer(),
                ],
              ),
              if (i < lessons.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: isLeft ? 40 : 0, right: isLeft ? 0 : 40),
                  child: Column(
                    children: List.generate(3, (_) => Container(
                      width: 3, height: 8, margin: const EdgeInsets.symmetric(vertical: 2),
                      color: lesson.isCompleted ? AppColors.leafGreen.withAlpha(60) : AppColors.divider,
                    )),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final LearningLesson lesson;
  final int index;
  const _LessonNode({required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) {
    final isLocked = !lesson.isUnlocked;
    final isCompleted = lesson.isCompleted;
    final isCurrent = lesson.isUnlocked && !lesson.isCompleted;

    Color bg;
    Color borderColor;
    if (isCompleted) {
      bg = AppColors.leafGreen;
      borderColor = AppColors.deepGreen;
    } else if (isCurrent) {
      bg = AppColors.turmeric;
      borderColor = AppColors.kumkum;
    } else {
      bg = AppColors.divider.withAlpha(80);
      borderColor = AppColors.divider;
    }

    return GestureDetector(
      onTap: isLocked ? null : () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
          value: context.read<GameController>(),
          child: LessonDetailScreen(lesson: lesson),
        )));
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: isCurrent ? 4 : 2),
              boxShadow: isCurrent ? [BoxShadow(color: AppColors.turmeric.withAlpha(80), blurRadius: 16, offset: const Offset(0, 4))] : [],
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock, color: Colors.white54, size: 32)
                  : Text(lesson.emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: Text(
              lesson.titleHindi,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 12,
                color: isLocked ? AppColors.textSecondary.withAlpha(100) : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
