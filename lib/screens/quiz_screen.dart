import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/widgets/quiz_area.dart';
import 'package:quiz_host/widgets/quiz_sidebar.dart';

class QuizScreen extends ConsumerStatefulWidget{
  const QuizScreen({
    super.key,
    required this.quizId,
    required this.token
  });
  final String quizId;
  final String token;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _QuizScreenState();
  }
}

class _QuizScreenState extends ConsumerState<QuizScreen>{
  late final Quiz _selectedQuiz;
  @override
  void initState() {
    super.initState();
    _selectedQuiz = dummyQuizzes.firstWhere((quiz)=>quiz.quizId == widget.quizId);
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int currentuestionIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedQuiz.quizTitle),
      ),
      endDrawer: screenWidth<640?Drawer(
        child: QuizSidebar(
          selectedQuiz: _selectedQuiz,
        ),
      ):null,
      body: screenWidth<640?
      QuizArea(currentuestionIndex: currentuestionIndex, questionList: _selectedQuiz.questions):
      Row(
        children: [
          Expanded(child: QuizArea(currentuestionIndex: currentuestionIndex, questionList: _selectedQuiz.questions)),
          SizedBox(width: screenWidth*0.25,child: QuizSidebar(selectedQuiz: _selectedQuiz))
        ],
      )
    );
  }
}