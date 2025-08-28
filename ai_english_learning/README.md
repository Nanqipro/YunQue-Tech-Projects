# AI英语学习平台

一个基于AI技术的智能英语学习平台，提供个性化的英语学习体验，包括词汇学习、听力训练、阅读理解、写作练习和口语练习等功能。

## 🌟 特性

- **智能词汇学习**：基于艾宾浩斯遗忘曲线的智能复习系统
- **听力训练**：多样化的听力材料和智能评估
- **阅读理解**：分级阅读材料和理解测试
- **写作练习**：AI智能批改和写作建议
- **口语练习**：AI对话伙伴和发音评估
- **学习统计**：详细的学习进度和成绩分析
- **个性化推荐**：基于学习数据的智能内容推荐

## 🏗️ 技术架构

### 后端技术栈
- **语言**：Go 1.19+
- **框架**：Gin Web Framework
- **数据库**：MySQL 8.0+
- **缓存**：Redis 7.0+
- **认证**：JWT Token
- **日志**：Logrus
- **配置**：Viper
- **容器化**：Docker & Docker Compose

### 前端技术栈
- **框架**：Flutter
- **状态管理**：Provider/Riverpod
- **网络请求**：Dio
- **本地存储**：SharedPreferences/Hive

## 📁 项目结构

```
ai_english_learning/
├── client/                 # Flutter前端应用
│   ├── lib/
│   │   ├── models/        # 数据模型
│   │   ├── services/      # 业务服务
│   │   ├── screens/       # 页面组件
│   │   ├── widgets/       # 通用组件
│   │   └── utils/         # 工具类
│   └── pubspec.yaml
├── serve/                  # Go后端服务
│   ├── api/               # API处理器
│   ├── internal/          # 内部模块
│   │   ├── config/        # 配置管理
│   │   ├── database/      # 数据库操作
│   │   ├── logger/        # 日志系统
│   │   ├── middleware/    # 中间件
│   │   ├── models/        # 数据模型
│   │   └── services/      # 业务服务
│   ├── config/            # 配置文件
│   ├── logs/              # 日志文件
│   ├── main.go            # 应用入口
│   ├── router.go          # 路由配置
│   ├── Dockerfile         # Docker配置
│   ├── Makefile           # 构建脚本
│   └── start.sh           # 启动脚本
├── docs/                   # 项目文档
│   ├── API接口文档.md
│   ├── 需求文档.md
│   ├── 技术架构文档.md
│   └── database_schema.sql
├── docker-compose.yml      # Docker Compose配置
├── DEPLOYMENT.md           # 部署指南
└── README.md              # 项目说明
```

## 🚀 快速开始

### 环境要求

- Go 1.19+
- MySQL 8.0+
- Redis 7.0+
- Docker & Docker Compose (可选)
- Flutter 3.0+ (前端开发)

### 使用Docker Compose（推荐）

1. **克隆项目**
```bash
git clone <repository-url>
cd ai_english_learning
```

2. **启动所有服务**
```bash
docker-compose up -d
```

3. **查看服务状态**
```bash
docker-compose ps
```

4. **访问应用**
- 后端API：http://localhost:8080
- 健康检查：http://localhost:8080/health
- API文档：查看 `docs/API接口文档.md`

### 本地开发

#### 后端开发

1. **进入后端目录**
```bash
cd serve
```

2. **安装依赖**
```bash
go mod tidy
```

3. **配置数据库**
```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE ai_english_learning CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 导入数据库结构
mysql -u root -p ai_english_learning < ../docs/database_schema.sql
```

4. **配置应用**
```bash
# 复制配置文件
cp config/config.yaml config/config.local.yaml

# 编辑配置文件，修改数据库连接等信息
vim config/config.local.yaml
```

5. **启动应用**
```bash
# 使用启动脚本（推荐）
./start.sh -d

# 或者直接运行
go run .

# 或者使用Makefile
make dev
```

#### 前端开发

1. **进入前端目录**
```bash
cd client
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
flutter run
```

## 📖 API文档

详细的API文档请查看：[API接口文档.md](docs/API接口文档.md)

### 主要API端点

- **认证相关**
  - `POST /api/auth/register` - 用户注册
  - `POST /api/auth/login` - 用户登录
  - `POST /api/auth/refresh` - 刷新Token

- **用户管理**
  - `GET /api/users/profile` - 获取用户信息
  - `PUT /api/users/profile` - 更新用户信息
  - `GET /api/users/stats` - 获取学习统计

- **词汇学习**
  - `GET /api/vocabulary/words` - 获取单词列表
  - `POST /api/vocabulary/learn` - 学习单词
  - `GET /api/vocabulary/review` - 获取复习单词

- **健康检查**
  - `GET /health` - 综合健康检查
  - `GET /health/liveness` - 存活检查
  - `GET /health/readiness` - 就绪检查
  - `GET /version` - 版本信息

## 🔧 配置说明

### 环境变量

```bash
# 服务器配置
SERVER_PORT=8080
SERVER_MODE=release

# 数据库配置
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_USER=ai_english
DATABASE_PASSWORD=your_password
DATABASE_NAME=ai_english_learning

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT配置
JWT_SECRET=your-super-secret-jwt-key
JWT_ACCESS_TOKEN_TTL=3600
JWT_REFRESH_TOKEN_TTL=604800

# 应用配置
APP_ENVIRONMENT=production
LOG_LEVEL=info
```

### 配置文件

配置文件位于 `serve/config/config.yaml`，支持多环境配置。

## 🧪 测试

### 运行测试

```bash
# 后端测试
cd serve
make test

# 前端测试
cd client
flutter test
```

### 性能测试

```bash
cd serve
make bench
```

## 📦 部署

详细的部署指南请查看：[DEPLOYMENT.md](DEPLOYMENT.md)

### 生产环境部署

1. **构建Docker镜像**
```bash
make docker-build
```

2. **部署到生产环境**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

3. **配置反向代理**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🔍 监控和维护

### 日志查看

```bash
# 查看应用日志
tail -f serve/logs/app.log

# Docker环境日志
docker-compose logs -f ai-english-backend
```

### 健康检查

```bash
# 检查服务状态
curl http://localhost:8080/health

# 检查版本信息
curl http://localhost:8080/version
```

### 数据库备份

```bash
# 备份数据库
mysqldump -u root -p ai_english_learning > backup_$(date +%Y%m%d_%H%M%S).sql

# 使用Makefile
make backup
```

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

### 代码规范

- **Go代码**：遵循 `gofmt` 和 `golint` 规范
- **Flutter代码**：遵循 Dart 官方代码规范
- **提交信息**：使用语义化提交信息

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系我们

- **项目维护者**：[Your Name]
- **邮箱**：[your.email@example.com]
- **问题反馈**：[GitHub Issues](https://github.com/your-username/ai-english-learning/issues)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和用户。

---

**注意**：这是一个学习项目，仅供教育和研究目的使用。

## 核心特色

### 🤖 AI驱动的个性化学习
- 基于用户学习数据的智能推荐系统
- 自适应学习路径规划
- 个性化学习内容匹配
- 智能学习进度调整

### 📚 全技能覆盖
- **词汇学习**：科学记忆算法，多维度词汇训练
- **听力训练**：分级听力材料，智能语音识别
- **阅读理解**：多样化文章，智能阅读辅助
- **写作练习**：AI智能批改，实时反馈改进
- **口语练习**：AI对话伙伴，发音智能评估

### 🎯 考试导向支持
- 四六级英语考试专项训练
- 托福、雅思考试备考模块
- 考研英语专业辅导
- 商务英语实用技能

### 📊 数据驱动的学习分析
- 详细的学习数据统计
- 多维度能力分析报告
- 学习进度可视化展示
- 个性化改进建议

## 主要功能模块

### 1. 个人主页
- 学习数据概览（已学单词数、连续打卡天数、平均得分）
- 学习进度可视化（词库进度、技能雷达图）
- 今日学习推荐
- 个人信息管理

### 2. 单词学习模块
- **分级词库**：从小学到专业级别的完整词汇体系
- **智能记忆**：基于艾宾浩斯记忆曲线的复习算法
- **多模式学习**：卡片背诵、测试练习、语境学习
- **AI助手**：智能例句生成、词汇关联、记忆技巧

### 3. 听力训练模块
- **分级内容**：从日常对话到学术讲座的全覆盖
- **智能播放**：语速调节、重复播放、字幕控制
- **多样练习**：理解练习、听写练习、跟读练习
- **能力分析**：语音识别、语义理解、语速适应能力评估

### 4. 阅读理解模块
- **双模式阅读**：休闲阅读和练习阅读
- **智能辅助**：即点即译、段落摘要、结构分析
- **多样题型**：主旨大意、细节理解、推理判断
- **技能训练**：快速阅读、精读、扫读、略读

### 5. 写作练习模块
- **多种模式**：中译英练习、话题写作
- **考试专项**：四六级、考研、托福、雅思写作
- **AI智能批改**：语法检查、词汇评估、表达流畅度分析
- **写作辅助**：模板库、素材库、例句参考

### 6. 口语练习模块
- **AI对话伙伴**：商务、日常、旅行、学术等专业导师
- **场景训练**：生活、职场、学术等真实场景对话
- **智能评估**：发音准确度、流利度、语法正确性
- **个性化训练**：能力诊断、适应性训练

### 7. AI智能助手
- **个性化推荐**：学习内容和路径智能推荐
- **智能答疑**：语言问题解答、学习方法指导
- **学习分析**：行为分析、能力诊断
- **多模态交互**：文本、语音、视觉交互支持

## 技术架构

### 前端技术
- **Flutter**：跨平台移动应用开发
- 支持iOS、Android、Web、桌面多平台
- 响应式设计，优秀的用户体验

### 后端技术
- **Go Gin**：高性能API服务
- **微服务架构**：模块化、可扩展的系统设计
- **MySQL 8.0**：可靠的关系型数据库

### AI技术栈
- **Hugging Face Transformers**：自然语言处理
- **PyTorch**：深度学习框架
- **spaCy**：高级自然语言处理
- **语音识别与合成**：智能语音处理

### 部署与运维
- **Docker + Docker Compose**：容器化部署
- **GitHub Actions/Codemagic**：CI/CD自动化
- **Celery + RabbitMQ/Redis**：异步任务处理

## 项目结构

```
ai_english_learning/
├── docs/                          # 项目文档
│   ├── UI界面设计/                 # UI设计文件
│   ├── 详细需求文档.md             # 功能需求文档
│   └── 技术选型.md                 # 技术架构文档
├── frontend/                      # 前端代码（Flutter）
├── backend/                       # 后端代码
│   ├── api/                      # API服务
│   ├── ai_services/              # AI处理服务
│   └── database/                 # 数据库相关
├── deployment/                    # 部署配置
├── tests/                        # 测试代码
└── README.md                     # 项目说明文档
```

## 快速开始

### 环境要求
- Flutter SDK 3.0+
- Go 1.19+
- MySQL 8.0+
- Docker & Docker Compose
- Node.js 16+ (用于部分工具)

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/your-org/ai_english_learning.git
cd ai_english_learning
```

2. **后端环境设置**
```bash
cd backend
# 初始化Go模块
go mod init ai_english_learning
go mod tidy
```

3. **数据库设置**
```bash
# 启动MySQL数据库
docker-compose up -d mysql

# 运行数据库迁移
go run cmd/migrate/main.go
```

4. **前端环境设置**
```bash
cd frontend
flutter pub get
flutter run
```

5. **启动开发服务器**
```bash
# 后端API服务
cd backend
go run main.go

# AI服务
celery -A ai_services worker --loglevel=info
```

## 开发指南

### 代码规范
- 遵循Go官方代码规范（gofmt, golint）
- 使用Flutter官方代码规范
- 提交前运行代码格式化和静态检查

### 测试
```bash
# 后端测试
go test ./...

# 前端测试
flutter test
```

### 部署
```bash
# 使用Docker Compose部署
docker-compose up -d

# 生产环境部署
docker-compose -f docker-compose.prod.yml up -d
```

## 学习目标用户

### 学生群体
- **小学生**：基础词汇学习，简单对话练习
- **中学生**：考试备考，技能全面提升
- **大学生**：四六级备考，学术英语提升
- **研究生**：考研英语，学术写作训练

### 成人学习者
- **职场人士**：商务英语，职业发展需求
- **出国留学**：托福雅思备考，留学准备
- **兴趣学习**：日常英语，文化交流
- **专业提升**：行业英语，专业技能

## 学习效果

### 短期效果（1-3个月）
- 词汇量显著增加（500-1500词）
- 听力理解能力明显提升
- 基础语法掌握更加牢固
- 口语表达更加自信

### 中期效果（3-6个月）
- 阅读速度和理解能力大幅提升
- 写作表达更加地道和流畅
- 口语交流基本无障碍
- 考试成绩显著提高

### 长期效果（6个月以上）
- 英语思维逐步建立
- 能够进行复杂的英语交流
- 具备独立的英语学习能力
- 达到目标英语水平

## 贡献指南

我们欢迎社区贡献！请遵循以下步骤：

1. Fork 项目仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 贡献类型
- 🐛 Bug修复
- ✨ 新功能开发
- 📚 文档改进
- 🎨 UI/UX优化
- ⚡ 性能优化
- 🧪 测试覆盖

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系我们

- **项目主页**：https://github.com/your-org/ai_english_learning
- **问题反馈**：https://github.com/your-org/ai_english_learning/issues
- **邮箱联系**：contact@ai-english-learning.com
- **官方网站**：https://www.ai-english-learning.com

## 更新日志

### v1.0.0 (2024-01-01)
- 🎉 项目初始版本发布
- ✨ 完整的词汇学习模块
- ✨ 基础的听说读写功能
- ✨ AI智能助手集成
- ✨ 用户数据统计分析

### 即将发布
- 🔄 更多AI功能集成
- 📱 移动端应用优化
- 🌐 多语言界面支持
- 🎮 游戏化学习元素
- 👥 社交学习功能

---

**让AI助力您的英语学习之旅！** 🚀

通过科学的学习方法和先进的AI技术，我们相信每个人都能够高效地掌握英语，实现自己的学习目标。立即开始您的智能英语学习体验吧！