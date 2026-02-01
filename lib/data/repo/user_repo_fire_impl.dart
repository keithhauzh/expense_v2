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
		debugPrint("email: $email,  username: $username,  password: $password");
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    await _collection.doc(uid).set({
      'uid': uid,
      'email': email.trim(),
      'username': username,
    });
    return cred;
  }
}
