import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _username = "", _email = "", _password = "";
  String? _nameError, _passError, _emailError;

  void _navigateToSignup() {
    context.go('/signup');
  }

  bool _validateFields() {
    if (_username.isEmpty) {
      _nameError = "username cannot be empty";
      return false;
    }
    return true;
  }

  void _onNameChanged(String value) {
    setState(() {
      _username = value;
      _nameError = null;
    });
  }

  void _onEmailChanged(String value) {
    setState(() {
      _email = value;
      _emailError = null;
    });
  }

  void _onPassChanged(String value) {
    setState(() {
      _password = value;
      _passError = null;
    });
  }

  Future<void> _onConfirm() async {
    // TODO: logic for logging in
    debugPrint("logging in placeholder");
    // if (_validateFields()) {
    //   try {
    //     final cred = await FirebaseAuth.instance.login(
    //       email: _username.trim(),
    //       password: _password,
    //     );
    //     debugPrint(cred.toString());
    //     context.go('/dashboard');
    //   } on FirebaseAuthException catch (error) {
    //     setState(() {
    //       _passError = error.message;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) => _onEmailChanged(value),
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  errorText: _emailError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) => _onNameChanged(value),
                decoration: InputDecoration(
                  hintText: "Enter your username",
                  errorText: _nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) => _onPassChanged(value),
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  errorText: _passError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              FilledButton(onPressed: () => _onConfirm(), child: Text("Login")),
              TextButton(
                onPressed: () => _navigateToSignup(),
                child: Text("Don't have an account? Sign up ->"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
