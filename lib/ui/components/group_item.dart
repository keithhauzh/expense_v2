import 'package:expense_v2/data/model/group.dart';
import 'package:flutter/material.dart';

class GroupItem extends StatelessWidget {
  const GroupItem({super.key, required this.group, required this.onClickItem});
  final Group group;
  final Function(Group) onClickItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

		// expensesStream = 

    // TODO: make group item show total expense amount
    //  and number of accounts in the group
		// StreamBuilder(stream: stream, builder: builder)
    return GestureDetector(
      onTap: () => onClickItem(group),
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getGroupColor(group.name),
                _getGroupColor(group.name).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Name
                Text(
                  group.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Total Amount and Accounts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$0.00',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '0 accounts',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
