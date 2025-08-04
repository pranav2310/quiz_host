import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_host/home/new_question.dart';

class NewQuiz extends ConsumerStatefulWidget{
  const NewQuiz({super.key,required this.hostId});
  final String hostId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _NewQuizState();
  }
}

class _NewQuizState extends ConsumerState<NewQuiz>{
  final _formKey = GlobalKey<FormState>();
  final List<QuestionData> _questions = [QuestionData()];
  final TextEditingController _quizTitleController = TextEditingController();

  bool _isSubmitting = false;
  
  Future<void> addQuiz(Quiz quiz) async {
    final addQuizUrl = Uri.https(
      'iocl-quiz-host-default-rtdb.firebaseio.com',
      'quiz-list-${widget.hostId}.json',
    );

    final response = await http.post(
      addQuizUrl,
      body: json.encode(quiz.toJson()),
      headers: {'Content-Type':'application/json'}
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save quiz to Firebase.');
    }
  }

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
      _questions[idx].dispose();
      _questions.removeAt(idx);
    });
  }

  Future<void> _submitQuiz()async{
    if(!_formKey.currentState!.validate()){
      return;
    }
    for(var q in _questions){
      if(q.optionControllers.length<2){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Each Question must have Atleast 2 options')));
        return;
      }
      for(var op in q.optionControllers){
        if(op.text.trim().isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill out the options')));
          return;
        }
      }
      final title = _quizTitleController.text.trim();
      final questions = _questions.map((q){
        return Question(
          questionText: q.questionInputController.text, 
          options: q.optionControllers.map((o)=>o.text.trim()).toList()
        );
      }).toList();
      final newQuiz = Quiz(quizTitle: title, questions: questions);
      setState(() {
        _isSubmitting = true;
      });
      try{
        await addQuiz(newQuiz);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quiz Created Successfully')));
        _formKey.currentState!.reset();
        _quizTitleController.clear();
        for(final q in _questions){q.dispose();}
        _questions.clear();
        _questions.add(QuestionData());
        setState(() {});
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to Create Quiz $e.')));
      }
      finally{
        setState(() {
          _isSubmitting = true;
        });
      }
    }
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
              Center(child: Text(
                'Create a New Quiz',
                style: Theme.of(context).textTheme.titleLarge
              )),
              SizedBox(height: 16,),
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
              const SizedBox(height: 16),
              ..._questions.asMap().entries.map((entry){
                final idx = entry.key;
                final question = entry.value;
                return NewQuestion(
                  idx :idx, 
                  question :question,
                  addOption :()=>_addOption(idx),
                  removeOption :(optionIdx)=>_removeOption(idx, optionIdx),
                  removeQuestion :()=>_removeQuestion(idx),
                  totalQuestions :_questions.length
                );
              }),
              TextButton.icon(
                onPressed: _addQuestion, 
                label: Text('Add Question'),
                icon: Icon(Icons.add),
              ),
              const SizedBox(height: 30),
              _isSubmitting?
              const Center(child: CircularProgressIndicator(),)
              :ElevatedButton(
                onPressed: _submitQuiz,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 16.0),
                  child: const Text('Create Quiz'),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

class QuestionData{
  final TextEditingController questionInputController = TextEditingController();
  List<TextEditingController> optionControllers = [TextEditingController()];

  void dispose(){
    questionInputController.dispose();
    for(var opctrl in optionControllers){
      opctrl.dispose();
    }
  }
}