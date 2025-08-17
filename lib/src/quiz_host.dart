import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz_host/firebase_options.dart';
import 'package:quiz_host/src/auth_gate.dart';
import 'package:quiz_host/src/theme_data.dart';

class QuizHostApp extends StatelessWidget{
  const QuizHostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Quiz Host",
      theme: appTheme,
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform
        ), 
        builder: (ctx, snap){
          if(snap.connectionState == ConnectionState.done){
            return AuthGate();
          }
          if(snap.hasError){
            return Scaffold(
              appBar: AppBar(
                title: const Text('IOCL Quiz Host'),
              ),
              body: Text(
                snap.error.toString(), 
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Theme.of(context).colorScheme.error
                ),
              ),
            );
          }
          return Scaffold(appBar: AppBar(title: const Text('IOCL Quiz Host'),),body: CircularProgressIndicator.adaptive(),);
        }
      )
    );
  }
}