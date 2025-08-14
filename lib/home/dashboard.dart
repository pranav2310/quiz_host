import 'dart:io';
import 'dart:math';
import 'dart:html' as html;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/models/session.dart';
import 'package:quiz_host/provider/quiz_provider.dart';
import 'package:intl/intl.dart';
import 'package:quiz_host/quiz/quiz_screen.dart';
import 'package:share_plus/share_plus.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key, required this.hostId});
  final String hostId;
  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  List<Quiz> _quizList = [];
  List<Session> _sessionList = [];
  void fetchSessions() async {
    final sessionsRef = FirebaseDatabase.instance
        .ref('session')
        .orderByChild('hostId')
        .equalTo(widget.hostId);
    final sessionsSnap = await sessionsRef.get();
    final List<Session> sessionList = [];
    if (sessionsSnap.exists) {
      final rawData = sessionsSnap.value;
      if (rawData is Map) {
        rawData.forEach((id, session) {
          if (session is Map) {
            sessionList.add(
              Session.fromJson(Map<String, dynamic>.from(session)),
            );
          }
        });
      }
    }
    if (mounted) {
      setState(() {
        _sessionList = sessionList
          ..sort((a, b) {
            final aDate = a.sessionCreatedAt ?? DateTime(1970);
            final bDate = b.sessionCreatedAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
      });
    }
  }

  Future<void> _deleteQuiz(Quiz selectedQuiz) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text(
          'Are you sure you want to delete this quiz? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    try {
      final quizRef = FirebaseDatabase.instance.ref(
        'quiz-list/${widget.hostId}/${selectedQuiz.quizId}',
      );
      await quizRef.remove();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Quiz Deleted!!!')));
        ref.read(selectedQuizProvider.notifier).state = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to Delete Quiz: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  void _downloadLeaderboard(String sessionId, String quizTitle, List<Player> sortedPlayers)async{
    StringBuffer csvbuffer = StringBuffer();
    csvbuffer.writeln('Rank,Name,EmpId,Score');
    for(int i=0;i<sortedPlayers.length;i++){
      csvbuffer.writeln('${i+1},"${sortedPlayers[i].name}","${sortedPlayers[i].id}","${sortedPlayers[i].score}"');
    }
    final csvData = csvbuffer.toString();
    if(kIsWeb){
      final blob = html.Blob([csvData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'leaderboard_${quizTitle}_$sessionId.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
    else{
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/leaderboard_${quizTitle}_$sessionId.csv';
      final file = File(path);
      await file.writeAsString(csvData);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    }
    print(csvData);
  }

  void showLeaderBoardGotoQuiz(Session session, String quizTitle) {
    if(session.state == SessionState.ended){
      showDialog(
        context: context,
        builder: (ctx) {
          final sortedPlayers = session.players.values.toList()
            ..sort((a, b) => b.score.compareTo(a.score));

          return AlertDialog(
            title: Text('Leaderboard - $quizTitle'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortedPlayers.length,
                itemBuilder: (_, index) {
                  final player = sortedPlayers[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${index + 1}'),
                        // const SizedBox(width: 16,),
                        Text(player.name),
                        // const SizedBox(width: 16,),
                        Text(player.id),
                        // const SizedBox(width: 16,),
                        Text(player.score.toString()),
                      ],
                    );
                },
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                label: const Text('Close'),
                icon: Icon(Icons.close),
              ),
              TextButton.icon(
                onPressed: () {_downloadLeaderboard(session.sessionId,quizTitle,sortedPlayers);},
                label: Text('Download Leaderboard'),
                icon: Icon(Icons.file_download_outlined),
              ),
            ],
          );
        },
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          playerId: 'host01',
          sessionId: session.sessionId,
          isHost: true,
        ),
      ),
    );
  }

  void resetSession(Session session) async {
    final sessionRef = FirebaseDatabase.instance.ref(
      'session/${session.sessionId}',
    );
    await sessionRef.update({
      'state': SessionState.waiting.name,
      'players': {},
      'currentQuestion': 0,
      'sessionCreatedAt': ServerValue.timestamp,
    });
    setState(() {
      fetchSessions();
    });
  }

  Widget _cardButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
        onPressed: onPressed,
        label: Text(label),
        icon: Icon(icon, size: 16),
      ),
    );
  }

  Widget statsCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 175,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSecondary),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _hostQuiz(Quiz selectedQuiz) async {
    try {
      final sessionRef = FirebaseDatabase.instance
          .ref('session')
          .orderByChild('hostId')
          .equalTo(widget.hostId);
      final sessionSnapshot = await sessionRef.get();
      if (sessionSnapshot.exists) {
        final rawData = sessionSnapshot.value;
        if (rawData is Map) {
          final sessionData = Map<String, dynamic>.from(rawData);
          String? existingSessionId;
          sessionData.forEach((id, session) {
            if (session is Map) {
              final quizId = session['quizId']?.toString();
              final sesstate = session['state']?.toString();
              if (quizId == selectedQuiz.quizId && sesstate != 'ended') {
                existingSessionId = session['sessionId']?.toString();
              }
            }
          });
          if (existingSessionId != null) {
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => QuizScreen(
                  playerId: 'host01',
                  sessionId: existingSessionId!,
                  isHost: true,
                ),
              ),
            );
            return;
          }
        }
      }
      String sessionId;
      DatabaseReference sessionCreationRef;
      var checkSnap;
      do {
        sessionId = List.generate(
          6,
          (_) => '0123456789'[Random().nextInt(10)],
        ).join();
        sessionCreationRef = FirebaseDatabase.instance.ref(
          'session/$sessionId',
        );
        checkSnap = await sessionCreationRef.get();
      } while (checkSnap.exists);
      await sessionCreationRef.update({
        'sessionId': sessionId,
        'hostId': widget.hostId,
        'quizId': selectedQuiz.quizId,
        'currentQuestion': 0,
        'state': 'waiting',
        'players': {},
        'sessionCreatedAt': ServerValue.timestamp,
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => QuizScreen(
            playerId: 'host01',
            sessionId: sessionId,
            isHost: true,
          ),
        ),
      ).then((_)=>fetchSessions());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to Create Session $e')));
    }
  }

  Widget _dashboardCard({
    required String title,
    required String subtitle,
    required List<String> buttonLabels,
    required List<VoidCallback> buttonOnPressed,
    required List<IconData> buttonIcon,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                buttonLabels.length,
                (i)=>_cardButton(icon: buttonIcon[i], label: buttonLabels[i], onPressed: buttonOnPressed[i])
                )
            ),
          ],
          
          // title: Text(
          //   title,
          //   style: Theme.of(context).textTheme.titleLarge!.copyWith(
          //     color: Theme.of(context).colorScheme.onSurface,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // subtitle: Text(
          //   subtitle,
          //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
          //     color: Theme.of(context).colorScheme.onSurface,
          //   ),
          // ),
          // trailing: ConstrainedBox(
          //   constraints: BoxConstraints(maxWidth: 300),
          //   child: Wrap(
          //     spacing: 8,
          //     runSpacing: 4,
          //     children: List.generate(
          //       buttonLabels.length,
          //       (i)=>_cardButton(icon: buttonIcon[i], label: buttonLabels[i], onPressed: buttonOnPressed[i])
          //       )
          //   ),
          // ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizListAsync = ref.watch(quizListProvider(widget.hostId));
    return quizListAsync.when(
      loading: () => Center(child: CircularProgressIndicator.adaptive()),
      error: (error, _) => Center(child: Text('Error $error')),
      data: (quizList) {
        _quizList = quizList
          ..sort((a, b) {
            final aDate = a.createdOn ?? DateTime(1970);
            final bDate = b.createdOn ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Center(
              child: Text(
                'Dashboard',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Wrap(
                runSpacing: 8,
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  statsCard(
                    title: 'Total Quizes',
                    value: _quizList.length.toString(),
                    icon: Icons.question_answer,
                  ),
                  statsCard(
                    title: 'Total Quizes Hosted',
                    value: _sessionList.length.toString(),
                    icon: Icons.event,
                  ),
                  statsCard(
                    title: 'Total Players joined',
                    value: _sessionList
                        .fold(0, (sum, s) => sum + s.players.length)
                        .toString(),
                    icon: Icons.people,
                  ),
                  statsCard(
                    title: 'Active Sessions',
                    value: _sessionList
                        .where((s) => s.state.name != 'ended')
                        .length
                        .toString(),
                    icon: Icons.event,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_quizList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8,
                ),
                child: Text(
                  'Created Quizzes',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              ...quizList.map((quiz) {
                final quizCreationDate = quiz.createdOn != null
                    ? DateFormat('dd MM yyyy').format(quiz.createdOn!)
                    : 'Unknown Date';
                return _dashboardCard(
                  title: quiz.quizTitle, 
                  subtitle: 'Description: ${quiz.quizDescription}\n'
                    'Created On: $quizCreationDate', 
                  buttonLabels: ['Host Quiz','View Quiz','Delete Quiz'], 
                  buttonOnPressed: [
                    () {
                      _hostQuiz(quiz);
                    },
                    () {
                      ref.read(selectedQuizProvider.notifier).state =quiz;
                      ref.read(mainScreenProvider.notifier).state ='quiz';
                    },
                    (){
                      _deleteQuiz(quiz);
                    }
                  ], 
                  buttonIcon: [
                    Icons.event_available,
                    Icons.edit,
                    Icons.delete
                  ]
                );
              }),
            ]else Center(child: Text('You havent Created a quiz yet',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondary),)),
            const SizedBox(height: 16),
            if (_sessionList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8,
                ),
                child: Text(
                  'Created Quiz Sessions',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              ..._sessionList.map((session) {
                final quiz = _quizList.firstWhere(
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
                return _dashboardCard(
                  title: quiz.quizTitle, 
                  subtitle: 'SessionID: ${session.sessionId} • Players: $playerCount\n'
                      'Session State: ${session.state.name} • Hosted on: $sessionDate\n'
                      'Questions: ${quiz.questions.length}', 
                  buttonLabels: [
                    session.state != SessionState.ended
                                ? 'Go Back to Quiz'
                                : 'Leaderboard',
                    'Reset Session',
                    'Delete Session'
                                ], 
                  buttonOnPressed: [
                    (){
                      showLeaderBoardGotoQuiz(session, quiz.quizTitle);
                    },
                    () {
                      resetSession(session);
                    },
                    ()async{
                      final sessionRef = FirebaseDatabase.instance.ref('session/${session.sessionId}');
                      await sessionRef.remove();
                    }
                  ], 
                  buttonIcon: [
                    session.state != SessionState.ended
                                ? Icons.play_arrow
                                : Icons.emoji_events,
                    Icons.restore,
                    Icons.delete
                  ]
                );
              }),
            ] else
              Center(child: Text('You havent Hosted a quiz Yet',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondary),)),
          ],
        );
      },
    );
  }
}
