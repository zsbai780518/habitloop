# HabitLoop - 习惯追踪器

> 离线记录习惯，在线联结成长，让坚持可视化

一款面向自律人群、自我提升爱好者的**离线优先**习惯追踪工具，兼具个性化习惯管理、数据可视化分析、社区挑战互动功能。

---

## 📱 项目状态

**当前版本:** V1.0 开发中  
**目标上线:** 2026-05-07  
**开发阶段:** 核心功能开发

---

## ✨ 核心特性

- **🔒 离线优先** - 无网络也能正常使用全部基础功能
- **📊 数据可视化** - 柱状图、折线图展示打卡进度
- **🔥 Streak 计数** - 直观展示连续打卡天数
- **🔔 本地提醒** - 离线状态下提醒正常生效
- **🎨 自定义主题** - 个性化习惯图标和颜色
- **📤 数据导出** - 支持 JSON/CSV 格式导出

---

## 🛠️ 技术栈

| 模块 | 技术 |
|------|------|
| 前端框架 | Flutter (跨平台) |
| 本地数据库 | SQLite |
| 状态管理 | Provider |
| 数据可视化 | fl_chart |
| 本地通知 | flutter_local_notifications |
| 云服务 (V1.5) | Firebase |
| 广告变现 (V1.5) | AdMob |

---

## 📁 项目结构

```
habitloop/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/                   # 数据模型
│   │   ├── habit.dart           # 习惯模型
│   │   ├── checkin.dart         # 打卡记录模型
│   │   └── user_setting.dart    # 用户设置模型
│   ├── services/                 # 服务层
│   │   ├── database_service.dart # 数据库服务
│   │   ├── checkin_service.dart  # 打卡服务
│   │   └── notification_service.dart # 通知服务
│   ├── screens/                  # 页面
│   │   ├── home_screen.dart     # 首页
│   │   ├── stats_screen.dart    # 统计页
│   │   ├── profile_screen.dart  # 个人中心
│   │   ├── create_habit_screen.dart # 创建习惯
│   │   ├── habit_detail_screen.dart # 习惯详情
│   │   ├── reminder_settings_screen.dart # 提醒设置
│   │   └── data_export_screen.dart # 数据导出
│   └── widgets/                  # 可复用组件
│       └── charts.dart          # 图表组件
├── docs/                         # 文档
│   ├── DATABASE_DESIGN.md       # 数据库设计
│   ├── UI_DESIGN.md             # UI 设计稿
│   ├── FUNCTIONAL_REQUIREMENTS.md # 功能需求
│   ├── DEVELOPMENT_LOG.md       # 开发日志
│   ├── V1.5_COMMUNITY_DESIGN.md # V1.5 设计方案
│   ├── PRIVACY_POLICY.md        # 隐私政策
│   └── TERMS_OF_SERVICE.md      # 用户协议
├── test/                         # 单元测试
│   └── models_test.dart
├── assets/                       # 资源文件
└── temp/                         # 临时文件
    └── habitloop-v1-plan.md     # 开发计划
```

---

## 🚀 开发计划

### V1.0 核心功能版 (4 周)
- [x] 项目初始化
- [x] 数据库设计
- [x] UI 设计
- [x] 核心代码骨架
- [ ] 打卡功能完整实现
- [ ] 数据可视化图表
- [ ] 本地通知提醒
- [ ] 测试与优化

### V1.5 社区功能版 (3 周)
- [ ] Firebase 接入
- [ ] 社区挑战功能
- [ ] 好友邀请裂变
- [ ] AdMob 广告接入

### V2.0 付费完整版 (2 周)
- [ ] 订阅付费功能
- [ ] 高级统计分析
- [ ] 自定义主题
- [ ] 云端同步

---

## 📊 功能优先级

| 优先级 | 功能模块 | 版本 |
|--------|----------|------|
| P0 | 自定义习惯打卡、本地存储、Streak 展示 | V1.0 |
| P0 | 基础周/月总结、本地提醒 | V1.0 |
| P1 | 社区挑战基础参与、好友邀请 | V1.5 |
| P2 | 高级统计、自定义主题、云端同步 | V2.0 |

---

## 💰 商业模式

- **免费版:** 基础功能 + AdMob 广告
- **订阅版:** $4.99/月 (无广告 + 高级功能)
- **预估 MRR:** $2K-$10K

---

## 📄 文档

- [产品规划文档](PRODUCT_PLAN.md)
- [数据库设计](docs/DATABASE_DESIGN.md)
- [UI 设计稿](docs/UI_DESIGN.md)
- [功能需求](docs/FUNCTIONAL_REQUIREMENTS.md)
- [开发计划](../temp/habitloop-v1-plan.md)

---

## 🏃 快速开始

```bash
# 克隆项目
cd habitloop

# 安装依赖
flutter pub get

# 运行开发
flutter run

# 构建发布版
flutter build apk --release  # Android
flutter build ios --release  # iOS

# 运行测试
flutter test
```

---

## 📝 开发日志

### 2026-04-09
- ✅ 完成产品规划文档归档
- ✅ 创建项目目录结构
- ✅ 完成数据库设计文档
- ✅ 完成 UI 设计文档 (含线框图)
- ✅ 完成功能需求拆解
- ✅ 实现核心代码骨架 (main.dart, models, services, screens)

---

## 📞 联系方式

- **官网:** (待上线)
- **邮箱:** (待添加)
- **GitHub:** (待开源)

---

## 📜 许可证

MIT License

---

*HabitLoop - 让坚持可视化*
