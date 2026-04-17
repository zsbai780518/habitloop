/// 用户设置数据模型
class UserSetting {
  final String key;
  final dynamic value;
  final int updatedAt;

  UserSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });

  factory UserSetting.fromMap(Map<String, dynamic> map) {
    return UserSetting(
      key: map['key'] as String,
      value: map['value'] as dynamic,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value is String ? value : value.toString(),
      'updated_at': updatedAt,
    };
  }
}
