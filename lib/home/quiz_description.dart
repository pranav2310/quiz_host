import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_host/quiz/quiz_screen.dart';

class QuizDescription extends ConsumerStatefulWidget{
  const QuizDescription({
    super.key,
    required this.hostId,
    required this.selectedQuiz,
    required this.constraints,
  });
  final String hostId;
  final Quiz selectedQuiz;
  final Size constraints;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _QuizDescriptionState();
  }
}

class _QuizDescriptionState extends ConsumerState<QuizDescription>{
  void _hostQuiz() async {
    final baseUrl = 'iocl-quiz-host-default-rtdb.firebaseio.com';
    final sessionUrl = Uri.https(baseUrl,'session.json');
    final sessionResponse = await http.get(sessionUrl);
    if(sessionResponse.statusCode != 200){
      throw Exception('Failed to fetch sessions');
    }
    final sessionData = json.decode(sessionResponse.body) as Map<String,dynamic>?;

    String? existingSessionId;
    String? state;

    if(sessionData != null){
      sessionData.forEach((id,session){
        if(session is Map){
          final String? quizId = session['quizId'];
          final String? sesstate = session['state'];
          if(quizId == widget.selectedQuiz.quizId && state != 'ended'){
            existingSessionId = session['sessionId'];
            state = sesstate;
          }
        }
      });
    }
    if(existingSessionId != null){
      Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx)=>QuizScreen(
        playerId: 'host01',
        sessionId: existingSessionId!,
        isHost: true,
      )));
      return;
    }

    final sessionId = List.generate(6, (_)=>'0123456789'[Random().nextInt(10)]).join();
    final sessionCreationUrl = Uri.https(
      baseUrl,
      'session/$sessionId.json'
    );
    final response = await http.put(
      sessionCreationUrl,
      body:json.encode({
        'sessionId': sessionId,
        'hostId': widget.hostId,
        'quizId': widget.selectedQuiz.quizId,
        'currentQuestion': 0,
        'state': 'waiting',
        'players': {}
      }),
      headers: {'Content-Type':'application/json'}
    );
    if(response.statusCode != 200 && response.statusCode != 201){
      throw Exception('Failed to create session');
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx)=>QuizScreen(
        playerId: 'host01',
        sessionId: sessionId,
        isHost: true,
      )));
  }
  bool showAnswers = false;
  @override
  Widget build(BuildContext context) {
    final selectedQuiz = widget.selectedQuiz;
    return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        selectedQuiz.quizTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.play_arrow),
                          onPressed: _hostQuiz, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                          ),
                          label: Text('Host Quiz'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(showAnswers? Icons.visibility_off : Icons.visibility),
                          onPressed: (){
                            setState(() {
                              showAnswers=!showAnswers;
                            });
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                          ),
                          label: Text(showAnswers ?'Hide Answers' :'Show Answers'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.edit),
                          onPressed: (){}, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                          ),
                          label: Text('Edit Quiz'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Questions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    ListView.builder(itemBuilder: (ctx, idx){
                      final question = selectedQuiz.questions[idx];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 6.0),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(question.questionText, style:Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold
                              )),
                              for(int opIdx=0; opIdx<question.options.length;opIdx++)
                                Padding(
                                  padding: EdgeInsets.only(left: 8,bottom: 4),
                                  child: Text(
                                    question.options[opIdx],
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: (opIdx==0 && showAnswers)?
                                        Colors.green:
                                        Theme.of(context).colorScheme.onSurface,
                                      fontWeight: (opIdx==0 && showAnswers)?FontWeight.bold:FontWeight.normal
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    }, 
                      itemCount: selectedQuiz.questions.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                    // Additional content for the selected quiz can go here
                  ],
                ),
              ),
            ),
          );
        },
      );
  }
}