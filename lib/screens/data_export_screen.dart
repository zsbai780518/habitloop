import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:habitloop/services/database_service.dart';
import 'package:habitloop/models/habit.dart';
import 'package:habitloop/models/checkin.dart';
import 'package:intl/intl.dart';

/// 数据导出页面
class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _isExporting = false;
  String? _lastExportPath;
  DateTime? _lastExportTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据导出'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '导出数据',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '导出所有习惯和打卡记录数据，支持 JSON 和 CSV 格式。\n导出的文件将保存到手机存储中，你可以随时查看或备份。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 导出选项
            _buildExportOption(
              icon: Icons.data_object,
              title: '导出为 JSON',
              subtitle: '包含完整的习惯和打卡数据',
              onTap: () => _exportData(format: 'json'),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.table_chart,
              title: '导出为 CSV',
              subtitle: '适合用 Excel 打开分析',
              onTap: () => _exportData(format: 'csv'),
            ),
            const SizedBox(height: 24),

            // 最近导出记录
            if (_lastExportPath != null) ...[
              const Text(
                '最近导出',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(_lastExportPath!.split('/').last),
                  subtitle: Text(
                    _lastExportTime != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(_lastExportTime!)
                        : '',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: 分享文件
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 隐私说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '你的数据仅存储在本地，不会上传到云端，导出文件也由你完全控制',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportData({required String format}) async {
    setState(() {
      _isExporting = true;
    });

    try {
      // 获取数据
      final habits = await DatabaseService.instance.queryAllHabits();
      final allCheckins = <Checkin>[];
      
      for (final habit in habits) {
        final checkins = await DatabaseService.instance.queryCheckinsByHabit(habit.id);
        allCheckins.addAll(checkins);
      }

      // 生成文件内容
      String content;
      String extension;
      
      if (format == 'json') {
        content = _generateJson(habits, allCheckins);
        extension = 'json';
      } else {
        content = _generateCsv(habits, allCheckins);
        extension = 'csv';
      }

      // 保存文件
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/habitloop_export_$timestamp.$extension';
      final file = File(filePath);
      await file.writeAsString(content);

      setState(() {
        _lastExportPath = filePath;
        _lastExportTime = DateTime.now();
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('导出成功：${file.path.split('/').last}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    }
  }

  String _generateJson(List<Habit> habits, List<Checkin> checkins) {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'habits': habits.map((h) => h.toMap()).toList(),
      'checkins': checkins.map((c) => c.toMap()).toList(),
      'summary': {
        'totalHabits': habits.length,
        'totalCheckins': checkins.length,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String _generateCsv(List<Habit> habits, List<Checkin> checkins) {
    final buffer = StringBuffer();
    
    // 习惯表头
    buffer.writeln('习惯 ID，习惯名称，图标，颜色，频率类型，创建时间');
    for (final habit in habits) {
      buffer.writeln(
        '${habit.id},"${habit.name}",${habit.icon},${habit.color},${habit.frequencyType},${DateFormat('yyyy-MM-dd').format(habit.createdAt)}',
      );
    }
    
    buffer.writeln();
    
    // 打卡表头
    buffer.writeln('打卡 ID，习惯 ID，习惯名称，打卡日期，打卡时间，是否补卡，备注');
    for (final checkin in checkins) {
      final habit = habits.firstWhere((h) => h.id == checkin.habitId, orElse: () => habits.first);
      buffer.writeln(
        '${checkin.id},${checkin.habitId},"${habit.name}",${checkin.checkinDate},${DateFormat('HH:mm').format(checkin.checkinTime)},${checkin.isMakeup ? '是' : '否'},"${checkin.note ?? ''}"',
      );
    }
    
    return buffer.toString();
  }
}
