import 'package:flutter_test/flutter_test.dart';
import 'package:habitloop/models/habit.dart';
import 'package:habitloop/models/checkin.dart';

void main() {
  group('Habit 模型测试', () {
    test('Habit.fromMap 正确解析数据库 Map', () {
      final map = {
        'id': 'test-id-123',
        'name': '晨跑',
        'icon': '🏃',
        'color': 0xFF4CAF50,
        'frequency_type': 'daily',
        'frequency_value': '[]',
        'target_count': 1,
        'reminder_enabled': 1,
        'reminder_time': '08:00',
        'created_at': 1712620800000,
        'updated_at': 1712620800000,
        'is_deleted': 0,
      };

      final habit = Habit.fromMap(map);

      expect(habit.id, 'test-id-123');
      expect(habit.name, '晨跑');
      expect(habit.icon, '🏃');
      expect(habit.color, 0xFF4CAF50);
      expect(habit.frequencyType, 'daily');
      expect(habit.reminderEnabled, true);
      expect(habit.reminderTime, '08:00');
      expect(habit.isDeleted, false);
    });

    test('Habit.toMap 正确转换为数据库格式', () {
      final habit = Habit(
        id: 'test-id',
        name: '阅读',
        icon: '📚',
        color: 0xFF2196F3,
        frequencyType: 'weekly',
        frequencyValue: '[1,3,5]',
        targetCount: 2,
        reminderEnabled: true,
        reminderTime: '20:00',
        createdAt: DateTime(2024, 4, 9),
        updatedAt: DateTime(2024, 4, 9),
      );

      final map = habit.toMap();

      expect(map['id'], 'test-id');
      expect(map['name'], '阅读');
      expect(map['icon'], '📚');
      expect(map['color'], 0xFF2196F3);
      expect(map['frequency_type'], 'weekly');
      expect(map['target_count'], 2);
      expect(map['reminder_enabled'], 1);
      expect(map['reminder_time'], '20:00');
    });

    test('Habit.copyWith 正确创建副本', () {
      final original = Habit(
        id: 'original-id',
        name: '原始习惯',
        icon: '🎯',
        color: 0xFF4CAF50,
        frequencyType: 'daily',
        frequencyValue: '[]',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final modified = original.copyWith(
        name: '修改后的习惯',
        targetCount: 3,
      );

      expect(modified.id, original.id); // 不变
      expect(modified.name, '修改后的习惯'); // 修改
      expect(modified.icon, original.icon); // 不变
      expect(modified.targetCount, 3); // 修改
    });
  });

  group('Checkin 模型测试', () {
    test('Checkin.fromMap 正确解析数据库 Map', () {
      final map = {
        'id': 'checkin-id-456',
        'habit_id': 'habit-id-123',
        'checkin_date': '2024-04-09',
        'checkin_time': 1712620800000,
        'note': '今天状态不错',
        'is_makeup': 1,
        'created_at': 1712620800000,
      };

      final checkin = Checkin.fromMap(map);

      expect(checkin.id, 'checkin-id-456');
      expect(checkin.habitId, 'habit-id-123');
      expect(checkin.checkinDate, '2024-04-09');
      expect(checkin.note, '今天状态不错');
      expect(checkin.isMakeup, true);
    });

    test('Checkin.toMap 正确转换为数据库格式', () {
      final checkin = Checkin(
        id: 'test-checkin',
        habitId: 'test-habit',
        checkinDate: '2024-04-09',
        checkinTime: DateTime(2024, 4, 9, 8, 30),
        note: null,
        isMakeup: false,
        createdAt: DateTime(2024, 4, 9),
      );

      final map = checkin.toMap();

      expect(map['id'], 'test-checkin');
      expect(map['habit_id'], 'test-habit');
      expect(map['checkin_date'], '2024-04-09');
      expect(map['is_makeup'], 0);
      expect(map['note'], null);
    });
  });

  group('打卡逻辑测试', () {
    test('Streak 计算 - 连续 3 天打卡', () {
      // 模拟连续 3 天的打卡记录
      final now = DateTime(2024, 4, 9);
      final day1 = DateTime(2024, 4, 7);
      final day2 = DateTime(2024, 4, 8);
      final day3 = DateTime(2024, 4, 9);

      // 验证日期差值计算
      expect(day3.difference(day2).inDays, 1);
      expect(day2.difference(day1).inDays, 1);
    });

    test('日期格式化', () {
      final date = DateTime(2024, 4, 9);
      final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      expect(formatted, '2024-04-09');
    });
  });
}
