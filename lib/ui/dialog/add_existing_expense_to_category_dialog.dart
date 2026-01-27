import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:flutter/material.dart';

class AddExistingExpenseToCategoryDialog extends StatefulWidget {
  const AddExistingExpenseToCategoryDialog({super.key});

  @override
  State<AddExistingExpenseToCategoryDialog> createState() =>
      _AddExistingExpenseToCategoryDialogState();
}

class _AddExistingExpenseToCategoryDialogState
    extends State<AddExistingExpenseToCategoryDialog> {
  Category? category;
  Category categoryData = Category();
  List<Expense>? expenses;
  List<bool> expenseBools = <bool>[];
  Category? _selectedValue;
  final categoryRepo = CategoryRepoFireImpl();
  final expenseRepo = ExpenseRepoFireImpl();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add existing expense to a category"),
      // We need a sized box, so that the scroll view will have restraints
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
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
                        builder: (ctx, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          if (snap.hasError) return const SizedBox();
                          final categories = snap.data ?? [];
                          return DropdownButton<Category>(
                            value: _selectedValue,
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (c) =>
                                setState(() => _selectedValue = c),
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
              stream: expenseRepo.getAllExpensesWithoutCategory(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (snap.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text(snap.error.toString())),
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('No expenses available')),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (c, i) => ListTile(title: Text(items[i].name)),
                    childCount: items.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
