import 'package:uuid/uuid.dart';

class Quiz {
  final String quizId;
  final String quizTitle;
  final List<Question> questions;

  Quiz({
    String? quizId,
    required this.quizTitle,
    required this.questions,
  }):quizId =quizId ?? Uuid().v4();

  factory Quiz.fromJson(Map<String,dynamic> json){
    return Quiz(
      quizId: json['quizId'],
      quizTitle: json['quizTitle'],
      questions: (json['questions'] as List<dynamic>).map((q)=>Question.fromJson(q as Map<String,dynamic>)).toList()
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'quizId': quizId,
      'quizTitle':quizTitle,
      'questions':questions.map((q)=>q.toJson()).toList()
    };
  }
}

class Question {
  final String qId;
  final String questionText;
  final List<String> options; //final option is always correct
  
  Question({
    String? qId,
    required this.questionText,
    required this.options
  }):qId =qId ?? Uuid().v4();

  factory Question.fromJson(Map<String,dynamic>json){
    return Question(
      questionText: json['questionText'], 
      options: (json['options'] as List<dynamic>).map((o)=>o as String).toList());
  }

  Map<String ,dynamic> toJson(){
    return {
      'qId': qId,
      'questionText':questionText,
      'options': options.map((o)=>o).toList()
    };
  }
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