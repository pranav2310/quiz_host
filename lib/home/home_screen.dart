import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/home/main_area.dart';
import 'package:quiz_host/home/sidebar.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.hostId});
  final String hostId;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<List<Quiz>> _quizList;
  Future<List<Quiz>> loadQuizzes() async {
    final quizListUrl = Uri.https(
      'iocl-quiz-host-default-rtdb.firebaseio.com',
      'quiz-list-${widget.hostId}.json',
    );
    final response = await http.get(quizListUrl);

    if (response.statusCode >= 400) {
      throw Exception('Failed to Load Quiz ${response.statusCode}');
    }

    final decoded = json.decode(response.body);

    final quizList = <Quiz>[];

    (decoded as Map<String, dynamic>).forEach((key, val) {
      quizList.add(Quiz.fromJson(val));
    });

    return quizList;
  }

  @override
  void initState() {
    _quizList = loadQuizzes();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: _quizList,
      builder: (context, snap) {
        final quizList = snap.data ?? [];
        if(snap.connectionState == ConnectionState.waiting){
          return  Scaffold(body: Center(child: CircularProgressIndicator(),),);
        }
        // if(snap.hasError){
        //   return Scaffold(body: Center(child: Text('Error ${snap.error}'),),);
        // }
        return Scaffold(
          appBar: AppBar(title: const Text("Cyber Security Quiz")),
          drawer: screenWidth < 640 ? Drawer(child: Sidebar(hostId: widget.hostId,quizList: quizList,)) : null,
          body:  screenWidth < 640
                  ? MainArea(hostId: widget.hostId,quizList: quizList,)
                  : Row(
                      children: [
                        SizedBox(width: screenWidth * 0.25, child: Sidebar(hostId: widget.hostId,quizList: quizList,)),
                        Expanded(child: MainArea(hostId: widget.hostId,quizList: quizList,)),
                      ],
                    )
                  );
      }
    );
  }
}
