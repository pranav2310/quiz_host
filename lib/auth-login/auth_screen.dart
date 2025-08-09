import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/auth-login/host_login.dart';
import 'package:quiz_host/auth-login/player_signup.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isHost = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 400
                  ),
                  child: isHost?
                  HostLogin(onToggle : (){
                    setState(() {
                      isHost = false;
                    });
                  }):
                  PlayerSignup(onToggle : (){
                    setState(() {
                      isHost = true;
                    });
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
