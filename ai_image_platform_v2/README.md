# AI图像处理平台 v2.0

一个基于现代Web技术栈构建的AI图像处理平台，提供专业的图像美化、滤镜、颜色调整等功能。

## 🚀 项目特色

- **前后端分离架构**: 前端使用现代Web技术，后端采用Flask + SQLAlchemy ORM
- **专业图像处理**: 集成多种AI算法，提供美颜、滤镜、修复等功能
- **用户友好界面**: 响应式设计，支持拖拽上传，实时预览
- **RESTful API**: 标准化API设计，易于扩展和集成
- **模块化架构**: MVC模式，代码结构清晰，便于维护

## 📁 项目结构

```
ai_image_platform_v2/
├── frontend/              # 前端应用
│   ├── public/           # 静态资源
│   ├── src/              # 源代码
│   │   ├── api/          # API接口
│   │   ├── assets/       # 资源文件
│   │   │   ├── css/      # 样式文件
│   │   │   └── js/       # JavaScript文件
│   │   ├── components/   # 组件
│   │   ├── pages/        # 页面
│   │   └── utils/        # 工具函数
│   ├── dist/             # 构建输出
│   ├── package.json      # 前端依赖
│   ├── webpack.config.js # 构建配置
│   └── README.md         # 前端说明
├── backend/              # 后端应用
│   ├── app/              # Flask应用
│   ├── models/           # 数据模型
│   ├── controllers/      # 控制器
│   ├── services/         # 业务逻辑
│   ├── utils/            # 工具函数
│   ├── config/           # 配置文件
│   ├── migrations/       # 数据库迁移
│   ├── static/           # 静态文件
│   ├── requirements.txt  # 后端依赖
│   ├── run.py           # 应用入口
│   └── README.md        # 后端说明
├── docs/                # 项目文档
├── docker-compose.yml   # Docker编排
└── README.md           # 项目总览
```

## 🛠️ 技术栈

### 前端技术
- **HTML5/CSS3**: 现代Web标准
- **JavaScript (ES6+)**: 核心逻辑
- **jQuery**: DOM操作和AJAX
- **Webpack**: 模块打包
- **PostCSS**: CSS后处理
- **Babel**: JavaScript转译

### 后端技术
- **Python 3.8+**: 编程语言
- **Flask**: Web框架
- **SQLAlchemy**: ORM数据库操作
- **PyJWT**: JWT认证
- **Pillow**: 图像处理
- **OpenCV**: 计算机视觉
- **通义千问大模型**: AI图像分析和智能处理
- **DashScope**: 阿里云大模型API客户端
- **Gunicorn**: WSGI服务器

### 数据库
- **SQLite**: 开发环境
- **PostgreSQL**: 生产环境
- **Redis**: 缓存和会话存储

## ⚡ 快速开始

### 环境要求

- **Node.js** >= 14.0.0
- **Python** >= 3.8
- **npm** >= 6.0.0
- **pip** >= 20.0

### 1. 克隆项目

```bash
git clone https://github.com/your-username/ai-image-platform-v2.git
cd ai-image-platform-v2
```

### 2. 后端设置

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

# 初始化数据库
python run.py --init-db

# 启动后端服务
python run.py
```

后端服务将在 http://localhost:5000 启动

### 3. 前端设置

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

前端应用将在 http://localhost:3000 启动

### 4. 配置AI功能（可选）

如需使用AI智能功能，请配置通义千问大模型：

```bash
# 复制环境变量配置文件
cp .env.example .env

# 编辑.env文件，添加你的通义千问API密钥
# QWEN_API_KEY=your_api_key_here
```

详细配置说明请参考：[AI集成文档](backend/docs/AI_INTEGRATION.md)

### 5. 访问应用

打开浏览器访问 http://localhost:3000，开始使用AI图像处理平台！

## 🎨 功能特性

### 图像处理工具

#### 🌟 美颜功能
- **磨皮**: 智能肌肤平滑，保留自然纹理
- **美白**: 肤色提亮，自然美白效果
- **眼部增强**: 眼部亮化，增强神采
- **唇部增强**: 唇色调整，增加饱和度

#### 🎭 滤镜效果
- **复古滤镜**: 怀旧色调，复古质感
- **黑白滤镜**: 经典黑白，艺术表现
- **棕褐滤镜**: 温暖色调，怀旧氛围
- **冷色滤镜**: 冷色调，现代感
- **暖色滤镜**: 暖色调，温馨感

#### 🎨 颜色调整
- **亮度调整**: 图像明暗控制
- **对比度调整**: 明暗对比增强
- **饱和度调整**: 色彩鲜艳度控制
- **色相调整**: 色彩偏移调整

#### 🌄 背景处理
- **背景虚化**: 智能背景模糊
- **边缘羽化**: 自然过渡效果

#### 🔧 智能修复
- **噪点去除**: AI降噪算法
- **划痕修复**: 智能瑕疵修复

#### 🤖 AI智能功能
- **图像内容分析**: 基于通义千问大模型的智能图像识别
- **美颜建议**: AI分析面部特征，提供个性化美颜建议
- **风格推荐**: 智能分析图像风格，推荐最适合的滤镜效果
- **构图优化**: AI分析图像构图，提供专业的优化建议
- **智能增强**: 基于图像内容的自动化处理建议

### 用户体验

#### 📱 响应式设计
- 适配桌面、平板、手机
- 流畅的触摸交互
- 优化的移动端体验

#### 🖱️ 交互功能
- 拖拽文件上传
- 实时参数调整
- 图像缩放和平移
- 键盘快捷键支持

#### 👤 用户系统
- 用户注册和登录
- 个人资料管理
- 图片历史记录
- 处理记录追踪

## 🏗️ 架构设计

### 前后端分离

```
┌─────────────────┐    HTTP/AJAX    ┌─────────────────┐
│                 │ ──────────────► │                 │
│   前端应用       │                 │   后端API       │
│  (JavaScript)   │ ◄────────────── │   (Flask)       │
│                 │    JSON数据     │                 │
└─────────────────┘                 └─────────────────┘
         │                                   │
         ▼                                   ▼
┌─────────────────┐                 ┌─────────────────┐
│   静态资源       │                 │   数据库         │
│  (HTML/CSS/JS)  │                 │ (SQLite/PgSQL)  │
└─────────────────┘                 └─────────────────┘
```

### MVC架构模式

```
┌─────────────────┐
│     View        │  ← 前端界面
│   (Frontend)    │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Controller    │  ← 路由控制
│  (Flask Routes) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│     Model       │  ← 数据模型
│  (SQLAlchemy)   │
└─────────────────┘
```

## 🔧 开发指南

### 添加新功能

1. **后端API开发**:
   ```bash
   # 1. 在models/中定义数据模型
   # 2. 在controllers/中添加路由处理
   # 3. 在services/中实现业务逻辑
   # 4. 更新API文档
   ```

2. **前端功能开发**:
   ```bash
   # 1. 在src/assets/js/中添加功能逻辑
   # 2. 在src/assets/css/中添加样式
   # 3. 在src/api/中添加API调用
   # 4. 更新用户界面
   ```

### 代码规范

```bash
# 前端代码检查
cd frontend
npm run lint
npm run format

# 后端代码检查
cd backend
flake8 .
black .
```

### 测试

```bash
# 前端测试
cd frontend
npm test

# 后端测试
cd backend
python -m pytest
```

## 🚀 部署指南

### Docker部署

```bash
# 构建和启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 生产环境部署

1. **前端部署**:
   ```bash
   cd frontend
   npm run build
   # 将dist/目录部署到Web服务器
   ```

2. **后端部署**:
   ```bash
   cd backend
   gunicorn -w 4 -b 0.0.0.0:5000 run:app
   ```

3. **Nginx配置**:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       # 前端静态文件
       location / {
           root /var/www/frontend/dist;
           try_files $uri $uri/ /index.html;
       }
       
       # 后端API代理
       location /api {
           proxy_pass http://localhost:5000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

## 📊 性能优化

### 前端优化
- 代码分割和懒加载
- 图片压缩和WebP格式
- CDN加速
- 浏览器缓存策略

### 后端优化
- 数据库索引优化
- Redis缓存
- 异步任务处理
- 负载均衡

## 🔒 安全考虑

- JWT认证机制
- CORS跨域配置
- 文件上传安全
- SQL注入防护
- XSS攻击防护
- HTTPS强制使用

## 📈 监控和日志

- 应用性能监控
- 错误日志收集
- 用户行为分析
- 系统资源监控

## 🤝 贡献指南

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 📝 更新日志

### v2.0.0 (2024-01-XX)
- 🎉 全新的前后端分离架构
- 🏗️ 采用MVC设计模式
- 🎨 现代化的用户界面
- 🔧 完善的ORM数据模型
- 📱 响应式设计支持
- 🚀 性能优化和代码重构

### v1.0.0 (2023-XX-XX)
- 🎯 基础图像处理功能
- 👤 用户认证系统
- 📁 文件上传管理
- 🎭 基础滤镜效果

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- **项目地址**: https://github.com/your-username/ai-image-platform-v2
- **问题反馈**: https://github.com/your-username/ai-image-platform-v2/issues
- **邮箱**: your-email@example.com
- **官网**: https://your-website.com

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和用户！

---

⭐ 如果这个项目对你有帮助，请给我们一个星标！