import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quiz_host/models/quiz.dart';

class QuestionDisplay extends StatefulWidget {
  const QuestionDisplay({
    super.key,
    required this.sessionId,
    required this.playerId,
    required this.question,
    required this.currentQuestionIndex,
    required this.revealAnswer,
    required this.isHost
  });
  final String sessionId;
  final String playerId;
  final Question question;
  final int currentQuestionIndex;
  final bool revealAnswer;
  final bool isHost;

  @override
  State<StatefulWidget> createState() => _QuestionDisplayState();
}

class _QuestionDisplayState extends State<QuestionDisplay> {
  late List<String> shuffledOptions;

  @override
  void initState() {
    super.initState();
    shuffledOptions = List<String>.from(widget.question.options)..shuffle();
  }

  String? _selectedOption;
  bool _submitedOnce = false;

  void _nextScreen(){
      final sessionRef = FirebaseDatabase.instance.ref('session/${widget.sessionId}');
      try{
        sessionRef.update({
          'state':'showLeaderBoard',
          'currentQuestion' : widget.currentQuestionIndex+1
        });
      }catch(e){
        throw Exception('Error $e');
      }
    }

    void _submitAns() async {
      final playerRef = FirebaseDatabase.instance.ref('session/${widget.sessionId}/players/${widget.playerId}');
      
      final currentScoreSnap = await playerRef.child('score').get();
      int currentScore = 0;
      if(currentScoreSnap.exists && currentScoreSnap.value is int){
        currentScore = currentScoreSnap.value as int;
      }
      if(_selectedOption == widget.question.options[0]){
        await playerRef.update({'score':currentScore + 1});
      }
      setState(() {
        _submitedOnce = true;
      });
    }

    void _revealAnswer(){
      final sessionRef = FirebaseDatabase.instance.ref('session/${widget.sessionId}');
      try{
        sessionRef.update({
          'state':'revealAnswer'
        });
      }
      catch(e){
        throw Exception('Error : $e');
      }
    }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Theme.of(context).colorScheme.surface,
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.question.questionText,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true, // Important to avoid infinite height error
            physics: const NeverScrollableScrollPhysics(), // Disable inner scroll
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3, // Adjust for card height/width ratio
            ),
            itemCount: shuffledOptions.length,
            itemBuilder: (ctx, idx) {
              bool isCorrectOption = widget.question.options[0] == shuffledOptions[idx];
              bool isSelected = _selectedOption == shuffledOptions[idx];
              Color cardColor;
              if (widget.revealAnswer){
                  cardColor = isCorrectOption ? Colors.green.withOpacity(.2): Colors.white;
              }
              else{
                cardColor = isSelected? Theme.of(context).colorScheme.secondary.withOpacity(0.2):Colors.white;
              }
              
              return InkWell(
                onTap: (){
                  setState(() {
                    _selectedOption = shuffledOptions[idx];
                  });
                },
                onHover:(value) {},
                child: Card(
                  color: cardColor,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        shuffledOptions[idx],
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: 
                            Theme.of(context).colorScheme.onSurface
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16,),
          widget.isHost ? Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface
              ),
              onPressed: (){
                widget.revealAnswer
                ?_nextScreen()
                :_revealAnswer();
            }, child: Text(widget.revealAnswer?'Show Leaderboard':'Reveal Answer')),
          ):
          widget.revealAnswer ?
          SizedBox.shrink():
          ElevatedButton(
            onPressed: _submitedOnce? null :_submitAns, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface
            ),
            child: Text('Submit Answer'),
          )
        ],
      ),
    );
  }
}
