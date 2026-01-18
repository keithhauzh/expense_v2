import 'package:expense_v2/ui/dialog/add_group_dialog.dart';
import 'package:flutter/material.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  void _triggerModal() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddGroupDialog();
      },
    );

    if (result == 'OK') {
      print("Expense Added Successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Text('Groups', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),

        Positioned(
          right: 16.0,
          bottom: 16.0,
          child: FloatingActionButton(
            onPressed: _triggerModal,
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
