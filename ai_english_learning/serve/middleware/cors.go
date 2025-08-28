package middleware

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// CORSMiddleware CORS中间件
func CORSMiddleware() gin.HandlerFunc {
	config := cors.DefaultConfig()
	
	// 允许的源
	config.AllowOrigins = []string{
		"http://localhost:3000",
		"http://127.0.0.1:3000",
		"http://localhost:8080",
		"http://127.0.0.1:8080",
	}
	
	// 允许的方法
	config.AllowMethods = []string{
		"GET",
		"POST",
		"PUT",
		"DELETE",
		"OPTIONS",
		"PATCH",
	}
	
	// 允许的头部
	config.AllowHeaders = []string{
		"Origin",
		"Content-Type",
		"Accept",
		"Authorization",
		"X-Requested-With",
		"X-Request-ID",
	}
	
	// 允许凭证
	config.AllowCredentials = true
	
	// 暴露的头部
	config.ExposeHeaders = []string{
		"Content-Length",
		"X-Request-ID",
	}
	
	return cors.New(config)
}