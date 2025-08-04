class Session {
  Session({
    required this.sessionId,
    required this.hostId,
    required this.quizId,
    this.currentQuestion = -1,
    this.state = SessionState.waiting,
    Map<String,Player>? players,
  }):players = players ?? {};

  final String sessionId;
  final String hostId;
  final String quizId;
  final int currentQuestion;
  final SessionState state;
  final Map<String, Player> players;

  Map<String,dynamic> toJson()=>{
    'sessionId':sessionId,
    'hostId':hostId,
    'quizId':quizId,
    'currentQuestion':currentQuestion,
    'state':state.name,
    'players':players
  };

  static SessionState _statefromString(String stateString){
    return SessionState.values.firstWhere((e)=>e.name == stateString,orElse: ()=>SessionState.waiting);
  }


  factory Session.fromJson(Map<String,dynamic>json){
    final playersMap = json['players'];
    Map<String,Player>playerObjects = {};
    if(playersMap is Map){
      playerObjects = playersMap.map<String, Player>((key, value) {
        return MapEntry(key.toString(), Player.fromJson(Map<String, dynamic>.from(value)));
      });
    }
    return Session(
      sessionId: json['sessionId'], 
      hostId: json['hostId'], 
      quizId: json['quizId'],
      currentQuestion: json['currentQuestion'],
      state: _statefromString(json['state']),
      players: playerObjects
    );
  }
}

enum SessionState{
  waiting,
  displayQuestion,
  revealAnswer,
  showLeaderBoard,
  ended
}

enum ActivityStatus{
  active,
  inactive
}

class Player{
  final String id;
  final String ioclempId;
  final String name;
  final int score;
  Player({
    required this.id,
    required this.ioclempId,
    required this.name,
    this.score = 0
  });

  Map<String,dynamic> toJson(){
    return {
      'id':id,
      'ioclempId':ioclempId,
      'name':name,
      'score':score
    };
  }

  factory Player.fromJson(Map<String, dynamic> json){
    return Player(
      id: json['id'], 
      ioclempId: json['ioclempId'], 
      name: json['name'], 
      score: json['score'] ?? 0
    );
  }
}