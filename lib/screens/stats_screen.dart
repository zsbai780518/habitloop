import 'package:flutter/material.dart';
import 'package:habitloop/services/checkin_service.dart';
import 'package:habitloop/widgets/charts.dart';

/// 统计页面
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'week';
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> stats;
      if (_selectedPeriod == 'week') {
        stats = await CheckinService.getWeeklyStats();
      } else {
        stats = await CheckinService.getMonthlyStats();
      }

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('加载统计失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: 选择日期范围
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: 导出数据
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 时间范围选择
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  
                  // 总览卡片
                  _buildOverviewCards(),
                  const SizedBox(height: 24),
                  
                  // 打卡趋势图
                  _buildTrendChart(),
                  const SizedBox(height: 24),
                  
                  // 习惯完成率排行
                  _buildHabitRanking(),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'week', label: Text('本周')),
        ButtonSegment(value: 'month', label: Text('本月')),
        ButtonSegment(value: 'all', label: Text('全部')),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<String> selected) {
        setState(() {
          _selectedPeriod = selected.first;
        });
        _loadStats();
      },
    );
  }

  Widget _buildOverviewCards() {
    final checkinDays = _stats['checkinDays'] as int? ?? 0;
    final completionRate = _stats['completionRate'] as double? ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: '打卡总次数',
          value: '$checkinDays',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          title: '平均完成率',
          value: '${(completionRate * 100).toStringAsFixed(0)}%',
          icon: Icons.trending_up,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: '当前最长 streak',
          value: '21 天', // TODO: 实际计算
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: '历史最长 streak',
          value: '45 天', // TODO: 实际计算
          icon: Icons.emoji_events,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每日打卡趋势',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // 使用实际图表组件
            WeeklyBarChart(
              data: (_stats['data'] as List?)?.cast<Map<String, dynamic>>() ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitRanking() {
    // TODO: 从数据库获取实际数据
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '习惯完成率排行',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildRankItem('🎯 待办清单', 1.0, Colors.green),
            _buildRankItem('📚 阅读 30 分钟', 0.85, Colors.blue),
            _buildRankItem('🏃 晨跑', 0.75, Colors.orange),
            _buildRankItem('💧 喝水 8 杯', 0.50, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(String name, double rate, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 14)),
              Text(
                '${(rate * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
