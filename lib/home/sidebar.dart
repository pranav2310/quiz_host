import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/provider/dashboard_controller.dart';
import 'package:quiz_host/provider/quiz_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key, required this.hostId});
  final String hostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider(hostId));
    final selectedQuiz = ref.watch(quizNotifierProvider(hostId)).quiz;
    final mainScreen = ref.watch(mainScreenProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Branding/Profile
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Quiz Host',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),

            // Main navigation
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: mainScreen == 'mis',
              onTap: () {
                ref.read(quizNotifierProvider(hostId).notifier).clearQuixSelection();
                ref.read(mainScreenProvider.notifier).state = 'mis';
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Quiz'),
              selected: mainScreen == 'new_quiz',
              onTap: () {
                ref.read(quizNotifierProvider(hostId).notifier).clearQuixSelection();
                ref.read(mainScreenProvider.notifier).state = 'new_quiz';
                Navigator.of(context).pop();
              },
            ),
            const Divider(),

            // Manage Quizzes section header
            if (state.quizList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Manage Quizzes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

            // Quiz List (scrollable)
            Expanded(
              child: ListView.builder(
                itemCount: state.quizList.length,
                itemBuilder: (context, index) {
                  final quiz = state.quizList[index];
                  return ListTile(
                    leading: const Icon(Icons.quiz),
                    title: Text(
                      quiz.quizTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: selectedQuiz == quiz && mainScreen == 'quiz',
                    onTap: () {
                      ref.read(quizNotifierProvider(hostId).notifier).setSelectedQuiz(quiz);
                      ref.read(mainScreenProvider.notifier).state = 'quiz';
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),

            const Divider(),

            // Logout button at bottom
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
