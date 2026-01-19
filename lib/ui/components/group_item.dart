import 'package:expense_v2/data/model/group.dart';
import 'package:flutter/material.dart';

class GroupItem extends StatelessWidget {
  const GroupItem({super.key, required this.group, required this.onClickItem});
  final Group group;
  final Function(Group) onClickItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClickItem(group),
      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(group.name),
            Text(
              group.description == null || group.description!.isEmpty
                  ? "No description."
                  : group.description!,
            ),
          ],
        ),
      ),
    );
  }
}
