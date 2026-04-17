import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:habitloop/models/habit.dart';
import 'package:habitloop/models/checkin.dart';
import 'package:habitloop/models/user_setting.dart';

/// 数据库服务 - 单例模式
/// 负责数据库初始化、版本管理、CRUD 操作
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// 获取数据库实例 (懒加载)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habitloop.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 创建 habits 表
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        frequency_type TEXT NOT NULL,
        frequency_value TEXT NOT NULL,
        target_count INTEGER DEFAULT 1,
        reminder_enabled INTEGER DEFAULT 0,
        reminder_time TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    // 创建 checkins 表
    await db.execute('''
      CREATE TABLE checkins (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        checkin_date TEXT NOT NULL,
        checkin_time INTEGER NOT NULL,
        note TEXT,
        is_makeup INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id)
      )
    ''');

    // 创建 user_settings 表
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_habits_created_at ON habits(created_at DESC)');
    await db.execute('CREATE INDEX idx_habits_is_deleted ON habits(is_deleted)');
    await db.execute('CREATE INDEX idx_checkins_habit_date ON checkins(habit_id, checkin_date)');
    await db.execute('CREATE INDEX idx_checkins_date ON checkins(checkin_date DESC)');
    await db.execute('CREATE INDEX idx_checkins_habit ON checkins(habit_id)');
  }

  /// 数据库升级处理
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO: 版本迁移逻辑
    if (oldVersion < 2) {
      // 示例：添加新字段
      // await db.execute('ALTER TABLE habits ADD COLUMN new_column TEXT');
    }
  }

  /// 数据库降级处理
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // 降级策略：通常不处理或抛出异常
    throw Exception('数据库降级不支持');
  }

  // ==================== Habit CRUD ====================

  /// 插入习惯
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  /// 查询所有习惯 (未删除)
  Future<List<Habit>> queryAllHabits() async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  /// 查询今日需打卡习惯
  Future<List<Habit>> queryTodayHabits() async {
    final db = await database;
    // TODO: 根据 frequency_type 过滤今日应打卡习惯
    final maps = await db.query(
      'habits',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  /// 根据 ID 查询习惯
  Future<Habit?> queryHabitById(String id) async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
    );
    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  /// 更新习惯
  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// 软删除习惯
  Future<int> deleteHabit(String id) async {
    final db = await database;
    return await db.update(
      'habits',
      {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 硬删除习惯 (及关联打卡记录)
  Future<void> hardDeleteHabit(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('checkins', where: 'habit_id = ?', whereArgs: [id]);
      await txn.delete('habits', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ==================== Checkin CRUD ====================

  /// 插入打卡记录
  Future<int> insertCheckin(Checkin checkin) async {
    final db = await database;
    return await db.insert('checkins', checkin.toMap());
  }

  /// 查询某习惯的打卡记录
  Future<List<Checkin>> queryCheckinsByHabit(String habitId, {String? startDate, String? endDate}) async {
    final db = await database;
    var where = 'habit_id = ?';
    var whereArgs = [habitId];

    if (startDate != null) {
      where += ' AND checkin_date >= ?';
      whereArgs.add(startDate);
    }
    if (endDate != null) {
      where += ' AND checkin_date <= ?';
      whereArgs.add(endDate);
    }

    final maps = await db.query(
      'checkins',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'checkin_date DESC',
    );
    return maps.map((map) => Checkin.fromMap(map)).toList();
  }

  /// 查询今日是否已打卡
  Future<bool> hasCheckedInToday(String habitId) async {
    final db = await database;
    final today = _formatDate(DateTime.now());
    final maps = await db.query(
      'checkins',
      where: 'habit_id = ? AND checkin_date = ?',
      whereArgs: [habitId, today],
    );
    return maps.isNotEmpty;
  }

  /// 计算连续打卡天数
  Future<int> calculateStreak(String habitId) async {
    final db = await database;
    final checkins = await queryCheckinsByHabit(habitId);
    
    if (checkins.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (var checkin in checkins) {
      final checkinDate = DateTime.parse(checkin.checkinDate);
      final diff = currentDate.difference(checkinDate).inDays;
      
      if (diff <= 1) {
        streak++;
        currentDate = checkinDate;
      } else {
        break;
      }
    }
    
    return streak;
  }

  // ==================== User Settings CRUD ====================

  /// 保存设置
  Future<int> saveSetting(String key, dynamic value) async {
    final db = await database;
    final setting = UserSetting(
      key: key,
      value: value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    return await db.insert(
      'user_settings',
      setting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取设置
  Future<dynamic> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (maps.isEmpty) return null;
    return UserSetting.fromMap(maps.first).value;
  }

  // ==================== 统计查询 ====================

  /// 获取周统计
  Future<Map<String, dynamic>> getWeeklyStats() async {
    final db = await database;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startDate = _formatDate(weekStart);
    final endDate = _formatDate(now);

    final result = await db.rawQuery('''
      SELECT 
        checkin_date,
        COUNT(*) as count
      FROM checkins
      WHERE checkin_date BETWEEN ? AND ?
      GROUP BY checkin_date
    ''', [startDate, endDate]);

    return {'data': result, 'startDate': startDate, 'endDate': endDate};
  }

  /// 获取月统计
  Future<Map<String, dynamic>> getMonthlyStats() async {
    final db = await database;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final startDate = _formatDate(monthStart);
    final endDate = _formatDate(now);

    final result = await db.rawQuery('''
      SELECT 
        checkin_date,
        COUNT(*) as count
      FROM checkins
      WHERE checkin_date BETWEEN ? AND ?
      GROUP BY checkin_date
    ''', [startDate, endDate]);

    return {'data': result, 'startDate': startDate, 'endDate': endDate};
  }

  // ==================== 工具方法 ====================

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
