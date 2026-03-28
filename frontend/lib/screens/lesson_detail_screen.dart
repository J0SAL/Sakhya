import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/learning_lesson.dart';
import '../services/tts_service.dart';
import '../theme/app_strings.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = AppStrings.of(context);
      final localLesson = s.lessonOf(widget.lesson.id);
      TtsService.instance.speakL(
        isHindi: s.isHindi,
        hindi: localLesson?.concept ?? widget.lesson.concept,
        english: localLesson?.concept ?? widget.lesson.concept,
      );
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

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
    final s = AppStrings.of(context);
    final coins = _usedHint ? 1 : 2;
    if (correct) {
      TtsService.instance.speakL(
        isHindi: s.isHindi,
        hindi: 'शाबाश! सही जवाब! +$coins सिक्का मिला!',
        english: 'Well done! Correct answer! +$coins coin earned!',
      );
    } else {
      TtsService.instance.speakL(
        isHindi: s.isHindi,
        hindi: 'गलत जवाब। -1 सिक्का। फिर कोशिश करें।',
        english: 'Wrong answer. -1 coin. Try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        leading: const BackButton(color: Colors.white),
        actions: [
          // Replay TTS button
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            tooltip: 'Sunein',
            onPressed: () {
              if (_showQuiz && !_answered) {
                TtsService.instance.speak(widget.lesson.quizQuestion);
              } else {
                TtsService.instance.speak(widget.lesson.concept);
              }
            },
          ),
        ],
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
              child: Builder(builder: (ctx) {
                final localLesson = AppStrings.of(ctx).lessonOf(widget.lesson.id);
                final title = localLesson?.titleNative ?? widget.lesson.titleHindi;
                final concept = localLesson?.concept ?? widget.lesson.concept;
                return Column(
                  children: [
                    Text(widget.lesson.emoji, style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF5E3A8A))),
                    const SizedBox(height: 16),
                    Text(concept, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6), textAlign: TextAlign.center),
                  ],
                );
              }),
            ),
            const SizedBox(height: 24),

            if (!_showQuiz)
              Builder(builder: (ctx) {
                final s = AppStrings.of(ctx);
                return ElevatedButton(
                  onPressed: () {
                    setState(() => _showQuiz = true);
                    final localLesson = s.lessonOf(widget.lesson.id);
                    TtsService.instance.speak(localLesson?.question ?? widget.lesson.quizQuestion);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B5EA7)),
                  child: Text(s.startQuizButton),
                );
              })
            else ...[
              Builder(builder: (ctx) {
                final s = AppStrings.of(ctx);
                final localLesson = s.lessonOf(widget.lesson.id);
                final question = localLesson?.question ?? widget.lesson.quizQuestion;
                final opts = localLesson?.options ?? widget.lesson.options;
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.questionLabel, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(question, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.4)),
                  const SizedBox(height: 20),

                  // Options
                  ...List.generate(opts.length, (i) {
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
                            Expanded(child: Text(opts[i], style: Theme.of(context).textTheme.bodyLarge)),
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
                      onPressed: () {
                        setState(() { _showHint = true; _usedHint = true; });
                        TtsService.instance.speak(
                            '${s.hintLabel}: ${opts[widget.lesson.correctIndex]}');
                      },
                      icon: const Icon(Icons.support_agent, color: AppColors.turmeric),
                      label: Text(s.laxmiHintButton, style: const TextStyle(color: AppColors.turmeric)),
                    ),

                  if (_showHint && !_answered)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.turmeric.withAlpha(15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.turmeric.withAlpha(60))),
                      child: Text('👩 ${s.hintLabel}: ${opts[widget.lesson.correctIndex]}', style: const TextStyle(color: AppColors.maatiBrown, fontWeight: FontWeight.w600)),
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
                      child: Text(
                        _selectedOption == widget.lesson.correctIndex
                            ? s.correctAnswer(_usedHint ? 1 : 2)
                            : s.wrongAnswer,
                        style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16,
                          color: _selectedOption == widget.lesson.correctIndex ? AppColors.successGreen : AppColors.errorRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(s.goBackButton),
                    ),
                  ],
                ]);
              }),
            ],
          ],
        ),
      ),
    );
  }
}
