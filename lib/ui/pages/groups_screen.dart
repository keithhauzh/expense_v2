import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/group_item.dart';
import 'package:expense_v2/ui/dialog/add_group_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final repo = GroupRepoFireImpl();

  void _navigateToGroupView(String groupId) async {
    context.go('/groups/$groupId');
  }

  void _triggerModal() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddGroupDialog();
      },
    );

    if (result == 'OK') {
      debugPrint("Expense Added Successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                stretch: true,
                pinned: true,
                floating: false,
                snap: false,
                flexibleSpace: const FlexibleSpaceBar(title: Text('Groups')),
              ),
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
                            _navigateToGroupView(group.docId!),
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
          right: 16.0,
          bottom: 16.0,
          child: FloatingActionButton(
            onPressed: _triggerModal,
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
