# AI图像处理平台 v2.0 PowerShell启动脚本
# 用于快速启动开发环境

param(
    [switch]$Help,
    [switch]$Docker,
    [switch]$Production,
    [switch]$NoOpen  # 不自动打开浏览器
)

# 设置控制台标题和编码
$Host.UI.RawUI.WindowTitle = "AI图像处理平台 v2.0 启动器"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 全局变量
$BackendProcess = $null
$FrontendProcess = $null
$Script:CleanupExecuted = $false

# 颜色输出函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Write-Info { Write-ColorOutput $args[0] "Cyan" }
function Write-Success { Write-ColorOutput $args[0] "Green" }
function Write-Warning { Write-ColorOutput $args[0] "Yellow" }
function Write-Error { Write-ColorOutput $args[0] "Red" }

# 检查命令是否存在
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# 检查端口是否被占用
function Test-Port {
    param([int]$Port)
    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        return $connection.Count -gt 0
    }
    catch {
        return $false
    }
}

# 等待服务启动
function Wait-ForService {
    param(
        [string]$Url,
        [string]$ServiceName,
        [int]$MaxAttempts = 30
    )
    
    Write-Info "等待 $ServiceName 启动..."
    
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Success "$ServiceName 已启动"
                return $true
            }
        }
        catch {
            # 继续等待
        }
        
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 2
    }
    
    Write-Error "$ServiceName 启动超时"
    return $false
}

# 清理函数
function Invoke-Cleanup {
    if ($Script:CleanupExecuted) {
        return
    }
    $Script:CleanupExecuted = $true
    
    Write-Info "正在清理进程..."
    
    # 停止后端服务
    if ($BackendProcess -and !$BackendProcess.HasExited) {
        try {
            $BackendProcess.Kill()
            Write-Info "后端服务已停止"
        }
        catch {
            Write-Warning "无法停止后端服务: $($_.Exception.Message)"
        }
    }
    
    # 停止前端服务
    if ($FrontendProcess -and !$FrontendProcess.HasExited) {
        try {
            $FrontendProcess.Kill()
            Write-Info "前端服务已停止"
        }
        catch {
            Write-Warning "无法停止前端服务: $($_.Exception.Message)"
        }
    }
    
    # 清理可能的残留进程
    try {
        Get-Process -Name "python" -ErrorAction SilentlyContinue | 
            Where-Object { $_.MainWindowTitle -like "*AI Image Platform*" } |
            Stop-Process -Force
            
        Get-Process -Name "node" -ErrorAction SilentlyContinue | 
            Where-Object { $_.MainWindowTitle -like "*AI Image Platform*" } |
            Stop-Process -Force
    }
    catch {
        # 忽略错误
    }
    
    Write-Info "清理完成"
}

# 设置Ctrl+C处理
Register-EngineEvent PowerShell.Exiting -Action {
    Invoke-Cleanup
}

# 信号处理
$null = Register-ObjectEvent -InputObject ([Console]) -EventName CancelKeyPress -Action {
    Invoke-Cleanup
    [Environment]::Exit(0)
}

# 显示帮助信息
function Show-Help {
    Write-Host @"
AI图像处理平台 v2.0 PowerShell启动脚本

用法: .\start.ps1 [选项]

选项:
  -Help          显示帮助信息
  -Docker        使用 Docker 启动
  -Production    生产模式启动
  -NoOpen        不自动打开浏览器

示例:
  .\start.ps1                    # 开发模式启动
  .\start.ps1 -Production        # 生产模式启动
  .\start.ps1 -Docker            # Docker模式启动
  .\start.ps1 -NoOpen            # 启动但不打开浏览器

"@
}

# Docker模式
function Start-DockerMode {
    Write-Info "使用 Docker 启动服务..."
    
    if (!(Test-Command "docker")) {
        Write-Error "Docker 未安装，请先安装 Docker Desktop"
        exit 1
    }
    
    if (!(Test-Command "docker-compose")) {
        Write-Error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    }
    
    Write-Info "构建并启动 Docker 服务..."
    & docker-compose up --build
    exit 0
}

# 主函数
function Start-Application {
    Write-Info "=== AI图像处理平台 v2.0 启动脚本 ==="
    
    # 检查必要的命令
    Write-Info "检查系统依赖..."
    
    if (!(Test-Command "python")) {
        Write-Error "Python 未安装，请先安装 Python 3.8+"
        Read-Host "按任意键退出"
        exit 1
    }
    
    if (!(Test-Command "node")) {
        Write-Error "Node.js 未安装，请先安装 Node.js 14+"
        Read-Host "按任意键退出"
        exit 1
    }
    
    if (!(Test-Command "npm")) {
        Write-Error "npm 未安装，请先安装 npm"
        Read-Host "按任意键退出"
        exit 1
    }
    
    Write-Success "系统依赖检查通过"
    
    # 设置环境变量
    $env:FLASK_PORT = "5002"
    Write-Info "后端服务将使用端口 5002"
    
    if ($Production) {
        $env:FLASK_ENV = "production"
        $env:NODE_ENV = "production"
        Write-Info "使用生产模式"
    }
    else {
        $env:FLASK_ENV = "development"
        $env:NODE_ENV = "development"
        Write-Info "使用开发模式"
    }
    
    # 检查端口占用
    if (Test-Port 3000) {
        Write-Warning "端口 3000 已被占用，前端服务可能无法启动"
    }
    
    if (Test-Port 5002) {
        Write-Warning "端口 5002 已被占用，后端服务可能无法启动"
    }
    
    # 启动后端服务
    Write-Info "启动后端服务..."
    
    $backendPath = Join-Path $PSScriptRoot "backend"
    if (!(Test-Path $backendPath)) {
        Write-Error "无法找到backend目录: $backendPath"
        Read-Host "按任意键退出"
        exit 1
    }
    
    Push-Location $backendPath
    
    try {
        # 检查虚拟环境
        $venvPath = Join-Path $backendPath "venv"
        if (!(Test-Path $venvPath)) {
            Write-Info "创建 Python 虚拟环境..."
            & python -m venv venv
            if ($LASTEXITCODE -ne 0) {
                throw "创建虚拟环境失败"
            }
        }
        
        # 激活虚拟环境
        $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
        if (Test-Path $activateScript) {
            Write-Info "激活虚拟环境..."
            & $activateScript
        }
        else {
            Write-Warning "找不到PowerShell激活脚本，尝试使用批处理版本"
            & "$venvPath\Scripts\activate.bat"
        }
        
        # 安装依赖
        Write-Info "安装后端依赖..."
        & pip install -r requirements.txt
        if ($LASTEXITCODE -ne 0) {
            Write-Error "后端依赖安装失败！"
            Write-Info "尝试解决方案:"
            Write-Info "1. 升级pip: python -m pip install --upgrade pip"
            Write-Info "2. 清理缓存: pip cache purge"
            Write-Info "3. 使用国内镜像: pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/"
            throw "依赖安装失败"
        }
        
        # 初始化数据库
        if (!(Test-Path "app.db")) {
            Write-Info "初始化数据库..."
            & python run.py init-db
            if ($LASTEXITCODE -ne 0) {
                throw "数据库初始化失败"
            }
        }
        
        # 启动后端服务
        Write-Info "启动后端 API 服务..."
        $script:BackendProcess = Start-Process -FilePath "python" -ArgumentList "run.py" -PassThru -WindowStyle Minimized
        
        Start-Sleep -Seconds 3
    }
    catch {
        Write-Error "后端启动失败: $($_.Exception.Message)"
        Pop-Location
        Read-Host "按任意键退出"
        exit 1
    }
    finally {
        Pop-Location
    }
    
    # 等待后端服务启动
    if (!(Wait-ForService "http://localhost:5002/api/health" "后端服务")) {
        Write-Error "后端服务启动失败"
        Invoke-Cleanup
        Read-Host "按任意键退出"
        exit 1
    }
    
    # 启动前端服务
    Write-Info "启动前端服务..."
    
    $frontendPath = Join-Path $PSScriptRoot "frontend"
    if (!(Test-Path $frontendPath)) {
        Write-Error "无法找到frontend目录: $frontendPath"
        Invoke-Cleanup
        Read-Host "按任意键退出"
        exit 1
    }
    
    Push-Location $frontendPath
    
    try {
        # 安装依赖
        if (!(Test-Path "node_modules")) {
            Write-Info "安装前端依赖..."
            & npm install
            if ($LASTEXITCODE -ne 0) {
                throw "前端依赖安装失败"
            }
        }
        
        # 启动前端开发服务器
        Write-Info "启动前端开发服务器..."
        $script:FrontendProcess = Start-Process -FilePath "npm" -ArgumentList "run", "dev" -PassThru -WindowStyle Minimized
        
        Start-Sleep -Seconds 3
    }
    catch {
        Write-Error "前端启动失败: $($_.Exception.Message)"
        Pop-Location
        Invoke-Cleanup
        Read-Host "按任意键退出"
        exit 1
    }
    finally {
        Pop-Location
    }
    
    # 等待前端服务启动
    if (!(Wait-ForService "http://localhost:3000" "前端服务")) {
        Write-Warning "前端服务可能需要更长时间启动，请手动检查"
    }
    
    # 显示启动信息
    Write-Success "=== 服务启动完成 ==="
    Write-Host ""
    Write-Info "前端应用: http://localhost:3000"
    Write-Info "后端API: http://localhost:5002"
    Write-Info "健康检查: http://localhost:5002/api/health"
    Write-Info "API文档: http://localhost:5002/api/docs"
    Write-Host ""
    Write-Warning "按任意键停止所有服务并退出"
    Write-Host ""
    
    # 自动打开浏览器
    if (!$NoOpen) {
        Start-Process "http://localhost:3000"
    }
    
    # 等待用户输入
    Read-Host
    
    # 清理并退出
    Invoke-Cleanup
}

# 主程序入口
try {
    if ($Help) {
        Show-Help
        exit 0
    }
    
    if ($Docker) {
        Start-DockerMode
    }
    else {
        Start-Application
    }
}
catch {
    Write-Error "脚本执行失败: $($_.Exception.Message)"
    Invoke-Cleanup
    Read-Host "按任意键退出"
    exit 1
}
