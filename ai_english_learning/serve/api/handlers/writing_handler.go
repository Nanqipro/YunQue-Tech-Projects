package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// WritingHandler 写作练习处理器
type WritingHandler struct {
	writingService *services.WritingService
}

// NewWritingHandler 创建写作练习处理器实例
func NewWritingHandler(writingService *services.WritingService) *WritingHandler {
	return &WritingHandler{
		writingService: writingService,
	}
}

// ===== 请求和响应结构体 =====

// CreateWritingPromptRequest 创建写作题目请求
type CreateWritingPromptRequest struct {
	Title        string  `json:"title" binding:"required"`
	Prompt       string  `json:"prompt" binding:"required"`
	Instructions *string `json:"instructions"`
	MinWords     *int    `json:"min_words"`
	MaxWords     *int    `json:"max_words"`
	TimeLimit    *int    `json:"time_limit"`
	Level        string  `json:"level" binding:"required"`
	Category     string  `json:"category"`
	Tags         *string `json:"tags"`
	SampleAnswer *string `json:"sample_answer"`
	Rubric       *string `json:"rubric"`
}

// UpdateWritingPromptRequest 更新写作题目请求
type UpdateWritingPromptRequest struct {
	Title        *string `json:"title"`
	Prompt       *string `json:"prompt"`
	Instructions *string `json:"instructions"`
	MinWords     *int    `json:"min_words"`
	MaxWords     *int    `json:"max_words"`
	TimeLimit    *int    `json:"time_limit"`
	Level        *string `json:"level"`
	Category     *string `json:"category"`
	Tags         *string `json:"tags"`
	SampleAnswer *string `json:"sample_answer"`
	Rubric       *string `json:"rubric"`
}

// CreateWritingSubmissionRequest 创建写作提交请求
type CreateWritingSubmissionRequest struct {
	PromptID string `json:"prompt_id" binding:"required"`
}

// SubmitWritingRequest 提交写作请求
type SubmitWritingRequest struct {
	Content   string `json:"content" binding:"required"`
	TimeSpent int    `json:"time_spent" binding:"required"`
}

// GradeWritingRequest AI批改请求
type GradeWritingRequest struct {
	Score          float64 `json:"score" binding:"required,min=0,max=100"`
	GrammarScore   float64 `json:"grammar_score" binding:"required,min=0,max=100"`
	VocabScore     float64 `json:"vocab_score" binding:"required,min=0,max=100"`
	CoherenceScore float64 `json:"coherence_score" binding:"required,min=0,max=100"`
	Feedback       string  `json:"feedback" binding:"required"`
	Suggestions    string  `json:"suggestions"`
}

// Response 通用响应结构
type Response struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// ===== 写作题目管理接口 =====

// GetWritingPrompts 获取写作题目列表
// @Summary 获取写作题目列表
// @Description 获取写作题目列表，支持按难度和分类筛选
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param difficulty query string false "难度筛选"
// @Param category query string false "分类筛选"
// @Param page query int false "页码" default(1)
// @Param limit query int false "每页数量" default(10)
// @Success 200 {object} Response
// @Router /writing/prompts [get]
func (h *WritingHandler) GetWritingPrompts(c *gin.Context) {
	difficulty := c.Query("difficulty")
	category := c.Query("category")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	offset := (page - 1) * limit

	prompts, err := h.writingService.GetWritingPrompts(difficulty, category, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取写作题目失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取写作题目成功",
		"data": prompts,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": len(prompts),
		},
	})
}

// GetWritingPrompt 获取单个写作题目
// @Summary 获取写作题目详情
// @Description 根据ID获取写作题目详情
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param id path string true "题目ID"
// @Success 200 {object} Response
// @Router /writing/prompts/{id} [get]
func (h *WritingHandler) GetWritingPrompt(c *gin.Context) {
	id := c.Param("id")

	prompt, err := h.writingService.GetWritingPrompt(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "写作题目不存在",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取写作题目成功",
		"data": prompt,
	})
}

// CreateWritingPrompt 创建写作题目
// @Summary 创建写作题目
// @Description 创建新的写作题目
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param request body CreateWritingPromptRequest true "创建请求"
// @Success 201 {object} Response
// @Router /writing/prompts [post]
func (h *WritingHandler) CreateWritingPrompt(c *gin.Context) {
	var req CreateWritingPromptRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	prompt := &models.WritingPrompt{
		ID:           uuid.New().String(),
		Title:        req.Title,
		Prompt:       req.Prompt,
		Instructions: req.Instructions,
		MinWords:     req.MinWords,
		MaxWords:     req.MaxWords,
		TimeLimit:    req.TimeLimit,
		Level:        req.Level,
		Category:     req.Category,
		Tags:         req.Tags,
		SampleAnswer: req.SampleAnswer,
		Rubric:       req.Rubric,
		IsActive:     true,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	if err := h.writingService.CreateWritingPrompt(prompt); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建写作题目失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "写作题目创建成功",
		"data": prompt,
	})
}

// UpdateWritingPrompt 更新写作题目
// @Summary 更新写作题目
// @Description 更新写作题目信息
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param id path string true "题目ID"
// @Param request body UpdateWritingPromptRequest true "更新请求"
// @Success 200 {object} Response
// @Router /writing/prompts/{id} [put]
func (h *WritingHandler) UpdateWritingPrompt(c *gin.Context) {
	id := c.Param("id")

	var req UpdateWritingPromptRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 检查题目是否存在
	existingPrompt, err := h.writingService.GetWritingPrompt(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "写作题目不存在",
			"details": err.Error(),
		})
		return
	}

	// 构建更新数据
	updateData := &models.WritingPrompt{
		UpdatedAt: time.Now(),
	}

	if req.Title != nil {
		updateData.Title = *req.Title
	}
	if req.Prompt != nil {
		updateData.Prompt = *req.Prompt
	}
	if req.Instructions != nil {
		updateData.Instructions = req.Instructions
	}
	if req.MinWords != nil {
		updateData.MinWords = req.MinWords
	}
	if req.MaxWords != nil {
		updateData.MaxWords = req.MaxWords
	}
	if req.TimeLimit != nil {
		updateData.TimeLimit = req.TimeLimit
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
	if req.SampleAnswer != nil {
		updateData.SampleAnswer = req.SampleAnswer
	}
	if req.Rubric != nil {
		updateData.Rubric = req.Rubric
	}

	if err := h.writingService.UpdateWritingPrompt(id, updateData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "更新写作题目失败",
			"details": err.Error(),
		})
		return
	}

	// 返回更新后的题目
	updatedPrompt, _ := h.writingService.GetWritingPrompt(id)
	c.JSON(http.StatusOK, gin.H{
		"message": "写作题目更新成功",
		"data": updatedPrompt,
		"original": existingPrompt,
	})
}

// DeleteWritingPrompt 删除写作题目
// @Summary 删除写作题目
// @Description 软删除写作题目
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param id path string true "题目ID"
// @Success 200 {object} Response
// @Router /writing/prompts/{id} [delete]
func (h *WritingHandler) DeleteWritingPrompt(c *gin.Context) {
	id := c.Param("id")

	// 检查题目是否存在
	_, err := h.writingService.GetWritingPrompt(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "写作题目不存在",
			"details": err.Error(),
		})
		return
	}

	if err := h.writingService.DeleteWritingPrompt(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "删除写作题目失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "写作题目删除成功",
	})
}

// SearchWritingPrompts 搜索写作题目
// @Summary 搜索写作题目
// @Description 根据关键词搜索写作题目
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param keyword query string true "搜索关键词"
// @Param difficulty query string false "难度筛选"
// @Param category query string false "分类筛选"
// @Param page query int false "页码" default(1)
// @Param limit query int false "每页数量" default(10)
// @Success 200 {object} Response
// @Router /writing/prompts/search [get]
func (h *WritingHandler) SearchWritingPrompts(c *gin.Context) {
	keyword := c.Query("keyword")
	if keyword == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "搜索关键词不能为空",
		})
		return
	}

	difficulty := c.Query("difficulty")
	category := c.Query("category")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	offset := (page - 1) * limit

	prompts, err := h.writingService.SearchWritingPrompts(keyword, difficulty, category, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "搜索写作题目失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "搜索写作题目成功",
		"data": prompts,
		"search_params": gin.H{
			"keyword":    keyword,
			"difficulty": difficulty,
			"category":   category,
		},
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": len(prompts),
		},
	})
}

// GetRecommendedPrompts 获取推荐写作题目
// @Summary 获取推荐写作题目
// @Description 根据用户历史表现推荐合适的写作题目
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param limit query int false "推荐数量" default(5)
// @Success 200 {object} Response
// @Router /writing/prompts/recommendations [get]
func (h *WritingHandler) GetRecommendedPrompts(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "5"))

	prompts, err := h.writingService.GetRecommendedPrompts(userID.(string), limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取推荐题目失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取推荐题目成功",
		"data": prompts,
	})
}

// ===== 写作提交管理接口 =====

// CreateWritingSubmission 创建写作提交
// @Summary 创建写作提交
// @Description 开始写作练习，创建写作提交记录
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param request body CreateWritingSubmissionRequest true "创建请求"
// @Success 201 {object} Response
// @Router /writing/submissions [post]
func (h *WritingHandler) CreateWritingSubmission(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	var req CreateWritingSubmissionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 检查是否已有该题目的提交记录
	existingSubmission, err := h.writingService.GetWritingProgress(userID.(string), req.PromptID)
	if err == nil && existingSubmission != nil {
		c.JSON(http.StatusOK, gin.H{
			"message": "写作提交记录已存在",
			"data": existingSubmission,
		})
		return
	}

	submission := &models.WritingSubmission{
		ID:        uuid.New().String(),
		UserID:    userID.(string),
		PromptID:  req.PromptID,
		StartedAt: time.Now(),
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := h.writingService.CreateWritingSubmission(submission); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建写作提交失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "写作提交创建成功",
		"data": submission,
	})
}

// SubmitWriting 提交写作作业
// @Summary 提交写作作业
// @Description 提交完成的写作内容
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param id path string true "提交ID"
// @Param request body SubmitWritingRequest true "提交请求"
// @Success 200 {object} Response
// @Router /writing/submissions/{id}/submit [put]
func (h *WritingHandler) SubmitWriting(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	submissionID := c.Param("id")

	var req SubmitWritingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 检查提交记录是否存在且属于当前用户
	submission, err := h.writingService.GetWritingSubmission(submissionID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "写作提交不存在",
			"details": err.Error(),
		})
		return
	}

	if submission.UserID != userID.(string) {
		c.JSON(http.StatusForbidden, gin.H{
			"error": "无权限访问此提交记录",
		})
		return
	}

	if submission.SubmittedAt != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "该写作已经提交，无法重复提交",
		})
		return
	}

	if err := h.writingService.SubmitWriting(submissionID, req.Content, req.TimeSpent); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "提交写作失败",
			"details": err.Error(),
		})
		return
	}

	// 返回更新后的提交记录
	updatedSubmission, _ := h.writingService.GetWritingSubmission(submissionID)
	c.JSON(http.StatusOK, gin.H{
		"message": "写作提交成功",
		"data": updatedSubmission,
	})
}

// GradeWriting AI批改写作
// @Summary AI批改写作
// @Description 对提交的写作进行AI批改和评分
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param id path string true "提交ID"
// @Param request body GradeWritingRequest true "批改请求"
// @Success 200 {object} Response
// @Router /writing/submissions/{id}/grade [put]
func (h *WritingHandler) GradeWriting(c *gin.Context) {
	submissionID := c.Param("id")

	var req GradeWritingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 检查提交记录是否存在
	submission, err := h.writingService.GetWritingSubmission(submissionID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "写作提交不存在",
			"details": err.Error(),
		})
		return
	}

	if submission.SubmittedAt == nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "该写作尚未提交，无法批改",
		})
		return
	}

	if submission.GradedAt != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "该写作已经批改，无法重复批改",
		})
		return
	}

	if err := h.writingService.GradeWriting(
		submissionID,
		req.Score,
		req.GrammarScore,
		req.VocabScore,
		req.CoherenceScore,
		req.Feedback,
		req.Suggestions,
	); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "批改写作失败",
			"details": err.Error(),
		})
		return
	}

	// 返回更新后的提交记录
	updatedSubmission, _ := h.writingService.GetWritingSubmission(submissionID)
	c.JSON(http.StatusOK, gin.H{
		"message": "写作批改成功",
		"data": updatedSubmission,
	})
}

// GetWritingSubmission 获取写作提交详情
// @Summary 获取写作提交详情
// @Description 根据ID获取写作提交详情
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param id path string true "提交ID"
// @Success 200 {object} Response
// @Router /writing/submissions/{id} [get]
func (h *WritingHandler) GetWritingSubmission(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	submissionID := c.Param("id")

	submission, err := h.writingService.GetWritingSubmission(submissionID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "写作提交不存在",
			"details": err.Error(),
		})
		return
	}

	// 检查权限
	if submission.UserID != userID.(string) {
		c.JSON(http.StatusForbidden, gin.H{
			"error": "无权限访问此提交记录",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取写作提交成功",
		"data": submission,
	})
}

// GetUserWritingSubmissions 获取用户写作提交列表
// @Summary 获取用户写作提交列表
// @Description 获取当前用户的写作提交列表
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param page query int false "页码" default(1)
// @Param limit query int false "每页数量" default(10)
// @Success 200 {object} Response
// @Router /writing/submissions [get]
func (h *WritingHandler) GetUserWritingSubmissions(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	offset := (page - 1) * limit

	submissions, err := h.writingService.GetUserWritingSubmissions(userID.(string), limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取写作提交列表失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取写作提交列表成功",
		"data": submissions,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": len(submissions),
		},
	})
}

// ===== 写作统计和进度接口 =====

// GetWritingStats 获取用户写作统计
// @Summary 获取用户写作统计
// @Description 获取用户写作学习统计数据
// @Tags 写作练习
// @Accept json
// @Produce json
// @Success 200 {object} Response
// @Router /writing/stats [get]
func (h *WritingHandler) GetWritingStats(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	stats, err := h.writingService.GetUserWritingStats(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取写作统计失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取写作统计成功",
		"data": stats,
	})
}

// GetWritingProgress 获取写作进度
// @Summary 获取写作进度
// @Description 获取用户在特定题目上的写作进度
// @Tags 写作练习
// @Accept json
// @Produce json
// @Param prompt_id path string true "题目ID"
// @Success 200 {object} Response
// @Router /writing/progress/{prompt_id} [get]
func (h *WritingHandler) GetWritingProgress(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	promptID := c.Param("prompt_id")

	progress, err := h.writingService.GetWritingProgress(userID.(string), promptID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "写作进度不存在",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取写作进度成功",
		"data": progress,
	})
}