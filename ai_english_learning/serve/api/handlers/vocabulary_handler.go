package handlers

import (
	"net/http"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/services"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/utils"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

// VocabularyHandler 词汇处理器
type VocabularyHandler struct {
	vocabularyService *services.VocabularyService
	validator         *validator.Validate
}

// NewVocabularyHandler 创建词汇处理器
func NewVocabularyHandler(vocabularyService *services.VocabularyService, validator *validator.Validate) *VocabularyHandler {
	return &VocabularyHandler{
		vocabularyService: vocabularyService,
		validator:         validator,
	}
}

// CreateCategoryRequest 创建词汇分类请求
type CreateCategoryRequest struct {
	Name        string `json:"name" validate:"required,min=1,max=100"`
	Description string `json:"description" validate:"max=500"`
	Level       string `json:"level" validate:"required,oneof=beginner intermediate advanced"`
}

// UpdateCategoryRequest 更新词汇分类请求
type UpdateCategoryRequest struct {
	Name        string `json:"name" validate:"omitempty,min=1,max=100"`
	Description string `json:"description" validate:"omitempty,max=500"`
	Level       string `json:"level" validate:"omitempty,oneof=beginner intermediate advanced"`
}

// CreateVocabularyRequest 创建词汇请求
type CreateVocabularyRequest struct {
	Word         string                   `json:"word" validate:"required,min=1,max=100"`
	Phonetic     string                   `json:"phonetic" validate:"max=200"`
	Level        string                   `json:"level" validate:"required,oneof=beginner intermediate advanced"`
	Frequency    int                      `json:"frequency" validate:"min=0"`
	CategoryID   string                   `json:"category_id" validate:"required"`
	Definitions  []CreateDefinitionRequest `json:"definitions" validate:"required,min=1"`
	Examples     []CreateExampleRequest    `json:"examples"`
	Images       []CreateImageRequest      `json:"images"`
}

// CreateDefinitionRequest 创建词汇定义请求
type CreateDefinitionRequest struct {
	PartOfSpeech string `json:"part_of_speech" validate:"required"`
	Definition   string `json:"definition" validate:"required,min=1"`
	Translation  string `json:"translation" validate:"required,min=1"`
}

// CreateExampleRequest 创建例句请求
type CreateExampleRequest struct {
	Sentence    string `json:"sentence" validate:"required,min=1"`
	Translation string `json:"translation" validate:"required,min=1"`
}

// CreateImageRequest 创建图片请求
type CreateImageRequest struct {
	URL         string `json:"url" validate:"required,url"`
	Description string `json:"description" validate:"max=200"`
}

// UpdateVocabularyProgressRequest 更新学习进度请求
type UpdateVocabularyProgressRequest struct {
	MasteryLevel int  `json:"mastery_level" validate:"min=0,max=5"`
	IsLearned    bool `json:"is_learned"`
}

// CreateVocabularyTestRequest 创建词汇测试请求
type CreateVocabularyTestRequest struct {
	Name        string   `json:"name" validate:"required,min=1,max=100"`
	Description string   `json:"description" validate:"max=500"`
	Level       string   `json:"level" validate:"required,oneof=beginner intermediate advanced"`
	Questions   []string `json:"questions" validate:"required,min=1"`
}

// UpdateTestResultRequest 更新测试结果请求
type UpdateTestResultRequest struct {
	Score       int                    `json:"score" validate:"min=0,max=100"`
	Answers     map[string]interface{} `json:"answers" validate:"required"`
	TimeSpent   int                    `json:"time_spent" validate:"min=0"`
	CompletedAt string                 `json:"completed_at"`
}

// GetCategories 获取词汇分类列表
func (h *VocabularyHandler) GetCategories(c *gin.Context) {
	page, pageSize := utils.GetPaginationParams(c)
	level := c.Query("level")

	paginationData, err := h.vocabularyService.GetCategories(page, pageSize, level)
	if err != nil {
		common.InternalServerErrorResponse(c, "获取词汇分类失败")
		return
	}

	common.PaginationSuccessResponse(c, paginationData.Items, paginationData.Pagination)
}

// CreateCategory 创建词汇分类
func (h *VocabularyHandler) CreateCategory(c *gin.Context) {
	var req CreateCategoryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	category, err := h.vocabularyService.CreateCategory(req.Name, req.Description, req.Level)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "创建词汇分类失败")
		return
	}

	common.SuccessResponse(c, category)
}

// UpdateCategory 更新词汇分类
func (h *VocabularyHandler) UpdateCategory(c *gin.Context) {
	categoryID := c.Param("id")
	if categoryID == "" {
		common.BadRequestResponse(c, "分类ID不能为空")
		return
	}

	var req UpdateCategoryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	updates := make(map[string]interface{})
	if req.Name != "" {
		updates["name"] = req.Name
	}
	if req.Description != "" {
		updates["description"] = req.Description
	}
	if req.Level != "" {
		updates["level"] = req.Level
	}

	category, err := h.vocabularyService.UpdateCategory(categoryID, updates)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "更新词汇分类失败")
		return
	}

	common.SuccessResponse(c, category)
}

// DeleteCategory 删除词汇分类
func (h *VocabularyHandler) DeleteCategory(c *gin.Context) {
	categoryID := c.Param("id")
	if categoryID == "" {
		common.BadRequestResponse(c, "分类ID不能为空")
		return
	}

	err := h.vocabularyService.DeleteCategory(categoryID)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "删除词汇分类失败")
		return
	}

	common.SuccessResponse(c, map[string]string{"message": "删除成功"})
}

// GetVocabulariesByCategory 根据分类获取词汇列表
func (h *VocabularyHandler) GetVocabulariesByCategory(c *gin.Context) {
	categoryID := c.Param("categoryId")
	if categoryID == "" {
		common.BadRequestResponse(c, "分类ID不能为空")
		return
	}

	page, pageSize := utils.GetPaginationParams(c)
	level := c.Query("level")

	paginationData, err := h.vocabularyService.GetVocabulariesByCategory(categoryID, page, pageSize, level)
	if err != nil {
		common.InternalServerErrorResponse(c, "获取词汇列表失败")
		return
	}

	common.PaginationSuccessResponse(c, paginationData.Items, paginationData.Pagination)
}

// GetVocabulary 获取词汇详情
func (h *VocabularyHandler) GetVocabulary(c *gin.Context) {
	vocabularyID := c.Param("id")
	if vocabularyID == "" {
		common.BadRequestResponse(c, "词汇ID不能为空")
		return
	}

	vocabulary, err := h.vocabularyService.GetVocabularyByID(vocabularyID)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusNotFound, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "获取词汇详情失败")
		return
	}

	common.SuccessResponse(c, vocabulary)
}

// CreateVocabulary 创建词汇
func (h *VocabularyHandler) CreateVocabulary(c *gin.Context) {
	var req CreateVocabularyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 转换定义为字符串切片
	definitions := make([]string, len(req.Definitions))
	for i, def := range req.Definitions {
		definitions[i] = def.Definition
	}

	// 转换例句为字符串切片
	examples := make([]string, len(req.Examples))
	for i, ex := range req.Examples {
		examples[i] = ex.Sentence
	}

	// 转换图片为字符串切片
	images := make([]string, len(req.Images))
	for i, img := range req.Images {
		images[i] = img.URL
	}

	vocabulary, err := h.vocabularyService.CreateVocabulary(
		req.Word, req.Phonetic, req.Level, req.Frequency, req.CategoryID,
		definitions, examples, images,
	)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "创建词汇失败")
		return
	}

	common.SuccessResponse(c, vocabulary)
}

// SearchVocabularies 搜索词汇
func (h *VocabularyHandler) SearchVocabularies(c *gin.Context) {
	query := c.Query("q")
	if query == "" {
		common.BadRequestResponse(c, "搜索关键词不能为空")
		return
	}

	page, pageSize := utils.GetPaginationParams(c)
	level := c.Query("level")

	paginationData, err := h.vocabularyService.SearchVocabularies(query, level, page, pageSize)
	if err != nil {
		common.InternalServerErrorResponse(c, "搜索词汇失败")
		return
	}

	common.PaginationSuccessResponse(c, paginationData.Items, paginationData.Pagination)
}

// GetUserVocabularyProgress 获取用户词汇学习进度
func (h *VocabularyHandler) GetUserVocabularyProgress(c *gin.Context) {
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	vocabularyID := c.Param("vocabularyId")
	if vocabularyID == "" {
		common.BadRequestResponse(c, "词汇ID不能为空")
		return
	}

	progress, err := h.vocabularyService.GetUserVocabularyProgress(userID, vocabularyID)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusNotFound, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "获取学习进度失败")
		return
	}

	common.SuccessResponse(c, progress)
}

// UpdateUserVocabularyProgress 更新用户词汇学习进度
func (h *VocabularyHandler) UpdateUserVocabularyProgress(c *gin.Context) {
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	vocabularyID := c.Param("vocabularyId")
	if vocabularyID == "" {
		common.BadRequestResponse(c, "词汇ID不能为空")
		return
	}

	var req UpdateVocabularyProgressRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	updates := map[string]interface{}{
		"mastery_level": req.MasteryLevel,
		"is_learned":    req.IsLearned,
	}

	progress, err := h.vocabularyService.UpdateUserVocabularyProgress(userID, vocabularyID, updates)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "更新学习进度失败")
		return
	}

	common.SuccessResponse(c, progress)
}

// GetUserVocabularyStats 获取用户词汇学习统计
func (h *VocabularyHandler) GetUserVocabularyStats(c *gin.Context) {
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	stats, err := h.vocabularyService.GetUserVocabularyStats(userID)
	if err != nil {
		common.InternalServerErrorResponse(c, "获取学习统计失败")
		return
	}

	common.SuccessResponse(c, stats)
}

// CreateVocabularyTest 创建词汇测试
func (h *VocabularyHandler) CreateVocabularyTest(c *gin.Context) {
	var req CreateVocabularyTestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 从上下文获取用户ID
	userID := c.GetString("user_id")
	if userID == "" {
		common.ErrorResponse(c, http.StatusUnauthorized, "用户未认证")
		return
	}

	test, err := h.vocabularyService.CreateVocabularyTest(userID, req.Name, req.Level, len(req.Questions))
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "创建词汇测试失败")
		return
	}

	common.SuccessResponse(c, test)
}

// GetVocabularyTest 获取词汇测试
func (h *VocabularyHandler) GetVocabularyTest(c *gin.Context) {
	testID := c.Param("testId")
	if testID == "" {
		common.BadRequestResponse(c, "测试ID不能为空")
		return
	}

	test, err := h.vocabularyService.GetVocabularyTest(testID)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusNotFound, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "获取词汇测试失败")
		return
	}

	common.SuccessResponse(c, test)
}

// UpdateVocabularyTestResult 更新词汇测试结果
func (h *VocabularyHandler) UpdateVocabularyTestResult(c *gin.Context) {
	_, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	testID := c.Param("testId")
	if testID == "" {
		common.BadRequestResponse(c, "测试ID不能为空")
		return
	}

	var req UpdateTestResultRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 计算正确答案数量（这里简化处理，实际应该根据答案计算）
	correctWords := req.Score // 简化处理，假设分数就是正确答案数
	
	err := h.vocabularyService.UpdateVocabularyTestResult(
		testID, correctWords, float64(req.Score), req.TimeSpent,
	)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "更新测试结果失败")
		return
	}

	common.SuccessResponse(c, gin.H{"message": "测试结果更新成功"})
}