// api/router.go
package api

import (
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/api/handlers" // 注意修改为你的模块路径
	"github.com/gin-gonic/gin"
)

// SetupRouter 配置所有路由
func SetupRouter() *gin.Engine {
	router := gin.Default()

	// 为 /hello 路径注册 HelloHandler
	router.GET("/hello", handlers.HelloHandler)

	// 在这里可以继续添加更多的路由组和路由
	// v1 := router.Group("/api/v1")
	// {
	//     v1.GET("/users", handlers.GetUsers)
	//     v1.POST("/users", handlers.CreateUser)
	// }

	return router
}
