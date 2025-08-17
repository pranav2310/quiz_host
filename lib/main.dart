import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz_host/firebase_options.dart';
import 'package:quiz_host/src/quiz_host.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  try{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
  }catch(e){
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Failed to Initialize app: $e'),),),));
    return;
  }
  runApp(
    ProviderScope(child: const QuizHostApp())
  );
}
