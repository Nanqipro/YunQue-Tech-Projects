package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/services"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/utils"
	"github.com/gin-gonic/gin"
)

// SpeakingHandler 口语练习处理器
type SpeakingHandler struct {
	speakingService *services.SpeakingService
}

// NewSpeakingHandler 创建口语练习处理器实例
func NewSpeakingHandler(speakingService *services.SpeakingService) *SpeakingHandler {
	return &SpeakingHandler{
		speakingService: speakingService,
	}
}

// ==================== 口语场景管理 ====================

// GetSpeakingScenarios 获取口语场景列表
func (h *SpeakingHandler) GetSpeakingScenarios(c *gin.Context) {
	level := c.Query("level")
	category := c.Query("category")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	scenarios, total, err := h.speakingService.GetSpeakingScenarios(level, category, page, pageSize)
	if err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "获取口语场景列表失败")
		return
	}

	response := gin.H{
		"scenarios": scenarios,
		"pagination": gin.H{
			"page":       page,
			"page_size":  pageSize,
			"total":      total,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	}

	common.SuccessResponse(c, response)
}

// GetSpeakingScenario 获取单个口语场景
func (h *SpeakingHandler) GetSpeakingScenario(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		common.ErrorResponse(c, http.StatusBadRequest, "场景ID不能为空")
		return
	}

	scenario, err := h.speakingService.GetSpeakingScenario(id)
	if err != nil {
		common.ErrorResponse(c, http.StatusNotFound, "口语场景不存在")
		return
	}

	common.SuccessResponse(c, scenario)
}

// CreateSpeakingScenarioRequest 创建口语场景请求
type CreateSpeakingScenarioRequest struct {
	Title       string  `json:"title" binding:"required,max=200"`
	Description string  `json:"description" binding:"required"`
	Context     *string `json:"context"`
	Level       string  `json:"level" binding:"required,oneof=beginner intermediate advanced"`
	Category    string  `json:"category" binding:"max=50"`
	Tags        *string `json:"tags"`
	Dialogue    *string `json:"dialogue"`
	KeyPhrases  *string `json:"key_phrases"`
}

// CreateSpeakingScenario 创建口语场景
func (h *SpeakingHandler) CreateSpeakingScenario(c *gin.Context) {
	var req CreateSpeakingScenarioRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ErrorResponse(c, http.StatusBadRequest, "请求参数错误")
		return
	}

	scenario := &models.SpeakingScenario{
		ID:          utils.GenerateUUID(),
		Title:       req.Title,
		Description: req.Description,
		Context:     req.Context,
		Level:       req.Level,
		Category:    req.Category,
		Tags:        req.Tags,
		Dialogue:    req.Dialogue,
		KeyPhrases:  req.KeyPhrases,
		IsActive:    true,
	}

	if err := h.speakingService.CreateSpeakingScenario(scenario); err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "创建口语场景失败")
		return
	}

	common.SuccessResponse(c, scenario)
}

// UpdateSpeakingScenarioRequest 更新口语场景请求
type UpdateSpeakingScenarioRequest struct {
	Title       *string `json:"title" binding:"omitempty,max=200"`
	Description *string `json:"description"`
	Context     *string `json:"context"`
	Level       *string `json:"level" binding:"omitempty,oneof=beginner intermediate advanced"`
	Category    *string `json:"category" binding:"omitempty,max=50"`
	Tags        *string `json:"tags"`
	Dialogue    *string `json:"dialogue"`
	KeyPhrases  *string `json:"key_phrases"`
}

// UpdateSpeakingScenario 更新口语场景
func (h *SpeakingHandler) UpdateSpeakingScenario(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		common.ErrorResponse(c, http.StatusBadRequest, "场景ID不能为空")
		return
	}

	var req UpdateSpeakingScenarioRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ErrorResponse(c, http.StatusBadRequest, "请求参数错误")
		return
	}

	updateData := &models.SpeakingScenario{}
	if req.Title != nil {
		updateData.Title = *req.Title
	}
	if req.Description != nil {
		updateData.Description = *req.Description
	}
	if req.Context != nil {
		updateData.Context = req.Context
	}
	if req.Level != nil {
		updateData.Level = *req.Level
	}
	if req.Category != nil {
		updateData.Category = *req.Category
	}
	if req.Tags != nil {
		updateData.Tags = req.Tags
	}
	if req.Dialogue != nil {
		updateData.Dialogue = req.Dialogue
	}
	if req.KeyPhrases != nil {
		updateData.KeyPhrases = req.KeyPhrases
	}

	if err := h.speakingService.UpdateSpeakingScenario(id, updateData); err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "更新口语场景失败")
		return
	}

	common.SuccessResponse(c, gin.H{"message": "更新成功"})
}

// DeleteSpeakingScenario 删除口语场景
func (h *SpeakingHandler) DeleteSpeakingScenario(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		common.ErrorResponse(c, http.StatusBadRequest, "场景ID不能为空")
		return
	}

	if err := h.speakingService.DeleteSpeakingScenario(id); err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "删除口语场景失败")
		return
	}

	common.SuccessResponse(c, gin.H{"message": "删除成功"})
}

// SearchSpeakingScenarios 搜索口语场景
func (h *SpeakingHandler) SearchSpeakingScenarios(c *gin.Context) {
	keyword := c.Query("keyword")
	level := c.Query("level")
	category := c.Query("category")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	scenarios, total, err := h.speakingService.SearchSpeakingScenarios(keyword, level, category, page, pageSize)
	if err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "搜索口语场景失败")
		return
	}

	response := gin.H{
		"scenarios": scenarios,
		"pagination": gin.H{
			"page":       page,
			"page_size":  pageSize,
			"total":      total,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	}

	common.SuccessResponse(c, response)
}

// GetRecommendedScenarios 获取推荐的口语场景
func (h *SpeakingHandler) GetRecommendedScenarios(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		common.ErrorResponse(c, http.StatusUnauthorized, "用户未认证")
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	if limit < 1 || limit > 50 {
		limit = 10
	}

	scenarios, err := h.speakingService.GetRecommendedScenarios(userID.(string), limit)
	if err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "获取推荐场景失败")
		return
	}

	common.SuccessResponse(c, scenarios)
}

// ==================== 口语练习记录管理 ====================

// CreateSpeakingRecordRequest 创建口语练习记录请求
type CreateSpeakingRecordRequest struct {
	ScenarioID string `json:"scenario_id" binding:"required"`
}

// CreateSpeakingRecord 创建口语练习记录
func (h *SpeakingHandler) CreateSpeakingRecord(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		common.ErrorResponse(c, http.StatusUnauthorized, "用户未认证")
		return
	}

	var req CreateSpeakingRecordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ErrorResponse(c, http.StatusBadRequest, "请求参数错误")
		return
	}

	now := time.Now()
	record := &models.SpeakingRecord{
		ID:         utils.GenerateUUID(),
		UserID:     userID.(string),
		ScenarioID: req.ScenarioID,
		StartedAt:  now,
		CreatedAt:  now,
		UpdatedAt:  now,
	}

	if err := h.speakingService.CreateSpeakingRecord(record); err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "创建口语练习记录失败")
		return
	}

	common.SuccessResponse(c, record)
}

// GetUserSpeakingRecords 获取用户的口语练习记录
func (h *SpeakingHandler) GetUserSpeakingRecords(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		common.ErrorResponse(c, http.StatusUnauthorized, "用户未认证")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	records, total, err := h.speakingService.GetUserSpeakingRecords(userID.(string), page, pageSize)
	if err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "获取口语练习记录失败")
		return
	}

	response := gin.H{
		"records": records,
		"pagination": gin.H{
			"page":       page,
			"page_size":  pageSize,
			"total":      total,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	}

	common.SuccessResponse(c, response)
}

// GetSpeakingRecord 获取单个口语练习记录
func (h *SpeakingHandler) GetSpeakingRecord(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		common.ErrorResponse(c, http.StatusBadRequest, "记录ID不能为空")
		return
	}

	record, err := h.speakingService.GetSpeakingRecord(id)
	if err != nil {
		common.ErrorResponse(c, http.StatusNotFound, "口语练习记录不存在")
		return
	}

	common.SuccessResponse(c, record)
}

// SubmitSpeakingRequest 提交口语练习请求
type SubmitSpeakingRequest struct {
	AudioURL   string `json:"audio_url" binding:"required"`
	Transcript string `json:"transcript"`
}

// SubmitSpeaking 提交口语练习
func (h *SpeakingHandler) SubmitSpeaking(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		common.ErrorResponse(c, http.StatusBadRequest, "记录ID不能为空")
		return
	}

	var req SubmitSpeakingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ErrorResponse(c, http.StatusBadRequest, "请求参数错误")
		return
	}

	if err := h.speakingService.SubmitSpeaking(id, req.AudioURL, req.Transcript); err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "提交口语练习失败")
		return
	}

	common.SuccessResponse(c, gin.H{"message": "提交成功"})
}

// GradeSpeakingRequest 评分口语练习请求
type GradeSpeakingRequest struct {
	PronunciationScore float64 `json:"pronunciation_score" binding:"required,min=0,max=100"`
	FluencyScore       float64 `json:"fluency_score" binding:"required,min=0,max=100"`
	AccuracyScore      float64 `json:"accuracy_score" binding:"required,min=0,max=100"`
	OverallScore       float64 `json:"overall_score" binding:"required,min=0,max=100"`
	Feedback           string  `json:"feedback"`
	Suggestions        string  `json:"suggestions"`
}

// GradeSpeaking 评分口语练习
func (h *SpeakingHandler) GradeSpeaking(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		common.ErrorResponse(c, http.StatusBadRequest, "记录ID不能为空")
		return
	}

	var req GradeSpeakingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ErrorResponse(c, http.StatusBadRequest, "请求参数错误")
		return
	}

	if err := h.speakingService.GradeSpeaking(id, req.PronunciationScore, req.FluencyScore, req.AccuracyScore, req.OverallScore, req.Feedback, req.Suggestions); err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "评分口语练习失败")
		return
	}

	common.SuccessResponse(c, gin.H{"message": "评分成功"})
}

// ==================== 口语学习统计和进度 ====================

// GetSpeakingStats 获取口语学习统计
func (h *SpeakingHandler) GetSpeakingStats(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		common.ErrorResponse(c, http.StatusUnauthorized, "用户未认证")
		return
	}

	stats, err := h.speakingService.GetUserSpeakingStats(userID.(string))
	if err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "获取口语学习统计失败")
		return
	}

	common.SuccessResponse(c, stats)
}

// GetSpeakingProgress 获取口语学习进度
func (h *SpeakingHandler) GetSpeakingProgress(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		common.ErrorResponse(c, http.StatusUnauthorized, "用户未认证")
		return
	}

	scenarioID := c.Param("scenario_id")
	if scenarioID == "" {
		common.ErrorResponse(c, http.StatusBadRequest, "场景ID不能为空")
		return
	}

	progress, err := h.speakingService.GetSpeakingProgress(userID.(string), scenarioID)
	if err != nil {
		common.ErrorResponse(c, http.StatusInternalServerError, "获取口语学习进度失败")
		return
	}

	common.SuccessResponse(c, progress)
}