import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:expense_v2/ui/dialog/add_expense_to_group_dialog.dart';
import 'package:expense_v2/ui/dialog/view_expense_dialog.dart';
import 'package:flutter/material.dart';

class ViewGroupDialog extends StatefulWidget {
  const ViewGroupDialog({required this.groupName, super.key});

  final String groupName;

  @override
  State<ViewGroupDialog> createState() => _ViewGroupDialogState();
}

class _ViewGroupDialogState extends State<ViewGroupDialog> {
  final expenseRepo = ExpenseRepoFireImpl();
  final groupRepo = GroupRepoFireImpl();
  Group? group;
  Group? groupData = Group();
  List<Expense>? expenses;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    group = await groupRepo.getGroupByName(widget.groupName);
    if (group != null || expenses != null) {
      setState(() {
        groupData = group!;
      });
    } else {
      debugPrint("group found from groupName is null");
    }
  }

  void _showExpenseDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewExpenseDialog(expense: expense);
      },
    );
  }

  void _triggerModal(String groupName) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExpenseToGroupDialog(groupName: groupName);
      },
    );

    if (result == 'OK') {
      debugPrint(
        "Expense Added Successfully to ${groupData?.name} successfully",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
		return 
  }
}
