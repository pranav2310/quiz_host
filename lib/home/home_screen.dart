import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/home/main_area.dart';
import 'package:quiz_host/home/sidebar.dart';
import 'package:quiz_host/provider/quiz_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.hostId});
  final String hostId;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final quizListAsync = ref.watch(quizListProvider(widget.hostId));
    final screenWidth = MediaQuery.of(context).size.width;
    return quizListAsync.when(
      loading: ()=>const Scaffold(body: Center(child: CircularProgressIndicator(),),),
      error: (error, _)=>Scaffold(body: Center(child: Text('Error: $error'),),),
      data: (quizList)=>Scaffold(
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
                  )
          )
        );
      }
  }
