import 'package:flutter/material.dart';
import 'package:habitloop/services/database_service.dart';
import 'package:habitloop/services/checkin_service.dart';
import 'package:habitloop/models/habit.dart';
import 'create_habit_screen.dart';
import 'habit_detail_screen.dart';

/// 首页 - 展示习惯列表和打卡功能
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  Map<String, int> _streaks = {}; // habitId -> streak
  Map<String, bool> _todayCheckins = {}; // habitId -> hasCheckedIn
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final habits = await DatabaseService.instance.queryAllHabits();
      
      // 并行加载每个习惯的 Streak 和今日打卡状态
      final streaks = <String, int>{};
      final todayCheckins = <String, bool>{};
      
      await Future.wait(habits.map((habit) async {
        final streak = await CheckinService.getStreak(habit.id);
        final hasCheckedIn = await DatabaseService.instance.hasCheckedInToday(habit.id);
        streaks[habit.id] = streak;
        todayCheckins[habit.id] = hasCheckedIn;
      }));

      setState(() {
        _habits = habits;
        _streaks = streaks;
        _todayCheckins = todayCheckins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败：$e')),
        );
      }
    }
  }

  Future<void> _handleCheckIn(Habit habit) async {
    final success = await CheckinService.checkIn(habitId: habit.id);
    
    if (success && mounted) {
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('${habit.name} 打卡成功！🔥'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // 刷新数据
      await _loadHabits();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('今日已打卡')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            Text(
              _formatDate(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // TODO: 快速查看统计
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateHabitScreen()),
              );
              _loadHabits();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHabits,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _habits.isEmpty
                ? _buildEmptyState()
                : _buildHabitList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有习惯',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 创建第一个习惯',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateHabitScreen()),
              );
              _loadHabits();
            },
            icon: const Icon(Icons.add),
            label: const Text('创建习惯'),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        final streak = _streaks[habit.id] ?? 0;
        final hasCheckedIn = _todayCheckins[habit.id] ?? false;
        return _buildHabitCard(habit, streak, hasCheckedIn);
      },
    );
  }

  Widget _buildHabitCard(Habit habit, int streak, bool hasCheckedIn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitDetailScreen(habitId: habit.id),
            ),
          );
          _loadHabits();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 图标和名称
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(habit.color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(habit.icon, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '连续 $streak 天',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 打卡按钮
              ElevatedButton(
                onPressed: hasCheckedIn ? null : () => _handleCheckIn(habit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasCheckedIn
                      ? Colors.grey[300]
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: hasCheckedIn
                      ? Colors.grey[500]
                      : Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: hasCheckedIn
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 18),
                          SizedBox(width: 4),
                          Text('已完成'),
                        ],
                      )
                    : const Text('打卡'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，早点休息';
    if (hour < 12) return '早上好，今天也要加油';
    if (hour < 14) return '中午好，记得午休';
    if (hour < 18) return '下午好，保持专注';
    if (hour < 22) return '晚上好，放松一下';
    return '夜深了，早点休息';
  }

  String _formatDate() {
    final now = DateTime.now();
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${now.month}月${now.day}日 ${weekdays[now.weekday - 1]}';
  }
}
