# 命令行启动指南

## 🚀 使用命令行运行AI英语学习平台

### 环境准备

#### 1. 安装Java JDK
```bash
# 检查Java版本（需要JDK 11或更高）
java -version
javac -version

# 如果未安装，下载安装JDK 11+
# Windows: https://adoptium.net/
# macOS: brew install openjdk@11
# Ubuntu: sudo apt install openjdk-11-jdk
```

#### 2. 安装Android SDK
```bash
# 方法1：通过Android Studio安装（推荐）
# 下载Android Studio会自动安装SDK

# 方法2：仅安装命令行工具
# 下载地址：https://developer.android.com/studio#command-tools
```

#### 3. 配置环境变量

**Windows (PowerShell):**
```powershell
# 设置ANDROID_HOME
$env:ANDROID_HOME = "C:\Users\YourName\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools"

# 永久设置（添加到系统环境变量）
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\YourName\AppData\Local\Android\Sdk", "User")
```

**macOS/Linux (Bash):**
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
# export ANDROID_HOME=$HOME/Android/Sdk        # Linux
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools

# 重新加载配置
source ~/.bashrc  # 或 source ~/.zshrc
```

### 快速启动

#### Windows用户
```cmd
# 进入Android项目目录
cd ai_english_learning\Android

# 运行启动脚本
run_app.bat
```

#### macOS/Linux用户
```bash
# 进入Android项目目录
cd ai_english_learning/Android

# 给脚本执行权限
chmod +x run_app.sh

# 运行启动脚本
./run_app.sh
```

### 手动步骤详解

#### 1. 项目清理和构建

```bash
# 进入Android项目目录
cd ai_english_learning/Android

# 清理项目
./gradlew clean          # macOS/Linux
.\gradlew clean          # Windows

# 构建Debug版本
./gradlew assembleDebug  # macOS/Linux
.\gradlew assembleDebug  # Windows

# 构建Release版本（可选）
./gradlew assembleRelease
```

#### 2. 设备准备

**选项A：使用真实设备**
```bash
# 检查连接的设备
adb devices

# 如果设备显示为"unauthorized"，在设备上允许USB调试
# 如果没有设备，请：
# 1. 连接Android设备到电脑
# 2. 启用开发者选项和USB调试
# 3. 安装设备驱动程序
```

**选项B：使用模拟器**
```bash
# 列出可用的AVD
emulator -list-avds

# 启动模拟器（替换AVD_NAME为实际名称）
emulator -avd AVD_NAME &

# 等待模拟器完全启动
adb wait-for-device
```

#### 3. 安装和启动应用

```bash
# 安装APK到设备
adb install app/build/outputs/apk/debug/app-debug.apk

# 如果已安装，强制重新安装
adb install -r app/build/outputs/apk/debug/app-debug.apk

# 启动应用
adb shell am start -n com.nanqipro.ai_english_application/.MainActivity
```

### 高级命令

#### 调试和日志
```bash
# 查看应用日志
adb logcat | grep "AI_English"

# 查看所有日志
adb logcat

# 清除日志缓冲区
adb logcat -c

# 查看设备信息
adb shell getprop ro.build.version.release  # Android版本
adb shell getprop ro.product.model          # 设备型号
```

#### 应用管理
```bash
# 卸载应用
adb uninstall com.nanqipro.ai_english_application

# 强制停止应用
adb shell am force-stop com.nanqipro.ai_english_application

# 查看已安装的包
adb shell pm list packages | grep ai_english

# 查看应用信息
adb shell dumpsys package com.nanqipro.ai_english_application
```

#### 文件传输
```bash
# 推送文件到设备
adb push local_file.txt /sdcard/

# 从设备拉取文件
adb pull /sdcard/file.txt ./

# 查看设备文件
adb shell ls /sdcard/
```

### 创建模拟器（命令行方式）

```bash
# 列出可用的系统镜像
avdmanager list targets

# 下载系统镜像（如果需要）
sdkmanager "system-images;android-30;google_apis;x86_64"

# 创建AVD
avdmanager create avd \
  -n "AI_English_AVD" \
  -k "system-images;android-30;google_apis;x86_64" \
  -d "pixel_4"

# 启动创建的AVD
emulator -avd AI_English_AVD
```

### 性能优化

#### Gradle构建优化
```bash
# 并行构建
./gradlew assembleDebug --parallel

# 使用构建缓存
./gradlew assembleDebug --build-cache

# 离线模式（如果依赖已下载）
./gradlew assembleDebug --offline

# 详细输出
./gradlew assembleDebug --info
```

#### 模拟器性能优化
```bash
# 启用硬件加速
emulator -avd AI_English_AVD -gpu host

# 增加内存
emulator -avd AI_English_AVD -memory 2048

# 启用快照
emulator -avd AI_English_AVD -snapshot-save
```

### 故障排除

#### 常见问题

**1. Gradle构建失败**
```bash
# 清理Gradle缓存
./gradlew clean
rm -rf ~/.gradle/caches/  # macOS/Linux
# Windows: 删除 C:\Users\YourName\.gradle\caches\

# 重新下载依赖
./gradlew assembleDebug --refresh-dependencies
```

**2. ADB连接问题**
```bash
# 重启ADB服务
adb kill-server
adb start-server

# 检查ADB版本
adb version

# 检查端口占用
netstat -an | grep 5037
```

**3. 设备未识别**
```bash
# 检查USB驱动
# Windows: 设备管理器中查看
# macOS: 系统信息中查看USB设备
# Linux: lsusb

# 尝试不同的USB模式
# 在设备上切换USB配置为"文件传输"或"PTP"
```

**4. 模拟器启动失败**
```bash
# 检查虚拟化支持
# Windows: 任务管理器 → 性能 → CPU → 虚拟化
# macOS: sysctl -a | grep machdep.cpu.features
# Linux: grep -E '(vmx|svm)' /proc/cpuinfo

# 重新创建AVD
avdmanager delete avd -n AI_English_AVD
# 然后重新创建
```

### 自动化脚本示例

**完整的构建和部署脚本 (deploy.sh):**
```bash
#!/bin/bash

set -e  # 遇到错误立即退出

echo "开始构建和部署AI英语学习应用..."

# 清理和构建
echo "1. 清理项目..."
./gradlew clean

echo "2. 构建应用..."
./gradlew assembleDebug

# 检查设备
echo "3. 检查设备连接..."
DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device" | wc -l)
if [ $DEVICE_COUNT -eq 0 ]; then
    echo "错误：没有连接的设备"
    exit 1
fi

# 安装应用
echo "4. 安装应用..."
adb install -r app/build/outputs/apk/debug/app-debug.apk

# 启动应用
echo "5. 启动应用..."
adb shell am start -n com.nanqipro.ai_english_application/.MainActivity

echo "部署完成！"
```

### 持续集成示例

**GitHub Actions配置 (.github/workflows/android.yml):**
```yaml
name: Android CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 11
      uses: actions/setup-java@v3
      with:
        java-version: '11'
        distribution: 'temurin'
        
    - name: Setup Android SDK
      uses: android-actions/setup-android@v2
      
    - name: Cache Gradle packages
      uses: actions/cache@v3
      with:
        path: |
          ~/.gradle/caches
          ~/.gradle/wrapper
        key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
        restore-keys: |
          ${{ runner.os }}-gradle-
          
    - name: Grant execute permission for gradlew
      run: chmod +x gradlew
      working-directory: ./Android
      
    - name: Build with Gradle
      run: ./gradlew assembleDebug
      working-directory: ./Android
      
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-debug
        path: Android/app/build/outputs/apk/debug/app-debug.apk
```

---

**注意事项：**
- 确保网络连接稳定（首次构建需要下载依赖）
- 某些防火墙可能阻止ADB连接，需要添加例外
- 模拟器需要足够的系统资源（至少4GB RAM）
- 真实设备测试效果更好，性能更接近实际使用