import 'package:flutter/material.dart';
import 'package:habitloop/models/habit.dart';
import 'package:habitloop/services/database_service.dart';
import 'package:habitloop/services/notification_service.dart';
import 'package:intl/intl.dart';

/// 提醒设置页面
class ReminderSettingsScreen extends StatefulWidget {
  final String habitId;

  const ReminderSettingsScreen({super.key, required this.habitId});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  Habit? _habit;
  bool _isLoading = true;
  
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _repeatDaily = true;
  List<int> _repeatDays = [1, 2, 3, 4, 5, 6, 7]; // 1-7 表示周一到周日

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  Future<void> _loadHabit() async {
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

      setState(() {
        _habit = habit;
        _reminderEnabled = habit.reminderEnabled;
        if (habit.reminderTime != null) {
          final parts = habit.reminderTime!.split(':');
          _reminderTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
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

  Future<void> _saveSettings() async {
    if (_habit == null) return;

    try {
      final updatedHabit = _habit!.copyWith(
        reminderEnabled: _reminderEnabled,
        reminderTime: _reminderEnabled ? _reminderTime.format(context) : null,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.instance.updateHabit(updatedHabit);

      // 更新通知
      if (_reminderEnabled) {
        await NotificationService.instance.scheduleDailyReminder(
          id: _habit!.id.hashCode,
          title: _habit!.name,
          body: '该打卡啦！坚持就是胜利 💪',
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );
      } else {
        await NotificationService.instance.cancelReminder(_habit!.id.hashCode);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设置已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒设置'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 习惯信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(_habit!.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(_habit!.icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _habit!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 启用提醒开关
          Card(
            child: SwitchListTile(
              title: const Text('启用提醒'),
              subtitle: const Text('在指定时间提醒你打卡'),
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() => _reminderEnabled = value);
              },
              secondary: const Icon(Icons.notifications),
            ),
          ),
          const SizedBox(height: 16),

          if (_reminderEnabled) ...[
            // 提醒时间选择
            Card(
              child: ListTile(
                title: const Text('提醒时间'),
                subtitle: Text(_reminderTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                  );
                  if (time != null) {
                    setState(() => _reminderTime = time);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // 重复设置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '重复',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _repeatDaily = !_repeatDaily;
                                if (_repeatDaily) {
                                  _repeatDays = [1, 2, 3, 4, 5, 6, 7];
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _repeatDaily
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '每天',
                                  style: TextStyle(
                                    color: _repeatDaily ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _repeatDaily = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_repeatDaily
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  '自定义',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_repeatDaily) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildDayChip('一', 1),
                          _buildDayChip('二', 2),
                          _buildDayChip('三', 3),
                          _buildDayChip('四', 4),
                          _buildDayChip('五', 5),
                          _buildDayChip('六', 6),
                          _buildDayChip('日', 7),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 提示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '提醒会在设定时间推送通知，即使离线也能正常接收',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayChip(String label, int day) {
    final isSelected = _repeatDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _repeatDays.remove(day);
          } else {
            _repeatDays.add(day);
          }
        });
      },
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
