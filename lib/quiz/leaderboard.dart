import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quiz_host/models/session.dart';

class Leaderboard extends StatefulWidget{
  const Leaderboard({
    super.key,
    required this.sessionId,
    required this.playerData,
    required this.isFinal,
    required this.isHost
  });
  final String sessionId;
  final Map<String, Player>playerData;
  final bool isFinal;
  final bool isHost;

  @override
  State<StatefulWidget> createState() {
    return _LeaderboardState();
  }
}

class _LeaderboardState extends State<Leaderboard>{
  @override
  Widget build(BuildContext context) {
    List<Player> sortedPlayers = widget.playerData.values.toList()..sort((a, b) => b.score.compareTo(a.score));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 16,),
          Text(
            widget.isFinal? 'Final Leaderboard':'Leaderboard',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface
            ),
          ),
          const SizedBox(height: 16,),
          Expanded(
            child: ListView.separated(
              itemCount: sortedPlayers.length,
              separatorBuilder: (context,idx)=>Divider(),
              itemBuilder: (ctx, idx){
                final player = sortedPlayers[idx];
                return ListTile(
                  leading: Text('${idx+1}'),
                  title: Text(player.name),
                  trailing: Text('${player.score}'),
                  tileColor: idx==0? Colors.amber[300]:null,
                );
              },
            )
          ),
          if(widget.isHost)
            Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: widget.isFinal ?() async {
                final sessionRef = FirebaseDatabase.instance.ref('session/${widget.sessionId}');
                try{
                  sessionRef.update({
                    'state':'ended',
                  });
                }catch(e){
                  throw Exception('Error $e');
                }
              }:
              () async {
                final sessionRef = FirebaseDatabase.instance.ref('session/${widget.sessionId}');
                final sessionState = sessionRef.child('state');
                if(sessionState == 'ended'){
                  if(widget.isHost){
                    //back to home scree
                  }
                  else{
                    // back to auth screen
                  }
                }
                try{
                  sessionRef.update({
                    'state':'displayQuestion',
                  });
                }catch(e){
                  throw Exception('Error $e');
                }
              },
              child: Text( widget.isFinal ? "End Game" : "Next Question"),
          ),
        ),
        ],
      ),
    );
  }
}