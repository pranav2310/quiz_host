import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/landing_page/auth_service.dart';
import 'package:quiz_host/models/session.dart';
import 'package:quiz_host/quiz/quiz_screen.dart';

class PlayerJoinPage extends ConsumerStatefulWidget {
  const PlayerJoinPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlayerJoinPageState();
  }
}

class _PlayerJoinPageState extends ConsumerState<PlayerJoinPage> {
  final _playerFormKey = GlobalKey<FormState>();
  var _quizCode = '';
  var _isLoading = false;
  var _playerName = '';
  var _empId = '';
  bool isHost = false;

  String? _empIdError;

  Future<void> _joinQuiz() async {
    final isValid = _playerFormKey.currentState!.validate();
    if (!isValid) return;
    _playerFormKey.currentState!.save();
    final Player player = Player(id: _empId, name: _playerName);

    setState(() {
      _isLoading = true;
    });
    try{
      final newPlayer = await ref.read(authServiceProvider).playerJoin(_quizCode, player);
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
    }catch (e) {
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Card(
                color: Theme.of(context).colorScheme.primary,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AbsorbPointer(
                      absorbing: _isLoading,
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
        ),
      ),
    );
  }
}
