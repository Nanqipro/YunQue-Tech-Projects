// api/router.go
package api

import (
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/api/handlers"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/config"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/database"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/middleware"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

// SetupRouter 配置所有路由
func SetupRouter() *gin.Engine {
	// 根据环境设置Gin模式
	gin.SetMode(config.GlobalConfig.Server.Mode)
	
	// 创建路由引擎，不使用默认中间件
	router := gin.New()

	// 添加自定义中间件
	router.Use(middleware.RequestLogger())
	router.Use(middleware.ErrorHandler())
	router.Use(middleware.CORS())
	router.Use(middleware.RateLimiter())

	// 初始化数据库连接
	db := database.GetDB()

	// 初始化验证器
	validate := validator.New()

	// 初始化服务
	userService := services.NewUserService(db)
	vocabularyService := services.NewVocabularyService(db)
	listeningService := services.NewListeningService(db)
	readingService := services.NewReadingService(db)
	writingService := services.NewWritingService(db)
	speakingService := services.NewSpeakingService(db)

	// 初始化处理器
	authHandler := handlers.NewAuthHandler(userService)
	userHandler := handlers.NewUserHandler(userService)
	vocabularyHandler := handlers.NewVocabularyHandler(vocabularyService, validate)
	listeningHandler := handlers.NewListeningHandler(listeningService, validate)
	readingHandler := handlers.NewReadingHandler(readingService)
	writingHandler := handlers.NewWritingHandler(writingService)
	speakingHandler := handlers.NewSpeakingHandler(speakingService)



	// 健康检查和系统信息路由
	router.GET("/health", handlers.HealthCheck)
	router.GET("/health/readiness", handlers.ReadinessCheck)
	router.GET("/health/liveness", handlers.LivenessCheck)
	router.GET("/version", handlers.GetVersion)

	// 为 /hello 路径注册 HelloHandler
	router.GET("/hello", handlers.HelloHandler)

	// 认证相关路由（无需认证）
	auth := router.Group("/api/v1/auth")
	{
		auth.POST("/register", authHandler.Register)
		auth.POST("/login", authHandler.Login)
		auth.POST("/refresh", authHandler.RefreshToken)
	}

	// 用户相关路由（需要认证）
	user := router.Group("/api/v1/user")
	user.Use(AuthMiddleware())
	{
		user.GET("/profile", userHandler.GetUserProfile)
		user.PUT("/profile", userHandler.UpdateUserProfile)
		user.PUT("/preferences", userHandler.UpdateUserPreferences)
		user.GET("/stats", userHandler.GetUserStats)
		user.GET("/progress", userHandler.GetUserLearningProgress)
		user.POST("/change-password", authHandler.ChangePassword)
	}

	// 词汇相关路由
	vocabulary := router.Group("/api/v1/vocabulary")
	vocabulary.Use(AuthMiddleware())
	{
		// 词汇分类
		vocabulary.GET("/categories", vocabularyHandler.GetCategories)
		vocabulary.POST("/categories", vocabularyHandler.CreateCategory)
		vocabulary.PUT("/categories/:id", vocabularyHandler.UpdateCategory)
		vocabulary.DELETE("/categories/:id", vocabularyHandler.DeleteCategory)

		// 词汇管理
		vocabulary.GET("/categories/:id/vocabularies", vocabularyHandler.GetVocabulariesByCategory)
		vocabulary.GET("/:id", vocabularyHandler.GetVocabulary)
		vocabulary.POST("/", vocabularyHandler.CreateVocabulary)
		vocabulary.GET("/search", vocabularyHandler.SearchVocabularies)

		// 用户词汇进度
		vocabulary.GET("/progress/:vocabulary_id", vocabularyHandler.GetUserVocabularyProgress)
		vocabulary.PUT("/progress/:vocabulary_id", vocabularyHandler.UpdateUserVocabularyProgress)
		vocabulary.GET("/stats", vocabularyHandler.GetUserVocabularyStats)

		// 词汇测试
		vocabulary.POST("/tests", vocabularyHandler.CreateVocabularyTest)
		vocabulary.GET("/tests/:id", vocabularyHandler.GetVocabularyTest)
		vocabulary.PUT("/tests/:id/result", vocabularyHandler.UpdateVocabularyTestResult)
	}

	// 听力训练相关路由
	listening := router.Group("/api/v1/listening")
	listening.Use(AuthMiddleware())
	{
		// 听力材料管理
		listening.GET("/materials", listeningHandler.GetListeningMaterials)
		listening.GET("/materials/:id", listeningHandler.GetListeningMaterial)
		listening.POST("/materials", listeningHandler.CreateListeningMaterial)
		listening.PUT("/materials/:id", listeningHandler.UpdateListeningMaterial)
		listening.DELETE("/materials/:id", listeningHandler.DeleteListeningMaterial)
		listening.GET("/materials/search", listeningHandler.SearchListeningMaterials)

		// 听力练习记录
		listening.POST("/records", listeningHandler.CreateListeningRecord)
		listening.PUT("/records/:id", listeningHandler.UpdateListeningRecord)
		listening.GET("/records", listeningHandler.GetUserListeningRecords)
		listening.GET("/records/:id", listeningHandler.GetListeningRecord)

		// 听力学习统计和进度
		listening.GET("/stats", listeningHandler.GetUserListeningStats)
		listening.GET("/progress/:material_id", listeningHandler.GetListeningProgress)
	}

	// 阅读理解相关路由
	reading := router.Group("/api/v1/reading")
	reading.Use(AuthMiddleware())
	{
		// 阅读材料管理
		reading.GET("/materials", readingHandler.GetReadingMaterials)
		reading.GET("/materials/:id", readingHandler.GetReadingMaterial)
		reading.POST("/materials", readingHandler.CreateReadingMaterial)
		reading.PUT("/materials/:id", readingHandler.UpdateReadingMaterial)
		reading.DELETE("/materials/:id", readingHandler.DeleteReadingMaterial)
		reading.GET("/materials/search", readingHandler.SearchReadingMaterials)

		// 阅读练习记录
		reading.POST("/records", readingHandler.CreateReadingRecord)
		reading.PUT("/records/:id", readingHandler.UpdateReadingRecord)
		reading.GET("/records", readingHandler.GetUserReadingRecords)
		reading.GET("/records/:id", readingHandler.GetReadingRecord)

		// 阅读学习统计和进度
		reading.GET("/stats", readingHandler.GetReadingStats)
		reading.GET("/progress/:material_id", readingHandler.GetReadingProgress)
		reading.GET("/recommendations", readingHandler.GetRecommendedMaterials)
	}

	// 写作练习相关路由
	writing := router.Group("/api/v1/writing")
	writing.Use(AuthMiddleware())
	{
		// 写作题目管理
		writing.GET("/prompts", writingHandler.GetWritingPrompts)
		writing.GET("/prompts/:id", writingHandler.GetWritingPrompt)
		writing.POST("/prompts", writingHandler.CreateWritingPrompt)
		writing.PUT("/prompts/:id", writingHandler.UpdateWritingPrompt)
		writing.DELETE("/prompts/:id", writingHandler.DeleteWritingPrompt)
		writing.GET("/prompts/search", writingHandler.SearchWritingPrompts)
		writing.GET("/prompts/recommendations", writingHandler.GetRecommendedPrompts)

		// 写作提交管理
		writing.POST("/submissions", writingHandler.CreateWritingSubmission)
		writing.GET("/submissions", writingHandler.GetUserWritingSubmissions)
		writing.GET("/submissions/:id", writingHandler.GetWritingSubmission)
		writing.PUT("/submissions/:id/submit", writingHandler.SubmitWriting)
		writing.PUT("/submissions/:id/grade", writingHandler.GradeWriting)

		// 写作学习统计和进度
		writing.GET("/stats", writingHandler.GetWritingStats)
		writing.GET("/progress/:prompt_id", writingHandler.GetWritingProgress)
	}

	// 口语练习相关路由
	speaking := router.Group("/api/v1/speaking")
	speaking.Use(AuthMiddleware())
	{
		// 口语场景管理
		speaking.GET("/scenarios", speakingHandler.GetSpeakingScenarios)
		speaking.GET("/scenarios/:id", speakingHandler.GetSpeakingScenario)
		speaking.POST("/scenarios", speakingHandler.CreateSpeakingScenario)
		speaking.PUT("/scenarios/:id", speakingHandler.UpdateSpeakingScenario)
		speaking.DELETE("/scenarios/:id", speakingHandler.DeleteSpeakingScenario)
		speaking.GET("/scenarios/search", speakingHandler.SearchSpeakingScenarios)
		speaking.GET("/scenarios/recommendations", speakingHandler.GetRecommendedScenarios)

		// 口语记录管理
		speaking.POST("/records", speakingHandler.CreateSpeakingRecord)
		speaking.GET("/records", speakingHandler.GetUserSpeakingRecords)
		speaking.GET("/records/:id", speakingHandler.GetSpeakingRecord)
		speaking.PUT("/records/:id/submit", speakingHandler.SubmitSpeaking)
		speaking.PUT("/records/:id/grade", speakingHandler.GradeSpeaking)

		// 口语学习统计和进度
		speaking.GET("/stats", speakingHandler.GetSpeakingStats)
		speaking.GET("/progress/:scenario_id", speakingHandler.GetSpeakingProgress)
	}

	return router
}
