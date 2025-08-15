# AI图像处理平台 v2.0 - Windows启动指南

本指南提供了在Windows系统上一键启动前后端服务的方法。

## 📁 脚本文件说明

我们提供了三种启动方式，满足不同用户的需求：

### 1. `start.bat` - 完整版批处理脚本
- ✅ 完整的错误检查和状态监控
- ✅ 彩色输出显示
- ✅ 服务健康检查
- ✅ 端口冲突检测
- ✅ 优雅的进程清理
- ✅ 支持命令行参数
- 📝 适合：开发人员和高级用户

### 2. `start.ps1` - PowerShell脚本（推荐）
- ✅ 最强大的功能和错误处理
- ✅ 更好的进程管理
- ✅ 支持多种启动模式
- ✅ 详细的日志输出
- ✅ 自动浏览器打开
- 📝 适合：Windows 10/11用户（推荐）

### 3. `start_simple.bat` - 简化版批处理脚本
- ✅ 简单易用，快速启动
- ✅ 最小化配置
- ✅ 适合初学者
- 📝 适合：快速测试和简单使用

## 🚀 使用方法

### 方法一：PowerShell脚本（推荐）

1. **右键点击空白处** → **在终端中打开** 或 **PowerShell**
2. **运行脚本**：
   ```powershell
   .\start.ps1
   ```

#### PowerShell高级用法
```powershell
# 基本启动
.\start.ps1

# 生产模式启动
.\start.ps1 -Production

# 启动但不打开浏览器
.\start.ps1 -NoOpen

# Docker模式启动
.\start.ps1 -Docker

# 查看帮助
.\start.ps1 -Help
```

### 方法二：批处理脚本

#### 完整版
1. **双击** `start.bat` 文件
2. 或在命令提示符中运行：
   ```cmd
   start.bat
   ```

#### 简化版（推荐新手）
1. **双击** `start_simple.bat` 文件
2. 等待自动启动完成

### 方法三：命令行参数

```cmd
# 查看帮助
start.bat --help

# Docker模式
start.bat --docker

# 生产模式
start.bat --production
```

## 📋 系统要求

### 必需软件
- **Python 3.8+** - [下载地址](https://www.python.org/downloads/)
- **Node.js 14+** - [下载地址](https://nodejs.org/)
- **npm** - 通常随Node.js自动安装

### 可选软件
- **Docker Desktop** - 如需使用Docker模式
- **Git** - 用于版本控制

## 🔧 故障排除

### 常见问题解决

#### 1. Python/Node.js未找到
```bash
# 检查Python安装
python --version

# 检查Node.js安装
node --version

# 检查npm安装
npm --version
```

#### 2. 端口被占用
- **端口3000被占用**：前端无法启动
- **端口5002被占用**：后端无法启动

**解决方法**：
```cmd
# 查看端口占用
netstat -ano | findstr :3000
netstat -ano | findstr :5002

# 结束占用进程（替换PID为实际进程ID）
taskkill /F /PID <PID>
```

#### 3. PowerShell执行策略限制
如果PowerShell提示执行策略限制：
```powershell
# 临时允许执行
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 然后运行脚本
.\start.ps1
```

#### 4. 依赖安装失败

**Python依赖问题**：
```cmd
# 升级pip
python -m pip install --upgrade pip

# 清理缓存
pip cache purge

# 使用国内镜像
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/
```

**Node.js依赖问题**：
```cmd
# 清理缓存
npm cache clean --force

# 删除node_modules重新安装
rmdir /s node_modules
npm install

# 使用国内镜像
npm install --registry https://registry.npmmirror.com
```

#### 5. 虚拟环境问题
```cmd
# 删除现有虚拟环境
rmdir /s backend\venv

# 重新运行启动脚本让其自动创建
```

## 🌐 访问地址

启动成功后，您可以通过以下地址访问：

- **前端应用**: http://localhost:3000
- **后端API**: http://localhost:5002
- **健康检查**: http://localhost:5002/api/health
- **API文档**: http://localhost:5002/api/docs

## 🛑 停止服务

### 自动停止
- **PowerShell/批处理窗口**：按任意键
- **简化版**：关闭命令窗口

### 手动停止
```cmd
# 停止所有相关进程
taskkill /F /IM python.exe
taskkill /F /IM node.exe
```

## 📞 获取帮助

如果遇到问题：

1. **查看日志输出** - 注意红色错误信息
2. **检查系统要求** - 确保软件版本正确
3. **重启计算机** - 解决环境变量问题
4. **查看错误代码** - 根据具体错误搜索解决方案

## 💡 使用建议

1. **首次使用**：建议使用 `start_simple.bat`
2. **开发调试**：建议使用 `start.ps1`
3. **生产部署**：建议使用 Docker 模式
4. **定期更新**：重新运行脚本会自动更新依赖

---

**注意**：如果遇到任何问题，请检查控制台输出中的错误信息，通常会包含解决问题的提示。
