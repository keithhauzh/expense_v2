import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class UserRepoFireImpl {
  static final UserRepoFireImpl _instance = UserRepoFireImpl._internal();
  UserRepoFireImpl._internal();

  factory UserRepoFireImpl() {
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("users");

  Future<UserCredential> signUp(
    String email,
    String username,
    String password,
  ) async {
		// Don't do a try and catch here, we do in the frontend side so we 
		// can setState and show error
		// to the user
    debugPrint("email: $email,  username: $username,  password: $password");
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final uid = cred.user!.uid;
    await _collection.doc(uid).set({
      'uid': uid,
      'email': email.trim(),
      'username': username,
    });
    return cred;
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint("Firestore error: ${e.toString()}");
    } catch (_) {
      debugPrint("Failed to log out");
    }
  }

  Future<UserCredential> login(String email, String password) async {
		// Don't do a try and catch here (2)
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return cred;
  }
}
