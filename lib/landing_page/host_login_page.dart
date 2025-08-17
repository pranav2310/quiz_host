import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/home/home_screen.dart';
import 'package:quiz_host/landing_page/auth_service.dart';
import 'package:quiz_host/landing_page/host_signup_page.dart';

class HostLoginPage extends ConsumerStatefulWidget {
  const HostLoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HostLoginPageState();
  }
}

class _HostLoginPageState extends ConsumerState<HostLoginPage> {
  var _enteredEmail = '';
  var _enteredPassword = '';
  final _hostFormKey = GlobalKey<FormState>();
  var _isLoading = false;
  bool isHost = false;
  void _submit() async {
    final isValid = _hostFormKey.currentState!.validate();
    if (!isValid) return;

    _hostFormKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      final userCreds = await ref.read(authServiceProvider).login(_enteredEmail, _enteredPassword);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(hostId: userCreds.user!.uid, hostName:userCreds.user!.displayName??''),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error : $e')));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Host Login')),
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
                        key: _hostFormKey,
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
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                label: Text('Email Address'),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
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
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
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
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Text('Login'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HostSignupPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Create an Account',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
