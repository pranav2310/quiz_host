
import 'package:flutter/material.dart';
import 'package:quiz_host/home/new_quiz.dart';

class NewQuestion extends StatelessWidget{
    const NewQuestion({
      super.key,
      required this.idx,
      required this.question,
      required this.addOption,
      required this.removeOption,
      required this.removeQuestion,
      required this.totalQuestions,
    });
    final int idx;
    final QuestionData question;
    final VoidCallback addOption;
    final void Function(int) removeOption;
    final VoidCallback removeQuestion;
    final int totalQuestions;

    @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: question.questionInputController,
                    decoration: InputDecoration(
                      label: Text('Question ${idx+1}'),
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return 'Please Enter Question';
                      }
                      return null;
                    },
                  ),
                ),
                // const Spacer(),
                if(totalQuestions>1)
                IconButton(
                  onPressed: removeQuestion, 
                  icon: Icon(Icons.delete),
                  tooltip: 'Remove Question',
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            SizedBox(height: 8,),
            ...question.optionControllers.asMap().entries.map((e){
              final opIdx = e.key;
              final ctrl = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        decoration: InputDecoration(
                          label: Text('Option ${e.key+1}'),
                          helper: e.key== 0 ? Text('1st option is the correct ans of the question'):null
                        ),
                        validator: (value) {
                          if(value == null || value.isEmpty){
                          return 'Please Enter Valid Option';
                        }
                        return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8,),
                    if (question.optionControllers.length>1)
                    IconButton(
                      onPressed: ()=>removeOption(opIdx), 
                      icon: Icon(Icons.remove),
                      color: Theme.of(context).colorScheme.error,
                    )
                  ],
                ),
              );
            }),
            if(question.optionControllers.length<4)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: addOption, 
                label: Text('Add Option'),
                icon: Icon(Icons.add),
              )
            )
          ],
        ),
      ),
    );
  }

  }
