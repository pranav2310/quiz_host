import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_host/home/home_screen.dart';
import 'package:quiz_host/landing_page/login_screen.dart';

class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (ctx, snap){
        if(snap.connectionState == ConnectionState.waiting){
          return Scaffold(body: CircularProgressIndicator.adaptive(),);
        }
        if(snap.hasData){
          return HomeScreen(hostId: snap.data!.uid, hostName: snap.data!.displayName ?? '');
        }
        return LoginScreen();
      }
    );
  }
} 