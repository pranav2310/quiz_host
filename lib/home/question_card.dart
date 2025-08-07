import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    super.key,
    required this.showAnswers,
    required this.qidx,
    required this.quizId,
    required this.hostId
  });
  final bool showAnswers;
  final int qidx;
  final String quizId;
  final String hostId;

  @override
  State<StatefulWidget> createState() {
    return _QuestionCardState();
  }
}

class _QuestionCardState extends State<QuestionCard> {
  TextEditingController? questionController;
  List<TextEditingController>? optionControllers;
  bool isEditing = false;

  void _initControllers(Map rawQuesData){
    questionController = TextEditingController(text: rawQuesData['questionText']??'');
    final optionsRaw = rawQuesData['options'];
    final List<String> options = optionsRaw is List? optionsRaw.map((o)=>o?.toString()??'').toList():[];
    optionControllers = options.map((o)=>TextEditingController(text: o)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final questionRef = FirebaseDatabase.instance.ref('/quiz-list/${widget.hostId}/${widget.quizId}/questions/${widget.qidx}');
    return StreamBuilder<DatabaseEvent>(
      stream: questionRef.onValue,
      builder: (context, quesSnap) {
        if(quesSnap.hasError){
          return Center(child: Text('Error ${quesSnap.error}'),);
        }
        if(!quesSnap.hasData || !quesSnap.data!.snapshot.exists){
          return Center(child: CircularProgressIndicator(),);
        }
        final rawQuesData = quesSnap.data!.snapshot.value as Map;
        final String question = rawQuesData['questionText']??'';
        final List<String> options = List<String>.from(rawQuesData['options']);
        if(isEditing && (questionController == null || optionControllers == null)){
          _initControllers(rawQuesData);
        }
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.symmetric(vertical: 6.0),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: isEditing
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: questionController,
                              decoration: InputDecoration(label: Text('Question')),
                            ),
                            ...optionControllers!.asMap().entries.map((entry) {
                              final opIdx = entry.key;
                              final opCtrl = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: opCtrl,
                                        decoration: InputDecoration(
                                          label: Text('Option ${opIdx+1}'),
                                        ),
                                      ),
                                    ),
                                    if(optionControllers!.length>2)
                                    IconButton(onPressed: (){setState(() {
                                      optionControllers![opIdx].dispose();
                                      optionControllers!.removeAt(opIdx);
                                    });}, icon: Icon(Icons.remove))
                                  ],
                                ),
                              );
                            }).toList(),
                            if(optionControllers!.length<4)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: (){
                                  setState(() {
                                    optionControllers!.add(TextEditingController());
                                  });
                                }, 
                                label: Text('Add Option'), 
                                icon: Icon(Icons.add),),
                            )
                          ],
                        ): Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            for (
                              int opIdx = 0;
                              opIdx < options.length;
                              opIdx++
                            )
                              Padding(
                                padding: EdgeInsets.only(left: 8, bottom: 4),
                                child: Text(
                                  options[opIdx],
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: (opIdx == 0 && widget.showAnswers)
                                            ? Colors.green
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        fontWeight:
                                            (opIdx == 0 && widget.showAnswers)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                          ],
                        )
                ),
                IconButton(
                  tooltip: isEditing ? 'Save Question' : 'Edit Question',
                  onPressed: () async {
                    if (isEditing) {
                      if(optionControllers!.length<2){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Number of options must be more than 2')));
                        return;
                      }
                      final questionRef = FirebaseDatabase.instance.ref('/quiz-list/${widget.hostId}/${widget.quizId}/questions/${widget.qidx}');
                      await questionRef.update({
                        'questionText':questionController!.text,
                        'options': optionControllers!.map((ctrl)=>ctrl.text).toList()
                      });
                      setState(() {
                        isEditing = false;
                      });
                    } else {
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
                  icon: Icon(Icons.edit),
                ),
                if(isEditing)IconButton(onPressed: (){
                  setState(() {
                    isEditing = false;
                  });
                }, icon: Icon(Icons.cancel))
              ],
            ),
          ),
        );
      }
    );
  }
}
