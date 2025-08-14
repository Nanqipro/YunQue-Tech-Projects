# AI图像处理平台 - 后端

这是AI图像处理平台的后端部分，使用Flask框架和SQLAlchemy ORM构建的RESTful API服务。

## 技术栈

- **Flask** - Web框架
- **SQLAlchemy** - ORM数据库操作
- **Flask-CORS** - 跨域资源共享
- **PyJWT** - JWT认证
- **Pillow** - 图像处理
- **OpenCV** - 计算机视觉
- **Gunicorn** - WSGI服务器
- **SQLite/PostgreSQL** - 数据库

## 项目结构

```
backend/
├── app/                   # 应用核心
│   ├── __init__.py       # Flask应用初始化
│   └── routes.py         # 路由配置（预留）
├── models/               # 数据模型
│   ├── __init__.py       # 模型导入
│   ├── user.py          # 用户模型
│   ├── image.py         # 图片模型
│   └── processing_record.py # 处理记录模型
├── controllers/          # 控制器
│   ├── user_controller.py    # 用户控制器
│   ├── image_controller.py   # 图片控制器
│   └── processing_controller.py # 处理控制器
├── services/            # 业务逻辑
│   └── image_processing_service.py # 图像处理服务
├── utils/               # 工具函数
│   ├── auth.py          # 认证工具
│   └── image_utils.py   # 图像工具
├── config/              # 配置文件
│   └── config.py        # 应用配置
├── migrations/          # 数据库迁移
├── static/              # 静态文件
│   └── uploads/         # 上传文件
├── requirements.txt     # 依赖包
├── run.py              # 应用入口
└── README.md           # 项目说明
```

## 功能特性

### 🔐 用户管理
- **用户注册**: 邮箱验证、密码加密
- **用户登录**: JWT认证、会话管理
- **个人资料**: 信息更新、头像上传
- **权限控制**: 基于角色的访问控制

### 🖼️ 图片管理
- **图片上传**: 多格式支持、大小限制
- **图片存储**: 本地存储、云存储支持
- **图片信息**: 元数据提取、缩略图生成
- **图片分类**: 标签管理、分类检索

### 🎨 图像处理
- **美颜算法**: 磨皮、美白、五官增强
- **滤镜效果**: 多种艺术滤镜
- **颜色调整**: HSV、RGB调整
- **背景处理**: 虚化、替换
- **智能修复**: AI驱动的图像修复

### 📊 数据统计
- **处理记录**: 操作历史、参数记录
- **用户统计**: 使用情况、偏好分析
- **性能监控**: 处理时间、成功率

## 快速开始

### 环境要求

- Python >= 3.8
- pip >= 20.0
- SQLite (开发) / PostgreSQL (生产)

### 安装依赖

```bash
cd backend

# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

### 配置环境

创建 `.env` 文件：

```bash
# 数据库配置
DATABASE_URL=sqlite:///app.db
# DATABASE_URL=postgresql://user:password@localhost/dbname

# JWT密钥
JWT_SECRET_KEY=your-secret-key-here

# 文件上传
UPLOAD_FOLDER=static/uploads
MAX_CONTENT_LENGTH=16777216  # 16MB

# Redis配置（可选）
REDIS_URL=redis://localhost:6379/0

# 邮件配置（可选）
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

### 初始化数据库

```bash
# 运行应用（自动创建数据库）
python run.py --init-db
```

### 启动服务

```bash
# 开发模式
python run.py

# 生产模式
gunicorn -w 4 -b 0.0.0.0:5000 run:app
```

访问 http://localhost:5000

## API文档

### 用户相关

#### 用户注册
```http
POST /api/users/register
Content-Type: application/json

{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
}
```

#### 用户登录
```http
POST /api/users/login
Content-Type: application/json

{
    "username": "testuser",
    "password": "password123"
}
```

#### 获取用户信息
```http
GET /api/users/profile
Authorization: Bearer <token>
```

### 图片相关

#### 上传图片
```http
POST /api/images/upload
Content-Type: multipart/form-data
Authorization: Bearer <token>

image: <file>
title: "My Image"
description: "Image description"
tags: "tag1,tag2"
```

#### 获取图片列表
```http
GET /api/images?page=1&per_page=10&tag=beauty
Authorization: Bearer <token>
```

#### 获取图片详情
```http
GET /api/images/{image_id}
Authorization: Bearer <token>
```

### 图像处理

#### 美颜处理
```http
POST /api/processing/beauty
Content-Type: application/json
Authorization: Bearer <token>

{
    "image_id": 1,
    "tool_name": "smooth",
    "smoothIntensity": 50,
    "detailPreservation": 30
}
```

#### 滤镜处理
```http
POST /api/processing/filter
Content-Type: application/json
Authorization: Bearer <token>

{
    "image_id": 1,
    "filter_type": "vintage",
    "filterIntensity": 80
}
```

#### 颜色调整
```http
POST /api/processing/color
Content-Type: application/json
Authorization: Bearer <token>

{
    "image_id": 1,
    "brightness": 10,
    "contrast": 5,
    "saturation": -10,
    "hue": 0
}
```

## 数据库设计

### 用户表 (users)
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    avatar_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 图片表 (images)
```sql
CREATE TABLE images (
    id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    file_path VARCHAR(500) NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    width INTEGER,
    height INTEGER,
    title VARCHAR(200),
    description TEXT,
    tags VARCHAR(500),
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 处理记录表 (processing_records)
```sql
CREATE TABLE processing_records (
    id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    image_id INTEGER REFERENCES images(id),
    tool_type VARCHAR(50) NOT NULL,
    tool_name VARCHAR(50) NOT NULL,
    parameters TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    result_path VARCHAR(500),
    error_message TEXT,
    processing_time FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);
```

## 开发指南

### 添加新的图像处理功能

1. **在 `services/image_processing_service.py` 中添加处理方法**:
```python
def apply_new_effect(self, image_path, **params):
    """应用新效果"""
    # 实现处理逻辑
    pass
```

2. **在 `controllers/processing_controller.py` 中添加路由**:
```python
@processing_bp.route('/new-effect', methods=['POST'])
@token_required
def apply_new_effect():
    # 处理请求逻辑
    pass
```

3. **更新API文档和测试**

### 数据库迁移

```bash
# 生成迁移文件
flask db migrate -m "Add new table"

# 应用迁移
flask db upgrade

# 回滚迁移
flask db downgrade
```

### 测试

```bash
# 运行单元测试
python -m pytest tests/

# 运行特定测试
python -m pytest tests/test_user_controller.py

# 生成覆盖率报告
python -m pytest --cov=app tests/
```

## 部署

### Docker部署

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 安装Python依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建上传目录
RUN mkdir -p static/uploads

EXPOSE 5000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "run:app"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  backend:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/aiplatform
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./static/uploads:/app/static/uploads

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=aiplatform
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

### 生产环境配置

```python
# config/production.py
class ProductionConfig:
    DEBUG = False
    TESTING = False
    DATABASE_URL = os.environ.get('DATABASE_URL')
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY')
    
    # 安全配置
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    
    # 文件上传
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    UPLOAD_FOLDER = '/app/uploads'
    
    # 日志配置
    LOG_LEVEL = 'INFO'
    LOG_FILE = '/app/logs/app.log'
```

## 性能优化

### 数据库优化
- 添加适当的索引
- 使用连接池
- 查询优化
- 读写分离

### 缓存策略
- Redis缓存热点数据
- 图片处理结果缓存
- API响应缓存

### 异步处理
- Celery任务队列
- 图像处理异步化
- 邮件发送异步化

## 监控和日志

### 日志配置
```python
import logging
from logging.handlers import RotatingFileHandler

# 配置日志
if not app.debug:
    file_handler = RotatingFileHandler(
        'logs/app.log', maxBytes=10240, backupCount=10
    )
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
```

### 健康检查
```python
@app.route('/health')
def health_check():
    return {'status': 'healthy', 'timestamp': datetime.utcnow()}
```

## 安全考虑

### 认证和授权
- JWT token过期机制
- 刷新token机制
- 基于角色的权限控制

### 输入验证
- 文件类型验证
- 文件大小限制
- SQL注入防护
- XSS防护

### 数据保护
- 密码加密存储
- 敏感数据加密
- HTTPS强制使用

## 故障排除

### 常见问题

1. **数据库连接失败**
   - 检查数据库服务状态
   - 验证连接字符串
   - 检查防火墙设置

2. **图像处理失败**
   - 检查OpenCV安装
   - 验证图片格式支持
   - 检查内存使用情况

3. **文件上传失败**
   - 检查上传目录权限
   - 验证文件大小限制
   - 检查磁盘空间

### 调试工具

- Flask调试模式
- Python调试器(pdb)
- 日志分析
- 性能分析工具

## 贡献指南

1. Fork项目
2. 创建功能分支
3. 编写测试
4. 提交更改
5. 创建Pull Request

## 许可证

MIT License

## 联系方式

- 项目地址: https://github.com/your-username/ai-image-platform
- 问题反馈: https://github.com/your-username/ai-image-platform/issues
- 邮箱: your-email@example.com