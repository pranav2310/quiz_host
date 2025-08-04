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
    required this.sessionId,
    required this.isHost
  });
  final String sessionId;
  final bool isHost;

  @override
  State<StatefulWidget> createState() {
    return _QuizScreenState();
  }
}

class _QuizScreenState extends State<QuizScreen>{

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('session/${widget.sessionId}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Title'),
        actions: [
          TextButton(child:Text('Quiz Code: ${widget.sessionId}',),onPressed:(){
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
          switch(session.state){
            case(SessionState.waiting):
            return Waiting(sessionId: widget.sessionId, isHost: widget.isHost);
            case (SessionState.displayQuestion):
              return QuestionDisplay(question: Question(questionText: 'Random Question', options: ['Random Option','Random Option','Random Option','Random Option']),revealAnswer: false, isHost: widget.isHost);
            case (SessionState.revealAnswer):
              return QuestionDisplay(question: Question(questionText: 'Random Question', options: ['Random Option','Random Option','Random Option','Random Option']),revealAnswer: true, isHost: widget.isHost);
            case (SessionState.showLeaderBoard):
              return Leaderboard(playerData: session.players, isFinal: false, isHost: widget.isHost);
            case (SessionState.ended):
              return Leaderboard(playerData: session.players, isFinal: true, isHost: widget.isHost);
          }
          
        }
      )
    );
  }
}