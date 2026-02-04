import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/expense_item.dart';
import 'package:expense_v2/ui/dialog/add_expense_to_group_dialog.dart';
import 'package:expense_v2/ui/dialog/delete_confirmation_dialog.dart';
import 'package:expense_v2/ui/dialog/edit_group_dialog.dart';
import 'package:expense_v2/ui/dialog/view_expense_dialog.dart';
import 'package:flutter/material.dart';

class ViewGroupDialog extends StatefulWidget {
  const ViewGroupDialog({required this.groupName, super.key});

  final String groupName;

  @override
  State<ViewGroupDialog> createState() => _ViewGroupDialogState();
}

class _ViewGroupDialogState extends State<ViewGroupDialog> {
  final expenseRepo = ExpenseRepoFireImpl();
  final groupRepo = GroupRepoFireImpl();

  Group? groupData;
  DateTime selectedMonth = DateTime.now();

  late Stream<List<Expense>> _expensesStream;
  String? _currentStreamGroupName;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final g = await groupRepo.getGroupByName(widget.groupName);
    if (g != null) {
      setState(() {
        groupData = g;
      });
      _updateExpensesStream(g.name);
    } else {
      debugPrint("group found from groupName is null");
      _updateExpensesStream(widget.groupName);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final name = groupData?.name ?? widget.groupName;
    _updateExpensesStream(name);
  }

  void _updateExpensesStream(String groupName) {
    if (_currentStreamGroupName == groupName) return;
    _expensesStream = expenseRepo
        .getAllExpensesInGroup(groupName)
        .asBroadcastStream();
    _currentStreamGroupName = groupName;
  }

  void _showExpenseDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewExpenseDialog(expense: expense);
      },
    );
  }

  Future<void> _editGroup(BuildContext context) async {
    Group? group = groupData;
    if (group == null) {
      final groupQuery = await FirebaseFirestore.instance
          .collection("groups")
          .where('name', isEqualTo: widget.groupName)
          .limit(1)
          .get();

      if (groupQuery.docs.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Group not found')));
        }
        return;
      }

      group = Group.fromMap(
        groupQuery.docs.first.data(),
      ).copy(docId: groupQuery.docs.first.id);
    }

    final result = await showDialog(
      context: context,
      builder: (context) => EditGroupDialog(group: group!),
    );

    if (result == 'OK') {
      _init();
    }
  }

  Future<void> _deleteGroup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );

    if (confirmed == true) {
      final groupNameToDelete = groupData?.name ?? widget.groupName;
      try {
        await groupRepo.deleteGroupWithExpenses(groupNameToDelete);
        if (context.mounted) {
          Navigator.of(context).pop('deleted');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Group and all expenses deleted successfully'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete group: $e')));
        }
      }
    }
  }

  Future<void> _triggerModal(String? maybeGroupName) async {
    final name = maybeGroupName ?? widget.groupName;
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExpenseToGroupDialog(groupName: name);
      },
    );

    if (result == 'OK') {
      debugPrint("Expense Added Successfully to $name");
    }
  }

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
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

  bool _isExpenseInMonth(Expense expense) {
    final created = expense.effectiveCreatedAt;
    // Use effectiveCreatedAt to avoid null checking
    return created.year == selectedMonth.year &&
        created.month == selectedMonth.month;
  }

  String _formatCurrency(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGroupName = groupData?.name ?? widget.groupName;
    final groupColor = _getGroupColor(effectiveGroupName);

    if (_currentStreamGroupName == null ||
        _currentStreamGroupName != effectiveGroupName) {
      _updateExpensesStream(effectiveGroupName);
    }

    return Dialog.fullscreen(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [groupColor, groupColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: StreamBuilder(
                    stream: _expensesStream,
                    builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                      final allExpensesInGroup = asyncData.data ?? [];
                      final monthExpenses = allExpensesInGroup
                          .where(_isExpenseInMonth)
                          .toList();
                      final total = monthExpenses.fold(
                        0.0,
                        (sum, expense) => sum + expense.amount,
                      );
                      final totalsByUsers = <String, double>{};
                      final users = [];
                      for (final expense in monthExpenses) {
                        if (!users.contains(expense.whopaid)) {
                          users.add(expense.whopaid);
                        }
                        totalsByUsers[expense.whopaid] =
                            (totalsByUsers[expense.whopaid] ?? 0.0) +
                            expense.amount;
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          16.0,
                          16.0,
                          24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    effectiveGroupName,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _editGroup(context),
                                  tooltip: 'Edit group',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _deleteGroup(context),
                                  tooltip: 'Delete group',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Total Amount
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(total),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Member Count
                            Row(
                              children: [
                                Icon(
                                  Icons.group,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${users.length} members',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: _previousMonth,
                                      ),
                                      Text(
                                        _formatMonth(selectedMonth),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: _nextMonth,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Per-User Percentages
                                  Text(
                                    'Breakdown by Member',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPercentageBreakdown(
                                    theme,
                                    totalsByUsers,
                                    total,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Monthly Selector
              SliverToBoxAdapter(),
              // Expenses List
              StreamBuilder<List<Expense>>(
                stream: _expensesStream,
                builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                  final allExpenses = asyncData.data ?? [];
                  final monthExpenses = allExpenses
                      .where(_isExpenseInMonth)
                      .toList();

                  if (asyncData.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (asyncData.hasError) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('Error loading expenses')),
                      ),
                    );
                  }

                  if (monthExpenses.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40.0,
                          horizontal: 16.0,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Expenses Yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start adding expenses to track spending',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final expense = monthExpenses[index];
                        return ExpenseItem(
                          expense: expense,
                          onClickItem: (expense) => _showExpenseDialog(expense),
                        );
                      }, childCount: monthExpenses.length),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),

          // FAB
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton.extended(
              onPressed: () => _triggerModal(groupData?.name),
              icon: const Icon(Icons.add),
              label: const Text("Add Expense"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageBreakdown(
    ThemeData theme,
    Map<String, double> totalsByUsers,
    double total,
  ) {
    final entries = totalsByUsers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];

    return Column(
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        final percent = total > 0 ? (e.value / total) * 100.0 : 0.0;
        final percentText = '${percent.toStringAsFixed(1)}%';
        final color = colors[i % colors.length];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: _buildPercentageRow(theme, e.key, percentText, color),
        );
      }),
    );
  }

  Widget _buildPercentageRow(
    ThemeData theme,
    String userName,
    String percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(userName, style: theme.textTheme.bodySmall)),
        Text(
          percentage,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatMonth(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
