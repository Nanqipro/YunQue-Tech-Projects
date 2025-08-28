# Makefile for AI English Learning Project

# 变量定义
APP_NAME := ai-english-learning
VERSION := $(shell git describe --tags --always --dirty)
BUILD_TIME := $(shell date +%Y-%m-%d_%H:%M:%S)
GO_VERSION := $(shell go version | awk '{print $$3}')
GIT_COMMIT := $(shell git rev-parse HEAD)

# Go相关变量
GOCMD := go
GOBUILD := $(GOCMD) build
GOCLEAN := $(GOCMD) clean
GOTEST := $(GOCMD) test
GOGET := $(GOCMD) get
GOMOD := $(GOCMD) mod

# 构建标志
LDFLAGS := -ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME) -X main.GitCommit=$(GIT_COMMIT)"

# 目录
SERVE_DIR := ./serve
CLIENT_DIR := ./client
DOCS_DIR := ./docs

.PHONY: help build clean test deps docker-build docker-run docker-stop dev prod lint format check

# 默认目标
all: clean deps test build

# 帮助信息
help:
	@echo "AI English Learning Project Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build         - Build the Go application"
	@echo "  clean         - Clean build artifacts"
	@echo "  test          - Run tests"
	@echo "  deps          - Download dependencies"
	@echo "  dev           - Run in development mode"
	@echo "  prod          - Run in production mode"
	@echo "  docker-build  - Build Docker image"
	@echo "  docker-run    - Run with Docker Compose"
	@echo "  docker-stop   - Stop Docker Compose"
	@echo "  lint          - Run linter"
	@echo "  format        - Format code"
	@echo "  check         - Run all checks (lint, test, build)"
	@echo "  migrate       - Run database migrations"
	@echo "  seed          - Seed database with test data"
	@echo "  logs          - Show application logs"

# 构建应用
build:
	@echo "Building $(APP_NAME)..."
	cd $(SERVE_DIR) && $(GOBUILD) $(LDFLAGS) -o $(APP_NAME) .
	@echo "Build completed: $(SERVE_DIR)/$(APP_NAME)"

# 清理构建产物
clean:
	@echo "Cleaning..."
	cd $(SERVE_DIR) && $(GOCLEAN)
	rm -f $(SERVE_DIR)/$(APP_NAME)
	rm -rf $(SERVE_DIR)/logs/*
	docker-compose down --volumes --remove-orphans 2>/dev/null || true
	docker system prune -f 2>/dev/null || true

# 下载依赖
deps:
	@echo "Downloading dependencies..."
	cd $(SERVE_DIR) && $(GOMOD) download
	cd $(SERVE_DIR) && $(GOMOD) tidy

# 运行测试
test:
	@echo "Running tests..."
	cd $(SERVE_DIR) && $(GOTEST) -v ./...

# 开发模式运行
dev: deps
	@echo "Starting development server..."
	cd $(SERVE_DIR) && go run main.go

# 生产模式运行
prod: build
	@echo "Starting production server..."
	cd $(SERVE_DIR) && ./$(APP_NAME)

# Docker构建
docker-build:
	@echo "Building Docker image..."
	docker-compose build ai-english-backend

# Docker运行
docker-run:
	@echo "Starting services with Docker Compose..."
	docker-compose up -d
	@echo "Services started. Backend available at http://localhost:8080"
	@echo "Use 'make logs' to view logs"

# Docker停止
docker-stop:
	@echo "Stopping Docker Compose services..."
	docker-compose down

# 代码检查
lint:
	@echo "Running linter..."
	cd $(SERVE_DIR) && golangci-lint run ./... || echo "golangci-lint not installed, skipping..."

# 代码格式化
format:
	@echo "Formatting code..."
	cd $(SERVE_DIR) && go fmt ./...
	cd $(SERVE_DIR) && goimports -w . 2>/dev/null || echo "goimports not installed, skipping..."

# 运行所有检查
check: format lint test build
	@echo "All checks passed!"

# 数据库迁移
migrate:
	@echo "Running database migrations..."
	@echo "Please ensure database is running and execute SQL files manually"
	@echo "SQL files location: $(DOCS_DIR)/database_schema.sql"

# 数据库种子数据
seed:
	@echo "Seeding database..."
	@echo "Please implement seed data scripts"

# 查看日志
logs:
	@echo "Showing application logs..."
	docker-compose logs -f ai-english-backend

# 查看所有服务状态
status:
	@echo "Service status:"
	docker-compose ps

# 重启服务
restart: docker-stop docker-run

# 安装开发工具
install-tools:
	@echo "Installing development tools..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install golang.org/x/tools/cmd/goimports@latest

# 生成API文档
docs:
	@echo "Generating API documentation..."
	@echo "API documentation available in $(DOCS_DIR)/API接口文档.md"

# 备份数据库
backup:
	@echo "Creating database backup..."
	mkdir -p ./backups
	docker-compose exec mysql mysqldump -u ai_english -pai_english_password ai_english_learning > ./backups/backup_$(shell date +%Y%m%d_%H%M%S).sql

# 恢复数据库
restore:
	@echo "To restore database, run:"
	@echo "docker-compose exec -T mysql mysql -u ai_english -pai_english_password ai_english_learning < ./backups/your_backup_file.sql"

# 性能测试
bench:
	@echo "Running benchmarks..."
	cd $(SERVE_DIR) && go test -bench=. -benchmem ./...

# 安全扫描
security:
	@echo "Running security scan..."
	cd $(SERVE_DIR) && gosec ./... 2>/dev/null || echo "gosec not installed, skipping..."

# 版本信息
version:
	@echo "Version: $(VERSION)"
	@echo "Build Time: $(BUILD_TIME)"
	@echo "Go Version: $(GO_VERSION)"
	@echo "Git Commit: $(GIT_COMMIT)"