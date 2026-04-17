import 'package:habitloop/models/habit.dart';
import 'package:habitloop/models/checkin.dart';
import 'package:habitloop/services/database_service.dart';
import 'package:uuid/uuid.dart';

/// 打卡服务 - 处理打卡核心逻辑
class CheckinService {
  /// 执行打卡
  /// 返回：是否打卡成功
  static Future<bool> checkIn({
    required String habitId,
    String? note,
    bool isMakeup = false,
  }) async {
    try {
      final habit = await DatabaseService.instance.queryHabitById(habitId);
      if (habit == null) return false;

      final now = DateTime.now();
      final today = _formatDate(now);

      // 检查今日是否已打卡
      final hasCheckedIn = await DatabaseService.instance.hasCheckedInToday(habitId);
      if (hasCheckedIn) {
        // TODO: 已打卡，可以选择增加次数或提示
        return false;
      }

      // 创建打卡记录
      final checkin = Checkin(
        id: const Uuid().v4(),
        habitId: habitId,
        checkinDate: today,
        checkinTime: now,
        note: note,
        isMakeup: isMakeup,
        createdAt: now,
      );

      await DatabaseService.instance.insertCheckin(checkin);
      return true;
    } catch (e) {
      print('打卡失败：$e');
      return false;
    }
  }

  /// 补卡
  static Future<bool> makeUpCheckin({
    required String habitId,
    required DateTime date,
    String? note,
  }) async {
    try {
      final now = DateTime.now();
      final checkinDate = _formatDate(date);

      // 检查该日期是否已打卡
      final checkins = await DatabaseService.instance.queryCheckinsByHabit(
        habitId,
        startDate: checkinDate,
        endDate: checkinDate,
      );

      if (checkins.isNotEmpty) {
        return false; // 该日期已打卡
      }

      // 检查是否在 7 天内
      final daysDiff = now.difference(date).inDays;
      if (daysDiff < 0 || daysDiff > 7) {
        return false; // 只能补 7 天内的卡
      }

      final checkin = Checkin(
        id: const Uuid().v4(),
        habitId: habitId,
        checkinDate: checkinDate,
        checkinTime: now,
        note: note,
        isMakeup: true,
        createdAt: now,
      );

      await DatabaseService.instance.insertCheckin(checkin);
      return true;
    } catch (e) {
      print('补卡失败：$e');
      return false;
    }
  }

  /// 获取连续打卡天数
  static Future<int> getStreak(String habitId) async {
    return await DatabaseService.instance.calculateStreak(habitId);
  }

  /// 获取历史最长连续打卡天数
  static Future<int> getMaxStreak(String habitId) async {
    final checkins = await DatabaseService.instance.queryCheckinsByHabit(habitId);
    
    if (checkins.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 1;

    for (int i = 1; i < checkins.length; i++) {
      final prevDate = DateTime.parse(checkins[i - 1].checkinDate);
      final currDate = DateTime.parse(checkins[i].checkinDate);
      
      final diff = prevDate.difference(currDate).inDays;
      
      if (diff == 1) {
        currentStreak++;
      } else {
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        currentStreak = 1;
      }
    }

    maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
    return maxStreak;
  }

  /// 获取周统计
  static Future<Map<String, dynamic>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = now;

    final stats = await DatabaseService.instance.getWeeklyStats();
    
    // 计算完成率等指标
    final totalDays = now.difference(weekStart).inDays + 1;
    final checkinDays = (stats['data'] as List).length;
    final completionRate = totalDays > 0 ? checkinDays / totalDays : 0;

    return {
      'startDate': stats['startDate'],
      'endDate': stats['endDate'],
      'totalDays': totalDays,
      'checkinDays': checkinDays,
      'completionRate': completionRate,
      'data': stats['data'],
    };
  }

  /// 获取月统计
  static Future<Map<String, dynamic>> getMonthlyStats() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final stats = await DatabaseService.instance.getMonthlyStats();
    
    // 计算完成率等指标
    final totalDays = now.difference(monthStart).inDays + 1;
    final checkinDays = (stats['data'] as List).length;
    final completionRate = totalDays > 0 ? checkinDays / totalDays : 0;

    return {
      'startDate': stats['startDate'],
      'endDate': stats['endDate'],
      'totalDays': totalDays,
      'checkinDays': checkinDays,
      'completionRate': completionRate,
      'data': stats['data'],
    };
  }

  /// 获取习惯的打卡历史
  static Future<List<Checkin>> getHabitHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await DatabaseService.instance.queryCheckinsByHabit(
      habitId,
      startDate: startDate != null ? _formatDate(startDate) : null,
      endDate: endDate != null ? _formatDate(endDate) : null,
    );
  }

  /// 检查某天是否已打卡
  static Future<bool> hasCheckedInOnDate({
    required String habitId,
    required DateTime date,
  }) async {
    final checkins = await DatabaseService.instance.queryCheckinsByHabit(
      habitId,
      startDate: _formatDate(date),
      endDate: _formatDate(date),
    );
    return checkins.isNotEmpty;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
