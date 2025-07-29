import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/models/quiz_attempt.dart';

final showNewQuizProvider = StateProvider<bool>((ref)=>false);

final quizProvider = Provider<List<Quiz>>((ref) {
  return dummyQuizzes;
});

final quizAttemptProvider = Provider<List<QuizAttempt>>((ref) {
  return dummyQuizAttempts;
});

final selectedQuizProvider = StateProvider<Quiz?>((ref) => null);