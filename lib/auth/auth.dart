import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<UserCredential?> LoginWithGoogle() async {
  //   try {
  //     final googleUser = await GoogleSignIn().signIn();

  //     final googleAuth = await googleUser?.authentication;

  //     final cred = GoogleAuthProvider.credential(
  //         idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);

  //     return await _auth.signInWithCredential(cred);
  //   } catch (e) {
  //     print(e.toString());
  //   }
  //   return null;
  // }

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      exceptionHandler(e.code);
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      log('Unknown error: $e');
      throw e;
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }
}

exceptionHandler(String code) {
  switch (code) {
    case "invalid-credential":
      log("Your login credential are invalid");
    case "weak-password":
      log("Your password must be at least 6 character");
    case "email-already-in-use":
      log("User Already exist");
    default:
      log("Something Went Wrong");
  }
}
