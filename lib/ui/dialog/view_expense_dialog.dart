import 'package:expense_v2/data/model/expense.dart';
import 'package:flutter/material.dart';

class ViewExpenseDialog extends StatelessWidget {
  const ViewExpenseDialog({
    required this.expense,
    super.key
  });

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        expense.name,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount - Prominent Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Paid By
            _buildDetailRow(
              context,
              'Paid by',
              expense.whopaid,
              Icons.person,
            ),
            const SizedBox(height: 16),

            // Group
            if (expense.groupName?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getGroupColor(expense.groupName!),
                          _getGroupColor(expense.groupName!)
                              .withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getGroupColor(expense.groupName!)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expense.groupName!,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              
            // Category
            if (expense.categoryName?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor(expense.categoryName!),
                          _getCategoryColor(expense.categoryName!)
                              .withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getCategoryColor(expense.categoryName!)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.label,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expense.categoryName!,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Description
            if (expense.description != null &&
                expense.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[200]!,
                      ),
                    ),
                    child: Text(
                      expense.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Generate consistent color for category badge based on category name
	//
	// Essentially, we are generating a hascode for the category name, 
	// every string has a hashcode that will never change, so this means
	// that every distinct category name will have the same color
	// regardless of app reload 
	// 
	// Then we use .abs to ensure we convert negative hash codes
	// to be positive, also giving a number between 0 and the length of
	// categories, ensuring we never get an index that is out of bounds
  Color _getCategoryColor(String category) {
    const colors = [
      Color(0xFFEF5350),
      Color(0xFF42A5F5),
      Color(0xFF66BB6A),
      Color(0xFFFFCA28),
      Color(0xFFAB47BC),
      Color(0xFF26C6DA),
      Color(0xFFEC407A),
      Color(0xFFFFB74D),
    ];
    final hash = category.hashCode;
    return colors[hash.abs() % colors.length];
  }

  // Generate consistent color for group badge based on group name (with hashcode)
  Color _getGroupColor(String groupName) {
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF3B82F6),
      Color(0xFF1D4ED8),
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
      Color(0xFFEA580C),
      Color(0xFFD97706),
      Color(0xFF059669),
    ];
    final hash = groupName.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
