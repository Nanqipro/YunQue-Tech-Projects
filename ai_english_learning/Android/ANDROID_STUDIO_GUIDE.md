# Android Studio 启动指南

## 📱 使用Android Studio运行AI英语学习平台

### 1. 安装Android Studio

1. **下载Android Studio**
   - 访问：https://developer.android.com/studio
   - 下载最新版本的Android Studio
   - 推荐版本：2023.1.1 或更高

2. **安装过程**
   - 运行下载的安装程序
   - 选择"Standard"安装类型
   - 确保勾选以下组件：
     - Android SDK
     - Android SDK Platform
     - Android Virtual Device

### 2. 配置Android Studio

1. **首次启动配置**
   - 启动Android Studio
   - 完成初始设置向导
   - 接受所有许可协议
   - 等待SDK组件下载完成

2. **SDK配置**
   - 打开 File → Settings (Windows) 或 Android Studio → Preferences (Mac)
   - 导航到 Appearance & Behavior → System Settings → Android SDK
   - 确保安装了以下组件：
     - Android API 24 (Android 7.0) 或更高
     - Android SDK Build-Tools
     - Android SDK Platform-Tools
     - Android SDK Tools

### 3. 打开项目

1. **导入项目**
   ```
   File → Open
   选择路径：ai_english_learning/Android
   点击 OK
   ```

2. **等待项目同步**
   - Android Studio会自动检测Gradle项目
   - 等待"Gradle sync"完成
   - 如果提示更新Gradle或插件，选择更新

3. **解决可能的问题**
   - 如果出现SDK路径问题：
     ```
     File → Project Structure → SDK Location
     设置正确的Android SDK路径
     ```

### 4. 配置运行设备

#### 选项A：使用真实设备

1. **启用开发者选项**
   - 在Android设备上：设置 → 关于手机
   - 连续点击"版本号"7次
   - 返回设置，找到"开发者选项"

2. **启用USB调试**
   - 开发者选项 → USB调试 → 开启
   - 连接USB线到电脑
   - 允许USB调试授权

3. **验证连接**
   - 在Android Studio中查看设备列表
   - 设备应该显示在运行配置中

#### 选项B：使用模拟器

1. **创建虚拟设备**
   ```
   Tools → AVD Manager
   点击 "Create Virtual Device"
   ```

2. **选择设备类型**
   - 推荐：Pixel 4 或 Pixel 6
   - 屏幕尺寸：5.5"以上

3. **选择系统镜像**
   - 推荐：Android 10 (API 29) 或更高
   - 选择x86_64架构（性能更好）
   - 下载所需的系统镜像

4. **配置AVD**
   - 设备名称：AI_English_AVD
   - 启动方向：Portrait
   - 内存：2048MB或更高

### 5. 运行应用

1. **选择运行配置**
   - 确保选择了"app"配置
   - 选择目标设备（真实设备或模拟器）

2. **构建并运行**
   - 点击绿色的"Run"按钮（▶️）
   - 或使用快捷键：Shift + F10 (Windows) / Ctrl + R (Mac)

3. **等待安装**
   - Android Studio会自动构建APK
   - 安装到选择的设备
   - 自动启动应用

### 6. 调试和开发

#### 查看日志
```
View → Tool Windows → Logcat
过滤器：com.nanqipro.ai_english_application
```

#### 重新安装应用
```
Build → Clean Project
Build → Rebuild Project
再次运行应用
```

#### 查看布局
```
Tools → Layout Inspector
选择运行中的应用进程
```

### 7. 常见问题解决

#### 问题1：Gradle同步失败
**解决方案：**
```
File → Invalidate Caches and Restart
选择 "Invalidate and Restart"
```

#### 问题2：设备未识别
**解决方案：**
- 检查USB线连接
- 重新启用USB调试
- 更新设备驱动程序
- 尝试不同的USB端口

#### 问题3：模拟器启动慢
**解决方案：**
- 启用硬件加速：
  ```
  SDK Manager → SDK Tools → Intel x86 Emulator Accelerator
  ```
- 增加模拟器内存
- 关闭不必要的后台程序

#### 问题4：构建错误
**解决方案：**
```
1. 检查网络连接（下载依赖需要）
2. 清理项目：Build → Clean Project
3. 重新同步：File → Sync Project with Gradle Files
4. 检查JDK版本（需要JDK 11或更高）
```

### 8. 性能优化建议

1. **增加IDE内存**
   ```
   Help → Edit Custom VM Options
   添加：
   -Xmx4096m
   -XX:ReservedCodeCacheSize=512m
   ```

2. **启用离线模式**（可选）
   ```
   File → Settings → Build → Gradle
   勾选 "Offline work"
   ```

3. **配置代理**（如果网络受限）
   ```
   File → Settings → Appearance & Behavior → System Settings → HTTP Proxy
   ```

### 9. 项目结构说明

```
Android/
├── app/
│   ├── src/main/
│   │   ├── java/com/nanqipro/ai_english_application/
│   │   │   ├── MainActivity.java          # 主Activity
│   │   │   ├── HomeFragment.java          # 首页Fragment
│   │   │   ├── WordsFragment.java         # AI单词模块
│   │   │   ├── ReadingFragment.java       # AI阅读模块
│   │   │   └── ProfileFragment.java       # 个人中心
│   │   ├── res/
│   │   │   ├── layout/                    # 布局文件
│   │   │   ├── values/                    # 资源文件
│   │   │   └── drawable/                  # 图标资源
│   │   └── AndroidManifest.xml           # 应用清单
│   └── build.gradle.kts                  # 应用构建配置
├── build.gradle.kts                      # 项目构建配置
└── gradle.properties                     # Gradle属性
```

### 10. 下一步开发

1. **连接后端API**
   - 添加网络请求库（Retrofit, OkHttp）
   - 实现API接口调用
   - 添加数据模型类

2. **数据持久化**
   - 集成Room数据库
   - 实现本地数据缓存
   - 添加用户偏好设置

3. **功能增强**
   - 添加语音识别功能
   - 实现离线学习模式
   - 集成推送通知

---

**提示：** 如果在使用过程中遇到问题，可以查看Android Studio的"Event Log"面板获取详细错误信息。