/// 打卡记录数据模型
class Checkin {
  final String id;
  final String habitId;
  final String checkinDate; // YYYY-MM-DD
  final DateTime checkinTime;
  final String? note;
  final bool isMakeup;
  final DateTime createdAt;

  Checkin({
    required this.id,
    required this.habitId,
    required this.checkinDate,
    required this.checkinTime,
    this.note,
    this.isMakeup = false,
    required this.createdAt,
  });

  /// 从数据库 Map 创建实例
  factory Checkin.fromMap(Map<String, dynamic> map) {
    return Checkin(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      checkinDate: map['checkin_date'] as String,
      checkinTime: DateTime.fromMillisecondsSinceEpoch(map['checkin_time'] as int),
      note: map['note'] as String?,
      isMakeup: (map['is_makeup'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'checkin_date': checkinDate,
      'checkin_time': checkinTime.millisecondsSinceEpoch,
      'note': note,
      'is_makeup': isMakeup ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  Checkin copyWith({
    String? id,
    String? habitId,
    String? checkinDate,
    DateTime? checkinTime,
    String? note,
    bool? isMakeup,
    DateTime? createdAt,
  }) {
    return Checkin(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      checkinDate: checkinDate ?? this.checkinDate,
      checkinTime: checkinTime ?? this.checkinTime,
      note: note ?? this.note,
      isMakeup: isMakeup ?? this.isMakeup,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Checkin(id: $id, habitId: $habitId, date: $checkinDate, time: $checkinTime)';
  }
}
