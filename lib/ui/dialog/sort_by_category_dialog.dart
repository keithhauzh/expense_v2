import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:flutter/material.dart';

class SortByCategoryDialog extends StatefulWidget {
  const SortByCategoryDialog({super.key});

  @override
  State<SortByCategoryDialog> createState() => _SortByCategoryDialogState();
}

class _SortByCategoryDialogState extends State<SortByCategoryDialog> {
  final repo = CategoryRepoFireImpl();
  List<bool> categoryBools = <bool>[];
  List<Category> categories = <Category>[];

  void _sortConfirm() {
    List<String> categoriesToBeSortedBy = [];
    for (int i = 0; i < categories.length; i++) {
      if (categoryBools[i]) {
        categoriesToBeSortedBy.add(categories[i].name);
      }
    }
    Navigator.of(context).pop(categoriesToBeSortedBy);
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
                             categories = asyncData.data ?? [];

                            if (categories.length != categoryBools.length) {
                              categoryBools = List<bool>.filled(
                                categories.length,
                                false,
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
                                  final isLast = index == categories.length - 1;
                                  return Column(
                                    children: [
                                      CheckboxListTile(
                                        value: categoryBools[index],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            categoryBools[index] = value!;
                                          });
                                        },
                                        title: Text(categories[index].name),
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
