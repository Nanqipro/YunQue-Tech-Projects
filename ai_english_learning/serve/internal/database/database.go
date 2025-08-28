package database

import (
	"fmt"
	"log"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/config"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

// InitDatabase 初始化数据库连接
func InitDatabase() {
	cfg := config.GlobalConfig

	// 构建DSN
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=%s&parseTime=True&loc=Local",
		cfg.Database.User,
		cfg.Database.Password,
		cfg.Database.Host,
		cfg.Database.Port,
		cfg.Database.DBName,
		cfg.Database.Charset,
	)

	// 配置GORM日志
	var gormLogger logger.Interface
	switch cfg.App.LogLevel {
	case "debug":
		gormLogger = logger.Default.LogMode(logger.Info)
	case "info":
		gormLogger = logger.Default.LogMode(logger.Warn)
	default:
		gormLogger = logger.Default.LogMode(logger.Error)
	}

	// 连接数据库
	var err error
	DB, err = gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: gormLogger,
	})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// 获取底层sql.DB对象进行连接池配置
	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatalf("Failed to get underlying sql.DB: %v", err)
	}

	// 设置连接池参数
	sqlDB.SetMaxIdleConns(10)                   // 最大空闲连接数
	sqlDB.SetMaxOpenConns(100)                  // 最大打开连接数
	sqlDB.SetConnMaxLifetime(time.Hour)         // 连接最大生存时间
	sqlDB.SetConnMaxIdleTime(time.Minute * 30)  // 连接最大空闲时间

	// 测试连接
	if err := sqlDB.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}

	log.Println("Database connected successfully")
}

// CloseDatabase 关闭数据库连接
func CloseDatabase() {
	if DB != nil {
		sqlDB, err := DB.DB()
		if err != nil {
			log.Printf("Failed to get underlying sql.DB: %v", err)
			return
		}
		if err := sqlDB.Close(); err != nil {
			log.Printf("Failed to close database: %v", err)
		}
	}
}

// GetDB 获取数据库实例
func GetDB() *gorm.DB {
	return DB
}