import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/provider/quiz_screen_provider.dart';

class QuizSidebar extends ConsumerStatefulWidget {
  const QuizSidebar({
    super.key,
    required this.selectedQuiz,
  });

  final Quiz selectedQuiz;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _QuizSidebarState();
  }
}

class _QuizSidebarState extends ConsumerState<QuizSidebar>{
  @override
  Widget build(BuildContext context) {
    final selectedQuestion = ref.watch(questionIndexProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.secondary,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: widget.selectedQuiz.questions.length,
        itemBuilder: (ctx, idx) {
          final bool isSelected = idx == selectedQuestion;
          return InkWell(
            onTap: () {
              setState(() {
                ref.read(questionIndexProvider.notifier).state = idx;
              });
            },
            borderRadius: BorderRadius.circular(4),
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Card(
              margin: EdgeInsets.zero,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : null,
              child: Center(
                child: Text(
                  'Q${idx + 1}',
                  style: isSelected
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
