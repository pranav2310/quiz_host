import 'package:flutter/material.dart';

class NewQuiz extends StatefulWidget{
  const NewQuiz({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewQuizState();
  }
}

class _NewQuizState extends State<NewQuiz>{
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Quiz Name',
              hintText: 'Enter the name of the quiz',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a quiz name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Process the data.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creating Quiz...')),
                );
              }
            },
            child: const Text('Create Quiz'),
          ),
        ],
      )
    );
  }
}