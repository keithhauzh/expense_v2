import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/ui/dialog/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';

class SortByCategoryDialog extends StatefulWidget {
  const SortByCategoryDialog({super.key, required this.selectedCategories});

  final List<String> selectedCategories;

  @override
  State<SortByCategoryDialog> createState() => _SortByCategoryDialogState();
}

class _SortByCategoryDialogState extends State<SortByCategoryDialog> {
  final repo = CategoryRepoFireImpl();
  final Map<String, bool> selectedByName = {};

  @override
  void initState() {
    super.initState();
    for (final name in widget.selectedCategories) {
      selectedByName[name] = true;
    }
  }

  void _sortConfirm() {
    final categoriesToBeSortedBy = selectedByName.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    Navigator.of(context).pop(categoriesToBeSortedBy);
  }

  Future<void> _deleteCategory(String docId, String categoryName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );
    
    if (confirmed == true) {
      try {
        await repo.deleteCategoryAndUpdateExpenses(docId, categoryName);
        if (mounted) {
          setState(() {
            selectedByName.remove(categoryName);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category "$categoryName" deleted and expenses updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete category: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Sort by Category"),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                slivers: [
                  StreamBuilder(
                    stream: repo.getAllCategories(),
                    builder:
                        (context, AsyncSnapshot<List<Category>> asyncData) {
                          if (asyncData.connectionState ==
                              ConnectionState.waiting) {
                            return const SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (asyncData.hasData) {
                            final categories = asyncData.data ?? [];

                            for (final category in categories) {
                              selectedByName.putIfAbsent(
                                category.name,
                                () => widget.selectedCategories.contains(
                                  category.name,
                                ),
                              );
                            }

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
                                  final category = categories[index];
                                  final isLast = index == categories.length - 1;
                                  return Column(
                                    children: [
                                      CheckboxListTile(
                                        value: selectedByName[category.name],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            selectedByName[category.name] = value!;
                                          });
                                        },
                                        title: Text(category.name),
                                        secondary: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () => _deleteCategory(
                                            category.docId!,
                                            category.name,
                                          ),
                                          tooltip: 'Delete category',
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
                              child: Center(
                                child: Text(asyncData.error.toString()),
                              ),
                            );
                          }
                        },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _sortConfirm,
                child: Icon(Icons.check),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
