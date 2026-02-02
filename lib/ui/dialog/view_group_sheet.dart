import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/model/group.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/group_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/expense_item.dart';
import 'package:expense_v2/ui/dialog/add_expense_to_group_dialog.dart';
import 'package:expense_v2/ui/dialog/view_expense_dialog.dart';
import 'package:flutter/material.dart';

class ViewGroupSheet extends StatefulWidget {
  const ViewGroupSheet({required this.groupName, super.key});

  final String groupName;

  @override
  State<ViewGroupSheet> createState() => _ViewGroupSheetState();
}

class _ViewGroupSheetState extends State<ViewGroupSheet> {
  final expenseRepo = ExpenseRepoFireImpl();
  final groupRepo = GroupRepoFireImpl();

  Group? groupData;
  DateTime selectedMonth = DateTime.now();

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
    } else {
      debugPrint("group found from groupName is null");
    }
  }

  void _showExpenseDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewExpenseDialog(expense: expense);
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGroupName = groupData?.name ?? widget.groupName;
    final groupColor = _getGroupColor(effectiveGroupName);

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
                      colors: [
                        groupColor,
                        groupColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                effectiveGroupName,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
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
                              '\$0.00',
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
                            Icon(Icons.group, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '0 members',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Monthly Selector
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _previousMonth,
                          ),
                          Text(
                            _formatMonth(selectedMonth),
                            style: theme.textTheme.titleMedium?.copyWith(
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
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPercentageBreakdown(theme),
                    ],
                  ),
                ),
              ),
              // Expenses List
              StreamBuilder<List<Expense>>(
                stream: expenseRepo.getAllExpensesInGroup(effectiveGroupName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('Error loading expenses')),
                      ),
                    );
                  }

                  final expenses = snapshot.data ?? [];

                  if (expenses.isEmpty) {
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
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final expense = expenses[index];
                          return ExpenseItem(
                            expense: expense,
                            onClickItem: (expense) =>
                                _showExpenseDialog(expense),
                          );
                        },
                        childCount: expenses.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
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

  Widget _buildPercentageBreakdown(ThemeData theme) {
    // Placeholder breakdown for 3 members
    return Column(
      children: [
        _buildPercentageRow(theme, 'User 1', '45.50%', Colors.blue),
        const SizedBox(height: 8),
        _buildPercentageRow(theme, 'User 2', '35.25%', Colors.green),
        const SizedBox(height: 8),
        _buildPercentageRow(theme, 'User 3', '19.25%', Colors.orange),
      ],
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
        Expanded(
          child: Text(
            userName,
            style: theme.textTheme.bodySmall,
          ),
        ),
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
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
