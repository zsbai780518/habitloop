import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 统计图表组件集合

/// 周打卡趋势柱状图
class WeeklyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const WeeklyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blue,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  const TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
                  if (value.toInt() >= 0 && value.toInt() < weekdays.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        weekdays[value.toInt()],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200],
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _generateBarGroups(),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 5;
    final maxCount = data.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b);
    return (maxCount + 1).toDouble();
  }

  List<BarChartGroupData> _generateBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final count = item['count'] as int;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: count > 0 ? Colors.blue : Colors.grey[300],
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }
}

/// 习惯完成率环形图
class HabitCompletionPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const HabitCompletionPieChart({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _generateSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    final total = habits.fold<double>(
      0,
      (sum, item) => sum + (item['completionRate'] as double),
    );

    return habits.asMap().entries.map((entry) {
      final index = entry.key;
      final habit = entry.value;
      final rate = habit['completionRate'] as double;
      final name = habit['name'] as String;
      final color = Color(habit['color'] as int);

      final percentage = (rate * 100).toStringAsFixed(0);

      return PieChartSectionData(
        value: rate,
        title: '$percentage%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

/// Streak 趋势折线图
class StreakLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const StreakLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    final date = DateTime.parse(data[value.toInt()]['date']);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${date.month}/${date.day}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value['streak'].toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.orange,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 打卡日历热力图
class CheckinHeatMap extends StatelessWidget {
  final Map<String, bool> checkinMap; // date -> hasCheckedIn
  final DateTime startDate;
  final int weeks;

  const CheckinHeatMap({
    super.key,
    required this.checkinMap,
    required this.startDate,
    this.weeks = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 星期标题
        Row(
          children: [
            const SizedBox(width: 30),
            ...['一', '二', '三', '四', '五', '六', '日'].map((day) {
              return SizedBox(
                width: 20,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 4),
        // 热力图网格
        Row(
          children: List.generate(weeks, (weekIndex) {
            return Column(
              children: List.generate(7, (dayIndex) {
                final date = startDate.add(Duration(
                  days: weekIndex * 7 + dayIndex,
                ));
                final dateStr = _formatDate(date);
                final hasCheckedIn = checkinMap[dateStr] ?? false;

                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: hasCheckedIn ? Colors.green : Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
