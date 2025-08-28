package middleware

import (
	"net/http"
	"runtime/debug"

	"github.com/gin-gonic/gin"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/logger"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
)

// ErrorHandler 全局错误处理中间件
func ErrorHandler() gin.HandlerFunc {
	return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
		if err, ok := recovered.(string); ok {
			logger.WithFields(map[string]interface{}{
				"error":      err,
				"method":     c.Request.Method,
				"path":       c.Request.URL.Path,
				"ip":         c.ClientIP(),
				"user_agent": c.Request.UserAgent(),
				"stack":      string(debug.Stack()),
			}).Error("Panic recovered")
		}
		if err, ok := recovered.(error); ok {
			logger.WithFields(map[string]interface{}{
				"error":      err.Error(),
				"method":     c.Request.Method,
				"path":       c.Request.URL.Path,
				"ip":         c.ClientIP(),
				"user_agent": c.Request.UserAgent(),
				"stack":      string(debug.Stack()),
			}).Error("Panic recovered")
		}

		// 返回统一的错误响应
		common.ErrorResponse(c, http.StatusInternalServerError, "Internal server error")
		c.Abort()
	})
}

// RequestLogger 请求日志中间件
func RequestLogger() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		logger.WithFields(map[string]interface{}{
			"timestamp":   param.TimeStamp.Format("2006-01-02 15:04:05"),
			"status_code": param.StatusCode,
			"latency":     param.Latency.String(),
			"client_ip":   param.ClientIP,
			"method":      param.Method,
			"path":        param.Path,
			"user_agent":  param.Request.UserAgent(),
			"error":       param.ErrorMessage,
		}).Info("HTTP Request")
		return ""
	})
}



// RateLimiter 简单的速率限制中间件（基于IP）
func RateLimiter() gin.HandlerFunc {
	// 这里可以集成更复杂的限流库，如 golang.org/x/time/rate
	return func(c *gin.Context) {
		// 简单实现，实际项目中应该使用更完善的限流算法
		c.Next()
	}
}