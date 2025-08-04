import 'package:flutter/material.dart';
import 'package:quiz_host/models/session.dart';

class Leaderboard extends StatefulWidget{
  const Leaderboard({
    super.key,
    required this.playerData,
    required this.isFinal,
    required this.isHost
  });
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
    // TODO: implement build
    throw UnimplementedError();
  }
}