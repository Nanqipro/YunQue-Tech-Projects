#!/bin/bash

# AI英语学习平台部署脚本
# 使用方法: ./deploy.sh [环境] [操作]
# 环境: dev, test, prod
# 操作: build, start, stop, restart, logs, clean

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

# 检查参数
if [ $# -lt 2 ]; then
    log_error "使用方法: $0 [环境] [操作]"
    log_info "环境: dev, test, prod"
    log_info "操作: build, start, stop, restart, logs, clean, backup, restore"
    exit 1
fi

ENVIRONMENT=$1
ACTION=$2

# 验证环境参数
if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
    log_error "无效的环境参数: $ENVIRONMENT"
    log_info "支持的环境: dev, test, prod"
    exit 1
fi

# 验证操作参数
if [[ ! "$ACTION" =~ ^(build|start|stop|restart|logs|clean|backup|restore)$ ]]; then
    log_error "无效的操作参数: $ACTION"
    log_info "支持的操作: build, start, stop, restart, logs, clean, backup, restore"
    exit 1
fi

# 设置环境变量
case $ENVIRONMENT in
    "dev")
        COMPOSE_FILE="docker-compose.yml"
        SPRING_PROFILE="dev"
        ;;
    "test")
        COMPOSE_FILE="docker-compose.test.yml"
        SPRING_PROFILE="test"
        ;;
    "prod")
        COMPOSE_FILE="docker-compose.prod.yml"
        SPRING_PROFILE="prod"
        ;;
esac

# 检查Docker和Docker Compose
check_dependencies() {
    log_info "检查依赖..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装或不在PATH中"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装或不在PATH中"
        exit 1
    fi
    
    log_success "依赖检查通过"
}

# 构建应用
build_app() {
    log_info "构建应用镜像..."
    
    # 清理旧的构建文件
    if [ -d "target" ]; then
        rm -rf target
    fi
    
    # Maven构建
    log_info "执行Maven构建..."
    ./mvnw clean package -DskipTests
    
    # Docker构建
    log_info "构建Docker镜像..."
    docker build -t ai-english-learning:latest .
    docker build -t ai-english-learning:$ENVIRONMENT .
    
    log_success "应用构建完成"
}

# 启动服务
start_services() {
    log_info "启动$ENVIRONMENT环境服务..."
    
    export SPRING_PROFILES_ACTIVE=$SPRING_PROFILE
    
    if [ "$ENVIRONMENT" = "prod" ]; then
        docker-compose -f $COMPOSE_FILE --profile production up -d
    else
        docker-compose -f $COMPOSE_FILE up -d
    fi
    
    log_success "服务启动完成"
    
    # 等待服务就绪
    log_info "等待服务就绪..."
    sleep 30
    
    # 健康检查
    check_health
}

# 停止服务
stop_services() {
    log_info "停止$ENVIRONMENT环境服务..."
    
    if [ "$ENVIRONMENT" = "prod" ]; then
        docker-compose -f $COMPOSE_FILE --profile production down
    else
        docker-compose -f $COMPOSE_FILE down
    fi
    
    log_success "服务停止完成"
}

# 重启服务
restart_services() {
    log_info "重启$ENVIRONMENT环境服务..."
    stop_services
    start_services
}

# 查看日志
view_logs() {
    log_info "查看$ENVIRONMENT环境日志..."
    
    if [ "$ENVIRONMENT" = "prod" ]; then
        docker-compose -f $COMPOSE_FILE --profile production logs -f
    else
        docker-compose -f $COMPOSE_FILE logs -f
    fi
}

# 清理资源
clean_resources() {
    log_warning "清理$ENVIRONMENT环境资源..."
    
    # 停止并删除容器
    if [ "$ENVIRONMENT" = "prod" ]; then
        docker-compose -f $COMPOSE_FILE --profile production down -v
    else
        docker-compose -f $COMPOSE_FILE down -v
    fi
    
    # 删除未使用的镜像
    docker image prune -f
    
    # 删除未使用的卷
    docker volume prune -f
    
    log_success "资源清理完成"
}

# 健康检查
check_health() {
    log_info "执行健康检查..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8080/actuator/health &> /dev/null; then
            log_success "应用健康检查通过"
            return 0
        fi
        
        log_info "健康检查失败，重试中... ($attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done
    
    log_error "应用健康检查失败"
    return 1
}

# 数据库备份
backup_database() {
    log_info "备份数据库..."
    
    local backup_dir="backups"
    local backup_file="$backup_dir/backup_$(date +%Y%m%d_%H%M%S).sql"
    
    mkdir -p $backup_dir
    
    docker-compose -f $COMPOSE_FILE exec mysql mysqldump -u root -prootpassword ai_english_learning > $backup_file
    
    if [ $? -eq 0 ]; then
        log_success "数据库备份完成: $backup_file"
    else
        log_error "数据库备份失败"
        return 1
    fi
}

# 数据库恢复
restore_database() {
    log_warning "恢复数据库..."
    
    local backup_dir="backups"
    
    if [ ! -d "$backup_dir" ]; then
        log_error "备份目录不存在: $backup_dir"
        return 1
    fi
    
    # 列出可用的备份文件
    log_info "可用的备份文件:"
    ls -la $backup_dir/*.sql 2>/dev/null || {
        log_error "没有找到备份文件"
        return 1
    }
    
    read -p "请输入要恢复的备份文件名: " backup_file
    
    if [ ! -f "$backup_dir/$backup_file" ]; then
        log_error "备份文件不存在: $backup_dir/$backup_file"
        return 1
    fi
    
    docker-compose -f $COMPOSE_FILE exec -T mysql mysql -u root -prootpassword ai_english_learning < "$backup_dir/$backup_file"
    
    if [ $? -eq 0 ]; then
        log_success "数据库恢复完成"
    else
        log_error "数据库恢复失败"
        return 1
    fi
}

# 主逻辑
main() {
    log_info "开始执行部署操作: $ACTION (环境: $ENVIRONMENT)"
    
    check_dependencies
    
    case $ACTION in
        "build")
            build_app
            ;;
        "start")
            start_services
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "logs")
            view_logs
            ;;
        "clean")
            clean_resources
            ;;
        "backup")
            backup_database
            ;;
        "restore")
            restore_database
            ;;
    esac
    
    log_success "部署操作完成: $ACTION"
}

# 执行主函数
main