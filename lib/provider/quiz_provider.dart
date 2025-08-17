import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';

final mainScreenProvider = StateProvider<String>((ref) => 'mis');

class QuizState {
  final Quiz? quiz;
  final bool isLoading;

  QuizState({this.quiz, this.isLoading = false});

  QuizState copyWith({Quiz? quiz, bool? isLoading}) {
    return QuizState(
      quiz: quiz ?? this.quiz,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final Ref ref;
  final String hostId;

  QuizNotifier(this.ref, this.hostId) : super(QuizState());

  void setSelectedQuiz(Quiz quiz) {
    state = state.copyWith(quiz: quiz);
  }

  Future<void> updateQuestions(List<Question> updatedQuestions) async {
    if (state.quiz == null) return;

    state = state.copyWith(isLoading: true);

    final updatedQuiz = state.quiz!.copyWith(
      questions: updatedQuestions,
    );
    final questionsRef = FirebaseDatabase.instance.ref(
      'quiz-list/$hostId/${updatedQuiz.quizId}/questions',
    );

    await questionsRef.set(updatedQuestions.map((q) => q.toJson()).toList());

    state = state.copyWith(quiz: updatedQuiz, isLoading: false);
  }

  Future<void> addQuestion(Question question) async {
    final currentQuiz = state.quiz;
    if (currentQuiz == null) return;
    final newQuestions = [...currentQuiz.questions, question];
    await updateQuestions(newQuestions);
  }

  Future<void> editQuestion(int index, Question question) async {
    final currentQuiz = state.quiz;
    if (currentQuiz == null) return;
    final newQuestions = [...currentQuiz.questions];
    newQuestions[index] = question;
    await updateQuestions(newQuestions);
  }

  Future<void> deleteQuestion(int index) async {
    final currentQuiz = state.quiz;
    if (currentQuiz == null) return;
    final newQuestions = [...currentQuiz.questions]..removeAt(index);
    await updateQuestions(newQuestions);
  }

  void clearQuixSelection(){
    state = state.copyWith(quiz: null);
  }
}

final quizNotifierProvider =
    StateNotifierProvider.family<QuizNotifier, QuizState, String>(
        (ref, hostId) => QuizNotifier(ref, hostId));

