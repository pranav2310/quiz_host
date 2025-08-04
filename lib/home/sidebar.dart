import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';

final selectedQuizProvider = StateProvider<Quiz?>((ref) => null);

class Sidebar extends ConsumerStatefulWidget{
  const Sidebar({
    super.key,
    required this.hostId,
    required this.quizList
  });
  final String hostId;
  final List<Quiz> quizList;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SidebarState();
  }
} 

class _SidebarState extends ConsumerState<Sidebar>{
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
        color: Theme.of(context).colorScheme.secondary,
      
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.add,
                      size: (16 * constraints.maxWidth/160).clamp(14, 24),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ), 
                    ),
                    onPressed: (){
                      ref.read(selectedQuizProvider.notifier).state = null;
                    }, 
                    label:Text(
                      'New Quiz',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: (16 * (constraints.maxWidth / 160)).clamp(14.0, 24.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  itemCount: widget.quizList.length,
                  itemBuilder: (ctx, index) {
                  final quiz = widget.quizList[index];
                  return ListTile(
                    title: Text(
                      quiz.quizTitle,
                      style: TextStyle(
                        fontSize: (16 * (constraints.maxWidth / 160)).clamp(14.0, 24.0),
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    onTap: () {
                      ref.read(selectedQuizProvider.notifier).state = quiz;
                    },
                  );
                }, 
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ],
            ),
          ),
        ),
        
      );
      }
    );
  }
}