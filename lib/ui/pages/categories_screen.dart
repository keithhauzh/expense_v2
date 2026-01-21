import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/category_item.dart';
import 'package:expense_v2/ui/dialog/add_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final categoryRepo = CategoryRepoFireImpl();
  final expenseRepo = ExpenseRepoFireImpl();

  void _viewCategory(String? categoryId) {
    if (categoryId == null) {
      debugPrint("Invalid category id");
    } else {
      context.go('/categories/$categoryId');
    }
  }

  void _triggerModal() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCategoryDialog();
      },
    );

    if (result == 'OK') {
      debugPrint("Category Added Successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Using a stack allows us to position certain elements, in this case, a FloatingActionButton widget
      // at a certain point in the window, we use Positioned widgets to do this, the reason i am using
      // this implementation instead of a Scaffold and FloatingActionButton is because you should not
      // nest Scaffold widgets within Scaffold widgets
      // this page is a nested class inside of main.dart
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                stretch: true,
                pinned: true,
                floating: false,
                snap: false,
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text('Categories'),
                ),
              ),
              StreamBuilder(
                stream: categoryRepo.getAllCategories(),
                builder: (context, AsyncSnapshot<List<Category>> asyncData) {
                  if (asyncData.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (asyncData.hasData) {
                    final categories = asyncData.data ?? [];
                    if (categories.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No categories are available'),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: categories.length,
                        (context, index) {
                          return Column(
                            children: [
                              CategoryItem(
                                category: categories[index],
                                onClickItem: (category) =>
                                    _viewCategory(category.docId),
                              ),
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
