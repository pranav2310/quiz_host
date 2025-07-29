import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/provider/main_screen_provider.dart';
import 'package:quiz_host/widgets/new_quiz.dart';
import 'package:quiz_host/widgets/quiz_description.dart';

class MainArea extends ConsumerStatefulWidget{
  const MainArea({super.key});

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
      NewQuiz():
      QuizDescription(
        selectedQuiz: selectedQuiz,
        constraints: MediaQuery.of(context).size,
      )
      ,
    );
  }
}