import 'package:flutter/material.dart';

class MonthPickerDialog extends StatefulWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthSelected;

  const MonthPickerDialog({
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int selectedYear;
  late int selectedMonthInt;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.selectedMonth.year;
    selectedMonthInt = widget.selectedMonth.month;
  }

  void _previousYear() {
    setState(() {
      selectedYear--;
    });
  }

  void _nextYear() {
    final now = DateTime.now();
    if (selectedYear < now.year) {
      setState(() {
        selectedYear++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final canGoToNextYear = selectedYear < now.year;

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return AlertDialog(
      title: Text('Select Month'),
      content: SizedBox(
        width: 300,
        height: 350,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousYear,
                ),
                Text(
                  selectedYear.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoToNextYear ? _nextYear : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Month Grid
            SizedBox(
              height: 280,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final monthNum = index + 1;
                  final isFutureMonth =
                      selectedYear > now.year ||
                      (selectedYear == now.year && monthNum > now.month);
                  final isSelected = selectedMonthInt == monthNum;

                  return GestureDetector(
                    onTap: !isFutureMonth
                        ? () {
                            widget.onMonthSelected(
                              DateTime(selectedYear, monthNum),
                            );
                          }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : isFutureMonth
                            ? Colors.grey[200]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          months[index],
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isFutureMonth
                                ? Colors.grey[400]
                                : isSelected
                                ? Colors.white
                                : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class MonthSelectorDelegate extends SliverPersistentHeaderDelegate {
  final DateTime selectedMonth;
  final VoidCallback onMonthPressed;
  final double totalExpenses;

  MonthSelectorDelegate({
    required this.selectedMonth,
    required this.onMonthPressed,
    required this.totalExpenses,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
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

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 2),
                Text(
                  'Total this month: \$${totalExpenses.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onMonthPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      '${months[selectedMonth.month - 1]} ${selectedMonth.year}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 65.0;

  @override
  double get minExtent => 65.0;

  @override
  bool shouldRebuild(MonthSelectorDelegate oldDelegate) {
    return oldDelegate.selectedMonth != selectedMonth ||
        oldDelegate.totalExpenses != totalExpenses;
  }
}
