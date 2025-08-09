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

  factory Quiz.fromMap(Map<dynamic,dynamic> map){
    final questionsRaw = map['questions'];
    List<Question> questionList = [];
    if(questionsRaw is List){
      questionList = questionsRaw
      .where((q)=>q!=null)
      .map<Question>((q)=>Question.fromMap(Map<String,dynamic>.from(q))).toList();
    }
    return Quiz(
      quizId: map['quizId'],
      quizTitle: map['quizTitle'],
      questions: questionList
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
  final String questionText;
  final List<String> options; //first option is always correct
  
  Question({
    required this.questionText,
    required this.options
  });

  factory Question.fromMap(Map<dynamic,dynamic>map){
    final optionsRaw = map['options'];
    List<String> options = [];
    if(optionsRaw is List){
      options = optionsRaw.map((o)=>o?.toString()??'').toList();
    }
    return Question(
      questionText: map['questionText'], 
      options: options
    );
  }

  Map<String ,dynamic> toJson(){
    return {
      'questionText':questionText,
      'options': options.map((o)=>o).toList()
    };
  }

  static Question empty()=>Question(questionText: '' ,options: []);
}