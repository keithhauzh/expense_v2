import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/group_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final repo = GroupRepoFireImpl();

  void _navigateToGroupView(String groupName) {
    debugPrint(groupName);
    context.go('/expenses/$groupName');
  }

  void _triggerSort() {
    debugPrint("triggered sort groups");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              StreamBuilder(
                stream: repo.getAllGroups(),
                builder: (context, AsyncSnapshot<List<Group>> asyncData) {
                  if (asyncData.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (asyncData.hasData) {
                    final groups = asyncData.data ?? [];

                    if (groups.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No Groups Found'),
                          ),
                        ),
                      );
                    }

                    return SliverList.builder(
                      itemBuilder: (context, index) => GroupItem(
                        group: groups[index],
                        onClickItem: (group) =>
                            _navigateToGroupView(group.name),
                      ),
                      itemCount: groups.length,
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(asyncData.error.toString())),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        Positioned(
          left: 16.0,
          bottom: 16.0,
          child: FloatingActionButton.extended(
            label: Text("Sort"),
            onPressed: _triggerSort,
            icon: Icon(Icons.sort),
          ),
        ),
      ],
    );
  }
}
