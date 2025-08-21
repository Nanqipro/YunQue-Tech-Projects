# AI英语学习平台

一款覆盖小学至成人阶段的全场景智能英语提升平台，强调"自主学习 + AI个性化反馈 + 场景化应用"。

## 📱 项目概述

### 核心理念
让不同阶段的学习者在"词汇 → 阅读 → 输出"三个环节中形成闭环，通过AI实现学习路径的智能推荐和实时纠错反馈。

### 主要功能
- **AI单词模块**：智能背词、语境记忆、智能测试、词汇能力画像
- **AI阅读模块**：分级阅读、AI伴读、段落提纲、智能问答
- **个人中心**：学习进度、成就系统、个性化设置

## 🏗️ 项目架构

```
ai_english_learning/
├── Android/          # Android客户端
├── service/          # 后端服务
└── docs/            # 项目文档
```

## 📱 Android客户端启动

### 环境要求
- **JDK**: 11 或更高版本
- **Android SDK**: API Level 24 (Android 7.0) 或更高
- **Gradle**: 8.0 或更高版本
- **Android Studio**: 2023.1.1 或更高版本（推荐）

### 方式一：Android Studio启动（推荐）

1. **安装Android Studio**
   - 下载地址：https://developer.android.com/studio
   - 安装时确保包含Android SDK和模拟器

2. **打开项目**
   ```bash
   # 启动Android Studio，选择"Open an Existing Project"
   # 选择项目路径：ai_english_learning/Android
   ```

3. **配置SDK**
   - File → Project Structure → SDK Location
   - 确保Android SDK路径正确设置

4. **同步项目**
   - 点击"Sync Project with Gradle Files"按钮
   - 等待依赖下载完成

5. **运行应用**
   - 连接Android设备或启动模拟器
   - 点击"Run"按钮（绿色三角形）
   - 选择目标设备运行

### 方式二：命令行启动

1. **环境配置**
   ```bash
   # 设置ANDROID_HOME环境变量
   export ANDROID_HOME=/path/to/android/sdk
   export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
   
   # Windows用户使用：
   # set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
   # set PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools
   ```

2. **进入Android项目目录**
   ```bash
   cd ai_english_learning/Android
   ```

3. **检查连接的设备**
   ```bash
   adb devices
   ```

4. **构建项目**
   ```bash
   # Windows
   .\gradlew assembleDebug
   
   # macOS/Linux
   ./gradlew assembleDebug
   ```

5. **安装到设备**
   ```bash
   # Windows
   .\gradlew installDebug
   
   # macOS/Linux
   ./gradlew installDebug
   ```

6. **启动应用**
   ```bash
   adb shell am start -n com.nanqipro.ai_english_application/.MainActivity
   ```

### 使用模拟器

1. **创建AVD（Android Virtual Device）**
   ```bash
   # 列出可用的系统镜像
   avdmanager list targets
   
   # 创建AVD
   avdmanager create avd -n "AI_English_AVD" -k "system-images;android-30;google_apis;x86_64"
   ```

2. **启动模拟器**
   ```bash
   emulator -avd AI_English_AVD
   ```

3. **安装应用到模拟器**
   ```bash
   adb install app/build/outputs/apk/debug/app-debug.apk
   ```

## 🚀 后端服务启动

### 环境要求
- **Java**: 17 或更高版本
- **Maven**: 3.8 或更高版本
- **MySQL**: 8.0 或更高版本
- **Docker**: 20.10 或更高版本（可选）

### 方式一：本地启动

1. **进入后端目录**
   ```bash
   cd ai_english_learning/service
   ```

2. **配置数据库**
   ```bash
   # 创建数据库
   mysql -u root -p
   CREATE DATABASE ai_english_learning;
   
   # 导入初始数据
   mysql -u root -p ai_english_learning < init.sql
   ```

3. **配置应用**
   ```bash
   # 编辑 src/main/resources/application.yml
   # 修改数据库连接信息
   ```

4. **启动服务**
   ```bash
   # Windows
   .\mvnw spring-boot:run
   
   # macOS/Linux
   ./mvnw spring-boot:run
   ```

5. **验证服务**
   ```bash
   curl http://localhost:8080/api/health
   ```

### 方式二：Docker启动（推荐）

1. **构建并启动所有服务**
   ```bash
   cd ai_english_learning/service
   docker-compose up -d
   ```

2. **查看服务状态**
   ```bash
   docker-compose ps
   ```

3. **查看日志**
   ```bash
   docker-compose logs -f app
   ```

4. **停止服务**
   ```bash
   docker-compose down
   ```

## 🔧 开发调试

### Android调试

1. **启用开发者选项**
   - 设置 → 关于手机 → 连续点击"版本号"7次
   - 设置 → 开发者选项 → 启用"USB调试"

2. **查看日志**
   ```bash
   adb logcat | grep "AI_English"
   ```

3. **重新安装应用**
   ```bash
   adb uninstall com.nanqipro.ai_english_application
   ./gradlew installDebug
   ```

### 后端调试

1. **开发模式启动**
   ```bash
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
   ```

2. **查看API文档**
   - 访问：http://localhost:8080/swagger-ui.html

3. **数据库管理**
   ```bash
   # 连接数据库
   docker exec -it service_mysql_1 mysql -u root -p ai_english_learning
   ```

## 📚 API接口

### 基础URL
```
开发环境: http://localhost:8080/api
生产环境: https://api.ai-english.com/api
```

### 主要接口
- `GET /words/levels` - 获取词汇等级列表
- `GET /words/{level}` - 获取指定等级的词汇
- `GET /reading/categories` - 获取阅读分类
- `GET /reading/articles` - 获取阅读文章列表
- `POST /user/progress` - 更新学习进度

详细API文档请参考：[后端接口文档](docs/后端接口文档.md)

## 🗄️ 数据库设计

数据库表结构设计请参考：[数据库表结构设计](docs/数据库表结构设计.sql)

主要数据表：
- `users` - 用户信息
- `vocabulary_levels` - 词汇等级
- `words` - 单词数据
- `reading_articles` - 阅读文章
- `user_progress` - 学习进度
- `achievements` - 成就系统

## 🚀 部署指南

### Android应用发布

1. **生成签名密钥**
   ```bash
   keytool -genkey -v -keystore ai-english-key.keystore -alias ai_english -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **配置签名**
   ```gradle
   // 在 app/build.gradle.kts 中添加
   android {
       signingConfigs {
           release {
               storeFile file("ai-english-key.keystore")
               storePassword "your_store_password"
               keyAlias "ai_english"
               keyPassword "your_key_password"
           }
       }
   }
   ```

3. **构建发布版本**
   ```bash
   ./gradlew assembleRelease
   ```

### 后端服务部署

1. **构建Docker镜像**
   ```bash
   docker build -t ai-english-service .
   ```

2. **部署到服务器**
   ```bash
   # 使用提供的部署脚本
   chmod +x deploy.sh
   ./deploy.sh
   ```

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系我们

- 项目主页：https://github.com/YunQue-Tech/ai_english_learning
- 问题反馈：https://github.com/YunQue-Tech/ai_english_learning/issues
- 邮箱：support@yunque-tech.com

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和用户！

---

**注意**：这是一个静态UI演示版本，部分功能需要后端API支持才能完全运行。