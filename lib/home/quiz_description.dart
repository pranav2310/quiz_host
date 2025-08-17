import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quiz_host/home/widgets/question_card.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/provider/dashboard_controller.dart';
import 'package:quiz_host/provider/quiz_provider.dart';

class QuizDescription extends ConsumerStatefulWidget {
  const QuizDescription({
    super.key,
    required this.hostId,
  });
  final String hostId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _QuizDescriptionState();
  }
}

class _QuizDescriptionState extends ConsumerState<QuizDescription> {

  bool showAnswers = false;
  Set<int> editQuesIdx = {};

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(dashboardControllerProvider(widget.hostId).notifier);
    final quizNotifier = ref.watch(quizNotifierProvider(widget.hostId).notifier);
    final quizState = ref.watch(quizNotifierProvider(widget.hostId));
    final selectedQuiz = quizState.quiz;

    if(selectedQuiz == null){
      return const Center(child: Text('No Quiz Selected'),);
    }

    final quizCreationDate = selectedQuiz.createdOn != null?DateFormat('dd MM yyyy').format(selectedQuiz.createdOn!):'Unknown Date';
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            selectedQuiz.quizTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              icon: Icons.play_arrow,
              label: 'Host Quiz',
              onPressed: (){controller.hostQuiz(selectedQuiz);},
            ),
            _buildActionButton(
              icon: showAnswers ? Icons.visibility_off : Icons.visibility,
              label: showAnswers ? 'Hide Answers' : 'Show Answers',
              onPressed: () {
                setState(() {
                  showAnswers = !showAnswers;
                });
              },
            ),
            _buildActionButton(
              icon: Icons.delete,
              label: 'Delete Quiz',
              onPressed: (){controller.deleteQuiz(selectedQuiz.quizId);},
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Created On: $quizCreationDate',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Questions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: selectedQuiz.questions.length,
          itemBuilder: (ctx, idx) {
            return QuestionCard(
              showAnswers: showAnswers,
              quesIdx: idx,
              quizId: selectedQuiz.quizId,
              hostId: widget.hostId,
              question: selectedQuiz.questions[idx],
              onDelete: () => quizNotifier.deleteQuestion(idx),
              onSave: (updatedQuestion) =>
                  quizNotifier.editQuestion(idx, updatedQuestion),
            );
          },
        ),
        ElevatedButton.icon(
          onPressed: (){
            setState(() {
              quizNotifier.addQuestion(
                Question(questionText: 'New Question', options: ['option','option'])
              );
            });
          },
          label: Text('Add a Question'),
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
