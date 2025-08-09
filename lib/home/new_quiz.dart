import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/home/new_question.dart';
import 'package:uuid/uuid.dart';

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
  List<QuestionData> _questions = [QuestionData()];
  final TextEditingController _quizTitleController = TextEditingController();

  bool _isSubmitting = false;
  
  Future<void> addQuiz(Quiz quiz) async {
    final quizRef = FirebaseDatabase.instance.ref('quiz-list/${widget.hostId}/${quiz.quizId}');
    await quizRef.update(quiz.toJson());
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
  Future<void> _submitQuiz() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSubmitting = true);

  try {
    // Validation
    for (final q in _questions) {
      if (q.optionControllers.length < 2) {
        throw Exception('Each question must have at least 2 options');
      }
      if (q.questionInputController.text.trim().isEmpty) {
        throw Exception('Please fill out all questions');
      }
      for (final op in q.optionControllers) {
        if (op.text.trim().isEmpty) {
          throw Exception('Please fill out all options');
        }
      }
    }

    final quizId = Uuid().v4();
    final title = _quizTitleController.text.trim();

    // Build questions as a LIST
    final questionsList = _questions.asMap().entries.map((entry) {

      final q = entry.value;

      return {
        'questionText': q.questionInputController.text,
        'options': q.optionControllers.map((op) => op.text).toList(),
      };
    }).toList();

    final newQuizData = {
      'quizId': quizId,
      'quizTitle': title,
      'questions': questionsList,
    };

    final newQuizRef =
        FirebaseDatabase.instance.ref('quiz-list/${widget.hostId}/$quizId');
    await newQuizRef.set(newQuizData);

    // Reset form
    _formKey.currentState?.reset();
    setState(() {
      _questions = [QuestionData()];
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Quiz Created!')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    setState(() => _isSubmitting = false);
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
  List<TextEditingController> optionControllers = [TextEditingController(),TextEditingController()];

  void dispose(){
    questionInputController.dispose();
    for(var opctrl in optionControllers){
      opctrl.dispose();
    }
  }
}