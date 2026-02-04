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

  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<UserCredential> signUp(
    String email,
    String username,
    String password,
  ) async {
    final normUsername = username.trim();
    final normEmail = email.trim();

    // Check if username is already taken
    final user = await _collection
        .where('username', isEqualTo: normUsername)
        .limit(1)
        .get();
    if (user.docs.isNotEmpty) {
      // This exception needs to be caught at the
      // try and catch at the frontend side
      // to be displayed to the user
      throw Exception('username is taken');
    } else {
      // Don't do a try and catch here, we do in the frontend side so we
      // can setState and show error
      // to the user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: normEmail,
        password: password.trim(),
      );
      final uid = cred.user!.uid;
      await _collection.doc(uid).set({
        'uid': uid,
        'email': normEmail,
        'username': normUsername,
      });
      return cred;
    }
  }

  Future<void> logout() async {
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

  Future<String> getUsername() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    String uid = "";
    if (currentUser == null) {
      throw Exception("Please sign in first.");
    } else {
      uid = currentUser.uid;
    }
    final user = await _collection.doc(uid).get();
    final username = (user.data()?['username'] as String?) ?? '';
    return username;
  }
}
