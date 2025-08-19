# AI英语学习平台后端服务

## 项目简介

这是一个基于Spring Boot的AI英语学习平台后端服务，提供完整的英语学习功能，包括词汇学习、阅读理解、AI辅助学习、社交功能等。

## 技术栈

- **框架**: Spring Boot 3.2.0
- **数据库**: MySQL 8.0
- **ORM**: Spring Data JPA
- **安全**: Spring Security + JWT
- **文档**: Swagger/OpenAPI 3
- **构建工具**: Maven
- **Java版本**: 17

## 项目结构

```
src/
├── main/
│   ├── java/com/nanqipro/
│   │   ├── config/          # 配置类
│   │   ├── controller/      # REST控制器
│   │   ├── dto/            # 数据传输对象
│   │   ├── entity/         # JPA实体类
│   │   ├── exception/      # 异常处理
│   │   ├── repository/     # 数据访问层
│   │   ├── service/        # 业务逻辑层
│   │   └── util/           # 工具类
│   └── resources/
│       ├── application.properties
│       └── application-dev.properties
└── test/                   # 单元测试
```

## 核心功能模块

### 1. 用户管理模块
- 用户注册、登录、注销
- JWT令牌认证
- 用户信息管理
- 密码重置

### 2. 词汇学习模块
- 词汇CRUD操作
- 按难度级别分类
- 词汇搜索和筛选
- 学习进度跟踪
- 复习算法

### 3. 阅读理解模块
- 文章管理
- 阅读进度跟踪
- 题目系统
- 难度分级

### 4. 学习记录模块
- 学习历史记录
- 统计分析
- 学习会话管理

### 5. AI功能模块
- 个性化推荐
- AI问答助手
- 语音评估
- 智能学习路径

### 6. 社交功能模块
- 挑战赛系统
- 打卡功能
- 学习排行榜

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.6+
- MySQL 8.0+

### 安装步骤

1. 克隆项目
```bash
git clone <repository-url>
cd ai_english_learning/service
```

2. 配置数据库
```sql
CREATE DATABASE ai_english_learning;
```

3. 修改配置文件
```properties
# application-dev.properties
spring.datasource.url=jdbc:mysql://localhost:3306/ai_english_learning
spring.datasource.username=your_username
spring.datasource.password=your_password
```

4. 运行项目
```bash
mvn spring-boot:run
```

5. 访问API文档
```
http://localhost:8080/swagger-ui.html
```

## API文档

### 认证相关

#### 用户注册
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}
```

#### 用户登录
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "password123"
}
```

### 词汇管理

#### 获取词汇列表
```
GET /api/vocabularies?page=0&size=10&level=BEGINNER
Authorization: Bearer <jwt_token>
```

#### 添加词汇
```
POST /api/vocabularies
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "word": "example",
  "phoneticUs": "/ɪɡˈzæmpəl/",
  "phoneticUk": "/ɪɡˈzɑːmpəl/",
  "wordType": "NOUN",
  "difficultyLevel": "BEGINNER"
}
```

### 文章管理

#### 获取文章列表
```
GET /api/articles?page=0&size=10&level=INTERMEDIATE
Authorization: Bearer <jwt_token>
```

#### 获取文章详情
```
GET /api/articles/{id}
Authorization: Bearer <jwt_token>
```

## 数据库设计

### 核心表结构

- `users` - 用户信息
- `vocabularies` - 词汇数据
- `articles` - 文章内容
- `learning_sessions` - 学习会话
- `challenges` - 挑战赛
- `check_ins` - 打卡记录

## 部署说明

### Docker部署

1. 构建镜像
```bash
docker build -t ai-english-learning .
```

2. 运行容器
```bash
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host:3306/ai_english_learning \
  -e SPRING_DATASOURCE_USERNAME=username \
  -e SPRING_DATASOURCE_PASSWORD=password \
  ai-english-learning
```

### 生产环境配置

1. 配置生产环境数据库
2. 设置JWT密钥
3. 配置日志级别
4. 启用HTTPS
5. 配置跨域策略

## 开发指南

### 代码规范

- 遵循Java编码规范
- 使用驼峰命名法
- 添加适当的注释
- 编写单元测试

### 测试

```bash
# 运行所有测试
mvn test

# 运行特定测试类
mvn test -Dtest=UserServiceTest
```

### 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 许可证

MIT License

## 联系方式

如有问题，请联系开发团队。