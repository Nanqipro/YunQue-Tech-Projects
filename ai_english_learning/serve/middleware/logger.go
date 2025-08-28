package middleware

import (
	"fmt"
	"time"

	"github.com/gin-gonic/gin"
)

// LoggerMiddleware 自定义日志中间件
func LoggerMiddleware() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return fmt.Sprintf("%s - [%s] \"%s %s %s %d %s \"%s\" %s\"\n",
			param.ClientIP,
			param.TimeStamp.Format(time.RFC1123),
			param.Method,
			param.Path,
			param.Request.Proto,
			param.StatusCode,
			param.Latency,
			param.Request.UserAgent(),
			param.ErrorMessage,
		)
	})
}

// RequestIDMiddleware 请求ID中间件
func RequestIDMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 生成请求ID
		requestID := fmt.Sprintf("%d", time.Now().UnixNano())
		
		// 设置到响应头
		c.Header("X-Request-ID", requestID)
		
		// 设置到上下文
		c.Set("request_id", requestID)
		
		c.Next()
	}
}