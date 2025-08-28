// api/router.go
package api

import (
	"ai_english_learning/config"
	"ai_english_learning/handlers"
	"ai_english_learning/middleware"
	"ai_english_learning/services"

	"github.com/gin-gonic/gin"
)

func SetupRouter() *gin.Engine {
	r := gin.Default()

	// 添加中间件
	r.Use(middleware.CORSMiddleware())
	r.Use(middleware.LoggerMiddleware())
	r.Use(middleware.RequestIDMiddleware())

	// 获取数据库连接
	db := config.GetDB()

	// 初始化服务
	authService := services.NewAuthService(db)

	// 初始化处理器
	authHandler := handlers.NewAuthHandler(authService)

	// 添加基本路由
	r.GET("/hello", handlers.HelloHandler)
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "message": "AI English Learning API is running"})
	})

	// API路由组
	api := r.Group("/api")
	{
		// 认证相关路由（无需认证）
		auth := api.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/refresh", authHandler.RefreshToken)
			auth.POST("/reset-password", authHandler.ResetPassword)
		}

		// 需要认证的路由
		protected := api.Group("/auth")
		protected.Use(middleware.AuthMiddleware())
		{
			protected.GET("/profile", authHandler.GetProfile)
			protected.POST("/change-password", authHandler.ChangePassword)
			protected.POST("/logout", authHandler.Logout)
			protected.GET("/validate", authHandler.ValidateToken)
		}

		// 用户管理路由（需要认证）
		// user := api.Group("/user")
		// user.Use(middleware.AuthMiddleware())
		// {
		//     user.GET("/profile", userHandler.GetProfile)
		//     user.PUT("/profile", userHandler.UpdateProfile)
		// }

		// 词汇学习路由（需要认证）
		// vocabulary := api.Group("/vocabulary")
		// vocabulary.Use(middleware.AuthMiddleware())
		// {
		//     vocabulary.GET("/categories", vocabularyHandler.GetCategories)
		//     vocabulary.GET("/words", vocabularyHandler.GetWords)
		// }

		// 听力训练路由（需要认证）
		// listening := api.Group("/listening")
		// listening.Use(middleware.AuthMiddleware())
		// {
		//     listening.GET("/exercises", listeningHandler.GetExercises)
		//     listening.POST("/submit", listeningHandler.SubmitAnswer)
		// }

		// 阅读理解路由（需要认证）
		// reading := api.Group("/reading")
		// reading.Use(middleware.AuthMiddleware())
		// {
		//     reading.GET("/exercises", readingHandler.GetExercises)
		//     reading.POST("/submit", readingHandler.SubmitAnswer)
		// }

		// 写作练习路由（需要认证）
		// writing := api.Group("/writing")
		// writing.Use(middleware.AuthMiddleware())
		// {
		//     writing.GET("/exercises", writingHandler.GetExercises)
		//     writing.POST("/submit", writingHandler.SubmitEssay)
		// }

		// 口语练习路由（需要认证）
		// speaking := api.Group("/speaking")
		// speaking.Use(middleware.AuthMiddleware())
		// {
		//     speaking.GET("/exercises", speakingHandler.GetExercises)
		//     speaking.POST("/submit", speakingHandler.SubmitRecording)
		// }

		// 数据统计路由（需要认证）
		// analytics := api.Group("/analytics")
		// analytics.Use(middleware.AuthMiddleware())
		// {
		//     analytics.GET("/stats", analyticsHandler.GetUserStats)
		//     analytics.GET("/progress", analyticsHandler.GetProgress)
		// }
	}

	return r
}
