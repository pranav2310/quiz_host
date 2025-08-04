import 'package:flutter/material.dart';

class PlayerJoin extends StatefulWidget{
  const PlayerJoin({
    super.key,
    required this.sessionId
  });
  final String sessionId;
  @override
  State<StatefulWidget> createState() {
    return _PlayerJoinState();
  }
}

class _PlayerJoinState extends State<PlayerJoin>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}