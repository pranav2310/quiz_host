import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quiz_host/quiz/quiz_screen.dart';
import 'package:http/http.dart' as http;

class PlayerSignup extends StatefulWidget {
  const PlayerSignup({super.key,required this.onToggle});
  final VoidCallback onToggle;

  @override
  State<StatefulWidget> createState() {
    return _PlayerSignupState();
  }
}

class _PlayerSignupState extends State<PlayerSignup> {
  final _playerFormKey = GlobalKey<FormState>();
  var _quizCode = '';
  var _isLoading = false;
  var _playerName = '';
  var _empId = '';
  bool isHost = false;

  
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
      final playerResponse = await http.get(playerUrl);
      if(playerResponse.statusCode == 200 && playerResponse.body!='null'){
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
        return;
      }
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
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
                      labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'Enter a valid Quiz Code';
                      }
                      return null;
                    },
                    onSaved: (newValue) => _quizCode = newValue!,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      label: Text('Player Name'),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Do not leave this Field Empty';
                      }
                      return null;
                    },
                    onSaved: (newValue) => _playerName = newValue!,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      label: Text('Employee Id '),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Do not leave this Field Empty';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_empIdError != null) {
                        setState(() {
                          _empIdError = null;
                        });
                      }
                    },
                    onSaved: (newValue) => _empId = newValue!,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _joinQuiz();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(),
                                )
                              : Text('Join Quiz!!!'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onToggle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                          ),
                          child: Text('Login as Host'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
