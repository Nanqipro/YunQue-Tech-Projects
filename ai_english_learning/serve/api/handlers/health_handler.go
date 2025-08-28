package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/config"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/database"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
)

// HealthResponse 健康检查响应结构
type HealthResponse struct {
	Status    string            `json:"status"`
	Timestamp time.Time         `json:"timestamp"`
	Version   string            `json:"version"`
	Services  map[string]string `json:"services"`
}

// VersionResponse 版本信息响应结构
type VersionResponse struct {
	Name        string `json:"name"`
	Version     string `json:"version"`
	Environment string `json:"environment"`
	BuildTime   string `json:"build_time"`
}

// HealthCheck 健康检查端点
func HealthCheck(c *gin.Context) {
	services := make(map[string]string)
	
	// 检查数据库连接
	db := database.GetDB()
	if db != nil {
		sqlDB, err := db.DB()
		if err != nil {
			services["database"] = "error"
		} else {
			if err := sqlDB.Ping(); err != nil {
				services["database"] = "down"
			} else {
				services["database"] = "up"
			}
		}
	} else {
		services["database"] = "not_initialized"
	}

	// 检查Redis连接（如果配置了Redis）
	// TODO: 添加Redis健康检查
	services["redis"] = "not_implemented"

	// 确定整体状态
	status := "healthy"
	for _, serviceStatus := range services {
		if serviceStatus != "up" && serviceStatus != "not_implemented" {
			status = "unhealthy"
			break
		}
	}

	response := HealthResponse{
		Status:    status,
		Timestamp: time.Now(),
		Version:   config.GlobalConfig.App.Version,
		Services:  services,
	}

	if status == "healthy" {
		common.SuccessResponse(c, response)
	} else {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"code":    http.StatusServiceUnavailable,
			"message": "Service unhealthy",
			"data":    response,
		})
	}
}

// GetVersion 获取版本信息
func GetVersion(c *gin.Context) {
	response := VersionResponse{
		Name:        config.GlobalConfig.App.Name,
		Version:     config.GlobalConfig.App.Version,
		Environment: config.GlobalConfig.App.Environment,
		BuildTime:   time.Now().Format("2006-01-02 15:04:05"), // 实际项目中应该在编译时注入
	}

	common.SuccessResponse(c, response)
}

// ReadinessCheck 就绪检查端点（用于Kubernetes等容器编排）
func ReadinessCheck(c *gin.Context) {
	// 检查关键服务是否就绪
	db := database.GetDB()
	if db == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "not_ready",
			"reason": "database_not_initialized",
		})
		return
	}

	sqlDB, err := db.DB()
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "not_ready",
			"reason": "database_connection_error",
		})
		return
	}

	if err := sqlDB.Ping(); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "not_ready",
			"reason": "database_ping_failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "ready",
	})
}

// LivenessCheck 存活检查端点（用于Kubernetes等容器编排）
func LivenessCheck(c *gin.Context) {
	// 简单的存活检查，只要服务能响应就认为是存活的
	c.JSON(http.StatusOK, gin.H{
		"status": "alive",
		"timestamp": time.Now(),
	})
}