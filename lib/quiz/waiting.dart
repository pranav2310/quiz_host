import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Waiting extends StatelessWidget{
  const Waiting({
    super.key,
    required this.sessionId,
    required this.isHost,
  });
  final String sessionId;
  final bool isHost;

  void _startQuiz(BuildContext context){
    final ref = FirebaseDatabase.instance.ref('session/$sessionId');
    try{
      ref.update({
        'currentQuestion' : 0,
        'state':'displayQuestion'
      });
    }
    catch(e){
      throw Exception('Failed to Start Quiz');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('session/$sessionId');
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Waiting for Players to join',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          const SizedBox(height: 16,),
          Expanded(
            child: StreamBuilder(
              stream: ref.onValue, 
              builder: (context, snapshot){
                if(!snapshot.hasData || snapshot.data!.snapshot.value == null){
                  return Text('No Players Joined yet!',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondary),);
                }
                final rawData = snapshot.data!.snapshot.value;
                final data = Map<String,dynamic>.from(rawData as Map);
                final playersRaw = data['players'];
                if (playersRaw == null){
                  return Center(child: Text('No Players Joined Yet',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondary)));
                }
                final playersMap = Map<String, dynamic>.from(playersRaw as Map);
                final playerNames = playersMap.values.map((player)=>player['name'].toString()).toList();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(isHost)Center(
                        child: ElevatedButton(
                          onPressed: (){
                            _startQuiz(context);
                          }, 
                          child: Text('Start Quiz',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),)
                        ),
                      ),
                      Text(
                        'Number of Players joined: ${playerNames.length}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary
                        ),
                      ),
                      const SizedBox(height: 12,),
                      Flexible(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 3
                          ),
                          itemCount: playerNames.length, 
                          itemBuilder: (context, idx){
                            return Card(
                              color: Theme.of(context).colorScheme.primary,
                              child: Center(
                                child: Text(
                                  playerNames[idx],
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ));
                          }
                        ),
                      )
                        
                    ],
                  ),
                );
              }),
          )
        ],
      ),
    );
  }
}
