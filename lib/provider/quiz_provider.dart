import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';

final quizListProvider = StreamProvider.family<List<Quiz>, String>((ref, hostId) {
  final refDb = FirebaseDatabase.instance.ref('quiz-list/$hostId');
  return refDb.onValue.map((event) {
    final data = event.snapshot.value;
    final List<Quiz> quizList = [];
    if (data != null && data is Map) {
      data.forEach((k, v) {
        if (v is Map) {
          quizList.add(Quiz.fromMap(v));
        }
      });
    }
    return quizList;
  });
});

final selectedQuizProvider = StateProvider<Quiz?>((ref) => null);
