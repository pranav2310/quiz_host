import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quiz_host/quiz/quiz_screen.dart';

class PlayerJoinPage extends StatefulWidget {
  const PlayerJoinPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PlayerJoinPageState();
  }
}

class _PlayerJoinPageState extends State<PlayerJoinPage> {
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
    if (!isValid) return;
    _playerFormKey.currentState!.save();
    final validateEmpId = await _validateEmpId(_empId);
    if (!validateEmpId) return;

    setState(() {
      _isLoading = true;
    });
    final sessionRef = FirebaseDatabase.instance.ref('session/$_quizCode');
    try {
      final sessionSnap = await sessionRef.get();
      if (!sessionSnap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The Quiz Code doesnt exist Enter Valid Quiz Code'),
          ),
        );
        return;
      }
      final playerRef = FirebaseDatabase.instance.ref(
        'session/$_quizCode/players/$_empId',
      );
      final playerSnap = await playerRef.get();
      if (!playerSnap.exists) {
        setState(() {
          _isLoading = false;
        });
        await playerRef.set({'id': _empId, 'name': _playerName, 'score': 0});
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => QuizScreen(
                playerId: _empId,
                sessionId: _quizCode,
                isHost: false,
              ),
            ),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => QuizScreen(
              playerId: _empId,
              sessionId: _quizCode,
              isHost: false,
            ),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Joining as Player')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
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
                        Text(
                          'Welcome to IOCL Quiz Host',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            label: Text('Quiz Code'),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            labelStyle: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
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
                            labelStyle: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
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
                            labelStyle: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
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
                                onPressed: () {},
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
          ),
        ),
      ),
    );
  }
}
