import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LogoutConfirmation extends StatefulWidget {
  const LogoutConfirmation({super.key});

  @override
  State<LogoutConfirmation> createState() => _LogoutConfirmationState();
}

class _LogoutConfirmationState extends State<LogoutConfirmation> {
	final repo = UserRepoFireImpl();

  void _onConfirm() async {
		repo.logout();
		context.go('/login');
	}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Logout Confirmation"),
      content: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Are you sure you want to logout?"),
              SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _onConfirm(),
                child: Text("Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
