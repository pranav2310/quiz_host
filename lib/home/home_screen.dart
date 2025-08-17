import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/home/dashboard.dart';
import 'package:quiz_host/home/new_quiz.dart';
import 'package:quiz_host/home/quiz_description.dart';
import 'package:quiz_host/home/sidebar.dart';
import 'package:quiz_host/home/sidebar_navigation_rail.dart';
import 'package:quiz_host/provider/quiz_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.hostId, required this.hostName});
  final String hostId;
  final String hostName;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Widget _buildMainArea(String mainScreen) {
    switch (mainScreen) {
      case 'mis':
        return Dashboard(hostId: widget.hostId);
      case 'new_quiz':
        return NewQuiz(hostId: widget.hostId);
      case 'quiz':
        return QuizDescription(hostId: widget.hostId);
      default:
        return Center(child: Text('An Option from the Sidebar'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainScreen = ref.watch(mainScreenProvider);
    return LayoutBuilder(
      builder: (ctx, constraints){
        if(constraints.maxWidth>=600){
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            appBar: AppBar(
              title: Text('Quiz Host'),
            ),
            body: Row(
              children: [
                SidebarNavigationRail(hostId: widget.hostId),
                const VerticalDivider(thickness: 1,width: 1,),
                Expanded(child: _buildMainArea(mainScreen))
              ],
            ),
          );
        }
        else{
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            appBar: AppBar(leadingWidth: 100, title: const Text("Quiz Host")),
            drawer: Drawer(child: Sidebar(hostId: widget.hostId)),
            body: _buildMainArea(mainScreen),
          );
        }
      },
    );
  }
}
