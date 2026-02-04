import 'package:expense_v2/firebase_options.dart';
import 'package:expense_v2/navigation/navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final navigation = Navigation();
  runApp(
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: navigation.router,
      theme: _buildTheme(),
    ),
  );
}

ThemeData _buildTheme() {
  final base = ThemeData.light();
  
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(fontSize: 64),
      displayMedium: base.textTheme.displayMedium?.copyWith(fontSize: 48),
      displaySmall: base.textTheme.displaySmall?.copyWith(fontSize: 40),
      
      headlineLarge: base.textTheme.headlineLarge?.copyWith(fontSize: 40),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontSize: 32),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(fontSize: 28),
      
      titleLarge: base.textTheme.titleLarge?.copyWith(fontSize: 22),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontSize: 18),
      titleSmall: base.textTheme.titleSmall?.copyWith(fontSize: 16),
      
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 18),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 16),
      bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 14),
      
      labelLarge: base.textTheme.labelLarge?.copyWith(fontSize: 16),
      labelMedium: base.textTheme.labelMedium?.copyWith(fontSize: 14),
      labelSmall: base.textTheme.labelSmall?.copyWith(fontSize: 12),
    ),
  );
}
