import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/home/dashboard.dart';
import 'package:quiz_host/home/new_quiz.dart';
import 'package:quiz_host/home/quiz_description.dart';
import 'package:quiz_host/home/sidebar.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/provider/quiz_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.hostId,required this.hostName});
  final String hostId;
  final String hostName;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final quizListAsync = ref.watch(quizListProvider(widget.hostId));
    final mainScreen = ref.watch(mainScreenProvider);
    Widget mainArea(List<Quiz> quizList){
      switch(mainScreen){
        case 'mis':
          return Dashboard(hostId: widget.hostId);
        case 'new_quiz':
          return NewQuiz(hostId: widget.hostId);
        case 'quiz':
          return QuizDescription(hostId: widget.hostId);
        default:
          return Center(child:Text('An Option from the Sidebar'));
      }
    }
    return quizListAsync.when(
      loading: ()=>const Scaffold(body: Center(child: CircularProgressIndicator(),),),
      error: (error, _)=>Scaffold(body: Center(child: Text('Error: $error'),),),
      data: (quizList)=>Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          appBar: AppBar(
            // leading: Text('Welcome ${widget.hostName}'),
            leadingWidth: 100,
            title: const Text("Quiz Host"),
          ),
          drawer: Drawer(
                  child: Sidebar(hostId: widget.hostId, quizList: quizList),
                ),
          body: mainArea(quizList)
          )
        );
      }
  }
