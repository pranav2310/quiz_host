import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/quiz/quiz_screen.dart';
import 'package:http/http.dart' as http;

final _firebase = FirebaseAuth.instance;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _hostFormKey = GlobalKey<FormState>();
  final _playerFormKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isLogin = false;
  var _quizCode = '';
  var _isLoading = false;
  var _playerName = '';
  var _empId = '';
  bool isHost = false;

  void _submit() async {
    final isValid = _hostFormKey.currentState!.validate();
    if (!isValid) return;
    _hostFormKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try{
      if(_isLogin){
        await _firebase.signInWithEmailAndPassword(email: _enteredEmail, password: _enteredPassword);
      }
      else{
        await _firebase.createUserWithEmailAndPassword(email: _enteredEmail, password: _enteredPassword);
      }

    }
    on FirebaseAuthException catch(err){
      String message = err.message ?? 'Authentication Failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error : $e')));
    }
    setState(() {
      _isLoading = false;
    });
  }
  String? _empIdError;
  Future<bool> _validateEmpId(String empId) async {
    // final emplink = "https://xsparsh.indianoil.in/soa-infra/resources/default/MPower/EmpProfile/?emp_code=$empId";
    // final response = await http.get(Uri.parse(emplink));
    // if (response.statusCode != 200 || !response.body.contains("EmpMasterPWAOutput")) {
    //   setState(() {
    //     _empIdError = "Please Enter Valid Employee Id";
    //   });
    //   return false;
    // }
    // setState(() {
    //   _empIdError = null;
    // });
    return true;
}

  Future<void> _joinQuiz() async {
    final isValid = _playerFormKey.currentState!.validate();
    if(!isValid)return;
    _playerFormKey.currentState!.save();
    final validateEmpId = await _validateEmpId(_empId);
    if(!validateEmpId)return;

    setState(() {
      _isLoading = true;
    });
    final sessionUrl = Uri.https(
      'iocl-quiz-host-default-rtdb.firebaseio.com',
      'session/$_quizCode.json'
    );
    try{
      final response = await http.get(sessionUrl);
      if(response.statusCode!=200){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('The Quiz Code doesnt exist Enter Valid Quiz Code')));
        return;
      }
      final playerUrl = Uri.https(
        'iocl-quiz-host-default-rtdb.firebaseio.com',
        'session/$_quizCode/players/$_empId.json'
      );
      final addPlayerResponse = await http.put(
        playerUrl,
        body: json.encode({
          'id':_empId,
          'name':_playerName,
          'score':0
        }),
        headers: {'Content-Type':'application/json'},
      );
      if(addPlayerResponse.statusCode != 200 && addPlayerResponse.statusCode != 201){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join quiz. Please try again.'))
      );
      return;
    }

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (ctx)=>QuizScreen(
          playerId : _empId,
          sessionId: _quizCode, 
          isHost: false
        )
      ));
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $e')));
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _hostFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16,),
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text('Email Address'),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary)
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Enter Valid Email Address';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text('Password'),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary)
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter Valid Password';
                                  }
                                  if (value.length < 6) {
                                    return 'Length of Password must be greater than equal to 6';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  _enteredPassword = val!;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null :_submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                      ),
                                      child: _isLoading? const SizedBox(
                                        height: 18,
                                        width:18 ,
                                        child: CircularProgressIndicator(),
                                      ) :Text( _isLogin ? 'Login' : 'SignUp'),
                                    ),
                                  ),
                                  const SizedBox(width: 8,),
                                  ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        isHost = !isHost;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                    ), 
                                    child: Text('Join Quiz as a Player'))
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(
                                  _isLogin
                                      ? 'Create an Account'
                                      : 'Already have an account. Login',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ):
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _playerFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text('Quiz Code'),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.secondary)
                                ),
                                validator: (value) {
                                  if (value==null || value.trim().length<6){
                                    return 'Enter a valid Quiz Code';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) => _quizCode = newValue!,
                              ),
                              const SizedBox(height: 8,),
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text('Player Name'),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.secondary)
                                ),
                                validator: (value) {
                                  if(value == null || value.trim().isEmpty){
                                    return 'Do not leave this Field Empty';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) => _playerName = newValue!,
                              ),
                              const SizedBox(height: 8,),
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text('Employee Id '),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.secondary)
                                ),
                                validator: (value) {
                                  if(value == null || value.trim().isEmpty){
                                    return 'Do not leave this Field Empty';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if(_empIdError != null){
                                    setState(() {
                                      _empIdError = null;
                                    });
                                  }
                                },
                                onSaved: (newValue) => _empId = newValue!,
                              ),
                              const SizedBox(height: 16,),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isLoading?null:(){
                                          _joinQuiz();
                                      }, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        foregroundColor: Theme.of(context).colorScheme.onSecondary
                                      ),
                                      child: _isLoading?SizedBox(width: 18,height: 18,child: CircularProgressIndicator(),) :Text('Join Quiz!!!'),
                                    ),
                                  ),
                                  const SizedBox(width: 8,),
                                  Expanded(
                                    child: ElevatedButton(onPressed: (){
                                      setState(() {
                                        isHost = !isHost;
                                      });
                                    }, 
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                    ),
                                    child: Text('Login as Host')),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
