import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/home/new_quiz.dart';
import 'package:quiz_host/home/quiz_description.dart';
import 'package:quiz_host/home/sidebar.dart';

class MainArea extends ConsumerStatefulWidget{
  const MainArea({
    super.key,
    required this.hostId,
    required this.quizList,
  });
  final String hostId;
  final List<Quiz> quizList;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MainAreaState();
  }
}

class _MainAreaState extends ConsumerState<MainArea>{

  @override
  Widget build(BuildContext context) {
    final selectedQuiz = ref.watch(selectedQuizProvider);
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: selectedQuiz == null ?
      NewQuiz(hostId: widget.hostId):
      QuizDescription(
        hostId: widget.hostId,
        selectedQuiz: selectedQuiz,
        constraints: MediaQuery.of(context).size,
      )
      ,
    );
  }
}