import 'package:expense_v2/data/model/expense.dart';
import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem({
    super.key,
    required this.expense,
    required this.onClickItem,
  });
  final Expense expense;
  final Function(Expense) onClickItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onClickItem(expense),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        elevation: 2,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Name and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      expense.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),


              // Who paid and category
              Row(
                children: [
                  Text(
                    'Paid by: ${expense.whopaid}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (expense.categoryName != null &&
                      expense.categoryName!.isNotEmpty)
                    const SizedBox(width: 8),
                  // Category badge
                  if (expense.categoryName != null &&
                      expense.categoryName!.isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(expense.categoryName!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          expense.categoryName!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),


              // Description and group badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  // Description
                  Expanded(
                    child: Text(
                      expense.description ?? "",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (expense.groupName != null &&
                      expense.groupName!.isNotEmpty)
                    const SizedBox(width: 8),
                  // Group Badge (Bottom Right)
                  if (expense.groupName != null &&
                      expense.groupName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        expense.groupName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFF45B7D1),
      Color(0xFFFFA07A),
      Color(0xFF98D8C8),
      Color(0xFFF7DC6F),
      Color(0xFFBB8FCE),
      Color(0xFF85C1E2),
    ];
    final hash = groupName.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
