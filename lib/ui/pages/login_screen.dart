import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final repo = UserRepoFireImpl();

  String _username = "", _email = "", _password = "";
  String? _nameError, _passError, _emailError;

  void _navigateToSignup() {
    context.go('/signup');
  }

  bool _validateFields() {
    if (_email.isEmpty) {
      _emailError = "email cannot be empty";
      return false;
    }
    if (_username.isEmpty) {
      _nameError = "username cannot be empty";
      return false;
    }
    if (_password.isEmpty) {
      _passError = "password cannot be empty";
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

  void _onConfirm() async {
    if (_validateFields()) {
      try {
        await repo.login(_email, _password);
        context.go("/dashboard");
      } on FirebaseAuthException catch (e) {
        setState(() {
          _nameError = e.toString();
        });
      } catch (e) {
        setState(() {
          _passError = "Login failed, please try again";
        });
      }
    }
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
