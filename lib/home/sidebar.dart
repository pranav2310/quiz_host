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
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8)
                    ),
                    onPressed: (){
                      ref.read(selectedQuizProvider.notifier).state = null;
                    }, 
                    label:Text(
                      'New Quiz',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: (16 * (constraints.maxWidth / 160)).clamp(14.0, 24.0).toDouble(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.quizList.length,
                    itemBuilder: (ctx, index) {
                    final quiz = widget.quizList[index];
                    return ListTile(
                      title: Text(
                        quiz.quizTitle,
                        style: TextStyle(
                          fontSize: (16 * (constraints.maxWidth / 160)).clamp(14.0, 24.0).toDouble(),
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
                ),
                const Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.white,),
                    title: Text('Logout', style: TextStyle(color: Colors.white),),
                    onTap: ()async{
                      await FirebaseAuth.instance.signOut();
                    },
                  )
              ],
            ),
          ),
        ),
        
      );
      }
    );
  }
}