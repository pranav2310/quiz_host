import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_host/landing_page/host_login_page.dart';

final _firebase = FirebaseAuth.instance;

class HostSignupPage extends StatefulWidget{
  const HostSignupPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HostSignupPageState();
  }
}

class _HostSignupPageState extends State<HostSignupPage>{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;

  void _signUp()async{
    setState(() {
      _isLoading = true;
    });
    if(!_formKey.currentState!.validate()){
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try{
      final userCred = await _firebase.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim()
      );
      await userCred.user?.updateDisplayName(_nameController.text.trim());
      if(mounted){
        Navigator.push(context, MaterialPageRoute(builder: (_)=>HostLoginPage()));
      }
    }on FirebaseAuthException catch(e){
      String message;
      switch(e.code){
        case 'email-already-in-use':
        message = 'This email is already registered.';
        break;
      case 'invalid-email':
        message = 'Invalid email address.';
        break;
      case 'weak-password':
        message = 'Password must be at least 6 characters.';
        break;
      default:
        message = e.message ?? 'Signup failed.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $e')));
    }finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Host Signup'),),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome to IOCL Quiz Host',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold
                ),
                        ),
                        const SizedBox(height: 16,),
                        TextFormField(
                          decoration: InputDecoration(
                          label: Text('Enter Name'),
                          border: OutlineInputBorder(),
                          filled: true
                          ),
                          controller: _nameController,
                          validator: (value) {
                            if(value==null || value.trim().isEmpty){
                              return 'This Field Cannot be left Empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16,),
                        TextFormField(
                          decoration: InputDecoration(
                          label: Text('Enter Email Address'),
                          border: OutlineInputBorder(),
                          filled: true
                          ),
                          controller: _emailController,
                          validator: (value) {
                            if(value==null || value.trim().isEmpty){
                              return 'This Field Cannot be left Empty';
                            }
                            if(!value.contains('@')){
                              return 'Enter Valid Email Addres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16,),
                        TextFormField(
                          decoration: InputDecoration(
                          label: Text('Enter Password'),
                          border: OutlineInputBorder(),
                          filled: true
                          ),
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if(value==null || value.trim().isEmpty){
                              return 'This Field Cannot be left Empty';
                            }
                            if(value.length<6){
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16,),
                        TextFormField(
                          decoration: InputDecoration(
                            label: Text('Re-Enter Password'),
                            border: OutlineInputBorder(),
                            filled: true
                          ),
                          obscureText: true,
                          validator: (value){
                            if(value == null || value.trim().isEmpty){
                              return 'Please Enter your Password';
                            }
                            if(value != _passwordController.text){
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                          ),
                          onPressed: _isLoading?null:_signUp, 
                          child:  _isLoading ?SizedBox(height:18,width: 18,child:  CircularProgressIndicator(strokeWidth: 2,) ,):Text('Sign Up') 
                        )
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