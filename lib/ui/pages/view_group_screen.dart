import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/expense_item.dart';
import 'package:expense_v2/ui/dialog/add_expense_to_group_dialog.dart';
import 'package:expense_v2/ui/dialog/view_expense_dialog.dart';
import 'package:flutter/material.dart';

class ViewGroupScreen extends StatefulWidget {
  const ViewGroupScreen({required this.groupName, super.key});

  final String groupName;

  @override
  State<ViewGroupScreen> createState() => _ViewGroupScreenState();
}

class _ViewGroupScreenState extends State<ViewGroupScreen> {
  final expenseRepo = ExpenseRepoFireImpl();
  final groupRepo = GroupRepoFireImpl();
  Group? group;
  Group groupData = Group();
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
        "Expense Added Successfully to ${groupData.name} successfully",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                stretch: true,
                pinned: true,
                floating: false,
                snap: false,
                flexibleSpace: FlexibleSpaceBar(title: Text(groupData.name)),
              ),
              StreamBuilder(
                stream: expenseRepo.getAllExpensesInGroup(groupData.name),
                builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                  if (asyncData.connectionState == ConnectionState.waiting) {
                    // Using non Sliver widgets necessitates a SliverToBoxAdapter
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (asyncData.hasData) {
                    final expenses = asyncData.data ?? [];
                    if (expenses.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No Expenses found in ${groupData.name}',
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList.builder(
                      itemBuilder: (context, index) => ExpenseItem(
                        expense: expenses[index],
                        onClickItem: (expense) => _showExpenseDialog(expense),
                      ),
                      itemCount: expenses.length,
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(asyncData.error.toString())),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        Positioned(
          right: 16.0,
          bottom: 16.0,
          child: FloatingActionButton.extended(
            onPressed: () => _triggerModal(groupData.name),
            icon: Icon(Icons.add),
            label: Text("Add Expense to Group"),
          ),
        ),
      ],
    );
  }
}
