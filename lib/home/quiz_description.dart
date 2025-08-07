import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/home/question_card.dart';
import 'package:quiz_host/home/sidebar.dart';
import 'package:quiz_host/models/quiz.dart';
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
  Future<void> _deleteQuiz() async{
    final shouldDelete = await showDialog<bool>(
      context: context, 
      builder: (ctx)=> AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            }, 
            child: Text('Cancel')),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(true);
            }, 
            child: Text('Delete'))
        ],
      )
    );
    if(shouldDelete!=true)return;
    try{
      final quizRef = FirebaseDatabase.instance.ref('quiz-list/${widget.hostId}/${widget.selectedQuiz.quizId}');
      await quizRef.remove();
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quiz Deleted!!!')));
        ref.read(selectedQuizProvider.notifier).state = null;
      }
    }
    catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to Delete Quiz: $e')));
      }
    }
  }
  void _hostQuiz() async {
    try{
      final sessionRef = FirebaseDatabase.instance.ref('session');
      final sessionSnapshot = await sessionRef.get();
      if(sessionSnapshot.exists){
        final sessionData = sessionSnapshot.value as Map<String,dynamic>?;
        String? existingSessionId;
        if(sessionData != null){
          sessionData.forEach((id,session){
            if(session is Map){
              final String? quizId = session['quizId'];
              final String? sesstate = session['state'];
              if(quizId == widget.selectedQuiz.quizId && sesstate != 'ended'){
                existingSessionId = session['sessionId'];
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
      }
    
      final sessionId = List.generate(6, (_)=>'0123456789'[Random().nextInt(10)]).join();
      final sessionCreationRef = FirebaseDatabase.instance.ref('session/$sessionId');
      await sessionCreationRef.update({
          'sessionId': sessionId,
          'hostId': widget.hostId,
          'quizId': widget.selectedQuiz.quizId,
          'currentQuestion': 0,
          'state': 'waiting',
          'players': {}
        }
      );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx)=>QuizScreen(
          playerId: 'host01',
          sessionId: sessionId,
          isHost: true,
        )
      ));
    }catch(e){
      throw Exception('Session CreationError $e');
    }
  }
  bool showAnswers = false;
  Set<int> editQuesIdx = {};

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
                              vertical: 14, 
                              horizontal: 24
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: Text(showAnswers ?'Hide Answers' :'Show Answers'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14, 
                              horizontal: 24
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _deleteQuiz, 
                          label: Text('Delete Quiz'), 
                          icon: Icon(Icons.delete),
                        )
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
                      return QuestionCard(showAnswers: showAnswers, qidx: idx,quizId: widget.selectedQuiz.quizId,hostId: widget.hostId,);
                    }, 
                      itemCount: selectedQuiz.questions.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
  }
}