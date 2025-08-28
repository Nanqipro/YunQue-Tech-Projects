package config

import (
	"fmt"
	"log"
	"time"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

// InitDatabase 初始化数据库连接
func InitDatabase() {
	config := AppConfig.Database
	
	// 构建DSN
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=%s&parseTime=True&loc=Local",
		config.User,
		config.Password,
		config.Host,
		config.Port,
		config.DBName,
		config.Charset,
	)

	// 配置GORM
	gormConfig := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	}

	// 如果是生产环境，关闭详细日志
	if AppConfig.Server.Mode == "release" {
		gormConfig.Logger = logger.Default.LogMode(logger.Silent)
	}

	var err error
	DB, err = gorm.Open(mysql.Open(dsn), gormConfig)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// 获取底层的sql.DB对象进行连接池配置
	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatal("Failed to get underlying sql.DB:", err)
	}

	// 设置连接池参数
	sqlDB.SetMaxIdleConns(10)                   // 最大空闲连接数
	sqlDB.SetMaxOpenConns(100)                  // 最大打开连接数
	sqlDB.SetConnMaxLifetime(time.Hour)         // 连接最大生存时间
	sqlDB.SetConnMaxIdleTime(time.Minute * 30)  // 连接最大空闲时间

	// 测试连接
	if err := sqlDB.Ping(); err != nil {
		log.Fatal("Failed to ping database:", err)
	}

	log.Println("Database connected successfully")
}

// CloseDatabase 关闭数据库连接
func CloseDatabase() {
	if DB != nil {
		sqlDB, err := DB.DB()
		if err != nil {
			log.Println("Failed to get underlying sql.DB:", err)
			return
		}
		if err := sqlDB.Close(); err != nil {
			log.Println("Failed to close database:", err)
		}
	}
}