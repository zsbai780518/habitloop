import 'package:flutter/material.dart';

/// 个人中心页面
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息卡片
            _buildProfileHeader(),
            const SizedBox(height: 16),
            
            // 功能列表
            _buildFeatureList(context),
            const SizedBox(height: 24),
            
            // 版本信息
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF81C784),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '累计坚持',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '45 天',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '总打卡次数',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '312 次',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Column(
          children: [
            _buildFeatureItem(
              context,
              icon: Icons.upload,
              title: '数据导出',
              subtitle: '导出习惯数据为 JSON/CSV',
              onTap: () {
                // TODO: 数据导出
              },
            ),
            const Divider(height: 1),
            _buildFeatureItem(
              context,
              icon: Icons.notifications,
              title: '提醒设置',
              subtitle: '管理打卡提醒时间',
              onTap: () {
                // TODO: 提醒设置
              },
            ),
            const Divider(height: 1),
            _buildFeatureItem(
              context,
              icon: Icons.palette,
              title: '主题设置',
              subtitle: '自定义应用主题和颜色',
              onTap: () {
                // TODO: 主题设置
              },
            ),
            const Divider(height: 1),
            _buildFeatureItem(
              context,
              icon: Icons.analytics,
              title: '使用统计',
              subtitle: '查看应用使用数据',
              onTap: () {
                // TODO: 使用统计
              },
            ),
            const Divider(height: 1),
            _buildFeatureItem(
              context,
              icon: Icons.help,
              title: '帮助与反馈',
              subtitle: '查看帮助或提交反馈',
              onTap: () {
                // TODO: 帮助与反馈
              },
            ),
            const Divider(height: 1),
            _buildFeatureItem(
              context,
              icon: Icons.star,
              title: '给应用打分',
              subtitle: '支持我们请给个好评',
              onTap: () {
                // TODO: 跳转应用商店
              },
            ),
            const Divider(height: 1),
            _buildFeatureItem(
              context,
              icon: Icons.info,
              title: '关于我们',
              subtitle: '版本信息和开源协议',
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'HabitLoop v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '离线记录习惯，在线联结成长',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('关于 HabitLoop'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本：1.0.0'),
            SizedBox(height: 8),
            Text('Slogan: 离线记录习惯，在线联结成长'),
            SizedBox(height: 16),
            Text(
              '一款离线优先的习惯追踪工具，\n兼具个性化习惯管理、数据可视化分析、\n社区挑战互动功能。',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
