#!/bin/bash

# AI图像处理平台Docker一键部署脚本
# 使用Docker Compose进行容器化部署

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 项目目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查Docker和Docker Compose
check_docker() {
    log_info "检查Docker环境..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    # 检查Docker是否运行
    if ! docker info &> /dev/null; then
        log_error "Docker服务未运行，请启动Docker"
        exit 1
    fi
    
    log_success "Docker环境检查完成"
}

# 创建环境配置文件
create_env_file() {
    log_info "创建环境配置文件..."
    
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        cat > "$PROJECT_DIR/.env" << EOF
# 数据库配置
DATABASE_URL=sqlite:///app.db
SECRET_KEY=your-secret-key-change-in-production

# 服务端口
BACKEND_PORT=5002
FRONTEND_PORT=8080

# AI服务配置
QWEN_API_KEY=your-qwen-api-key
QWEN_VL_API_KEY=your-qwen-vl-api-key

# 文件上传配置
MAX_CONTENT_LENGTH=104857600
UPLOAD_FOLDER=static/uploads

# 日志配置
LOG_LEVEL=INFO
EOF
        log_success "环境配置文件已创建: .env"
        log_warning "请编辑 .env 文件，配置您的API密钥和其他设置"
    else
        log_info "环境配置文件已存在"
    fi
}

# 更新Docker Compose配置
update_docker_compose() {
    log_info "更新Docker Compose配置..."
    
    cat > "$PROJECT_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ai_platform_backend
    restart: unless-stopped
    ports:
      - "${BACKEND_PORT:-5002}:5000"
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - SECRET_KEY=${SECRET_KEY}
      - QWEN_API_KEY=${QWEN_API_KEY}
      - QWEN_VL_API_KEY=${QWEN_VL_API_KEY}
      - MAX_CONTENT_LENGTH=${MAX_CONTENT_LENGTH}
      - UPLOAD_FOLDER=${UPLOAD_FOLDER}
      - LOG_LEVEL=${LOG_LEVEL}
    volumes:
      - ./backend/static/uploads:/app/static/uploads
      - ./logs:/app/logs
    networks:
      - ai_platform_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ai_platform_frontend
    restart: unless-stopped
    ports:
      - "${FRONTEND_PORT:-8080}:80"
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - ai_platform_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    container_name: ai_platform_nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
    depends_on:
      - frontend
      - backend
    networks:
      - ai_platform_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  ai_platform_network:
    driver: bridge

volumes:
  uploads:
  logs:
EOF
    
    log_success "Docker Compose配置已更新"
}

# 创建Nginx配置
create_nginx_config() {
    log_info "创建Nginx配置..."
    
    mkdir -p "$PROJECT_DIR/nginx"
    
    cat > "$PROJECT_DIR/nginx/nginx.conf" << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # 日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    # 基本设置
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json
        image/svg+xml;

    # 上传文件大小限制
    client_max_body_size 100M;
    client_body_timeout 60s;
    client_header_timeout 60s;

    # 上游服务器
    upstream backend {
        server ai_platform_backend:5000;
        keepalive 32;
    }

    upstream frontend {
        server ai_platform_frontend:80;
        keepalive 32;
    }

    # 主服务器配置
    server {
        listen 80;
        server_name _;

        # 安全头
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

        # API代理
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
            proxy_buffering off;
        }

        # 静态文件代理
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # 健康检查
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }

    # HTTPS配置（可选）
    # server {
    #     listen 443 ssl http2;
    #     server_name your-domain.com;
    #
    #     ssl_certificate /etc/nginx/ssl/cert.pem;
    #     ssl_certificate_key /etc/nginx/ssl/key.pem;
    #     ssl_session_timeout 1d;
    #     ssl_session_cache shared:MozTLS:10m;
    #     ssl_session_tickets off;
    #
    #     ssl_protocols TLSv1.2 TLSv1.3;
    #     ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    #     ssl_prefer_server_ciphers off;
    #
    #     # HSTS
    #     add_header Strict-Transport-Security "max-age=63072000" always;
    #
    #     # 其他配置与HTTP相同...
    # }
}
EOF
    
    log_success "Nginx配置已创建"
}

# 构建和启动服务
start_services() {
    log_info "构建和启动服务..."
    
    cd "$PROJECT_DIR"
    
    # 停止现有服务
    docker-compose down 2>/dev/null || true
    
    # 构建镜像
    log_info "构建Docker镜像..."
    docker-compose build --no-cache
    
    # 启动服务
    log_info "启动服务..."
    docker-compose up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    check_services_health
}

# 检查服务健康状态
check_services_health() {
    log_info "检查服务健康状态..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "健康检查尝试 $attempt/$max_attempts"
        
        # 检查后端
        if curl -f "http://localhost:${BACKEND_PORT:-5002}/api/health" > /dev/null 2>&1; then
            log_success "后端服务健康"
            backend_healthy=true
        else
            backend_healthy=false
        fi
        
        # 检查前端
        if curl -f "http://localhost:${FRONTEND_PORT:-8080}" > /dev/null 2>&1; then
            log_success "前端服务健康"
            frontend_healthy=true
        else
            frontend_healthy=false
        fi
        
        # 检查Nginx
        if curl -f "http://localhost:80/health" > /dev/null 2>&1; then
            log_success "Nginx服务健康"
            nginx_healthy=true
        else
            nginx_healthy=false
        fi
        
        if [ "$backend_healthy" = true ] && [ "$frontend_healthy" = true ] && [ "$nginx_healthy" = true ]; then
            log_success "所有服务健康检查通过"
            return 0
        fi
        
        sleep 5
        ((attempt++))
    done
    
    log_error "服务健康检查失败，请查看日志"
    docker-compose logs
    return 1
}

# 停止服务
stop_services() {
    log_info "停止所有服务..."
    cd "$PROJECT_DIR"
    docker-compose down
    log_success "所有服务已停止"
}

# 重启服务
restart_services() {
    log_info "重启所有服务..."
    cd "$PROJECT_DIR"
    docker-compose restart
    sleep 5
    check_services_health
}

# 查看服务状态
show_status() {
    log_info "服务状态..."
    cd "$PROJECT_DIR"
    
    echo "==========================================="
    echo "AI图像处理平台 - Docker部署状态"
    echo "==========================================="
    
    docker-compose ps
    
    echo ""
    echo "服务地址:"
    echo "  主站点: http://localhost:80"
    echo "  前端: http://localhost:${FRONTEND_PORT:-8080}"
    echo "  后端API: http://localhost:${BACKEND_PORT:-5002}/api"
    echo "  健康检查: http://localhost:80/health"
    echo ""
    echo "管理命令:"
    echo "  查看日志: docker-compose logs -f [service]"
    echo "  进入容器: docker-compose exec [service] /bin/bash"
    echo "  停止服务: ./docker-deploy.sh stop"
    echo "  重启服务: ./docker-deploy.sh restart"
    echo "==========================================="
}

# 查看日志
show_logs() {
    cd "$PROJECT_DIR"
    if [ -n "$2" ]; then
        docker-compose logs -f "$2"
    else
        docker-compose logs -f
    fi
}

# 清理资源
cleanup() {
    log_info "清理Docker资源..."
    cd "$PROJECT_DIR"
    
    # 停止并删除容器
    docker-compose down -v
    
    # 删除镜像
    docker-compose down --rmi all
    
    # 清理未使用的资源
    docker system prune -f
    
    log_success "清理完成"
}

# 主函数
main() {
    case "${1:-start}" in
        "start")
            log_info "开始Docker部署..."
            check_docker
            create_env_file
            update_docker_compose
            create_nginx_config
            start_services
            show_status
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            show_status
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "$@"
            ;;
        "cleanup")
            cleanup
            ;;
        "help")
            echo "用法: $0 [start|stop|restart|status|logs|cleanup|help]"
            echo "  start   - 构建并启动所有服务（默认）"
            echo "  stop    - 停止所有服务"
            echo "  restart - 重启所有服务"
            echo "  status  - 查看服务状态"
            echo "  logs    - 查看日志 (可指定服务名)"
            echo "  cleanup - 清理所有Docker资源"
            echo "  help    - 显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0 start          # 启动所有服务"
            echo "  $0 logs backend   # 查看后端日志"
            echo "  $0 logs frontend  # 查看前端日志"
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