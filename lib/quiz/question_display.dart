import 'package:flutter/material.dart';
import 'package:quiz_host/models/quiz.dart';

class QuestionDisplay extends StatefulWidget {
  const QuestionDisplay({
    super.key,
    required this.question,
    required this.revealAnswer,
    required this.isHost
  });

  final Question question;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.question.questionText,
              style: Theme.of(context).textTheme.bodyLarge,
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
            return Card(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(shuffledOptions[idx]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
