import 'package:flutter/material.dart';
import 'package:habitloop/models/habit.dart';
import 'package:habitloop/models/checkin.dart';
import 'package:habitloop/services/database_service.dart';
import 'package:habitloop/services/checkin_service.dart';
import 'package:habitloop/widgets/charts.dart';

/// 习惯详情页面
class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  Habit? _habit;
  int _currentStreak = 0;
  int _maxStreak = 0;
  bool _hasCheckedInToday = false;
  List<Checkin> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final habit = await DatabaseService.instance.queryHabitById(widget.habitId);
      if (habit == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('习惯不存在')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final currentStreak = await CheckinService.getStreak(widget.habitId);
      final maxStreak = await CheckinService.getMaxStreak(widget.habitId);
      final hasCheckedInToday = await DatabaseService.instance.hasCheckedInToday(widget.habitId);
      final history = await CheckinService.getHabitHistory(
        habitId: widget.habitId,
        endDate: DateTime.now(),
      );

      setState(() {
        _habit = habit;
        _currentStreak = currentStreak;
        _maxStreak = maxStreak;
        _hasCheckedInToday = hasCheckedInToday;
        _history = history.take(30).toList(); // 最近 30 条
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败：$e')),
        );
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (_hasCheckedInToday) return;

    final success = await CheckinService.checkIn(habitId: widget.habitId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('${_habit!.name} 打卡成功！🔥'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_habit == null) {
      return const Scaffold(
        body: Center(child: Text('习惯不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_habit!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 编辑习惯
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreMenu();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak 卡片
            _buildStreakCard(),
            const SizedBox(height: 16),

            // 今日打卡按钮
            _buildTodayCheckin(),
            const SizedBox(height: 24),

            // 本周进度
            _buildWeeklyProgress(),
            const SizedBox(height: 24),

            // 打卡历史
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(_habit!.color),
            Color(_habit!.color).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '当前连续',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_currentStreak',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '天',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '历史最长',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_maxStreak 天',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCheckin() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今天',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _hasCheckedInToday ? null : _handleCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasCheckedInToday
                      ? Colors.grey[300]
                      : Color(_habit!.color),
                  foregroundColor: _hasCheckedInToday
                      ? Colors.grey[500]
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _hasCheckedInToday
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 8),
                          Text('已完成', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : const Text('打卡', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '本周进度',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // TODO: 实现本周进度展示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayColumn('一', true),
                _buildDayColumn('二', true),
                _buildDayColumn('三', true),
                _buildDayColumn('四', false),
                _buildDayColumn('五', false),
                _buildDayColumn('六', false),
                _buildDayColumn('日', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayColumn(String day, bool completed) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: completed ? Color(_habit!.color) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.close,
            color: completed ? Colors.white : Colors.grey[400],
            size: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '打卡历史',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '还没有打卡记录',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final checkin = _history[index];
                  final checkinTime = checkin.checkinTime;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      checkin.isMakeup ? Icons.history : Icons.check_circle,
                      color: checkin.isMakeup ? Colors.orange : Color(_habit!.color),
                    ),
                    title: Text(
                      checkin.checkinDate,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      '${checkinTime.hour.toString().padLeft(2, '0')}:${checkinTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: checkin.isMakeup
                        ? Chip(
                            label: const Text('补卡', style: TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑习惯'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 编辑习惯
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('提醒设置'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 提醒设置
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除习惯', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirm();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除习惯'),
        content: const Text('确定要删除这个习惯吗？打卡记录将被保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.deleteHabit(widget.habitId);
              if (mounted) {
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(context); // 返回上一页
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已删除')),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
