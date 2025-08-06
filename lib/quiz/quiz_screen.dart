import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/models/session.dart';
import 'package:quiz_host/quiz/leaderboard.dart';
import 'package:quiz_host/quiz/question_display.dart';
import 'package:quiz_host/quiz/waiting.dart';

class QuizScreen extends StatefulWidget{
  const QuizScreen({
    super.key,
    required this.playerId,
    required this.sessionId,
    required this.isHost
  });
  final String playerId;
  final String sessionId;
  final bool isHost;

  @override
  State<StatefulWidget> createState() {
    return _QuizScreenState();
  }
}

class _QuizScreenState extends State<QuizScreen>{
  Future<Quiz> fetchQuiz(String hostId, String quizId)async{
    final quizRef = FirebaseDatabase.instance.ref('quiz-list/$hostId/$quizId');
    final quizSnapshot = await quizRef.get();
    if (!quizSnapshot.exists || quizSnapshot.value == null) {
      throw Exception('Quiz not found');
    }
    final quizData = json.decode(json.encode(quizSnapshot.value)) as Map<String, dynamic>;
    return Quiz.fromJson(quizData);
  }
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('session/${widget.sessionId}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Title'),
        actions: [
          TextButton(child:Text('Quiz Code: ${widget.sessionId}',style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),),onPressed:(){
            Clipboard.setData(ClipboardData(text: widget.sessionId));
          })
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue, 
        builder: (context, snapshot){
          if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if(!snapshot.hasData || !snapshot.data!.snapshot.exists){
            return Center(child: CircularProgressIndicator(),);
          }
          final dataMap = Map<String,dynamic>.from(snapshot.data!.snapshot.value as Map);
          final session = Session.fromJson(Map<String,dynamic>.from(dataMap));

          return FutureBuilder(
            future: fetchQuiz(session.hostId, session.quizId), 
            builder: (context, quizSnapshot){
              if (quizSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (quizSnapshot.hasError) {
                return Center(child: Text('Failed to load quiz: ${quizSnapshot.error}'));
              }
              final quiz = quizSnapshot.data!;
              final currentQuestionIndex = session.currentQuestion;
              bool finalQ = false;
              var currentQuestion;
              if (currentQuestionIndex >= quiz.questions.length) {
                finalQ = true;
              }
              else{
                currentQuestion = quiz.questions[session.currentQuestion];
              }
              switch(session.state){
            case(SessionState.waiting):
            return Waiting(
              sessionId: widget.sessionId, 
              isHost: widget.isHost
            );
            case (SessionState.displayQuestion):
              Question quesToDisplay = currentQuestion;
              return QuestionDisplay(
                sessionId : widget.sessionId,
                playerId: widget.playerId,
                question:quesToDisplay ,
                currentQuestionIndex: currentQuestionIndex,
                revealAnswer: false, 
                isHost: widget.isHost
              );
            case (SessionState.revealAnswer):
              Question quesToDisplay = currentQuestion;
              return QuestionDisplay(
                sessionId : widget.sessionId,
                playerId: widget.playerId,
                question:quesToDisplay ,
                currentQuestionIndex: currentQuestionIndex,
                revealAnswer: true, 
                isHost: widget.isHost
              );
            case (SessionState.showLeaderBoard):
              return Leaderboard(
                sessionId: widget.sessionId,
                playerData: session.players, 
                isFinal: finalQ, 
                isHost: widget.isHost
              );
            case (SessionState.ended):
              return Leaderboard(
                sessionId: widget.sessionId,
                playerData: session.players, 
                isFinal: finalQ, 
                isHost: widget.isHost
              );
          }
            }
          );
          
        }
      )
    );
  }
}