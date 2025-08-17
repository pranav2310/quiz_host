import 'package:flutter/material.dart';
import 'package:quiz_host/models/session.dart';
import 'package:quiz_host/provider/leaderboard_download.dart'
    if (dart.library.html) 'package:quiz_host/provider/leaderboard_download_web.dart';

class LeaderboardDialog extends StatelessWidget {
  const LeaderboardDialog({
    super.key,
    required this.session,
    required this.quizTitle,
  });
  final Session session;
  final String quizTitle;

  void _downloadLeaderboard(
    String sessionId,
    String quizTitle,
    List<Player> sortedPlayers,
  ) async {
    StringBuffer csvbuffer = StringBuffer();
    csvbuffer.writeln('Rank,Name,EmpId,Score');
    for (int i = 0; i < sortedPlayers.length; i++) {
      csvbuffer.writeln(
        '${i + 1},"${sortedPlayers[i].name}","${sortedPlayers[i].id}","${sortedPlayers[i].score}"',
      );
    }
    final csvData = csvbuffer.toString();
    await downloadLeaderboard(quizTitle, sessionId, csvData);
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = session.players.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return AlertDialog(
      title: Text('Leaderboard - $quizTitle'),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: FixedColumnWidth(100),
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
              children: ['Rank','Name','Empl Id', 'Score']
                .map((header)=>Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    header,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ).toList()
            ),
            ...sortedPlayers.asMap().entries.map((entry){
              final idx = entry.key;
              final player = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: idx==0?Colors.amber.shade300:idx==1?Colors.grey.shade300:idx==2?Colors.brown.shade300:Colors.transparent
                ),
                children: ['${idx+1}',player.name,player.id,'${player.score}'].map((val)=>Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    val,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center
                  ),
                )).toList()
              );
            })
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          label: const Text('Close'),
          icon: Icon(Icons.close),
        ),
        TextButton.icon(
          onPressed: () {
            _downloadLeaderboard(session.sessionId, quizTitle, sortedPlayers);
          },
          label: Text('Download Leaderboard'),
          icon: Icon(Icons.file_download_outlined),
        ),
      ],
    );
  }
}
