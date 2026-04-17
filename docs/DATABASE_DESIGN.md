# HabitLoop 数据库设计文档

## 数据库概述

- **数据库名称:** habitloop.db
- **存储位置:** 本地 SQLite (应用沙盒目录)
- **加密方式:** SQLCipher (可选，增强隐私保护)

---

## 数据表设计

### 1. habits (习惯表)

存储用户创建的所有习惯定义。

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID 唯一标识 |
| name | TEXT | NOT NULL | 习惯名称 (如"早起"、"阅读") |
| icon | TEXT | NOT NULL | 图标标识符 |
| color | INTEGER | NOT NULL | 主题颜色 (ARGB 整型) |
| frequency_type | TEXT | NOT NULL | 频率类型：daily/weekly/custom |
| frequency_value | TEXT | NOT NULL | 频率值：每日=1，每周=[1,2,3]，自定义=日期列表 |
| target_count | INTEGER | DEFAULT 1 | 每日目标次数 (默认 1 次) |
| reminder_enabled | INTEGER | DEFAULT 0 | 是否启用提醒 (0/1) |
| reminder_time | TEXT | NULL | 提醒时间 (HH:mm 格式) |
| created_at | INTEGER | NOT NULL | 创建时间戳 (毫秒) |
| updated_at | INTEGER | NOT NULL | 最后更新时间戳 |
| is_deleted | INTEGER | DEFAULT 0 | 软删除标记 (0/1) |

**索引:**
- `idx_habits_created_at` (created_at DESC) - 按创建时间排序
- `idx_habits_is_deleted` (is_deleted) - 软删除查询优化

---

### 2. checkins (打卡记录表)

存储每次习惯打卡的详细记录。

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID 唯一标识 |
| habit_id | TEXT | NOT NULL, FK | 关联 habits.id |
| checkin_date | TEXT | NOT NULL | 打卡日期 (YYYY-MM-DD) |
| checkin_time | INTEGER | NOT NULL | 打卡时间戳 (毫秒) |
| note | TEXT | NULL | 可选备注/心得 |
| is_makeup | INTEGER | DEFAULT 0 | 是否补卡 (0/1) |
| created_at | INTEGER | NOT NULL | 记录创建时间戳 |

**索引:**
- `idx_checkins_habit_date` (habit_id, checkin_date) - 查询某习惯某日打卡
- `idx_checkins_date` (checkin_date DESC) - 按日期查询
- `idx_checkins_habit` (habit_id) - 关联查询优化

---

### 3. user_settings (用户设置表)

存储用户个性化设置。

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| key | TEXT | PRIMARY KEY | 设置键名 |
| value | TEXT | NOT NULL | 设置值 (JSON 字符串) |
| updated_at | INTEGER | NOT NULL | 最后更新时间戳 |

**预设设置项:**
- `theme_mode`: "system" | "light" | "dark"
- `primary_color`: 主题色值
- `week_start_day`: 1-7 (周一至周日)
- `data_export_path`: 数据导出路径
- `notifications_enabled`: 全局通知开关

---

### 4. challenge_participants (挑战参与表) - V1.5

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID 唯一标识 |
| challenge_id | TEXT | NOT NULL | 挑战 ID |
| user_id | TEXT | NOT NULL | 用户 ID |
| join_date | INTEGER | NOT NULL | 参与时间戳 |
| status | TEXT | NOT NULL | 状态：active/completed/abandoned |
| progress | INTEGER | DEFAULT 0 | 当前进度 (打卡天数) |

---

## 核心查询示例

### 1. 获取某习惯的连续打卡天数 (Streak)

```sql
-- 获取当前连续打卡天数
SELECT COUNT(*) as streak
FROM (
  SELECT checkin_date
  FROM checkins
  WHERE habit_id = ? AND is_deleted = 0
  ORDER BY checkin_date DESC
)
WHERE checkin_date >= date('now', '-' || (ROW_NUMBER() OVER () - 1) || ' days');
```

### 2. 获取周/月打卡统计

```sql
-- 获取指定日期范围内的打卡记录
SELECT 
  checkin_date,
  COUNT(*) as checkin_count,
  GROUP_CONCAT(habit_id) as habit_ids
FROM checkins
WHERE checkin_date BETWEEN ? AND ?
GROUP BY checkin_date;
```

### 3. 获取习惯列表 (含最新打卡状态)

```sql
SELECT 
  h.id, h.name, h.icon, h.color, h.frequency_type,
  MAX(c.checkin_date) as last_checkin_date,
  c.checkin_date as today_checkin_date
FROM habits h
LEFT JOIN checkins c ON h.id = c.habit_id 
  AND c.checkin_date = date('now')
WHERE h.is_deleted = 0
GROUP BY h.id
ORDER BY h.created_at DESC;
```

---

## 数据迁移策略

### 版本管理
- 数据库版本存储于 `user_settings` 表
- 每次升级检查版本号，执行对应迁移脚本
- 迁移失败回滚，保障数据安全

### 数据备份
- 每次重大操作前自动备份数据库
- 支持用户手动导出为 JSON/CSV
- 备份文件存储于应用沙盒/用户指定目录

---

## 安全与隐私

1. **本地加密:** 可选 SQLCipher 加密数据库文件
2. **敏感数据:** 不存储用户身份信息 (V1.0 纯离线)
3. **数据导出:** 用户可随时导出全部数据
4. **数据删除:** 支持彻底删除 (物理删除 + 清空回收站)
