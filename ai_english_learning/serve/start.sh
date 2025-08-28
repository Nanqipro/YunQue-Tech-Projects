#!/bin/bash

# AI英语学习平台启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查Go
    if ! command -v go &> /dev/null; then
        log_error "Go未安装，请先安装Go 1.19+"
        exit 1
    fi
    
    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    log_info "Go版本: $GO_VERSION"
    
    # 检查配置文件
    if [ ! -f "config/config.yaml" ]; then
        log_error "配置文件不存在: config/config.yaml"
        exit 1
    fi
    
    log_success "依赖检查完成"
}

# 构建应用
build_app() {
    log_info "构建应用..."
    
    if go build -o ai-english-learning .; then
        log_success "应用构建成功"
    else
        log_error "应用构建失败"
        exit 1
    fi
}

# 检查数据库连接
check_database() {
    log_info "检查数据库连接..."
    
    # 这里可以添加数据库连接检查逻辑
    # 暂时跳过，应用启动时会检查
    log_warning "数据库连接检查跳过，将在应用启动时检查"
}

# 创建必要目录
create_directories() {
    log_info "创建必要目录..."
    
    mkdir -p logs
    mkdir -p uploads
    mkdir -p temp
    
    log_success "目录创建完成"
}

# 启动应用
start_app() {
    log_info "启动AI英语学习平台..."
    
    # 设置环境变量
    export GIN_MODE=${GIN_MODE:-release}
    
    # 启动应用
    ./ai-english-learning
}

# 显示帮助信息
show_help() {
    echo "AI英语学习平台启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -b, --build    仅构建应用"
    echo "  -c, --check    仅检查依赖"
    echo "  -d, --dev      开发模式启动"
    echo "  -p, --prod     生产模式启动"
    echo ""
    echo "环境变量:"
    echo "  GIN_MODE       Gin运行模式 (debug/release/test)"
    echo "  LOG_LEVEL      日志级别 (debug/info/warn/error)"
    echo ""
}

# 开发模式
dev_mode() {
    log_info "开发模式启动"
    export GIN_MODE=debug
    export LOG_LEVEL=debug
    
    check_dependencies
    create_directories
    build_app
    start_app
}

# 生产模式
prod_mode() {
    log_info "生产模式启动"
    export GIN_MODE=release
    export LOG_LEVEL=info
    
    check_dependencies
    create_directories
    build_app
    start_app
}

# 主函数
main() {
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--build)
            check_dependencies
            build_app
            exit 0
            ;;
        -c|--check)
            check_dependencies
            exit 0
            ;;
        -d|--dev)
            dev_mode
            ;;
        -p|--prod)
            prod_mode
            ;;
        "")
            # 默认模式
            log_info "默认模式启动"
            check_dependencies
            create_directories
            build_app
            start_app
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 信号处理
trap 'log_info "收到停止信号，正在关闭应用..."; exit 0' SIGINT SIGTERM

# 执行主函数
main "$@"