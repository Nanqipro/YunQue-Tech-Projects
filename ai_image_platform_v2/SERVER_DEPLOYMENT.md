# AI图像处理平台 - 服务器部署指南

## 概述
本指南将帮助你在其他服务器上部署AI图像处理平台，使用Nginx的80端口提供服务。

## 系统要求
- **操作系统**: Ubuntu 18.04+, CentOS 7+, RHEL 7+
- **Python**: 3.8+
- **内存**: 至少2GB RAM
- **存储**: 至少10GB可用空间
- **网络**: 80端口可访问

## 快速部署

### 1. 上传项目文件
将整个项目文件夹上传到服务器：
```bash
# 使用scp上传
scp -r ai_image_platform_v2 user@your-server:/home/user/

# 或使用git克隆
git clone <your-repo-url> /home/user/ai_image_platform_v2
```

### 2. 设置执行权限
```bash
cd /home/user/ai_image_platform_v2
chmod +x deploy-server.sh
```

### 3. 配置环境变量（可选）
```bash
# 设置域名（如果有）
export DOMAIN=your-domain.com

# 设置后端端口（默认5002）
export BACKEND_PORT=5002

# 设置工作进程数（默认4）
export WORKERS=4
```

### 4. 执行部署
```bash
# 开始部署
./deploy-server.sh start

# 或者分步执行
./deploy-server.sh help  # 查看帮助
```

## 部署过程说明

部署脚本会自动执行以下步骤：

1. **检查依赖**: 自动安装Python3、pip3、Nginx等必要软件
2. **创建目录**: 创建日志、PID、上传等必要目录
3. **安装依赖**: 安装Python依赖包，创建虚拟环境
4. **初始化数据库**: 创建数据库表和默认管理员用户
5. **构建前端**: 如果有Node.js则构建前端，否则复制现有文件
6. **配置Nginx**: 创建Nginx配置文件，设置反向代理
7. **创建服务**: 创建systemd服务文件
8. **启动服务**: 启动后端和Nginx服务
9. **配置防火墙**: 开放80端口

## 服务管理

### 查看状态
```bash
./deploy-server.sh status
```

### 重启服务
```bash
./deploy-server.sh restart
```

### 停止服务
```bash
./deploy-server.sh stop
```

### 卸载服务
```bash
./deploy-server.sh uninstall
```

## 系统服务管理

### 后端服务
```bash
# 查看状态
sudo systemctl status ai_image_backend

# 重启
sudo systemctl restart ai_image_backend

# 查看日志
sudo journalctl -u ai_image_backend -f
```

### Nginx服务
```bash
# 查看状态
sudo systemctl status nginx

# 重启
sudo systemctl restart nginx

# 查看日志
sudo tail -f /var/log/nginx/ai_image_*.log
```

## 访问地址

部署完成后，你可以通过以下地址访问：

- **前端界面**: http://your-server-ip 或 http://your-domain.com
- **后端API**: http://your-server-ip/api 或 http://your-domain.com/api
- **健康检查**: http://your-server-ip/api/health

## 默认登录信息

- **用户名**: admin
- **密码**: admin123

**注意**: 生产环境请务必修改默认密码！

## 配置文件位置

- **Nginx配置**: `/etc/nginx/conf.d/ai_image_platform.conf`
- **后端服务**: `/etc/systemd/system/ai_image_backend.service`
- **项目日志**: `/home/user/ai_image_platform_v2/logs/`
- **上传文件**: `/home/user/ai_image_platform_v2/backend/static/uploads/`

## 故障排除

### 1. 端口被占用
```bash
# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :5002

# 杀死占用进程
sudo kill -9 <PID>
```

### 2. 权限问题
```bash
# 确保用户有sudo权限
sudo visudo

# 检查文件权限
ls -la deploy-server.sh
chmod +x deploy-server.sh
```

### 3. 服务启动失败
```bash
# 查看详细错误信息
sudo systemctl status ai_image_backend -l
sudo journalctl -u ai_image_backend -n 50

# 检查配置文件
sudo nginx -t
```

### 4. 数据库连接失败
```bash
# 检查数据库文件权限
ls -la backend/instance/
chmod 644 backend/instance/*.db
```

## 性能优化

### 1. 调整工作进程数
```bash
export WORKERS=8  # 根据CPU核心数调整
./deploy-server.sh restart
```

### 2. 调整Nginx配置
编辑 `/etc/nginx/conf.d/ai_image_platform.conf`：
```nginx
# 增加worker连接数
worker_connections 2048;

# 启用gzip压缩
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

### 3. 调整后端配置
编辑 `backend/config/config.py`：
```python
# 增加上传文件大小限制
MAX_CONTENT_LENGTH = 100 * 1024 * 1024  # 100MB
```

## 安全建议

1. **修改默认密码**: 部署后立即修改admin用户密码
2. **配置防火墙**: 只开放必要端口（80, 443, 22）
3. **启用HTTPS**: 配置SSL证书，强制HTTPS访问
4. **定期备份**: 备份数据库和上传文件
5. **监控日志**: 定期检查访问和错误日志

## 备份和恢复

### 备份
```bash
# 备份数据库
cp backend/instance/*.db backup/

# 备份上传文件
tar -czf uploads_backup.tar.gz backend/static/uploads/

# 备份配置文件
cp -r nginx/ backup/
cp *.service backup/
```

### 恢复
```bash
# 恢复数据库
cp backup/*.db backend/instance/

# 恢复上传文件
tar -xzf uploads_backup.tar.gz

# 恢复配置
cp -r backup/nginx/* nginx/
cp backup/*.service ./
```

## 联系支持

如果遇到部署问题，请检查：
1. 系统日志: `/var/log/syslog` 或 `/var/log/messages`
2. 服务日志: 使用 `journalctl` 命令
3. Nginx日志: `/var/log/nginx/ai_image_*.log`
4. 项目日志: `logs/` 目录下的文件

---

**注意**: 本部署脚本适用于大多数Linux发行版，如果遇到特定系统的问题，可能需要手动调整配置。
