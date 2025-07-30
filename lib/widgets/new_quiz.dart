import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/provider/main_screen_provider.dart';

class NewQuiz extends ConsumerStatefulWidget{
  const NewQuiz({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _NewQuizState();
  }
}

class _NewQuizState extends ConsumerState<NewQuiz>{
  final _formKey = GlobalKey<FormState>();
  List<QuestionData> _questions = [QuestionData()];
  final TextEditingController _quizTitleController = TextEditingController();
  

  @override
  void dispose() {
    _quizTitleController.dispose();
    for(final q in _questions){
      q.dispose();
    }
    super.dispose();
  }

  void _addOption(int idx){
    setState(() {
      _questions[idx].optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int idx, int opidx){
    setState(() {
      _questions[idx].optionControllers[opidx].dispose();
      _questions[idx].optionControllers.removeAt(opidx);
    });
  }

  void _addQuestion(){
    setState(() {
      _questions.add(QuestionData());
    });
  }

  void _removeQuestion(int idx){
    setState(() {
      _questions.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Create a New Quiz',
                style: Theme.of(context).textTheme.titleLarge
              )),
              TextFormField(
                controller: _quizTitleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  hintText: 'Enter the name of the quiz',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ..._questions.asMap().entries.map((entry){
                final idx = entry.key;
                final question = entry.value;
                return _NewQuestion(idx, question);
              }),
              TextButton(onPressed: (){_addQuestion();}, child: Text('Add Question')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the data.
                    final title = _quizTitleController.text.trim();
                    final questions = _questions.map((q){
                      return Question(
                        questionText: q.questionInputController.text.trim(),
                        options: q.optionControllers.map((o)=>o.text.trim()).toList()
                      );
                    }).toList();
                    ref.read(quizProvider.notifier).addQuiz(Quiz(quizTitle: title, questions: questions));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Creating Quiz...')),
                    );
                  }
                },
                child: const Text('Create Quiz'),
              ),
            ],
          ),
        ),
      )
    );
  }
  Widget _NewQuestion(int idx, QuestionData question){
    return Card(
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
              if(_questions.length>1)
              IconButton(onPressed: (){_removeQuestion(idx);}, icon: Icon(Icons.delete)),
            ],
          ),
          ...question.optionControllers.asMap().entries.map((e){
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: question.optionControllers[e.key],
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
                IconButton(onPressed: (){_removeOption(idx, e.key);}, icon: Icon(Icons.remove))
              ],
            );
          }),
          TextButton.icon(onPressed: (){_addOption(idx);}, label: Text('Add Option'),icon: Icon(Icons.add),)
        ],
      ),
    );
  }
}


class QuestionData{
  final TextEditingController questionInputController = TextEditingController();
  List<TextEditingController> optionControllers = [TextEditingController()];

  void addOption(){
    optionControllers.add(TextEditingController());
  }

  void removeOption(int idx){
    optionControllers[idx].dispose();
    optionControllers.removeAt(idx);
  }

  void dispose(){
    questionInputController.dispose();
    for(var opctrl in optionControllers){
      opctrl.dispose();
    }
  }
}