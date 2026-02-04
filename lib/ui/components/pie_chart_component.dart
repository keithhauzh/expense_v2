import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartComponent extends StatefulWidget {
  const PieChartComponent({
    super.key,
    required this.nonZeroExpenses,
    required this.totalExpensePerCategory,
  });

  final List<MapEntry<String, double>> nonZeroExpenses;
  final Map<String, double> totalExpensePerCategory;

  @override
  State<PieChartComponent> createState() => _PieChartComponentState();
}

class _PieChartComponentState extends State<PieChartComponent> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Row(
        children: [
          const SizedBox(width: 28),
          Expanded(
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Convert your column items to sliver items
                SliverList(
                  delegate: SliverChildListDelegate(
                    _buildIndicators(widget.nonZeroExpenses),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: _buildPieChartSections(
                    widget.totalExpensePerCategory,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIndicators(
    List<MapEntry<String, double>> nonZeroExpenses,
  ) {
    if (nonZeroExpenses.isEmpty) {
      return [Text('No expenses', style: TextStyle(color: Colors.grey))];
    }

    final totalExpense = nonZeroExpenses.fold(
      0.0,
      (sum, category) => sum + category.value,
    );

    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.grey,
    ];

    return nonZeroExpenses.asMap().entries.map((entry) {
      final i = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / totalExpense) * 100;
      final color = colors[i % colors.length];

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryEntry.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$${categoryEntry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> totalExpensePerCategory,
  ) {
    final nonZeroExpenses = totalExpensePerCategory.entries
        .where((category) => category.value > 0)
        .toList();

    if (nonZeroExpenses.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'No data',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      ];
    }

    final totalExpense = nonZeroExpenses.fold(
      0.0,
      (sum, category) => sum + category.value,
    );

    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.grey,
    ];

    return List.generate(nonZeroExpenses.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      final category = nonZeroExpenses[i];
      final percentage = (category.value / totalExpense) * 100;
      final color = colors[i % colors.length];

      return PieChartSectionData(
        color: color,
        value: category.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }
}
