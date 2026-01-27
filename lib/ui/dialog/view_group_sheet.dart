import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/expense_item.dart';
import 'package:expense_v2/ui/dialog/add_expense_to_group_dialog.dart';
import 'package:expense_v2/ui/dialog/view_expense_dialog.dart';
import 'package:flutter/material.dart';

class ViewGroupSheet extends StatefulWidget {
  const ViewGroupSheet({required this.groupName, super.key});

  final String groupName;

  @override
  State<ViewGroupSheet> createState() => _ViewGroupSheetState();
}

class _ViewGroupSheetState extends State<ViewGroupSheet> {
  final expenseRepo = ExpenseRepoFireImpl();
  final groupRepo = GroupRepoFireImpl();

  Group? groupData;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final g = await groupRepo.getGroupByName(widget.groupName);
    if (g != null) {
      setState(() {
        groupData = g;
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

  Future<void> _triggerModal(String? maybeGroupName) async {
    final name = maybeGroupName ?? widget.groupName;
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExpenseToGroupDialog(groupName: name);
      },
    );

    if (result == 'OK') {
      debugPrint("Expense Added Successfully to $name");
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGroupName = groupData?.name ?? widget.groupName;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  stretch: true,
                  pinned: true,
                  floating: false,
                  snap: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(effectiveGroupName),
                  ),
                ),
                StreamBuilder<List<Expense>>(
                  stream: expenseRepo.getAllExpensesInGroup(effectiveGroupName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('Error loading expenses')),
                        ),
                      );
                    }

                    final expenses = snapshot.data ?? [];

                    if (expenses.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'No Expenses found in $effectiveGroupName',
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final expense = expenses[index];
                        return ExpenseItem(
                          expense: expense,
                          onClickItem: (expense) => _showExpenseDialog(expense),
                        );
                      }, childCount: expenses.length),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton.extended(
              onPressed: () => _triggerModal(groupData?.name),
              icon: const Icon(Icons.add),
              label: const Text("Add Expense to Group"),
            ),
          ),
        ],
      ),
    );
  }
}
