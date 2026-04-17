# HabitLoop - Android APK 编译指南

由于当前服务器环境限制，APK 需要在您的本地开发环境中编译。以下是详细步骤：

---

## 方法一：使用 Android Studio (推荐)

### 1. 安装 Android Studio
1. 下载：https://developer.android.com/studio
2. 安装并启动
3. 完成 SDK 配置

### 2. 打开项目
1. 启动 Android Studio
2. 选择 "Open an Existing Project"
3. 选择 `habitloop` 文件夹

### 3. 配置 Flutter 插件
1. File → Settings → Plugins
2. 搜索并安装 "Flutter" 和 "Dart" 插件
3. 重启 Android Studio

### 4. 编译 APK
```bash
# 在项目根目录打开终端
cd habitloop

# 获取依赖
flutter pub get

# 编译调试版 APK
flutter build apk --debug

# 编译发布版 APK (需要签名)
flutter build apk --release
```

### 5. 查找 APK 文件
- 调试版：`build/app/outputs/flutter-apk/app-debug.apk`
- 发布版：`build/app/outputs/flutter-apk/app-release.apk`

---

## 方法二：使用命令行

### 前置条件
- Flutter SDK 3.0+
- Android SDK
- Java JDK 11+

### 编译步骤
```bash
# 1. 进入项目目录
cd habitloop

# 2. 检查 Flutter 环境
flutter doctor -v

# 3. 获取依赖
flutter pub get

# 4. 编译 APK
flutter build apk --release

# 5. 查看输出
ls -lh build/app/outputs/flutter-apk/
```

---

## 方法三：创建签名发布版 (上架用)

### 1. 创建密钥库
```bash
keytool -genkey -v -keystore ~/habitloop-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias habitloop
```

### 2. 配置签名
在 `android/app/build.gradle` 中添加：
```gradle
android {
    ...
    signingConfigs {
        release {
            storeFile file('/path/to/habitloop-key.jks')
            storePassword 'your-store-password'
            keyAlias 'habitloop'
            keyPassword 'your-key-password'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. 编译签名版
```bash
flutter build apk --release
```

---

## 常见问题解决

### 问题 1: Android SDK 未找到
```bash
# 设置环境变量
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
```

### 问题 2: 许可证未接受
```bash
flutter doctor --android-licenses
# 输入 y 接受所有许可证
```

### 问题 3: Gradle 构建失败
```bash
# 清理并重新构建
flutter clean
flutter pub get
flutter build apk --release
```

### 问题 4: 内存不足
```bash
# 增加 Gradle 内存
# 在 gradle.properties 中添加：
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m
```

---

## 快速测试 (无需编译)

如果您想快速测试应用，可以使用以下方法：

### 方法 A: Flutter Run (连接真机)
```bash
# 1. 启用 USB 调试 (Android 手机)
# 2. 连接 USB
# 3. 运行
flutter run
```

### 方法 B: 使用模拟器
```bash
# 1. 创建模拟器
flutter emulators --create

# 2. 启动模拟器
flutter emulators --launch <emulator_id>

# 3. 运行应用
flutter run
```

---

## 输出文件说明

| 文件 | 大小 | 用途 |
|------|------|------|
| `app-debug.apk` | ~40MB | 调试测试 |
| `app-release.apk` | ~20MB | 发布上架 |
| `app-release.aab` | ~15MB | Google Play 上架格式 |

---

## 上架准备

### Google Play Store
1. 创建开发者账号 ($25 一次性)
2. 准备素材：
   - 应用图标 (512x512)
   - 截图 (至少 4 张)
   - 应用描述
   - 隐私政策链接
3. 上传 AAB 文件
4. 提交审核

### 国内应用商店
- 华为应用市场
- 小米应用商店
- OPPO 软件商店
- vivo 应用商店
- 应用宝

每个商店需要单独注册开发者账号。

---

## 联系支持

编译过程中遇到问题？
- Flutter 官方文档：https://docs.flutter.dev
- GitHub Issues: (待创建)
- 邮箱：support@habitloop.app (待设置)

---

*最后更新：2026-04-09*
