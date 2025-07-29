import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/provider/main_screen_provider.dart';

class Sidebar extends ConsumerStatefulWidget{
  const Sidebar({super.key});

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
                TextButton.icon(
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
                const SizedBox(height: 20),
                ListView.builder(itemBuilder: (ctx, index) {
                  final quiz = ref.watch(quizProvider)[index];
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
                  itemCount: ref.watch(quizProvider).length,
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