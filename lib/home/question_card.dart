import 'package:flutter/material.dart';
import 'package:quiz_host/models/quiz.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    super.key,
    required this.showAnswers,
    required this.quesIdx,
    required this.quizId,
    required this.hostId,
    required this.question,
    required this.onDelete,
    required this.onSave
  });
  final bool showAnswers;
  final int quesIdx;
  final String quizId;
  final String hostId;
  final Question question;
  final VoidCallback onDelete;
  final Function(Question updated) onSave;

  @override
  State<StatefulWidget> createState() {
    return _QuestionCardState();
  }
}

class _QuestionCardState extends State<QuestionCard> {
  TextEditingController? questionController;
  List<TextEditingController>? optionControllers;
  bool isEditing = false;

  void _initControllers(Question ques){
    questionController = TextEditingController(text: widget.question.questionText);
    final optionsRaw = widget.question.options;
    final List<String> options = optionsRaw.map((o)=>o).toList();
    optionControllers = options.map((o)=>TextEditingController(text: o)).toList();
  }

  void _saveLocal(){
    if(questionController!.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Question Field cannot be empty')));
      return;
    }
    if(optionControllers!.length<2 || optionControllers!.any((op)=>op.text.trim().isEmpty)){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Fill at least 2 valid Options')));
      return;
    }
    final updated = Question(questionText: questionController!.text, options: optionControllers!.map((op)=>op.text.trim()).toList());
    widget.onSave(updated);
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
        if(isEditing && (questionController == null || optionControllers == null)){
          _initControllers(widget.question);
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
                              widget.question.questionText,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            for (
                              int opIdx = 0;
                              opIdx < widget.question.options.length;
                              opIdx++
                            )
                              Padding(
                                padding: EdgeInsets.only(left: 8, bottom: 4),
                                child: Text(
                                  widget.question.options[opIdx],
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
                Column(
                  children: [
                    IconButton(
                      tooltip: isEditing ? 'Save Question' : 'Edit Question',
                      onPressed: () async {
                        if (isEditing) {
                          _saveLocal();
                        } else {
                          setState(() {
                            isEditing = true;
                          });
                        }
                      },
                      icon: Icon(isEditing ? Icons.save : Icons.edit),
                    ),
                    IconButton(
                      tooltip: 'Delete Question',
                      onPressed: widget.onDelete, 
                      icon: Icon(Icons.delete)),
                  ],
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
    // );
  // }
}
