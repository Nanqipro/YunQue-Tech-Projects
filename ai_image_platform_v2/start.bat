@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM AI图像处理平台 v2.0 Windows启动脚本
REM 用于快速启动开发环境

title AI图像处理平台 v2.0 启动器

REM 颜色定义 (使用PowerShell进行彩色输出)
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "NC=[0m"

REM 获取当前时间
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2% %dt:~8,2%:%dt:~10,2%:%dt:~12,2%"

REM 打印带颜色的消息函数
:print_info
echo [%timestamp%] %~1
goto :eof

:print_success
powershell -Command "Write-Host '[%timestamp%] %~1' -ForegroundColor Green"
goto :eof

:print_warning
powershell -Command "Write-Host '[%timestamp%] %~1' -ForegroundColor Yellow"
goto :eof

:print_error
powershell -Command "Write-Host '[%timestamp%] %~1' -ForegroundColor Red"
goto :eof

REM 检查命令是否存在
:command_exists
where %1 >nul 2>&1
if %errorlevel% equ 0 (
    exit /b 0
) else (
    exit /b 1
)

REM 检查端口是否被占用
:check_port
netstat -an | findstr ":%~1 " >nul 2>&1
if %errorlevel% equ 0 (
    exit /b 0
) else (
    exit /b 1
)

REM 等待服务启动
:wait_for_service
set "url=%~1"
set "service_name=%~2"
set "max_attempts=30"
set "attempt=1"

call :print_info "等待 %service_name% 启动..."

:wait_loop
if %attempt% gtr %max_attempts% (
    call :print_error "%service_name% 启动超时"
    exit /b 1
)

REM 使用curl检查服务状态（如果有curl）或使用PowerShell
where curl >nul 2>&1
if %errorlevel% equ 0 (
    curl -s "%url%" >nul 2>&1
    if !errorlevel! equ 0 (
        call :print_success "%service_name% 已启动"
        exit /b 0
    )
) else (
    REM 使用PowerShell检查HTTP连接
    powershell -Command "try { $response = Invoke-WebRequest -Uri '%url%' -UseBasicParsing -TimeoutSec 2; exit 0 } catch { exit 1 }" >nul 2>&1
    if !errorlevel! equ 0 (
        call :print_success "%service_name% 已启动"
        exit /b 0
    )
)

echo|set /p=.
timeout /t 2 /nobreak >nul
set /a attempt+=1
goto wait_loop

REM 清理函数
:cleanup
call :print_info "正在清理进程..."

REM 停止后端服务
if defined BACKEND_PID (
    taskkill /F /PID %BACKEND_PID% >nul 2>&1
)

REM 停止前端服务
if defined FRONTEND_PID (
    taskkill /F /PID %FRONTEND_PID% >nul 2>&1
)

REM 停止可能的残留进程
taskkill /F /IM python.exe /FI "WINDOWTITLE eq AI Image Platform Backend" >nul 2>&1
taskkill /F /IM node.exe /FI "WINDOWTITLE eq AI Image Platform Frontend" >nul 2>&1

call :print_info "清理完成"
exit /b 0

REM 主函数
:main
call :print_info "=== AI图像处理平台 v2.0 启动脚本 ==="

REM 检查必要的命令
call :print_info "检查系统依赖..."

call :command_exists python
if %errorlevel% neq 0 (
    call :print_error "Python 未安装，请先安装 Python 3.8+"
    pause
    exit /b 1
)

call :command_exists node
if %errorlevel% neq 0 (
    call :print_error "Node.js 未安装，请先安装 Node.js 14+"
    pause
    exit /b 1
)

call :command_exists npm
if %errorlevel% neq 0 (
    call :print_error "npm 未安装，请先安装 npm"
    pause
    exit /b 1
)

call :print_success "系统依赖检查通过"

REM 设置后端端口
call :print_info "设置后端端口..."
set "FLASK_PORT=5002"
call :print_info "后端服务将使用端口 5002"

call :check_port 3000
if %errorlevel% equ 0 (
    call :print_warning "端口 3000 已被占用，前端服务可能无法启动"
)

call :check_port 5002
if %errorlevel% equ 0 (
    call :print_warning "端口 5002 已被占用，后端服务可能无法启动"
)

REM 启动后端服务
call :print_info "启动后端服务..."

cd /d "%~dp0backend"
if %errorlevel% neq 0 (
    call :print_error "无法进入backend目录"
    pause
    exit /b 1
)

REM 检查虚拟环境
if not exist "venv" (
    call :print_info "创建 Python 虚拟环境..."
    python -m venv venv
    if !errorlevel! neq 0 (
        call :print_error "创建虚拟环境失败"
        pause
        exit /b 1
    )
)

REM 激活虚拟环境
call :print_info "激活虚拟环境..."
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    call :print_error "激活虚拟环境失败"
    pause
    exit /b 1
)

REM 安装依赖
call :print_info "安装后端依赖..."
pip install -r requirements.txt
if %errorlevel% neq 0 (
    call :print_error "后端依赖安装失败！"
    call :print_info "尝试解决方案:"
    call :print_info "1. 升级pip: python -m pip install --upgrade pip"
    call :print_info "2. 清理缓存: pip cache purge"
    call :print_info "3. 使用国内镜像: pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/"
    pause
    exit /b 1
)

REM 初始化数据库
if not exist "app.db" (
    call :print_info "初始化数据库..."
    python run.py --init-db
    if !errorlevel! neq 0 (
        call :print_error "数据库初始化失败"
        pause
        exit /b 1
    )
)

REM 启动后端服务
call :print_info "启动后端 API 服务..."
start "AI Image Platform Backend" /min python run.py
timeout /t 2 /nobreak >nul

REM 获取后端进程ID（简化处理）
for /f "tokens=2" %%i in ('tasklist /FI "WINDOWTITLE eq AI Image Platform Backend" /FO table /NH 2^>nul') do set "BACKEND_PID=%%i"

cd /d "%~dp0"

REM 等待后端服务启动
call :wait_for_service "http://localhost:5002/api/health" "后端服务"
if %errorlevel% neq 0 (
    call :print_error "后端服务启动失败"
    pause
    exit /b 1
)

REM 启动前端服务
call :print_info "启动前端服务..."

cd /d "%~dp0frontend"
if %errorlevel% neq 0 (
    call :print_error "无法进入frontend目录"
    pause
    exit /b 1
)

REM 安装依赖
if not exist "node_modules" (
    call :print_info "安装前端依赖..."
    npm install
    if !errorlevel! neq 0 (
        call :print_error "前端依赖安装失败"
        pause
        exit /b 1
    )
)

REM 启动前端开发服务器
call :print_info "启动前端开发服务器..."
start "AI Image Platform Frontend" /min npm run dev
timeout /t 2 /nobreak >nul

REM 获取前端进程ID（简化处理）
for /f "tokens=2" %%i in ('tasklist /FI "WINDOWTITLE eq AI Image Platform Frontend" /FO table /NH 2^>nul') do set "FRONTEND_PID=%%i"

cd /d "%~dp0"

REM 等待前端服务启动
call :wait_for_service "http://localhost:3000" "前端服务"
if %errorlevel% neq 0 (
    call :print_warning "前端服务可能需要更长时间启动，请手动检查"
)

REM 显示启动信息
call :print_success "=== 服务启动完成 ==="
echo.
call :print_info "前端应用: http://localhost:3000"
call :print_info "后端API: http://localhost:5002"
call :print_info "健康检查: http://localhost:5002/api/health"
call :print_info "API文档: http://localhost:5002/api/docs"
echo.
call :print_warning "按任意键停止所有服务并退出"
echo.

REM 自动打开浏览器
start http://localhost:3000

REM 等待用户输入
pause >nul

REM 清理并退出
call :cleanup
exit /b 0

REM 解析命令行参数
:parse_args
if "%~1"=="--help" goto show_help
if "%~1"=="-h" goto show_help
if "%~1"=="--docker" goto docker_mode
if "%~1"=="--production" goto production_mode
if "%~1"=="" goto main
call :print_error "未知选项: %~1"
echo 使用 --help 查看帮助信息
pause
exit /b 1

:show_help
echo AI图像处理平台 v2.0 启动脚本
echo.
echo 用法: %~nx0 [选项]
echo.
echo 选项:
echo   --help, -h     显示帮助信息
echo   --docker       使用 Docker 启动
echo   --production   生产模式启动
echo.
pause
exit /b 0

:docker_mode
call :print_info "使用 Docker 启动服务..."

call :command_exists docker
if %errorlevel% neq 0 (
    call :print_error "Docker 未安装，请先安装 Docker Desktop"
    pause
    exit /b 1
)

call :command_exists docker-compose
if %errorlevel% neq 0 (
    call :print_error "Docker Compose 未安装，请先安装 Docker Compose"
    pause
    exit /b 1
)

call :print_info "构建并启动 Docker 服务..."
docker-compose up --build
pause
exit /b 0

:production_mode
call :print_info "生产模式启动..."
set "FLASK_ENV=production"
set "NODE_ENV=production"
goto main

REM 脚本入口点
call :parse_args %*
