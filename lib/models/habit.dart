/// 习惯数据模型
class Habit {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String frequencyType; // 'daily', 'weekly', 'custom'
  final String frequencyValue; // JSON 字符串
  final int targetCount;
  final bool reminderEnabled;
  final String? reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.frequencyType,
    required this.frequencyValue,
    this.targetCount = 1,
    this.reminderEnabled = false,
    this.reminderTime,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// 从数据库 Map 创建实例
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as int,
      frequencyType: map['frequency_type'] as String,
      frequencyValue: map['frequency_value'] as String,
      targetCount: map['target_count'] as int? ?? 1,
      reminderEnabled: (map['reminder_enabled'] as int?) == 1,
      reminderTime: map['reminder_time'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isDeleted: (map['is_deleted'] as int?) == 1,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'frequency_type': frequencyType,
      'frequency_value': frequencyValue,
      'target_count': targetCount,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_time': reminderTime,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// 复制并修改
  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    String? frequencyType,
    String? frequencyValue,
    int? targetCount,
    bool? reminderEnabled,
    String? reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      targetCount: targetCount ?? this.targetCount,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// 检查今天是否需要打卡
  bool shouldCheckInToday() {
    if (frequencyType == 'daily') return true;
    if (frequencyType == 'weekly') {
      // 解析 frequency_value 判断今天是否在周期内
      // 示例："[1,3,5]" 表示周一、三、五
      return true; // TODO: 实现具体逻辑
    }
    return false;
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, icon: $icon, color: $color)';
  }
}
