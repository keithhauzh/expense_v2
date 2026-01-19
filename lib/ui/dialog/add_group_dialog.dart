import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:flutter/material.dart';

class AddGroupDialog extends StatefulWidget {
  const AddGroupDialog({super.key});

  @override
  State<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  final repo = GroupRepoFireImpl();

  String _name = "", _description = "";
  double _totalExpenseAmount = 0.0;
  String? _nameError, _descError, _totalExpenseAmountError;

  bool _validateFields(){
    final nameError = _name.isEmpty ? "Name cannot be empty" : null;
    final descError = _description.isEmpty ? "Description cannot be empty" : null;
    setState(() {
      _nameError = nameError;
      _descError = descError;
    });
    if(_name.isEmpty||_description.isEmpty){
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

  void _onDescChanged(String value) {
    setState(() {
      _description = value;
      _descError = null;
    });
  }

  void _onCancel() {
    Navigator.pop(context, "Cancel");
    print("Cancelled creation");
  }

  void _onConfirm() async {
    if(_validateFields()){
      final group = Group(name: _name, description: _description);
      await repo.addGroup(group);
      Navigator.pop(context, 'OK');
      print("Successfully added a group: $_name, $_description");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Group"),
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
              SizedBox(height: 10),
              TextField(
                onChanged: (value) => _onDescChanged(value),
                decoration: InputDecoration(
                  hintText: "Enter Description",
                  errorText: _descError,
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
