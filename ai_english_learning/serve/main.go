// main.go
package main

import (
	"fmt"
	"log"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/api"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/config"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/logger"
)

func main() {
	// 加载配置
	config.LoadConfig()
	if config.GlobalConfig == nil {
		log.Fatal("Failed to load configuration")
	}

	// 初始化日志系统
	loggerConfig := logger.LogConfig{
		Level:      config.GlobalConfig.Log.Level,
		Format:     config.GlobalConfig.Log.Format,
		Output:     config.GlobalConfig.Log.Output,
		FilePath:   config.GlobalConfig.Log.FilePath,
		MaxSize:    config.GlobalConfig.Log.MaxSize,
		MaxBackups: config.GlobalConfig.Log.MaxBackups,
		MaxAge:     config.GlobalConfig.Log.MaxAge,
		Compress:   config.GlobalConfig.Log.Compress,
	}
	logger.InitLogger(loggerConfig)

	// 记录启动信息
	logger.WithFields(map[string]interface{}{
		"app_name":    config.GlobalConfig.App.Name,
		"app_version": config.GlobalConfig.App.Version,
		"environment": config.GlobalConfig.App.Environment,
		"port":        config.GlobalConfig.Server.Port,
	}).Info("Starting AI English Learning Server")

	// 从 api 包获取配置好的路由引擎
	router := api.SetupRouter()

	// 启动服务
	port := fmt.Sprintf(":%s", config.GlobalConfig.Server.Port)
	logger.Infof("Server is running on port %s", config.GlobalConfig.Server.Port)
	if err := router.Run(port); err != nil {
		logger.Fatalf("Failed to start server: %v", err)
	}
}
