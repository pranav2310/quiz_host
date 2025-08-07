import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/home/main_area.dart';
import 'package:quiz_host/home/sidebar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.hostId});
  final String hostId;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final quizListRef = FirebaseDatabase.instance.ref(
      'quiz-list/${widget.hostId}',
    );
    return StreamBuilder(
      stream: quizListRef.onValue,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Scaffold(body: Center(child: Text('Error ${snap.error}')));
        }
        final data = snap.data?.snapshot.value as Map;
        final List<Quiz> quizList = [];
        data.forEach((k, v) {
          if (v is Map) {
            final questionsRaw = v['questions'];
            List<Question> questionData = [];

            if (questionsRaw is List) {
              questionData = questionsRaw.map<Question>((q) {
                if (q is Map) {
                  final optionsRaw = q['options'];
                  List<String> options = [];

                  if (optionsRaw is List) {
                    options = optionsRaw
                        .map((o) => o?.toString() ?? '')
                        .toList();
                  }

                  return Question(
                    qId: q['qId']?.toString() ?? '',
                    questionText: q['questionText']?.toString() ?? '',
                    options: options,
                  );
                }
                return Question(qId: '', questionText: '', options: []);
              }).toList();
            }
            quizList.add(Quiz(quizId: v['quizId'],quizTitle: v['quizTitle'], questions: questionData));
          }
        });
        return Scaffold(
          appBar: AppBar(title: const Text("Quiz Host")),
          drawer: screenWidth < 640
              ? Drawer(
                  child: Sidebar(hostId: widget.hostId, quizList: quizList),
                )
              : null,
          body: screenWidth < 640
              ? MainArea(hostId: widget.hostId, quizList: quizList)
              : Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.25,
                      child: Sidebar(hostId: widget.hostId, quizList: quizList),
                    ),
                    Expanded(
                      child: MainArea(
                        hostId: widget.hostId,
                        quizList: quizList,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
