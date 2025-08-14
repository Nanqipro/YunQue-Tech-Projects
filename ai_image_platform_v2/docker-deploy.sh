#!/bin/bash

# AI图像处理平台 - Docker部署脚本
# 使用Nginx 80端口

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 检查Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    log_success "Docker环境检查通过"
}

# 创建生产环境配置
create_production_config() {
    log_info "创建生产环境配置..."
    
    # 创建生产环境docker-compose文件
    cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  # 后端API服务
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ai_image_backend
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=sqlite:///app.db
      - JWT_SECRET_KEY=your-super-secret-jwt-key-change-in-production
      - UPLOAD_FOLDER=/app/static/uploads
    volumes:
      - ./backend/static:/app/static
      - ./backend/logs:/app/logs
      - ./backend/instance:/app/instance
    networks:
      - ai_image_network
    restart: unless-stopped
    healthcheck:
              test: ["CMD", "curl", "-f", "http://localhost:5002/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 前端Web服务
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ai_image_frontend
    environment:
      - REACT_APP_API_URL=http://localhost/api
    depends_on:
      - backend
    networks:
      - ai_image_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx反向代理
  nginx:
    image: nginx:alpine
    container_name: ai_image_nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./backend/static:/var/www/static
    depends_on:
      - frontend
      - backend
    networks:
      - ai_image_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  ai_image_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF

    # 创建Nginx配置
    mkdir -p nginx/conf.d
    
    cat > nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # 上传文件大小限制
    client_max_body_size 100M;

    include /etc/nginx/conf.d/*.conf;
}
EOF

    cat > nginx/conf.d/ai_image_platform.conf << 'EOF'
server {
    listen 80;
    server_name _;
    
    # 前端静态文件
    location / {
        proxy_pass http://frontend:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # API代理到后端
    location /api/ {
        proxy_pass http://backend:5002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # 处理大文件上传
        proxy_request_buffering off;
        proxy_buffering off;
    }
    
    # 静态文件服务
    location /static/ {
        alias /var/www/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

    log_success "生产环境配置创建完成"
}

# 构建和启动服务
deploy_services() {
    log_info "构建和启动服务..."
    
    # 停止现有服务
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    # 构建镜像
    log_info "构建Docker镜像..."
    docker-compose -f docker-compose.prod.yml build
    
    # 启动服务
    log_info "启动服务..."
    docker-compose -f docker-compose.prod.yml up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        log_success "服务启动成功"
    else
        log_error "服务启动失败"
        docker-compose -f docker-compose.prod.yml logs
        exit 1
    fi
}

# 显示状态
show_status() {
    log_info "服务状态:"
    docker-compose -f docker-compose.prod.yml ps
    
    echo ""
    echo "==========================================="
    echo "AI图像处理平台部署完成"
    echo "==========================================="
    echo "前端地址: http://localhost"
    echo "后端API: http://localhost/api"
    echo "健康检查: http://localhost/api/health"
    echo "==========================================="
    echo "管理命令:"
    echo "  查看状态: ./docker-deploy.sh status"
    echo "  查看日志: ./docker-deploy.sh logs"
    echo "  停止服务: ./docker-deploy.sh stop"
    echo "  重启服务: ./docker-deploy.sh restart"
    echo "==========================================="
}

# 查看日志
show_logs() {
    log_info "显示服务日志..."
    docker-compose -f docker-compose.prod.yml logs -f
}

# 停止服务
stop_services() {
    log_info "停止服务..."
    docker-compose -f docker-compose.prod.yml down
    log_success "服务已停止"
}

# 重启服务
restart_services() {
    log_info "重启服务..."
    docker-compose -f docker-compose.prod.yml restart
    log_success "服务已重启"
}

# 清理资源
cleanup() {
    log_info "清理Docker资源..."
    docker-compose -f docker-compose.prod.yml down -v --remove-orphans
    docker system prune -f
    log_success "清理完成"
}

# 主函数
main() {
    case "${1:-start}" in
        "start")
            log_info "开始Docker部署..."
            check_docker
            create_production_config
            deploy_services
            show_status
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "status")
            docker-compose -f docker-compose.prod.yml ps
            ;;
        "logs")
            show_logs
            ;;
        "cleanup")
            cleanup
            ;;
        "help")
            echo "用法: $0 [start|stop|restart|status|logs|cleanup|help]"
            echo "  start   - 启动所有服务（默认）"
            echo "  stop    - 停止所有服务"
            echo "  restart - 重启所有服务"
            echo "  status  - 查看服务状态"
            echo "  logs    - 查看服务日志"
            echo "  cleanup - 清理Docker资源"
            echo "  help    - 显示帮助信息"
            ;;
        *)
            log_error "未知命令: $1"
            echo "使用 '$0 help' 查看帮助信息"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"