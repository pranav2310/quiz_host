import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/provider/quiz_provider.dart';

class Sidebar extends ConsumerStatefulWidget{
  const Sidebar({
    super.key,
    required this.hostId,
    required this.quizList
  });
  final String hostId;
  final List<Quiz> quizList;
  @override
  ConsumerState<Sidebar> createState() {
    return _SidebarState();
  }
} 

class _SidebarState extends ConsumerState<Sidebar>{

  Widget _sidebarButton({
    required IconData icon, 
    required VoidCallback onTap, 
    required String label}){
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.onPrimary,),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  
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
                _sidebarButton(
                  icon: Icons.dashboard, 
                  onTap: (){
                      ref.read(selectedQuizProvider.notifier).state = null;
                      ref.read(mainScreenProvider.notifier).state = 'mis';
                      Navigator.of(context).pop();
                    }, 
                  label: 'Dashboard'
                ),
                const SizedBox(height: 20),
                _sidebarButton(
                  icon: Icons.add, 
                  onTap: (){
                      ref.read(selectedQuizProvider.notifier).state = null;
                      ref.read(mainScreenProvider.notifier).state = 'new_quiz';
                      Navigator.of(context).pop();
                    }, 
                  label: 'New Quiz'
                ),
                const SizedBox(height: 20),
                if(widget.quizList.isNotEmpty)
                Row(
                  children: [
                    Text(
                      'Existing Quizes',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onPrimary,)
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.quizList.length,
                    itemBuilder: (ctx, index) {
                    final quiz = widget.quizList[index];
                    final selectedQuiz = ref.watch(selectedQuizProvider);
                    final isSelected = selectedQuiz!=null  && quiz.quizTitle == selectedQuiz.quizTitle;
                    return InkWell(
                      onTap: () {
                          ref.read(selectedQuizProvider.notifier).state = quiz;
                          ref.read(mainScreenProvider.notifier).state = 'quiz';
                          Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected? Theme.of(context).colorScheme.surface.withValues(alpha: 0.25):null,
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                          child: Text(
                            quiz.quizTitle,
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontWeight: isSelected? FontWeight.bold:FontWeight.normal
                            ),
                          ),
                        ),
                        ),
                      );
                  }, 
                  ),
                ),
                const Divider(),
                _sidebarButton(
                  icon: Icons.logout, 
                  onTap: ()async{
                      await FirebaseAuth.instance.signOut();
                    }, 
                  label: 'LogOut'
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