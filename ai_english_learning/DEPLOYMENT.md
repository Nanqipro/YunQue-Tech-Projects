# AI英语学习平台部署指南

## 概述

本文档描述了如何部署AI英语学习平台的后端服务。项目支持多种部署方式：本地开发、Docker容器化部署和生产环境部署。

## 系统要求

### 基础要求
- Go 1.19+
- MySQL 8.0+
- Redis 7.0+
- Docker & Docker Compose (可选)

### 硬件要求
- CPU: 2核心以上
- 内存: 4GB以上
- 存储: 20GB以上可用空间

## 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd ai_english_learning
```

### 2. 使用Docker Compose（推荐）
```bash
# 启动所有服务
make docker-run

# 或者直接使用docker-compose
docker-compose up -d

# 查看服务状态
make status

# 查看日志
make logs
```

### 3. 本地开发
```bash
# 安装依赖
make deps

# 运行开发服务器
make dev
```

## 详细部署步骤

### 环境配置

#### 1. 数据库配置

**MySQL设置：**
```sql
CREATE DATABASE ai_english_learning CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'ai_english'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON ai_english_learning.* TO 'ai_english'@'%';
FLUSH PRIVILEGES;
```

**导入数据库结构：**
```bash
mysql -u ai_english -p ai_english_learning < docs/database_schema.sql
```

#### 2. Redis配置

基本Redis配置即可，无需特殊设置。

#### 3. 应用配置

复制并修改配置文件：
```bash
cp serve/config/config.yaml serve/config/config.local.yaml
```

编辑 `config.local.yaml`：
```yaml
server:
  port: "8080"
  mode: "release"  # debug, release, test

database:
  host: "localhost"
  port: "3306"
  user: "ai_english"
  password: "your_password"
  name: "ai_english_learning"
  charset: "utf8mb4"

jwt:
  secret: "your-super-secret-jwt-key"
  access_token_ttl: 3600
  refresh_token_ttl: 604800

redis:
  host: "localhost"
  port: "6379"
  password: ""
  db: 0

app:
  name: "AI English Learning"
  version: "1.0.0"
  environment: "production"
  log_level: "info"

log:
  level: "info"
  format: "json"  # json, text
  output: "both"  # console, file, both
  file_path: "./logs/app.log"
  max_size: 100
  max_backups: 10
  max_age: 30
  compress: true
```

### 环境变量

可以通过环境变量覆盖配置文件设置：

```bash
export SERVER_PORT=8080
export DATABASE_HOST=localhost
export DATABASE_USER=ai_english
export DATABASE_PASSWORD=your_password
export DATABASE_NAME=ai_english_learning
export REDIS_HOST=localhost
export JWT_SECRET=your-super-secret-jwt-key
export APP_ENVIRONMENT=production
export LOG_LEVEL=info
```

## 部署方式

### 1. Docker部署（推荐）

#### 构建镜像
```bash
make docker-build
```

#### 启动服务
```bash
make docker-run
```

#### 服务访问
- 后端API: http://localhost:8080
- 健康检查: http://localhost:8080/health
- API文档: 参考 docs/API接口文档.md

### 2. 二进制部署

#### 构建应用
```bash
make build
```

#### 启动服务
```bash
make prod
```

### 3. 系统服务部署

创建systemd服务文件 `/etc/systemd/system/ai-english-learning.service`：

```ini
[Unit]
Description=AI English Learning Backend Service
After=network.target mysql.service redis.service

[Service]
Type=simple
User=ai-english
Group=ai-english
WorkingDirectory=/opt/ai-english-learning
ExecStart=/opt/ai-english-learning/ai-english-learning
Restart=always
RestartSec=5
Environment=GIN_MODE=release
EnvironmentFile=/opt/ai-english-learning/.env

# 安全设置
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/ai-english-learning/logs

[Install]
WantedBy=multi-user.target
```

启用并启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable ai-english-learning
sudo systemctl start ai-english-learning
sudo systemctl status ai-english-learning
```

## 监控和维护

### 健康检查端点

- `/health` - 综合健康检查
- `/health/liveness` - 存活检查
- `/health/readiness` - 就绪检查
- `/version` - 版本信息

### 日志管理

日志文件位置：`./logs/app.log`

查看日志：
```bash
# 实时日志
tail -f logs/app.log

# Docker环境
make logs
```

### 数据库备份

```bash
# 创建备份
make backup

# 恢复备份
# 编辑Makefile中的restore命令并执行
make restore
```

### 性能监控

```bash
# 运行性能测试
make bench

# 安全扫描
make security
```

## 故障排除

### 常见问题

1. **数据库连接失败**
   - 检查数据库服务是否运行
   - 验证连接参数
   - 检查防火墙设置

2. **Redis连接失败**
   - 检查Redis服务状态
   - 验证连接配置

3. **端口冲突**
   - 修改配置文件中的端口设置
   - 检查端口占用情况

4. **权限问题**
   - 检查文件权限
   - 确保日志目录可写

### 调试模式

开启调试模式：
```bash
export GIN_MODE=debug
export LOG_LEVEL=debug
```

### 日志级别

- `debug` - 详细调试信息
- `info` - 一般信息
- `warn` - 警告信息
- `error` - 错误信息
- `fatal` - 致命错误

## 安全建议

1. **JWT密钥**：使用强随机密钥
2. **数据库密码**：使用复杂密码
3. **HTTPS**：生产环境启用HTTPS
4. **防火墙**：限制不必要的端口访问
5. **定期更新**：保持依赖库最新

## 扩展部署

### 负载均衡

使用Nginx进行负载均衡：

```nginx
upstream ai_english_backend {
    server 127.0.0.1:8080;
    server 127.0.0.1:8081;
    server 127.0.0.1:8082;
}

server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://ai_english_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 数据库集群

考虑使用MySQL主从复制或集群方案。

### 缓存策略

配置Redis集群或使用CDN加速静态资源。

## 联系支持

如遇到部署问题，请查看：
- 项目文档：docs/
- 问题追踪：GitHub Issues
- 技术支持：[联系方式]