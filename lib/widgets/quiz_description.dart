import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'dart:html' as html;
String? hostname = html.window.location.hostname; // e.g., 'your-app.vercel.app'
String protocol = html.window.location.protocol; // 'https:' (for scheme)
String port = html.window.location.port; // often '' (empty) for 443/80

// If port is empty, DON'T include it in the generated link URI.



class QuizDescription extends ConsumerStatefulWidget{
  const QuizDescription({
    super.key,
    required this.selectedQuiz,
    required this.constraints,
  });
  final Quiz selectedQuiz;
  final Size constraints;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _QuizDescriptionState();
  }
}

class _QuizDescriptionState extends ConsumerState<QuizDescription>{
    String? _token;
    String? _linkToQuiz;
  @override
  Widget build(BuildContext context) {
    String _randomToken(){
      String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final rand = Random.secure();
      return List.generate(24, (_)=>chars[rand.nextInt(chars.length)]).join();
    }
    void generateLink(){
      String token = _randomToken();
      final quizId = widget.selectedQuiz.quizId;
      final link = Uri(
        scheme: protocol,
        host: hostname,
        // port: int.tryParse(port),
        path: '/',
        fragment: '/quiz/$quizId?token=$token',
      ).toString();
      setState(() {
        _linkToQuiz = link;
        _token = token;
      });
      Clipboard.setData(ClipboardData(text: link));
    }
    final selectedQuiz = widget.selectedQuiz;
    return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedQuiz.quizTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      // fontSize: (24 * (constraints.maxWidth / 160)).clamp(20.0, 32.0),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: generateLink, 
                    label: Text('Generate Quiz Link'),
                    icon: Icon(Icons.link),
                  ),
                  if(_linkToQuiz!=null) ...[
                    const SizedBox(height: 20),
                    SelectableText(
                      _linkToQuiz!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        // fontSize: (16 * (constraints.maxWidth / 160)).clamp(14.0, 24.0),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onTap: () => Clipboard.setData(ClipboardData(text: _linkToQuiz!)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(onPressed: (){Clipboard.setData(ClipboardData(text: _linkToQuiz!));}, icon: Icon(Icons.copy),label: Text('Copy Link'),),
                  ],
                  const SizedBox(height: 20),
                  Text('Leaderboard',style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),),
                  const SizedBox(height: 20),
                  Text(
                    'Questions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      // fontSize: (20 * (constraints.maxWidth / 160)).clamp(16.0, 28.0),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  ListView.builder(itemBuilder: (ctx, idx){
                    final question = selectedQuiz.questions[idx];
                    return Card(
                      child: ListTile(
                        title: Text(
                          question.questionText,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            // fontSize: (16 * (constraints.maxWidth / 160)).clamp(14.0, 24.0),
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: ListView.builder(
                          itemBuilder: (ctx, optIdx) {
                            final option = question.options[optIdx];
                            return Text(
                              option,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                // fontSize: (14 * (constraints.maxWidth / 160)).clamp(12.0, 20.0),
                                color: optIdx == 0?Colors.green :Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
                          itemCount: question.options.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ),
                    );
                  }, 
                    itemCount: selectedQuiz.questions.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  // Additional content for the selected quiz can go here
                ],
              ),
            ),
          );
        },
      );
  }
}