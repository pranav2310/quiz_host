class Quiz {
  final String quizId;
  final String quizTitle;
  final List<Question> questions;

  const Quiz({
    required this.quizId,
    required this.quizTitle,
    required this.questions,
  });
}

class Question {
  final String qId;
  final String questionText;
  final List<String> options; //final option is always correct
  
  const Question({
    required this.qId,
    required this.questionText,
    required this.options
  });
}

final List<Quiz> dummyQuizzes = [
  Quiz(quizId: '123', quizTitle: 'Quiz 1', questions: [
    Question(qId: 'q1', questionText: 'q1',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q2', questionText: 'q2',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q3', questionText: 'q3',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q4', questionText: 'q4',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
  ]),
  Quiz(quizId: '234', quizTitle: 'Quiz 2', questions: [
    Question(qId: 'q1', questionText: 'q1',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q2', questionText: 'q2',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q3', questionText: 'q3',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q4', questionText: 'q4',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
  ]),
  Quiz(quizId: '345', quizTitle: 'Quiz 3', questions: [
    Question(qId: 'q1', questionText: 'q1',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q2', questionText: 'q2',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q3', questionText: 'q3',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q4', questionText: 'q4',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
  ]),
  Quiz(quizId: '456', quizTitle: 'Quiz 4', questions: [
    Question(qId: 'q1', questionText: 'q1',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q2', questionText: 'q2',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q3', questionText: 'q3',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
    Question(qId: 'q4', questionText: 'q4',options: ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
  ]),
];