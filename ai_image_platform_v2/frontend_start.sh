#!/bin/bash

# AI图像处理平台 v2.0 前端启动脚本
# 用于启动前端开发环境

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
    print_info "正在清理前端进程..."
    
    # 停止前端服务
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    
    print_info "前端清理完成"
    exit 0
}

# 设置信号处理
trap cleanup SIGINT SIGTERM

# 主函数
main() {
    print_info "=== AI图像处理平台 v2.0 前端启动脚本 ==="
    
    # 检查必要的命令
    print_info "检查系统依赖..."
    
    if ! command_exists node; then
        print_error "Node.js 未安装，请先安装 Node.js 14+"
        exit 1
    fi
    
    if ! command_exists npm; then
        print_error "npm 未安装，请先安装 npm"
        exit 1
    fi
    
    print_success "系统依赖检查通过"
    
    # 检查端口
    if check_port 3000; then
        print_warning "端口 3000 已被占用，前端服务可能无法启动"
        print_info "请停止占用端口 3000 的进程或修改配置"
    fi
    
    # 启动前端服务
    print_info "启动前端服务..."
    
    cd frontend
    
    # 安装依赖
    if [ ! -d "node_modules" ]; then
        print_info "安装前端依赖..."
        if ! npm install; then
            print_error "前端依赖安装失败！"
            print_info "尝试解决方案:"
            print_info "1. 清理缓存: npm cache clean --force"
            print_info "2. 删除node_modules: rm -rf node_modules && npm install"
            print_info "3. 使用yarn: yarn install"
            exit 1
        fi
    else
        print_info "检查并更新前端依赖..."
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
    print_success "=== 前端服务启动完成 ==="
    echo
    print_info "前端应用: http://localhost:3000"
    echo
    print_warning "按 Ctrl+C 停止前端服务"
    echo
    print_info "提示: 确保后端服务已启动 (http://localhost:5002)"
    echo
    
    # 保持脚本运行
    wait
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            echo "AI图像处理平台 v2.0 前端启动脚本"
            echo
            echo "用法: $0 [选项]"
            echo
            echo "选项:"
            echo "  --help, -h     显示帮助信息"
            echo "  --production   生产模式启动"
            echo
            exit 0
            ;;
        --production)
            print_info "生产模式启动..."
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