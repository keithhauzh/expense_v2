import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final repo = UserRepoFireImpl();
  String _email = "", _username = "", _password = "";
  String? _emailError, _nameError, _passError;

  void _navigateToLogin() {
    context.go('/login');
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

  void _onEmailChanged(String value) {
    setState(() {
      _email = value;
      _emailError = null;
    });
  }

  void _onNameChanged(String value) {
    setState(() {
      _username = value;
      _nameError = null;
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
        await repo.signUp(_email, _username, _password);
        context.go('/dashboard');
      } on FirebaseAuthException catch (e) {
        setState(() {
          _passError = e.toString();
        });
      } on Exception catch (e) {
				// This catch should be showing that username
				// already exists if user tries to use a prexisting
				// username
        setState(() {
          _passError = e.toString();
        });
      } catch (_) {
        setState(() {
          _passError = "Sign up failed, please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign up')),
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
              FilledButton(
                onPressed: () => _onConfirm(),
                child: Text("Sign up"),
              ),
              TextButton(
                onPressed: () => _navigateToLogin(),
                child: Text("Already have an account? Log in ->"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
