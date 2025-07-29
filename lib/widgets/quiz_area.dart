import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/provider/quiz_screen_provider.dart';

class QuizArea extends ConsumerStatefulWidget{
  const QuizArea({
    super.key,
    required this.currentuestionIndex,
    required this.questionList
  });
  final int currentuestionIndex;
  final List<Question> questionList;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _QuizAreaState();
  }
}

class _QuizAreaState extends ConsumerState<QuizArea>{

  @override
  Widget build(BuildContext context) {
    int currentquestionIndex = ref.watch(questionIndexProvider);
    return Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question No. ${currentquestionIndex + 1} of ${widget.questionList.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.questionList[currentquestionIndex].questionText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...widget.questionList[currentquestionIndex].options.map((option){
              return RadioListTile(
                value: option, 
                groupValue: option, 
                onChanged: (value){},
                title: Text(option, 
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            })
          ],
        ),
      );
  }
}