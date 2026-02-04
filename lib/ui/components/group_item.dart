import 'package:expense_v2/data/model/group.dart';
import 'package:flutter/material.dart';

class GroupItem extends StatelessWidget {
  const GroupItem({super.key, required this.group, required this.onClickItem});
  final Group group;
  final Function(Group) onClickItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription =
        group.description != null && group.description!.isNotEmpty;

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
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Text(
                  group.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasDescription)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      group.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

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
