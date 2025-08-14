#!/bin/bash

# AI图像处理平台 - 服务器部署脚本
# 适用于生产环境，使用Nginx 80端口

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
NGINX_CONF_DIR="/etc/nginx/conf.d"
NGINX_MAIN_CONF="/etc/nginx/nginx.conf"

# 默认配置
BACKEND_PORT=${BACKEND_PORT:-5002}
FRONTEND_PORT=${FRONTEND_PORT:-80}
WORKERS=${WORKERS:-4}
ENVIRONMENT=${ENVIRONMENT:-production}
DOMAIN=${DOMAIN:-localhost}

# 创建必要的目录
create_directories() {
    log_info "创建必要的目录..."
    mkdir -p "$LOG_DIR" "$PID_DIR"
    mkdir -p "$BACKEND_DIR/static/uploads"
    mkdir -p "$FRONTEND_DIR/dist"
    mkdir -p "$PROJECT_DIR/nginx"
    
    # 创建Nginx配置目录
    sudo mkdir -p "$NGINX_CONF_DIR"
    sudo mkdir -p /var/log/nginx
}

# 检查系统依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查是否为root用户或sudo权限
    if [ "$EUID" -ne 0 ] && ! sudo -n true 2>/dev/null; then
        log_error "需要sudo权限来安装和配置服务"
        exit 1
    fi
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        log_info "安装Python3..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip python3-venv
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3 python3-pip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip
        else
            log_error "无法自动安装Python3，请手动安装"
            exit 1
        fi
    fi
    
    # 检查pip
    if ! command -v pip3 &> /dev/null; then
        log_info "安装pip3..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y python3-pip
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3-pip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3-pip
        fi
    fi
    
    # 安装Nginx
    if ! command -v nginx &> /dev/null; then
        log_info "安装Nginx..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y nginx
        elif command -v yum &> /dev/null; then
            sudo yum install -y nginx
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y nginx
        fi
    fi
    
    # 安装其他必要工具
    if ! command -v curl &> /dev/null; then
        log_info "安装curl..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y curl
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl
        fi
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
    
    # 安装gunicorn（如果不在requirements.txt中）
    pip install gunicorn
    
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
        # 如果没有构建，复制现有的public目录
        if [ -d "$FRONTEND_DIR/public" ]; then
            cp -r "$FRONTEND_DIR/public" "$FRONTEND_DIR/dist"
            log_info "复制现有前端文件到dist目录"
        fi
    fi
}

# 配置Nginx
configure_nginx() {
    log_info "配置Nginx..."
    
    # 创建Nginx配置文件
    cat > "$PROJECT_DIR/nginx/ai_image_platform.conf" << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    # 日志配置
    access_log /var/log/nginx/ai_image_access.log;
    error_log /var/log/nginx/ai_image_error.log;
    
    # 前端静态文件
    root $FRONTEND_DIR/dist;
    index index.html index.htm;
    
    # 上传文件大小限制
    client_max_body_size 100M;
    
    # 静态文件缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # HTML文件不缓存
    location ~* \.html$ {
        expires -1;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
    }
    
    # API代理到后端
    location /api/ {
        proxy_pass http://127.0.0.1:$BACKEND_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # 处理大文件上传
        proxy_request_buffering off;
        proxy_buffering off;
    }
    
    # 静态文件服务（图片等）
    location /static/ {
        alias $BACKEND_DIR/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # 图片文件特殊处理
        location ~* \.(jpg|jpeg|png|gif|webp)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
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
    
    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
EOF
    
    # 复制配置文件到Nginx目录
    sudo cp "$PROJECT_DIR/nginx/ai_image_platform.conf" "$NGINX_CONF_DIR/"
    
    # 测试Nginx配置
    if sudo nginx -t; then
        log_success "Nginx配置完成"
    else
        log_error "Nginx配置测试失败"
        exit 1
    fi
}

# 创建systemd服务文件
create_systemd_services() {
    log_info "创建systemd服务文件..."
    
    # 创建后端服务文件
    cat > "$PROJECT_DIR/ai_image_backend.service" << EOF
[Unit]
Description=AI Image Platform Backend
After=network.target

[Service]
Type=fork
User=$USER
Group=$USER
WorkingDirectory=$BACKEND_DIR
Environment=PATH=$BACKEND_DIR/venv/bin
ExecStart=$BACKEND_DIR/venv/bin/gunicorn -w $WORKERS -b 127.0.0.1:$BACKEND_PORT --pid $PID_DIR/backend.pid --access-logfile $LOG_DIR/backend_access.log --error-logfile $LOG_DIR/backend_error.log --log-level info --daemon run:app
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    
    # 复制服务文件到systemd目录
    sudo cp "$PROJECT_DIR/ai_image_backend.service" /etc/systemd/system/
    
    # 重新加载systemd
    sudo systemctl daemon-reload
    
    log_success "systemd服务文件创建完成"
}

# 启动后端服务
start_backend() {
    log_info "启动后端服务..."
    
    # 启用并启动服务
    sudo systemctl enable ai_image_backend
    sudo systemctl start ai_image_backend
    
    # 等待服务启动
    sleep 5
    
    # 检查服务状态
    if sudo systemctl is-active --quiet ai_image_backend; then
        log_success "后端服务启动成功 (端口: $BACKEND_PORT)"
    else
        log_error "后端服务启动失败"
        sudo systemctl status ai_image_backend
        exit 1
    fi
}

# 启动Nginx服务
start_nginx() {
    log_info "启动Nginx服务..."
    
    # 启用并启动Nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    
    # 等待服务启动
    sleep 3
    
    # 检查服务状态
    if sudo systemctl is-active --quiet nginx; then
        log_success "Nginx服务启动成功 (端口: $FRONTEND_PORT)"
    else
        log_error "Nginx服务启动失败"
        sudo systemctl status nginx
        exit 1
    fi
}

# 配置防火墙
configure_firewall() {
    log_info "配置防火墙..."
    
    # 检查防火墙类型
    if command -v ufw &> /dev/null; then
        # Ubuntu/Debian UFW
        sudo ufw allow 80/tcp
        sudo ufw allow 22/tcp
        log_success "UFW防火墙配置完成"
    elif command -v firewall-cmd &> /dev/null; then
        # CentOS/RHEL firewalld
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --reload
        log_success "firewalld防火墙配置完成"
    else
        log_warning "未检测到防火墙，跳过配置"
    fi
}

# 显示服务状态
show_status() {
    log_info "服务状态检查..."
    
    echo "==========================================="
    echo "AI图像处理平台部署完成"
    echo "==========================================="
    echo "前端地址: http://$DOMAIN"
    echo "后端API: http://$DOMAIN/api"
    echo "日志目录: $LOG_DIR"
    echo "PID目录: $PID_DIR"
    echo "==========================================="
    
    # 检查服务状态
    echo "后端服务状态:"
    sudo systemctl status ai_image_backend --no-pager -l
    
    echo ""
    echo "Nginx服务状态:"
    sudo systemctl status nginx --no-pager -l
    
    echo "==========================================="
    echo "管理命令:"
    echo "  查看后端日志: sudo journalctl -u ai_image_backend -f"
    echo "  查看Nginx日志: sudo tail -f /var/log/nginx/ai_image_*.log"
    echo "  重启后端: sudo systemctl restart ai_image_backend"
    echo "  重启Nginx: sudo systemctl restart nginx"
    echo "  查看状态: ./deploy-server.sh status"
    echo "==========================================="
}

# 停止所有服务
stop_services() {
    log_info "停止所有服务..."
    
    # 停止后端服务
    if sudo systemctl is-active --quiet ai_image_backend; then
        sudo systemctl stop ai_image_backend
        sudo systemctl disable ai_image_backend
        log_success "后端服务已停止"
    fi
    
    # 停止Nginx服务
    if sudo systemctl is-active --quiet nginx; then
        sudo systemctl stop nginx
        sudo systemctl disable nginx
        log_success "Nginx服务已停止"
    fi
}

# 卸载服务
uninstall_services() {
    log_info "卸载服务..."
    
    # 停止服务
    stop_services
    
    # 删除服务文件
    sudo rm -f /etc/systemd/system/ai_image_backend.service
    sudo rm -f "$NGINX_CONF_DIR/ai_image_platform.conf"
    
    # 重新加载systemd
    sudo systemctl daemon-reload
    
    log_success "服务卸载完成"
}

# 主函数
main() {
    case "${1:-start}" in
        "start")
            log_info "开始部署AI图像处理平台到服务器..."
            create_directories
            check_dependencies
            install_python_dependencies
            init_database
            build_frontend
            configure_nginx
            create_systemd_services
            start_backend
            start_nginx
            configure_firewall
            show_status
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            stop_services
            sleep 2
            start_backend
            start_nginx
            show_status
            ;;
        "status")
            show_status
            ;;
        "uninstall")
            uninstall_services
            ;;
        "help")
            echo "用法: $0 [start|stop|restart|status|uninstall|help]"
            echo "  start     - 启动所有服务（默认）"
            echo "  stop      - 停止所有服务"
            echo "  restart   - 重启所有服务"
            echo "  status    - 查看服务状态"
            echo "  uninstall - 卸载所有服务"
            echo "  help      - 显示帮助信息"
            echo ""
            echo "环境变量:"
            echo "  BACKEND_PORT  - 后端端口 (默认: 5002)"
            echo "  FRONTEND_PORT - 前端端口 (默认: 80)"
            echo "  WORKERS       - 工作进程数 (默认: 4)"
            echo "  ENVIRONMENT   - 环境 (默认: production)"
            echo "  DOMAIN        - 域名 (默认: localhost)"
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
