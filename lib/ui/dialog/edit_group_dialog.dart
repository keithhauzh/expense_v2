import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:flutter/material.dart';

class EditGroupDialog extends StatefulWidget {
  final Group group;
  
  const EditGroupDialog({super.key, required this.group});

  @override
  State<EditGroupDialog> createState() => _EditGroupDialogState();
}

class _EditGroupDialogState extends State<EditGroupDialog> {
  final repo = GroupRepoFireImpl();

  late String _description;
  String? _descError;
  
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _description = widget.group.description ?? '';
    _nameController = TextEditingController(text: widget.group.name);
    _descController = TextEditingController(text: _description);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onDescChanged(String value) {
    setState(() {
      _description = value;
      _descError = null;
    });
  }

  void _onConfirm() async {
    try {
      final updatedGroup = widget.group.copy(description: _description);
      await repo.updateGroup(updatedGroup);
      if (!mounted) return;
      Navigator.pop(context, 'OK');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group updated successfully')),
      );
    } catch (e) {
      setState(() {
        _descError = "Failed to update group: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Group"),
      content: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                enabled: false,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name (cannot be changed)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) => _onDescChanged(value),
                controller: _descController,
                minLines: 3,
                maxLines: null,
                maxLength: 500,
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
