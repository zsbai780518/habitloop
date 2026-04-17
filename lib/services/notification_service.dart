import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as timezone;
import 'package:timezone/data/latest.dart' as timezone;

/// 本地通知服务 - 单例模式
/// 负责打卡提醒的推送管理
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  NotificationService._init();

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 初始化时区
    timezone.initializeTimeZones();
    
    // Android 初始化配置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 初始化配置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 请求权限 (Android 13+)
    await _requestPermissions();
    
    _isInitialized = true;
  }

  /// 请求通知权限
  Future<void> _requestPermissions() async {
    // Android 13+ 需要显式请求权限
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS 权限
    final iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 通知点击回调
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: 跳转到对应习惯详情页
    print('通知点击：${response.payload}');
  }

  /// 创建 Android 通知渠道
  Future<void> createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'habit_reminder_channel', // 渠道 ID
      '习惯提醒', // 渠道名称
      description: '每日习惯打卡提醒',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// 安排每日提醒
  /// [id] 通知唯一 ID (通常使用 habit.id 的 hash)
  /// [title] 通知标题
  /// [body] 通知内容
  /// [hour] 提醒小时 (0-23)
  /// [minute] 提醒分钟 (0-59)
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'habit_reminder_channel',
      '习惯提醒',
      channelDescription: '每日习惯打卡提醒',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 每日重复提醒
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 计算下一次提醒时间
  TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = TZDateTime.now(timezone.local);
    var scheduledDate = TZDateTime(timezone.local, now.year, now.month, now.day, hour, minute);
    
    // 如果今天的时间已过，则安排到明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// 取消提醒
  Future<void> cancelReminder(int id) async {
    if (!_isInitialized) await initialize();
    await _notificationsPlugin.cancel(id);
  }

  /// 取消所有提醒
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) await initialize();
    await _notificationsPlugin.cancelAll();
  }

  /// 显示即时通知 (测试用)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'habit_reminder_channel',
      '习惯提醒',
      channelDescription: '每日习惯打卡提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// 检查通知权限
  Future<bool> checkPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.areNotificationsEnabled();
      return granted ?? false;
    }
    
    return true;
  }
}
