import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/home/question_card.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/provider/quiz_provider.dart';
import 'package:quiz_host/quiz/quiz_screen.dart';

class QuizDescription extends ConsumerStatefulWidget {
  const QuizDescription({
    super.key,
    required this.hostId,
    // required this.selectedQuiz,
    required this.constraints,
  });
  final String hostId;
  // final Quiz selectedQuiz;
  final Size constraints;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _QuizDescriptionState();
  }
}

class _QuizDescriptionState extends ConsumerState<QuizDescription> {
  List<Question> questionCache = [];

  @override
  void initState() {
    super.initState();
    final selectedQuiz = ref.read(selectedQuizProvider);
    questionCache = List.from(selectedQuiz!.questions);
  }

  Future<void> _deleteQuiz(Quiz selectedQuiz) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text(
          'Are you sure you want to delete this quiz? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    try {
      final quizRef = FirebaseDatabase.instance.ref(
        'quiz-list/${widget.hostId}/${selectedQuiz.quizId}',
      );
      await quizRef.remove();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Quiz Deleted!!!')));
        ref.read(selectedQuizProvider.notifier).state = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to Delete Quiz: $e')));
      }
    }
  }

  void _hostQuiz(Quiz selectedQuiz) async {
    try {
      final sessionRef = FirebaseDatabase.instance.ref('session');
      final sessionSnapshot = await sessionRef.get();
      if (sessionSnapshot.exists) {
        final rawData = sessionSnapshot.value;
        if (rawData is Map) {
          final sessionData = Map<String, dynamic>.from(rawData);
          String? existingSessionId;
          sessionData.forEach((id, session) {
            if (session is Map) {
              final quizId = session['quizId']?.toString();
              final sesstate = session['state']?.toString();
              if (quizId == selectedQuiz.quizId &&
                sesstate != 'ended') {
                existingSessionId = session['sessionId']?.toString();
              }
            }
          });
          if (existingSessionId != null) {
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => QuizScreen(
                  playerId: 'host01',
                  sessionId: existingSessionId!,
                  isHost: true,
                ),
              ),
            );
            return;
          }
        }
      }
      String sessionId;
      DatabaseReference sessionCreationRef;
      var checkSnap;
      do {
        sessionId = List.generate(
          6,
          (_) => '0123456789'[Random().nextInt(10)],
        ).join();
        sessionCreationRef = FirebaseDatabase.instance.ref(
          'session/$sessionId',
        );
        checkSnap = await sessionCreationRef.get();
      } while (checkSnap.exists);
      await sessionCreationRef.update({
        'sessionId': sessionId,
        'hostId': widget.hostId,
        'quizId': selectedQuiz.quizId,
        'currentQuestion': 0,
        'state': 'waiting',
        'players': {},
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => QuizScreen(
            playerId: 'host01',
            sessionId: sessionId,
            isHost: true,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to Create Session $e')));
    }
  }

  Future<void> _updateAllQuestion(Quiz selectedQuiz) async {
    final questionsRef = FirebaseDatabase.instance.ref(
      'quiz-list/${widget.hostId}/${selectedQuiz.quizId}/questions',
    );
    await questionsRef.set(questionCache.map((q) => q.toJson()).toList());
  }

  Future<void> _deleteQuestionAt(int idx, Quiz selectedQuiz) async {
    setState(() {
      questionCache.removeAt(idx);
    });
    await _updateAllQuestion(selectedQuiz);
  }

  Future<void> _editQuestionAt(int idx, Question updated, Quiz selectedQuiz) async {
    setState(() {
      questionCache[idx] = updated;
    });
    await _updateAllQuestion(selectedQuiz);
  }

  bool showAnswers = false;
  Set<int> editQuesIdx = {};

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Quiz?>(selectedQuizProvider, (prev,next){
      if(next!=null){
        setState(() {
          questionCache = List.from(next.questions);
        });
      }
    });
    final selectedQuiz = ref.watch(selectedQuizProvider);
    // final selectedQuiz = widget.selectedQuiz;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                selectedQuiz!.quizTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.play_arrow,
                  label: 'Host Quiz',
                  onPressed: (){_hostQuiz(selectedQuiz);},
                ),
                _buildActionButton(
                  icon: showAnswers ? Icons.visibility_off : Icons.visibility,
                  label: showAnswers ? 'Hide Answers' : 'Show Answers',
                  onPressed: () {
                    setState(() {
                      showAnswers = !showAnswers;
                    });
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete Quiz',
                  onPressed: (){_deleteQuiz(selectedQuiz);},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Questions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: questionCache.length,
              itemBuilder: (ctx, idx) {
                return QuestionCard(
                  showAnswers: showAnswers,
                  quesIdx: idx,
                  quizId: selectedQuiz.quizId,
                  hostId: widget.hostId,
                  question: questionCache[idx],
                  onDelete: () => _deleteQuestionAt(idx, selectedQuiz),
                  onSave: (updatedQuestion) =>
                      _editQuestionAt(idx, updatedQuestion, selectedQuiz),
                );
              },
            ),
            ElevatedButton.icon(
              onPressed: (){
                setState(() {
                  questionCache.add(
                    Question(questionText: 'New Question', options: ['option','option'])
                  );
                });
              },
              label: Text('Add a Question'),
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
