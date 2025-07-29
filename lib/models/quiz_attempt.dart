class QuizAttempt {
  final String quizId;
  final String userId;
  final DateTime submitTime = DateTime.now();
  final List<QuestionAttempt> questionAttempts;

  QuizAttempt({
    required this.quizId,
    required this.userId,
    required this.questionAttempts,
  });
}

class QuestionAttempt {
  final String questionId;
  final String userAnswer;

  const QuestionAttempt({
    required this.questionId,
    required this.userAnswer,
  });
}

final List<QuizAttempt> dummyQuizAttempts= [
  QuizAttempt(quizId: '123', userId: '121', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 4'),
  ]),
  QuizAttempt(quizId: '123', userId: '242', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 1'),
  ]),
  QuizAttempt(quizId: '123', userId: '484', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 2'),
  ]),
  QuizAttempt(quizId: '123', userId: '484', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 3'),
  ]),
  QuizAttempt(quizId: '234', userId: '121', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 4'),
  ]),
  QuizAttempt(quizId: '345', userId: '121', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 4'),
  ]),
  QuizAttempt(quizId: '456', userId: '121', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 4'),
  ]),
  QuizAttempt(quizId: '234', userId: '242', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 1'),
  ]),
  QuizAttempt(quizId: '345', userId: '242', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 1'),
  ]),
  QuizAttempt(quizId: '456', userId: '242', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 1'),
  ]),
  QuizAttempt(quizId: '234', userId: '484', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 2'),
  ]),
  QuizAttempt(quizId: '345', userId: '484', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 2'),
  ]),
  QuizAttempt(quizId: '456', userId: '484', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 3'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 2'),
  ]),
  QuizAttempt(quizId: '234', userId: '484', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 3'),
  ]),
  QuizAttempt(quizId: '345', userId: '484', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 3'),
  ]),
  QuizAttempt(quizId: '456', userId: '484', questionAttempts: [
    QuestionAttempt(questionId: 'q1', userAnswer: 'Option 4'),
    QuestionAttempt(questionId: 'q2', userAnswer: 'Option 1'),
    QuestionAttempt(questionId: 'q3', userAnswer: 'Option 2'),
    QuestionAttempt(questionId: 'q4', userAnswer: 'Option 3'),
  ]),
];
