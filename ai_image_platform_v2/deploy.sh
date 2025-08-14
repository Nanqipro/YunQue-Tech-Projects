#!/bin/bash

# AI图像处理平台一键部署脚本
# 适用于生产环境部署

set -e  # 遇到错误立即退出

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

# 配置变量
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"
LOG_DIR="$PROJECT_DIR/logs"
PID_DIR="$PROJECT_DIR/pids"

# 默认配置
BACKEND_PORT=${BACKEND_PORT:-5002}
FRONTEND_PORT=${FRONTEND_PORT:-8080}
WORKERS=${WORKERS:-4}
ENVIRONMENT=${ENVIRONMENT:-production}

# 创建必要的目录
create_directories() {
    log_info "创建必要的目录..."
    mkdir -p "$LOG_DIR" "$PID_DIR"
    mkdir -p "$BACKEND_DIR/static/uploads"
    mkdir -p "$FRONTEND_DIR/dist"
}

# 检查系统依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装，请先安装 Python 3.8+"
        exit 1
    fi
    
    # 检查pip
    if ! command -v pip3 &> /dev/null; then
        log_error "pip3 未安装，请先安装 pip"
        exit 1
    fi
    
    # 检查nginx
    if ! command -v nginx &> /dev/null; then
        log_warning "Nginx 未安装，将使用内置服务器"
        USE_NGINX=false
    else
        USE_NGINX=true
    fi
    
    # 检查Node.js (可选，用于前端构建)
    if ! command -v node &> /dev/null; then
        log_warning "Node.js 未安装，跳过前端构建步骤"
        USE_NODE=false
    else
        USE_NODE=true
    fi
    
    log_success "依赖检查完成"
}

# 安装Python依赖
install_python_dependencies() {
    log_info "安装Python依赖..."
    cd "$BACKEND_DIR"
    
    # 创建虚拟环境（如果不存在）
    if [ ! -d "venv" ]; then
        log_info "创建Python虚拟环境..."
        python3 -m venv venv
    fi
    
    # 激活虚拟环境
    source venv/bin/activate
    
    # 升级pip
    pip install --upgrade pip
    
    # 安装依赖
    pip install -r requirements.txt
    
    log_success "Python依赖安装完成"
}

# 初始化数据库
init_database() {
    log_info "初始化数据库..."
    cd "$BACKEND_DIR"
    source venv/bin/activate
    
    # 初始化数据库
    python run.py --init-db
    
    log_success "数据库初始化完成"
}

# 构建前端（如果有Node.js）
build_frontend() {
    if [ "$USE_NODE" = true ]; then
        log_info "构建前端应用..."
        cd "$FRONTEND_DIR"
        
        # 安装依赖
        if [ -f "package.json" ]; then
            npm install
            npm run build
        fi
        
        log_success "前端构建完成"
    else
        log_info "跳过前端构建（Node.js未安装）"
    fi
}

# 配置Nginx
configure_nginx() {
    if [ "$USE_NGINX" = true ]; then
        log_info "配置Nginx..."
        
        # 创建Nginx配置
        cat > "$PROJECT_DIR/nginx-production.conf" << EOF
user nginx;
worker_processes auto;
error_log $LOG_DIR/nginx_error.log;
pid $PID_DIR/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log $LOG_DIR/nginx_access.log main;

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

    server {
        listen $FRONTEND_PORT;
        server_name _;
        
        root $FRONTEND_DIR/dist;
        index index.html index.htm;

        # API代理
        location /api/ {
            proxy_pass http://127.0.0.1:$BACKEND_PORT;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }

        # 静态文件缓存
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            access_log off;
        }

        # HTML文件不缓存
        location ~* \.html\$ {
            expires -1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
        }

        # 主页面路由
        location / {
            try_files \$uri \$uri/ /index.html;
            expires -1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
        }

        # 错误页面
        error_page 404 /index.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
}
EOF
        
        log_success "Nginx配置完成"
    fi
}

# 启动后端服务
start_backend() {
    log_info "启动后端服务..."
    cd "$BACKEND_DIR"
    source venv/bin/activate
    
    # 停止现有进程
    if [ -f "$PID_DIR/backend.pid" ]; then
        OLD_PID=$(cat "$PID_DIR/backend.pid")
        if kill -0 "$OLD_PID" 2>/dev/null; then
            log_info "停止现有后端进程 (PID: $OLD_PID)"
            kill "$OLD_PID"
            sleep 2
        fi
    fi
    
    # 启动Gunicorn
    gunicorn -w "$WORKERS" \
             -b "127.0.0.1:$BACKEND_PORT" \
             --pid "$PID_DIR/backend.pid" \
             --access-logfile "$LOG_DIR/backend_access.log" \
             --error-logfile "$LOG_DIR/backend_error.log" \
             --log-level info \
             --daemon \
             "run:app"
    
    # 等待服务启动
    sleep 3
    
    # 检查服务状态
    if curl -f "http://127.0.0.1:$BACKEND_PORT/api/health" > /dev/null 2>&1; then
        log_success "后端服务启动成功 (端口: $BACKEND_PORT)"
    else
        log_error "后端服务启动失败"
        exit 1
    fi
}

# 启动前端服务
start_frontend() {
    if [ "$USE_NGINX" = true ]; then
        log_info "启动Nginx前端服务..."
        
        # 停止现有Nginx进程
        if [ -f "$PID_DIR/nginx.pid" ]; then
            OLD_PID=$(cat "$PID_DIR/nginx.pid")
            if kill -0 "$OLD_PID" 2>/dev/null; then
                log_info "停止现有Nginx进程 (PID: $OLD_PID)"
                kill "$OLD_PID"
                sleep 2
            fi
        fi
        
        # 启动Nginx
        nginx -c "$PROJECT_DIR/nginx-production.conf"
        
        # 检查服务状态
        sleep 2
        if curl -f "http://127.0.0.1:$FRONTEND_PORT" > /dev/null 2>&1; then
            log_success "前端服务启动成功 (端口: $FRONTEND_PORT)"
        else
            log_error "前端服务启动失败"
            exit 1
        fi
    else
        log_info "使用内置服务器提供前端服务..."
        cd "$FRONTEND_DIR"
        
        # 停止现有进程
        if [ -f "$PID_DIR/frontend.pid" ]; then
            OLD_PID=$(cat "$PID_DIR/frontend.pid")
            if kill -0 "$OLD_PID" 2>/dev/null; then
                log_info "停止现有前端进程 (PID: $OLD_PID)"
                kill "$OLD_PID"
                sleep 2
            fi
        fi
        
        # 使用Python内置服务器
        cd dist
        python3 -m http.server "$FRONTEND_PORT" > "$LOG_DIR/frontend.log" 2>&1 &
        echo $! > "$PID_DIR/frontend.pid"
        
        sleep 2
        log_success "前端服务启动成功 (端口: $FRONTEND_PORT)"
    fi
}

# 显示服务状态
show_status() {
    log_info "服务状态检查..."
    
    echo "==========================================="
    echo "AI图像处理平台部署完成"
    echo "==========================================="
    echo "前端地址: http://localhost:$FRONTEND_PORT"
    echo "后端API: http://localhost:$BACKEND_PORT/api"
    echo "日志目录: $LOG_DIR"
    echo "PID目录: $PID_DIR"
    echo "==========================================="
    
    # 检查进程状态
    if [ -f "$PID_DIR/backend.pid" ]; then
        BACKEND_PID=$(cat "$PID_DIR/backend.pid")
        if kill -0 "$BACKEND_PID" 2>/dev/null; then
            echo "后端服务: 运行中 (PID: $BACKEND_PID)"
        else
            echo "后端服务: 已停止"
        fi
    fi
    
    if [ -f "$PID_DIR/nginx.pid" ]; then
        NGINX_PID=$(cat "$PID_DIR/nginx.pid")
        if kill -0 "$NGINX_PID" 2>/dev/null; then
            echo "Nginx服务: 运行中 (PID: $NGINX_PID)"
        else
            echo "Nginx服务: 已停止"
        fi
    elif [ -f "$PID_DIR/frontend.pid" ]; then
        FRONTEND_PID=$(cat "$PID_DIR/frontend.pid")
        if kill -0 "$FRONTEND_PID" 2>/dev/null; then
            echo "前端服务: 运行中 (PID: $FRONTEND_PID)"
        else
            echo "前端服务: 已停止"
        fi
    fi
    
    echo "==========================================="
    echo "管理命令:"
    echo "  查看日志: tail -f $LOG_DIR/*.log"
    echo "  停止服务: ./deploy.sh stop"
    echo "  重启服务: ./deploy.sh restart"
    echo "  查看状态: ./deploy.sh status"
    echo "==========================================="
}

# 停止所有服务
stop_services() {
    log_info "停止所有服务..."
    
    # 停止后端
    if [ -f "$PID_DIR/backend.pid" ]; then
        BACKEND_PID=$(cat "$PID_DIR/backend.pid")
        if kill -0 "$BACKEND_PID" 2>/dev/null; then
            log_info "停止后端服务 (PID: $BACKEND_PID)"
            kill "$BACKEND_PID"
        fi
        rm -f "$PID_DIR/backend.pid"
    fi
    
    # 停止Nginx
    if [ -f "$PID_DIR/nginx.pid" ]; then
        NGINX_PID=$(cat "$PID_DIR/nginx.pid")
        if kill -0 "$NGINX_PID" 2>/dev/null; then
            log_info "停止Nginx服务 (PID: $NGINX_PID)"
            kill "$NGINX_PID"
        fi
        rm -f "$PID_DIR/nginx.pid"
    fi
    
    # 停止前端
    if [ -f "$PID_DIR/frontend.pid" ]; then
        FRONTEND_PID=$(cat "$PID_DIR/frontend.pid")
        if kill -0 "$FRONTEND_PID" 2>/dev/null; then
            log_info "停止前端服务 (PID: $FRONTEND_PID)"
            kill "$FRONTEND_PID"
        fi
        rm -f "$PID_DIR/frontend.pid"
    fi
    
    log_success "所有服务已停止"
}

# 主函数
main() {
    case "${1:-start}" in
        "start")
            log_info "开始部署AI图像处理平台..."
            create_directories
            check_dependencies
            install_python_dependencies
            init_database
            build_frontend
            configure_nginx
            start_backend
            start_frontend
            show_status
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            stop_services
            sleep 2
            start_backend
            start_frontend
            show_status
            ;;
        "status")
            show_status
            ;;
        "help")
            echo "用法: $0 [start|stop|restart|status|help]"
            echo "  start   - 启动所有服务（默认）"
            echo "  stop    - 停止所有服务"
            echo "  restart - 重启所有服务"
            echo "  status  - 查看服务状态"
            echo "  help    - 显示帮助信息"
            echo ""
            echo "环境变量:"
            echo "  BACKEND_PORT  - 后端端口 (默认: 5002)"
            echo "  FRONTEND_PORT - 前端端口 (默认: 8080)"
            echo "  WORKERS       - 工作进程数 (默认: 4)"
            echo "  ENVIRONMENT   - 环境 (默认: production)"
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