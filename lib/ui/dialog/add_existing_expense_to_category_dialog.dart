import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddExistingExpenseToCategoryDialog extends StatefulWidget {
  const AddExistingExpenseToCategoryDialog({super.key});

  @override
  State<AddExistingExpenseToCategoryDialog> createState() =>
      _AddExistingExpenseToCategoryDialogState();
}

class _AddExistingExpenseToCategoryDialogState
    extends State<AddExistingExpenseToCategoryDialog> {
  final userRepo = UserRepoFireImpl();
  final categoryRepo = CategoryRepoFireImpl();
  final expenseRepo = ExpenseRepoFireImpl();
  Category? category;
  Category categoryData = Category();
  List<Expense> expenses = <Expense>[];
  List<bool> expenseBools = <bool>[];
  String? _selectedCategoryName;
  String? username;
  bool _loading = true;

  Future<void> _init(BuildContext context) async {
		// TODO: move this to a helper function?

		// We are using _init() here to check for 
		// the current logged in user and also
		// to assign the username to a variable
		// that we use to fetch the respective documents.
		//
		// If username doesn't exist (user is not logged in),
		// we send user back to the login screen
    try {
      // We use mounted here to prevent state problems
      // with navigation
      //
      // mounted is used for checking if
      // the state object we are operating on
      // is currently active in the widget tree
      // this is helps avoid erros when performing
      // async operations
      username = await userRepo.getUsername();
      if (username == null || username!.isEmpty) {
        if (mounted) context.go('/login');
        debugPrint("Please sign in first.");
        return;
      }
			// We set _loading to be false if username
			// is not null
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _init(context);
  }

  void _onConfirm(List<bool> expenseBools, List<Expense> expenses) async {
    List<Expense> expensesToBeAdded = [];
    for (int i = 0; i < expenseBools.length; i++) {
      if (expenseBools[i]) {
        expensesToBeAdded.add(expenses[i]);
      }
    }
    if (expensesToBeAdded.isNotEmpty && _selectedCategoryName != null) {
      Expense? currentExpense;
      for (Expense expense in expensesToBeAdded) {
        currentExpense = Expense(
          docId: expense.docId,
          name: expense.name,
          amount: expense.amount,
          description: expense.description,
          groupName: expense.groupName,
          categoryName: _selectedCategoryName,
          whopaid: expense.whopaid,
        );
        debugPrint(currentExpense.toString());
        expenseRepo.updateExpense(currentExpense);
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } else {
      // TODO: add a dialog for showing error?
      if (!mounted) return;
      Navigator.of(context).pop();
      debugPrint("expenses is empty or selected category is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add existing expense to a category"),
      // We need a sized box, so that the scroll view will have restraints
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: StreamBuilder<List<Category>>(
                              stream: categoryRepo.getAllCategories(),
                              builder:
                                  (
                                    context,
                                    AsyncSnapshot<List<Category>> asyncData,
                                  ) {
                                    if (_loading ||asyncData.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    if (asyncData.hasError) {
                                      return const SizedBox();
                                    }
                                    final categories = asyncData.data ?? [];
                                    return DropdownButton<String>(
                                      value: _selectedCategoryName,
                                      items: categories
                                          .where(
                                            (category) =>
                                                category.docId != null,
                                          )
                                          .map(
                                            (category) => DropdownMenuItem(
                                              value: category.name,
                                              child: Text(category.name),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (categoryName) => setState(() {
                                        _selectedCategoryName = categoryName;
                                      }),
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                    );
                                  },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Example expenses stream - every branch returns a Sliver
                  StreamBuilder<List<Expense>>(
                    stream: expenseRepo.getAllExpensesWithoutCategoryForCurrentUser(username!),
                    builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                      if (asyncData.connectionState ==
                          ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      if (asyncData.hasError) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Text(asyncData.error.toString()),
                          ),
                        );
                      }

                      expenses = asyncData.data ?? [];

                      if (expenses.length != expenseBools.length) {
                        expenseBools = List<bool>.filled(
                          expenses.length,
                          false,
                        );
                      }

                      if (expenses.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text('No expenses available')),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: expenses.length,
                          (context, index) {
                            final isLast = index == expenses.length - 1;
                            return Column(
                              children: [
                                CheckboxListTile(
                                  value: expenseBools[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      expenseBools[index] = value!;
                                    });
                                  },
                                  title: Text(expenses[index].name),
                                ),
                                if (!isLast) const Divider(height: 1),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _onConfirm(expenseBools, expenses);
                },
                icon: Icon(Icons.check),
                label: Text("Confirm selection"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
