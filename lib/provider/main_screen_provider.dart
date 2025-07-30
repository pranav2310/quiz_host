import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/models/quiz_attempt.dart';
import 'package:http/http.dart' as http;

final showNewQuizProvider = StateProvider<bool>((ref)=>false);



final quizProvider = StateNotifierProvider<QuizNotifier, List<Quiz>>((ref) {
  return QuizNotifier();
});

class QuizNotifier extends StateNotifier<List<Quiz>>{
  QuizNotifier():super([]);

  final quizListUrl = Uri.https(
    'cybersecurityhandbook-default-rtdb.firebaseio.com',
    'quiz-list.json'
  );

  Future<void> loadQuizes() async {
    final response = await http.get(quizListUrl);
    if(response.statusCode>=400){
      throw Exception('Failed to Load Quiz ${response.statusCode}');
    }
    if(response.statusCode==null){
      state = [];
    }

    final decoded = json.decode(response.body);

    final quizList = <Quiz>[];

    (decoded as Map<String,dynamic>).forEach((key,val){
      quizList.add(Quiz.fromJson(val));
    });

    state = quizList;
  }
  Future<void> addQuiz(Quiz quiz) async {
    final addQuizUrl = Uri.https(
      'cybersecurityhandbook-default-rtdb.firebaseio.com',
      'quiz-list/${quiz.quizId}.json',
    );

    final response = await http.put(
      addQuizUrl,
      body: json.encode(quiz.toJson()),
      headers: {'Content-Type':'application/json'}
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save quiz to Firebase.');
    }

    state = [...state, quiz];
  }

  void removeQuiz(String quizId){
    state = state.where((q)=>q.quizId!=quizId).toList();
  }

  void updateQuiz(Quiz quiz){
    state = [
      for(final q in state)
      if (q.quizId==quiz.quizId)quiz
      else
      q
    ];
  }
}

final quizAttemptProvider = Provider<List<QuizAttempt>>((ref) {
  return dummyQuizAttempts;
});

final selectedQuizProvider = StateProvider<Quiz?>((ref) => null);