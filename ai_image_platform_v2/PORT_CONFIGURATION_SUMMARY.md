# 端口配置修改总结

## 🎯 目标
统一使用5002端口，避免5000端口冲突

## ✅ 已修改的文件

### 1. 启动脚本
- **start.sh**: 移除端口检测逻辑，固定使用5002端口

### 2. Docker配置
- **docker-compose.yml**: 端口映射从5000改为5002
- **backend/Dockerfile**: 暴露端口从5000改为5002

### 3. 部署脚本
- **docker-deploy.sh**: 健康检查和代理配置从5000改为5002
- **deploy-server.sh**: 端口配置从5000改为5002

### 4. 文档文件
- **README.md**: 所有端口引用从5000改为5002
- **backend/README.md**: 后端文档端口从5000改为5002
- **frontend/README.md**: 前端配置端口从5000改为5002
- **COMPUTING_POWER_ANALYSIS.md**: 技术文档端口从5000改为5002

### 5. 环境配置
- **config.env**: 创建环境变量配置文件，设置FLASK_PORT=5002

## 🔧 端口配置详情

### 后端服务
- **端口**: 5002 (固定)
- **环境变量**: FLASK_PORT=5002
- **默认配置**: 后端代码中已设置默认端口5002

### 前端服务
- **端口**: 3000 (保持不变)
- **API地址**: http://127.0.0.1:5002/api (已更新)

### Docker部署
- **端口映射**: 5002:5002
- **健康检查**: http://localhost:5002/api/health
- **代理配置**: 所有API请求代理到5002端口

## 📋 修改检查清单

- [x] 启动脚本 (start.sh)
- [x] Docker配置 (docker-compose.yml, Dockerfile)
- [x] 部署脚本 (docker-deploy.sh, deploy-server.sh)
- [x] 文档文件 (所有README.md)
- [x] 前端配置 (main.js中的API地址)
- [x] 环境配置 (config.env)

## 🚀 启动命令

现在可以使用以下命令启动项目：

```bash
# 使用修改后的启动脚本
./start.sh

# 或者手动启动
cd backend && source venv/bin/activate && python run.py
cd frontend && npm run dev
```

## 🌐 访问地址

- **前端应用**: http://localhost:3000
- **后端API**: http://localhost:5002
- **健康检查**: http://localhost:5002/api/health

## ⚠️ 注意事项

1. **端口冲突**: 5000端口被macOS ControlCenter占用，已避免
2. **环境变量**: 创建了config.env文件，但可能需要手动加载
3. **前端配置**: main.js中已更新API地址为5002端口
4. **Docker部署**: 所有Docker相关配置已更新

## 🔍 验证方法

启动服务后，可以通过以下方式验证端口配置：

```bash
# 检查端口占用
lsof -i :5002
lsof -i :3000

# 测试API
curl http://localhost:5002/api/health

# 测试前端
curl http://localhost:3000
```

---

**修改完成时间**: 2025年8月14日  
**修改范围**: 全项目端口配置统一  
**目标端口**: 后端5002，前端3000
