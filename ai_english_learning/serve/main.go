// main.go
package main

import (
	"log"

	"ai_english_learning/api"
	"ai_english_learning/config"
	"ai_english_learning/models"
)

func main() {
	// 加载配置
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// 初始化数据库
	db, err := config.InitDatabase(cfg)
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer config.CloseDatabase()

	// 自动迁移数据库
	if err := models.AutoMigrate(db); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}

	// 初始化种子数据
	if err := models.SeedData(db); err != nil {
		log.Printf("Warning: Failed to seed data: %v", err)
	}

	log.Printf("Starting server on port %s", cfg.Server.Port)
	log.Printf("Environment: %s", cfg.Server.Environment)

	// 设置路由并启动服务器
	r := api.SetupRouter()
	if err := r.Run(":" + cfg.Server.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
