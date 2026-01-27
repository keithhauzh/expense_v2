import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:flutter/material.dart';

class AddExistingExpensesToCategoryScreen extends StatefulWidget {
  const AddExistingExpensesToCategoryScreen({
    required this.categoryId,
    super.key,
  });

  final String categoryId;

  @override
  State<AddExistingExpensesToCategoryScreen> createState() =>
      _AddExistingExpensesToCategoryScreenState();
}

class _AddExistingExpensesToCategoryScreenState
    extends State<AddExistingExpensesToCategoryScreen> {
  final categoryRepo = CategoryRepoFireImpl();
  final expenseRepo = ExpenseRepoFireImpl();
  Category? category;
  Category categoryData = Category();
  List<Expense>? expense;
  List<bool> expenseBools = <bool>[];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              // SliverAppBar(
              //   stretch: true,
              //   pinned: true,
              //   floating: false,
              //   snap: false,
              //   flexibleSpace: const FlexibleSpaceBar(),
              // ),
              StreamBuilder(
                stream: expenseRepo.getAllExpensesWithoutCategory(),
                builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                  if (asyncData.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (asyncData.hasData) {
                    final expenses = asyncData.data ?? [];

                    // to ensure both lists have the same length
                    if (expenseBools.length != expenses.length) {
                      expenseBools = List<bool>.filled(expenses.length, false);
                    }

                    if (expenses.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No Expenses found in ${categoryData.name}',
                            ),
                          ),
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
                                // safe to index now
                                value: expenseBools[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    expenseBools[index] = value!;
                                  });
                                },
                                // TODO: add functionality for adding expenses to category (confirm button)
                                title: Text(expenses[index].name),
                                subtitle: Text(
                                  expenses[index].description ??
                                      "No description",
                                ),
                              ),
                              if (!isLast) const Divider(height: 1),
                            ],
                          );
                        },
                      ),
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
      ],
    );
  }
}
