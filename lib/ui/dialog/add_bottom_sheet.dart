import 'package:expense_v2/ui/dialog/add_category_dialog.dart';
import 'package:expense_v2/ui/dialog/add_existing_expense_to_category_dialog.dart';
import 'package:expense_v2/ui/dialog/add_expense_dialog.dart';
import 'package:flutter/material.dart';

class AddBottomSheet extends StatelessWidget {
  const AddBottomSheet({super.key});

  void _showDialog(BuildContext context, Widget dialog) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.receipt_long,
            label: "Add Expense",
            onPressed: () => _showDialog(context, AddExpenseDialog()),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.category,
            label: "Add Category",
            onPressed: () => _showDialog(context, AddCategoryDialog()),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.link,
            label: "Link Expense",
            onPressed: () =>
                _showDialog(context, AddExistingExpenseToCategoryDialog()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(60),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
