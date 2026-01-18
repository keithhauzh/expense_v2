import 'package:expense_v2/ui/dialog/add_category_dialog.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreen();
}

class _CategoriesScreen extends State<CategoriesScreen> {
  void _triggerModal() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCategoryDialog();
      },
    );

    if (result == 'OK') {
      print("Categories added successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Using a stack allows us to position certain elements, in this case, a FloatingActionButton widget
      // at a certain point in the window, we use Positioned widgets to do this, the reason i am using
      // this implementation instead of a Scaffold and FloatingActionButton is because you should not
      // nest Scaffold widgets within Scaffold widgets (this page is a nested class inside of main.dart)
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),

        // We position the FloatingActionButton on this page to be on the bottom right
        // in this window
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
