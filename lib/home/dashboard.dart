import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quiz_host/provider/dashboard_controller.dart';
import 'package:quiz_host/home/widgets/dashboard_card.dart';
import 'package:quiz_host/home/widgets/leaderboard_dialog.dart';
import 'package:quiz_host/home/widgets/stats_summary.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/models/session.dart';
import 'package:quiz_host/provider/quiz_provider.dart';
import 'package:quiz_host/quiz/quiz_screen.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key, required this.hostId});
  final String hostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider(hostId));
    final controller = ref.watch(dashboardControllerProvider(hostId).notifier);

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('Error ${state.error}'));
    }
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            'Dashboard',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        StatsSummary(
          quizCount: state.quizList.length,
          sessionCount: state.sessionList.length,
          playerCount: state.sessionList.fold(
            0,
            (sum, s) => sum + s.players.length,
          ),
          activeSession: state.sessionList
              .where((s) => s.state.name != 'ended')
              .length,
        ),
        const SizedBox(height: 16),
        if (state.quizList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Text(
              'Created Quizzes',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...state.quizList.map((quiz) {
            final quizCreationDate = quiz.createdOn != null
                ? DateFormat('dd MM yyyy').format(quiz.createdOn!)
                : 'Unknown Date';
            return DashboardCard(
              title: quiz.quizTitle,
              subtitle:
                  'Description: ${quiz.quizDescription}\n'
                  'Created On: $quizCreationDate',
              buttonLabels: ['Host Quiz', 'View Quiz', 'Delete Quiz'],
              buttonOnPressed: [
                ()async {
                  try{
                    final sessionId = await controller.hostQuiz(quiz);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_)=>QuizScreen(playerId: 'host01', sessionId: sessionId!, isHost: true)));
    
                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Hosting Quiz: $e')));
                  }
                },
                () {
                  ref.read(quizNotifierProvider(hostId).notifier).setSelectedQuiz(quiz);
                  ref.read(mainScreenProvider.notifier).state = 'quiz';
                },
                () {
                  controller.deleteQuiz(quiz.quizId);
                },
              ],
              buttonIcon: [Icons.event_available, Icons.edit, Icons.delete],
            );
          }),
        ] else
          Center(
            child: Text(
              'You havent Created a quiz yet',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (state.sessionList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Text(
              'Created Quiz Sessions',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...state.sessionList.map((session) {
            final quiz = state.quizList.firstWhere(
              (q) => q.quizId == session.quizId,
              orElse: () => Quiz(
                quizId: session.quizId,
                quizTitle: 'Unknown Quiz',
                questions: [],
                quizDescription: 'Unknown',
              ),
            );
            final playerCount = session.players.length;
            final sessionDate = session.sessionCreatedAt != null
                ? DateFormat(
                    'dd MM yyyy, HH:mm',
                  ).format(session.sessionCreatedAt!)
                : 'Unknown Date';
            return DashboardCard(
              title: quiz.quizTitle,
              subtitle:
                  'SessionID: ${session.sessionId} • Players: $playerCount\n'
                  'Session State: ${session.state.name} • Hosted on: $sessionDate\n'
                  'Questions: ${quiz.questions.length}',
              buttonLabels: [
                session.state != SessionState.ended
                    ? 'Go Back to Quiz'
                    : 'Leaderboard',
                'Reset Session',
                'Delete Session',
              ],
              buttonOnPressed: [
                () {
                  if(session.state == SessionState.ended){
                    showDialog(context: context, builder: (_)=>LeaderboardDialog(session: session, quizTitle: quiz.quizTitle));
                  }
                  else{
                    Navigator.of(context).push(MaterialPageRoute(builder: (_)=>QuizScreen(playerId: 'host01', sessionId: session.sessionId, isHost: true)));
                  }
                },
                () {
                  controller.resetSession(session.sessionId);
                },
                () async {
                  controller.deleteSession(session.sessionId);
                },
              ],
              buttonIcon: [
                session.state != SessionState.ended
                    ? Icons.play_arrow
                    : Icons.emoji_events,
                Icons.restore,
                Icons.delete,
              ],
            );
          }),
        ] else
          Center(
            child: Text(
              'You havent Hosted a quiz Yet',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
      ],
    );
  }
}