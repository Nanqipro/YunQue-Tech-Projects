# AI图像处理平台 v2.0 - 生产环境上线部署文档

## 📋 项目概述

AI图像处理平台是一个基于现代Web技术栈构建的专业图像处理系统，提供AI美颜、滤镜效果、颜色调整、背景处理、智能修复、证件照生成等功能。

### 🎯 核心功能
- **AI智能美颜**: 磨皮、美白、眼部增强、唇部调整
- **滤镜效果**: 复古、黑白、棕褐、冷色调、暖色调
- **颜色调整**: 亮度、对比度、饱和度、色温调节
- **背景处理**: 背景虚化、智能抠图
- **智能修复**: 瑕疵修复、图像增强
- **证件照生成**: 标准证件照制作

### 🏗️ 技术架构
- **前端**: HTML5/CSS3 + JavaScript + jQuery + Webpack
- **后端**: Python Flask + SQLAlchemy + OpenCV + Pillow
- **AI服务**: 通义千问大模型 + DashScope API
- **数据库**: SQLite (开发) / PostgreSQL (生产)
- **缓存**: Redis (可选)
- **部署**: Nginx + Gunicorn + Systemd

## 🚀 快速上线部署

### 方案一：一键部署脚本（推荐）

```bash
# 1. 上传项目到服务器
scp -r ai_image_platform_v2 root@your-server:/home/work/

# 2. 登录服务器
ssh root@your-server

# 3. 进入项目目录
cd /home/work/ai_image_platform_v2

# 4. 执行一键部署
chmod +x deploy-server.sh
./deploy-server.sh start
```

### 方案二：手动部署

#### 1. 环境准备
```bash
# 更新系统
apt update && apt upgrade -y

# 安装基础依赖
apt install -y python3 python3-pip python3-venv nginx curl git

# 安装Node.js (用于前端构建)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install -y nodejs
```

#### 2. 项目部署
```bash
# 进入项目目录
cd /home/work/ai_image_platform_v2

# 创建虚拟环境
cd backend
python3 -m venv venv
source venv/bin/activate

# 安装Python依赖
pip install --upgrade pip
pip install -r requirements.txt

# 构建前端
cd ../frontend
npm install
npm run build
cd ..
```

#### 3. 配置Nginx
```bash
# 创建Nginx配置
sudo tee /etc/nginx/sites-available/ai_image_platform << 'EOF'
server {
    listen 80;
    server_name _;
    
    # 前端静态文件
    root /home/work/ai_image_platform_v2/frontend/dist;
    index index.html index.htm;
    
    # 日志配置
    access_log /var/log/nginx/ai_image_access.log;
    error_log /var/log/nginx/ai_image_error.log;
    
    # 上传文件大小限制
    client_max_body_size 100M;
    
    # 静态文件缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # HTML文件不缓存
    location ~* \.html$ {
        expires -1;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
    }
    
    # API代理到后端
    location /api/ {
        proxy_pass http://127.0.0.1:5002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # 处理大文件上传
        proxy_request_buffering off;
        proxy_buffering off;
        
        # 添加CORS头
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
        add_header Access-Control-Allow-Credentials "true" always;
        
        # 处理预检请求
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
            add_header Access-Control-Allow-Credentials "true" always;
            add_header Content-Type "text/plain charset=UTF-8";
            add_header Content-Length 0;
            return 204;
        }
    }
    
    # 静态文件服务（图片等）
    location /static/ {
        alias /home/work/picture_project/ai_image_platform_v2/backend/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # 主页面路由（支持SPA）
    location / {
        try_files $uri $uri/ /index.html;
        expires -1;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
    }
    
    # 错误页面
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF

# 启用配置
sudo ln -sf /etc/nginx/sites-available/ai_image_platform /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 测试并重启Nginx
sudo nginx -t && sudo systemctl restart nginx
```

#### 4. 创建后端服务
```bash
# 创建systemd服务文件
sudo tee /etc/systemd/system/ai_image_backend.service << 'EOF'
[Unit]
Description=AI Image Platform Backend
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/home/work/picture_project/ai_image_platform_v2/backend
Environment=PATH=/home/work/picture_project/ai_image_platform_v2/backend/venv/bin
Environment=FLASK_PORT=5002
ExecStart=/home/work/picture_project/ai_image_platform_v2/backend/venv/bin/python3 run.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
sudo systemctl daemon-reload
sudo systemctl enable ai_image_backend
sudo systemctl start ai_image_backend
```

#### 5. 配置防火墙
```bash
# 开放80端口
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

## 🔧 环境配置

### 1. 环境变量配置
```bash
# 创建.env文件
cat > .env << 'EOF'
# 数据库配置
DATABASE_URL=sqlite:///backend/instance/app.db
SECRET_KEY=your-super-secret-key-change-in-production

# 服务端口
BACKEND_PORT=5002
FRONTEND_PORT=80

# AI服务配置（需要申请通义千问API密钥）
QWEN_API_KEY=your-qwen-api-key
QWEN_VL_API_KEY=your-qwen-vl-api-key

# 文件上传配置
MAX_CONTENT_LENGTH=104857600
UPLOAD_FOLDER=backend/static/uploads

# 日志配置
LOG_LEVEL=INFO

# 环境配置
FLASK_ENV=production
FLASK_DEBUG=False
EOF
```

### 2. 数据库初始化
```bash
cd backend
source venv/bin/activate
python3 run.py --init-db
```

## 📊 系统要求

### 最低配置
- **CPU**: 2核心
- **内存**: 4GB RAM
- **存储**: 20GB可用空间
- **网络**: 公网IP，80端口可访问

### 推荐配置
- **CPU**: 4核心以上
- **内存**: 8GB RAM以上
- **存储**: 50GB可用空间
- **网络**: 带宽10Mbps以上

### 支持的操作系统
- Ubuntu 18.04+
- CentOS 7+
- RHEL 7+
- Debian 9+

## 🔍 部署验证

### 1. 服务状态检查
```bash
# 检查Nginx状态
sudo systemctl status nginx

# 检查后端服务状态
sudo systemctl status ai_image_backend

# 检查端口监听
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :5002
```

### 2. 功能测试
```bash
# 测试前端访问
curl -I http://localhost

# 测试API健康检查
curl -I http://localhost/api/health

# 测试API响应
curl http://localhost/api/health
```

## 🚨 故障排除

### 常见问题及解决方案

#### 1. 前端无法访问
```bash
# 检查Nginx配置
sudo nginx -t

# 检查文件权限
sudo chown -R root:root frontend/dist
sudo chmod -R 755 frontend/dist

# 检查Nginx状态
sudo systemctl status nginx
```

#### 2. API无法访问
```bash
# 检查后端服务状态
sudo systemctl status ai_image_backend

# 检查端口监听
sudo netstat -tlnp | grep :5002

# 检查日志
sudo journalctl -u ai_image_backend -n 50
```

#### 3. 跨域问题
```bash
# 检查CORS配置
# 确保.env文件中的CORS配置正确

# 或者通过Nginx添加CORS头（见Nginx配置）
```

## 🔒 安全配置

### 1. 防火墙配置
```bash
# 只开放必要端口
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw deny 5002       # 禁止直接访问后端端口
```

### 2. SSL配置（推荐）
```bash
# 安装certbot
sudo apt install certbot python3-certbot-nginx

# 获取SSL证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo crontab -e
# 添加: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📝 维护管理

### 1. 日常维护命令
```bash
# 查看服务状态
./deploy-server.sh status

# 重启服务
./deploy-server.sh restart

# 查看日志
sudo journalctl -u ai_image_backend -f
sudo tail -f /var/log/nginx/ai_image_*.log
```

### 2. 备份策略
```bash
# 备份数据库
cp backend/instance/*.db backup/

# 备份上传文件
tar -czf uploads_backup.tar.gz backend/static/uploads/

# 备份配置文件
cp -r nginx/ backup/
cp *.service backup/
```

## 🌐 访问地址

部署完成后，用户可以通过以下地址访问：

- **前端界面**: http://your-server-ip
- **后端API**: http://your-server-ip/api
- **健康检查**: http://your-server-ip/api/health
- **API文档**: http://your-server-ip/api/docs

## 📋 部署检查清单

- [ ] 系统依赖安装完成
- [ ] 项目文件上传到服务器
- [ ] Python虚拟环境创建并激活
- [ ] 后端依赖安装完成
- [ ] 前端构建完成
- [ ] 数据库初始化完成
- [ ] Nginx配置完成并测试通过
- [ ] 后端服务启动成功
- [ ] 防火墙配置完成
- [ ] 功能测试通过
- [ ] 日志监控正常
- [ ] 备份策略配置完成

---

**注意**: 本部署文档适用于生产环境，请根据实际情况调整配置参数。部署前请确保已备份重要数据。
