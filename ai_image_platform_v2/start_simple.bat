@echo off
chcp 65001 >nul
title AI图像处理平台 - 简易启动器

echo ========================================
echo     AI图像处理平台 v2.0 简易启动器
echo ========================================
echo.

REM 检查Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到Python，请先安装Python 3.8+
    pause
    exit /b 1
)

REM 检查Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到Node.js，请先安装Node.js 14+
    pause
    exit /b 1
)

REM 检查npm
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到npm，请确保Node.js安装正确
    pause
    exit /b 1
)

echo [信息] 系统依赖检查通过
echo.

REM 启动后端
echo [信息] 正在启动后端服务...
cd /d "%~dp0backend"

REM 创建虚拟环境（如果不存在）
if not exist "venv" (
    echo [信息] 创建Python虚拟环境...
    python -m venv venv
)

REM 激活虚拟环境并安装依赖
call venv\Scripts\activate.bat
echo [信息] 安装后端依赖...
pip install -r requirements.txt >nul 2>&1

REM 初始化数据库（如果需要）
if not exist "app.db" (
    echo [信息] 初始化数据库...
    python run.py init-db
)

REM 启动后端
echo [信息] 启动后端API服务 (端口: 5002)...
start "AI Platform Backend" python run.py

REM 等待后端启动
timeout /t 5 /nobreak >nul

REM 启动前端
cd /d "%~dp0frontend"
echo [信息] 正在启动前端服务...

REM 安装前端依赖（如果需要）
if not exist "node_modules" (
    echo [信息] 安装前端依赖...
    npm install >nul 2>&1
)

REM 启动前端
echo [信息] 启动前端开发服务器 (端口: 3000)...
start "AI Platform Frontend" npm run dev

REM 等待前端启动
timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo              启动完成!
echo ========================================
echo.
echo 前端地址: http://localhost:3000
echo 后端地址: http://localhost:5002
echo.
echo 提示: 
echo - 如果服务未正常启动，请等待几分钟再访问
echo - 关闭此窗口将同时停止所有服务
echo.

REM 自动打开浏览器
start http://localhost:3000

echo 按任意键退出并停止所有服务...
pause >nul

REM 清理进程
taskkill /F /FI "WINDOWTITLE eq AI Platform Backend" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq AI Platform Frontend" >nul 2>&1

echo 服务已停止
exit /b 0
