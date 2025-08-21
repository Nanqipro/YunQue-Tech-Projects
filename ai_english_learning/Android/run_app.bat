@echo off
echo ========================================
echo AI英语学习平台 - Android应用启动脚本
echo ========================================
echo.

echo 1. 清理项目...
call gradlew clean
if %errorlevel% neq 0 (
    echo 清理失败！
    pause
    exit /b 1
)

echo.
echo 2. 构建Debug版本...
call gradlew assembleDebug
if %errorlevel% neq 0 (
    echo 构建失败！
    pause
    exit /b 1
)

echo.
echo 3. 检查连接的设备...
adb devices
if %errorlevel% neq 0 (
    echo ADB未找到，请确保Android SDK已正确安装并添加到PATH中
    echo 或者使用Android Studio打开项目运行
    pause
    exit /b 1
)

echo.
echo 4. 安装应用到设备...
adb install -r app\build\outputs\apk\debug\app-debug.apk
if %errorlevel% neq 0 (
    echo 安装失败！请确保设备已连接并启用USB调试
    pause
    exit /b 1
)

echo.
echo 5. 启动应用...
adb shell am start -n com.nanqipro.ai_english_application/.MainActivity
if %errorlevel% neq 0 (
    echo 启动失败！
    pause
    exit /b 1
)

echo.
echo ========================================
echo 应用已成功启动！
echo APK位置: app\build\outputs\apk\debug\app-debug.apk
echo ========================================
pause