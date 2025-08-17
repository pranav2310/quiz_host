import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/provider/dashboard_controller.dart';
import 'package:quiz_host/provider/quiz_provider.dart';

class SidebarNavigationRail extends ConsumerWidget {
  const SidebarNavigationRail({super.key, required this.hostId});
  final String hostId;

  static const double _sidebarWidth = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider(hostId));
    final selectedQuiz = ref.watch(quizNotifierProvider(hostId)).quiz;
    final mainScreen = ref.watch(mainScreenProvider);

    int getFixedSelectedIndex() {
      if (mainScreen == 'mis') return 0;
      if (mainScreen == 'new_quiz') return 1;
      return -1; 
    }

    final fixedSelectedIndex = getFixedSelectedIndex();

    final labelStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        );

    return Container(
      width: _sidebarWidth,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                ref.read(quizNotifierProvider(hostId).notifier).clearQuixSelection();
                ref.read(mainScreenProvider.notifier).state = 'mis';
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(Icons.dashboard, color: fixedSelectedIndex==0?Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: 16),
                    Text(
                      'Dashboard', 
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: fixedSelectedIndex==0?Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface,
                      )),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                ref.read(quizNotifierProvider(hostId).notifier).clearQuixSelection();
                ref.read(mainScreenProvider.notifier).state = 'new_quiz';
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(Icons.add, color: fixedSelectedIndex==1?Theme.of(context).colorScheme.tertiary: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: 16),
                    Text('New Quiz', style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: fixedSelectedIndex==1?Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface,
                      )),
                  ],
                ),
              ),
            ),

            const Divider( height: 1),

            // Manage Quizzes header
            if (state.quizList.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Manage Quizzes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),

            // Scrollable quiz list
            if (state.quizList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: state.quizList.length,
                  itemBuilder: (context, index) {
                    final quiz = state.quizList[index];
                    final isSelected =
                        selectedQuiz == quiz && mainScreen == 'quiz';

                    return InkWell(
                      onTap: () {
                        ref.read(quizNotifierProvider(hostId).notifier).setSelectedQuiz(quiz);
                        ref.read(mainScreenProvider.notifier).state = 'quiz';
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white24 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          quiz.quizTitle,
                          style: labelStyle.copyWith(
                            color: isSelected? Theme.of(context).colorScheme.tertiary:Theme.of(context).colorScheme.onSurface
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Spacer between quizzes and logout
            if (state.quizList.isNotEmpty) const SizedBox(height: 8),

            const Divider(color: Colors.white54, height: 1),

            // Logout button at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
