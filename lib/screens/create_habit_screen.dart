import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:habitloop/models/habit.dart';
import 'package:habitloop/services/database_service.dart';

/// 创建/编辑习惯页面
class CreateHabitScreen extends StatefulWidget {
  final String? habitId; // 如果传入 ID 则为编辑模式

  const CreateHabitScreen({super.key, this.habitId});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedIcon = '🎯';
  int _selectedColor = 0xFF4CAF50;
  String _frequencyType = 'daily';
  int _targetCount = 1;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  bool _isSaving = false;

  // 预设图标
  static const List<String> _icons = [
    '🎯', '🏃', '📚', '💧', '🧘', '✏️', '🥗', '😴', '📱', '💰', '🎨', '🎵'
  ];

  // 预设颜色
  static const List<int> _colors = [
    0xFF4CAF50, // 绿
    0xFF2196F3, // 蓝
    0xFFFF9800, // 橙
    0xFF9C27B0, // 紫
    0xFFF44336, // 红
    0xFF00BCD4, // 青
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habitId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑习惯' : '创建习惯'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveHabit,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 习惯名称
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '习惯名称 *',
                hintText: '例如：早起、阅读、运动...',
                prefixIcon: Icon(Icons.edit),
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入习惯名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 选择图标
            _buildSectionTitle('选择图标'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.grey[200],
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 选择颜色
            _buildSectionTitle('选择颜色'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 打卡频率
            _buildSectionTitle('打卡频率 *'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('每天'),
                    leading: Radio<String>(
                      value: 'daily',
                      groupValue: _frequencyType,
                      onChanged: (value) => setState(() => _frequencyType = value!),
                    ),
                    onTap: () => setState(() => _frequencyType = 'daily'),
                  ),
                  ListTile(
                    title: const Text('每周 (选择星期)'),
                    leading: Radio<String>(
                      value: 'weekly',
                      groupValue: _frequencyType,
                      onChanged: (value) => setState(() => _frequencyType = value!),
                    ),
                    onTap: () => setState(() => _frequencyType = 'weekly'),
                  ),
                  ListTile(
                    title: const Text('自定义日期'),
                    leading: Radio<String>(
                      value: 'custom',
                      groupValue: _frequencyType,
                      onChanged: (value) => setState(() => _frequencyType = value!),
                    ),
                    onTap: () => setState(() => _frequencyType = 'custom'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 每日目标次数
            _buildSectionTitle('每日目标次数'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_targetCount > 1) {
                      setState(() => _targetCount--);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  width: 60,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '$_targetCount 次',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _targetCount++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 提醒设置
            _buildSectionTitle('设置提醒'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('启用提醒'),
                    subtitle: const Text('在指定时间提醒你打卡'),
                    value: _reminderEnabled,
                    onChanged: (value) => setState(() => _reminderEnabled = value),
                  ),
                  if (_reminderEnabled)
                    ListTile(
                      title: const Text('提醒时间'),
                      trailing: Text(
                        _reminderTime?.format(context) ?? '未设置',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (time != null) {
                          setState(() => _reminderTime = time);
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '保存习惯',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final habit = Habit(
        id: widget.habitId ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        frequencyType: _frequencyType,
        frequencyValue: '[]', // TODO: 根据频率类型生成
        targetCount: _targetCount,
        reminderEnabled: _reminderEnabled,
        reminderTime: _reminderTime?.format(context),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.habitId != null) {
        await DatabaseService.instance.updateHabit(habit);
      } else {
        await DatabaseService.instance.insertHabit(habit);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
