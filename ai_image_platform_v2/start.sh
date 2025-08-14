#!/bin/bash

# AI图像处理平台 v2.0 启动脚本
# 用于快速启动开发环境

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${2}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_info() {
    print_message "$1" "$BLUE"
}

print_success() {
    print_message "$1" "$GREEN"
}

print_warning() {
    print_message "$1" "$YELLOW"
}

print_error() {
    print_message "$1" "$RED"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # 端口被占用
    else
        return 1  # 端口可用
    fi
}

# 等待服务启动
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    print_info "等待 $service_name 启动..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" >/dev/null 2>&1; then
            print_success "$service_name 已启动"
            return 0
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    print_error "$service_name 启动超时"
    return 1
}

# 清理函数
cleanup() {
    print_info "正在清理进程..."
    
    # 停止后端服务
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    
    # 停止前端服务
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    
    print_info "清理完成"
    exit 0
}

# 设置信号处理
trap cleanup SIGINT SIGTERM

# 主函数
main() {
    print_info "=== AI图像处理平台 v2.0 启动脚本 ==="
    
    # 检查必要的命令
    print_info "检查系统依赖..."
    
    if ! command_exists python3; then
        print_error "Python 3 未安装，请先安装 Python 3.8+"
        exit 1
    fi
    
    if ! command_exists node; then
        print_error "Node.js 未安装，请先安装 Node.js 14+"
        exit 1
    fi
    
    if ! command_exists npm; then
        print_error "npm 未安装，请先安装 npm"
        exit 1
    fi
    
    print_success "系统依赖检查通过"
    
    # 检查端口占用
    print_info "检查端口占用..."
    
    if check_port 5000; then
        print_warning "端口 5000 已被占用，使用端口 5002"
        export FLASK_PORT=5002
    else
        export FLASK_PORT=5000
    fi
    
    if check_port 3000; then
        print_warning "端口 3000 已被占用，前端服务可能无法启动"
    fi
    
    # 启动后端服务
    print_info "启动后端服务..."
    
    cd backend
    
    # 检查虚拟环境
    if [ ! -d "venv" ]; then
        print_info "创建 Python 虚拟环境..."
        python3 -m venv venv
    fi
    
    # 激活虚拟环境
    source venv/bin/activate
    
    # 安装依赖
    print_info "安装后端依赖..."
    if ! pip install -r requirements.txt; then
        print_error "后端依赖安装失败！"
        print_info "尝试解决方案:"
        print_info "1. 升级pip: pip install --upgrade pip"
        print_info "2. 清理缓存: pip cache purge"
        print_info "3. 使用国内镜像: pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/"
        exit 1
    fi
    
    # 初始化数据库
    if [ ! -f "app.db" ]; then
        print_info "初始化数据库..."
        python run.py --init-db
    fi
    
    # 启动后端服务
    print_info "启动后端 API 服务..."
    python run.py &
    BACKEND_PID=$!
    
    cd ..
    
    # 等待后端服务启动
    wait_for_service "http://localhost:$FLASK_PORT/api/health" "后端服务"
    
    # 启动前端服务
    print_info "启动前端服务..."
    
    cd frontend
    
    # 安装依赖
    if [ ! -d "node_modules" ]; then
        print_info "安装前端依赖..."
        npm install
    fi
    
    # 启动前端开发服务器
    print_info "启动前端开发服务器..."
    npm run dev &
    FRONTEND_PID=$!
    
    cd ..
    
    # 等待前端服务启动
    wait_for_service "http://localhost:3000" "前端服务"
    
    # 显示启动信息
    print_success "=== 服务启动完成 ==="
    echo
    print_info "前端应用: http://localhost:3000"
    print_info "后端API: http://localhost:$FLASK_PORT"
    print_info "健康检查: http://localhost:$FLASK_PORT/api/health"
    print_info "API文档: http://localhost:$FLASK_PORT/api/docs"
    echo
    print_warning "按 Ctrl+C 停止所有服务"
    echo
    
    # 保持脚本运行
    wait
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            echo "AI图像处理平台 v2.0 启动脚本"
            echo
            echo "用法: $0 [选项]"
            echo
            echo "选项:"
            echo "  --help, -h     显示帮助信息"
            echo "  --docker       使用 Docker 启动"
            echo "  --production   生产模式启动"
            echo
            exit 0
            ;;
        --docker)
            print_info "使用 Docker 启动服务..."
            
            if ! command_exists docker; then
                print_error "Docker 未安装，请先安装 Docker"
                exit 1
            fi
            
            if ! command_exists docker-compose; then
                print_error "Docker Compose 未安装，请先安装 Docker Compose"
                exit 1
            fi
            
            print_info "构建并启动 Docker 服务..."
            docker-compose up --build
            exit 0
            ;;
        --production)
            print_info "生产模式启动..."
            export FLASK_ENV=production
            export NODE_ENV=production
            ;;
        *)
            print_error "未知选项: $1"
            echo "使用 --help 查看帮助信息"
            exit 1
            ;;
    esac
    shift
done

# 运行主函数
main