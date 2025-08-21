#!/bin/bash

echo "========================================"
echo "AI英语学习平台 - Android应用启动脚本"
echo "========================================"
echo

echo "1. 清理项目..."
./gradlew clean
if [ $? -ne 0 ]; then
    echo "清理失败！"
    exit 1
fi

echo
echo "2. 构建Debug版本..."
./gradlew assembleDebug
if [ $? -ne 0 ]; then
    echo "构建失败！"
    exit 1
fi

echo
echo "3. 检查连接的设备..."
adb devices
if [ $? -ne 0 ]; then
    echo "ADB未找到，请确保Android SDK已正确安装并添加到PATH中"
    echo "或者使用Android Studio打开项目运行"
    exit 1
fi

echo
echo "4. 安装应用到设备..."
adb install -r app/build/outputs/apk/debug/app-debug.apk
if [ $? -ne 0 ]; then
    echo "安装失败！请确保设备已连接并启用USB调试"
    exit 1
fi

echo
echo "5. 启动应用..."
adb shell am start -n com.nanqipro.ai_english_application/.MainActivity
if [ $? -ne 0 ]; then
    echo "启动失败！"
    exit 1
fi

echo
echo "========================================"
echo "应用已成功启动！"
echo "APK位置: app/build/outputs/apk/debug/app-debug.apk"
echo "========================================"