import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/session.dart';

class AuthService {
  final _firebase = FirebaseAuth.instance;

  Future<UserCredential> login(String email, String password)async{
    return _firebase.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password, String name)async{
    final userCred = await _firebase.createUserWithEmailAndPassword(email: email, password:password);
    await userCred.user?.updateDisplayName(name);
    return userCred;
  }

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

  Future<bool> playerJoin(String sessionId, Player player)async{
    final validateEmpId = await _validateEmpId(player.id);
    if (!validateEmpId){
      throw Exception('Invalid Employee Id');
    }
    final sessionRef = FirebaseDatabase.instance.ref('session/$sessionId');
    final sessionSnap = await sessionRef.get();

    if(!sessionSnap.exists){
      throw Exception('The Quiz Code does not exist');
    }

    final playerRef = sessionRef.child('players/${player.id}');
    final playerSnap = await playerRef.get();

    if(!playerSnap.exists){
      await playerRef.set({'id':player.id,'name':player.name,'score':0});
      return true;
    }
    return false;
  }
}

final authServiceProvider = Provider<AuthService>((ref)=>AuthService());