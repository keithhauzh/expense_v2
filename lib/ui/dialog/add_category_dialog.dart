import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:flutter/material.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final repo = CategoryRepoFireImpl();

  String _name = "";
  String? _nameError;

  bool _validateFields() {
    if (_name.isEmpty) {
      setState(() {
        _nameError = "Name cannot be empty";
      });
      return false;
    }
    return true;
  }

  void _onNameChanged(String value) {
    setState(() {
      _name = value;
      _nameError = null;
    });
  }

  void _onConfirm() async {
    if (_validateFields()) {
      final category = Category(name: _name);
      try {
        await repo.addCategory(category);
        Navigator.pop(context, 'OK');
        debugPrint("Successfully added a category: $_name");
      } on Exception catch (e) {
        setState(() {
          _nameError = e.toString();
        });
      }
    } else {
      debugPrint("Failed to add category $_name");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Category"),
      content: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextField(
                onChanged: (value) => _onNameChanged(value),
                decoration: InputDecoration(
                  hintText: "Enter Name",
                  errorText: _nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              FilledButton(
                onPressed: () => _onConfirm(),
                child: Text("Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
