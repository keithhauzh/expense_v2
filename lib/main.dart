import 'package:expense_v2/firebase_options.dart';
import 'package:expense_v2/navigation/navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final navigation = Navigation();
  runApp(MaterialApp.router(routerConfig: navigation.router));
}
