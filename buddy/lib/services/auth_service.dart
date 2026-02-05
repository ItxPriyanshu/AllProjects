import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  //Email+ PAss sign up//
  //ensuring the class should get email and pass
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  //Email + Password Login//
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }


  //Google Sign in /signup//
Future<User?> signInWithGoogle()async{
  final googleUser = await _googleSignIn.signIn();
  if(googleUser == null) return null;
  final googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCred = await _auth.signInWithCredential(credential);
  return userCred.user;
}

Future<void> logout()async{
  await _auth.signOut();
}
}



