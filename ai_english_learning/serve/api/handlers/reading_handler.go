package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/services"
	"github.com/gin-gonic/gin"
)

// ReadingHandler 阅读理解处理器
type ReadingHandler struct {
	readingService *services.ReadingService
}

// NewReadingHandler 创建阅读理解处理器实例
func NewReadingHandler(readingService *services.ReadingService) *ReadingHandler {
	return &ReadingHandler{
		readingService: readingService,
	}
}

// ===== 请求结构体定义 =====

// CreateReadingMaterialRequest 创建阅读材料请求
type CreateReadingMaterialRequest struct {
	Title     string `json:"title" binding:"required"`
	Content   string `json:"content" binding:"required"`
	Summary   string `json:"summary"`
	Level     string `json:"level" binding:"required,oneof=beginner intermediate advanced"`
	Category  string `json:"category" binding:"required"`
	WordCount int    `json:"word_count"`
	Tags      string `json:"tags"`
	Source    string `json:"source"`
	Author    string `json:"author"`
}

// UpdateReadingMaterialRequest 更新阅读材料请求
type UpdateReadingMaterialRequest struct {
	Title     *string `json:"title"`
	Content   *string `json:"content"`
	Summary   *string `json:"summary"`
	Level     *string `json:"level"`
	Category  *string `json:"category"`
	WordCount *int    `json:"word_count"`
	Tags      *string `json:"tags"`
	Source    *string `json:"source"`
	Author    *string `json:"author"`
}

// CreateReadingRecordRequest 创建阅读记录请求
type CreateReadingRecordRequest struct {
	MaterialID string `json:"material_id" binding:"required"`
}

// UpdateReadingRecordRequest 更新阅读记录请求
type UpdateReadingRecordRequest struct {
	ReadingTime        *int       `json:"reading_time"`
	ComprehensionScore *float64   `json:"comprehension_score"`
	ReadingSpeed       *float64   `json:"reading_speed"`
	Notes              *string    `json:"notes"`
	CompletedAt        *time.Time `json:"completed_at"`
}

// ===== 阅读材料管理接口 =====

// GetReadingMaterials 获取阅读材料列表
// @Summary 获取阅读材料列表
// @Description 获取阅读材料列表，支持按难度级别和分类筛选
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param level query string false "难度级别"
// @Param category query string false "分类"
// @Param page query int false "页码" default(1)
// @Param page_size query int false "每页数量" default(10)
// @Success 200 {object} Response
// @Router /reading/materials [get]
func (h *ReadingHandler) GetReadingMaterials(c *gin.Context) {
	level := c.Query("level")
	category := c.Query("category")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 10
	}

	materials, total, err := h.readingService.GetReadingMaterials(level, category, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取阅读材料失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": materials,
		"pagination": gin.H{
			"page":       page,
			"page_size":  pageSize,
			"total":      total,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	})
}

// GetReadingMaterial 获取单个阅读材料
// @Summary 获取单个阅读材料
// @Description 根据ID获取阅读材料详情
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param id path string true "材料ID"
// @Success 200 {object} Response
// @Router /reading/materials/{id} [get]
func (h *ReadingHandler) GetReadingMaterial(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "材料ID不能为空"})
		return
	}

	material, err := h.readingService.GetReadingMaterial(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "阅读材料不存在",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": material})
}

// CreateReadingMaterial 创建阅读材料
// @Summary 创建阅读材料
// @Description 创建新的阅读材料
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param request body CreateReadingMaterialRequest true "创建请求"
// @Success 201 {object} Response
// @Router /reading/materials [post]
func (h *ReadingHandler) CreateReadingMaterial(c *gin.Context) {
	var req CreateReadingMaterialRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	material := &models.ReadingMaterial{
		Title:     req.Title,
		Content:   req.Content,
		Summary:   &req.Summary,
		WordCount: req.WordCount,
		Level:     req.Level,
		Category:  req.Category,
		Tags:      &req.Tags,
		Source:    &req.Source,
		Author:    &req.Author,
		IsActive:  true,
	}

	if err := h.readingService.CreateReadingMaterial(material); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建阅读材料失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "阅读材料创建成功",
		"data": material,
	})
}

// UpdateReadingMaterial 更新阅读材料
// @Summary 更新阅读材料
// @Description 更新阅读材料信息
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param id path string true "材料ID"
// @Param request body UpdateReadingMaterialRequest true "更新请求"
// @Success 200 {object} Response
// @Router /reading/materials/{id} [put]
func (h *ReadingHandler) UpdateReadingMaterial(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "材料ID不能为空"})
		return
	}

	var req UpdateReadingMaterialRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	updates := make(map[string]interface{})
	if req.Title != nil {
		updates["title"] = *req.Title
	}
	if req.Content != nil {
		updates["content"] = *req.Content
	}
	if req.Summary != nil {
		updates["summary"] = *req.Summary
	}
	if req.Level != nil {
		updates["level"] = *req.Level
	}
	if req.Category != nil {
		updates["category"] = *req.Category
	}
	if req.WordCount != nil {
		updates["word_count"] = *req.WordCount
	}
	if req.Tags != nil {
		updates["tags"] = *req.Tags
	}
	if req.Source != nil {
		updates["source"] = *req.Source
	}
	if req.Author != nil {
		updates["author"] = *req.Author
	}

	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "没有提供更新字段"})
		return
	}

	if err := h.readingService.UpdateReadingMaterial(id, updates); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "更新阅读材料失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "阅读材料更新成功"})
}

// DeleteReadingMaterial 删除阅读材料
// @Summary 删除阅读材料
// @Description 软删除阅读材料
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param id path string true "材料ID"
// @Success 200 {object} Response
// @Router /reading/materials/{id} [delete]
func (h *ReadingHandler) DeleteReadingMaterial(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "材料ID不能为空"})
		return
	}

	if err := h.readingService.DeleteReadingMaterial(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "删除阅读材料失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "阅读材料删除成功"})
}

// SearchReadingMaterials 搜索阅读材料
// @Summary 搜索阅读材料
// @Description 根据关键词搜索阅读材料
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param keyword query string true "搜索关键词"
// @Param level query string false "难度级别"
// @Param category query string false "分类"
// @Param page query int false "页码" default(1)
// @Param page_size query int false "每页数量" default(10)
// @Success 200 {object} Response
// @Router /reading/materials/search [get]
func (h *ReadingHandler) SearchReadingMaterials(c *gin.Context) {
	keyword := c.Query("keyword")
	if keyword == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "搜索关键词不能为空"})
		return
	}

	level := c.Query("level")
	category := c.Query("category")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 10
	}

	materials, total, err := h.readingService.SearchReadingMaterials(keyword, level, category, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "搜索阅读材料失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": materials,
		"pagination": gin.H{
			"page":       page,
			"page_size":  pageSize,
			"total":      total,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	})
}

// ===== 阅读记录管理接口 =====

// CreateReadingRecord 创建阅读记录
// @Summary 创建阅读记录
// @Description 开始阅读材料，创建阅读记录
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param request body CreateReadingRecordRequest true "创建请求"
// @Success 201 {object} Response
// @Router /reading/records [post]
func (h *ReadingHandler) CreateReadingRecord(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	var req CreateReadingRecordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 检查是否已有该材料的阅读记录
	existingRecord, err := h.readingService.GetReadingProgress(userID.(string), req.MaterialID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "检查阅读记录失败",
			"details": err.Error(),
		})
		return
	}

	if existingRecord != nil {
		c.JSON(http.StatusOK, gin.H{
			"message": "阅读记录已存在",
			"data": existingRecord,
		})
		return
	}

	record := &models.ReadingRecord{
		UserID:     userID.(string),
		MaterialID: req.MaterialID,
	}

	if err := h.readingService.CreateReadingRecord(record); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建阅读记录失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "阅读记录创建成功",
		"data": record,
	})
}

// UpdateReadingRecord 更新阅读记录
// @Summary 更新阅读记录
// @Description 更新阅读进度和成绩
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param id path string true "记录ID"
// @Param request body UpdateReadingRecordRequest true "更新请求"
// @Success 200 {object} Response
// @Router /reading/records/{id} [put]
func (h *ReadingHandler) UpdateReadingRecord(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "记录ID不能为空"})
		return
	}

	var req UpdateReadingRecordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	updates := make(map[string]interface{})
	if req.ReadingTime != nil {
		updates["reading_time"] = *req.ReadingTime
	}
	if req.ComprehensionScore != nil {
		updates["comprehension_score"] = *req.ComprehensionScore
	}
	if req.ReadingSpeed != nil {
		updates["reading_speed"] = *req.ReadingSpeed
	}
	if req.Notes != nil {
		updates["notes"] = *req.Notes
	}
	if req.CompletedAt != nil {
		updates["completed_at"] = *req.CompletedAt
	}

	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "没有提供更新字段"})
		return
	}

	if err := h.readingService.UpdateReadingRecord(id, updates); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "更新阅读记录失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "阅读记录更新成功"})
}

// GetUserReadingRecords 获取用户阅读记录
// @Summary 获取用户阅读记录
// @Description 获取当前用户的阅读记录列表
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param page query int false "页码" default(1)
// @Param page_size query int false "每页数量" default(10)
// @Success 200 {object} Response
// @Router /reading/records [get]
func (h *ReadingHandler) GetUserReadingRecords(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 10
	}

	records, total, err := h.readingService.GetUserReadingRecords(userID.(string), page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取阅读记录失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": records,
		"pagination": gin.H{
			"page":       page,
			"page_size":  pageSize,
			"total":      total,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	})
}

// GetReadingRecord 获取单个阅读记录
// @Summary 获取单个阅读记录
// @Description 根据ID获取阅读记录详情
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param id path string true "记录ID"
// @Success 200 {object} Response
// @Router /reading/records/{id} [get]
func (h *ReadingHandler) GetReadingRecord(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "记录ID不能为空"})
		return
	}

	record, err := h.readingService.GetReadingRecord(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "阅读记录不存在",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": record})
}

// GetReadingProgress 获取阅读进度
// @Summary 获取阅读进度
// @Description 获取用户对特定材料的阅读进度
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param material_id path string true "材料ID"
// @Success 200 {object} Response
// @Router /reading/progress/{material_id} [get]
func (h *ReadingHandler) GetReadingProgress(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	materialID := c.Param("material_id")
	if materialID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "材料ID不能为空"})
		return
	}

	record, err := h.readingService.GetReadingProgress(userID.(string), materialID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取阅读进度失败",
			"details": err.Error(),
		})
		return
	}

	if record == nil {
		c.JSON(http.StatusOK, gin.H{
			"data": nil,
			"message": "暂无阅读记录",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": record})
}

// ===== 阅读统计接口 =====

// GetReadingStats 获取阅读统计
// @Summary 获取阅读统计
// @Description 获取用户阅读统计信息
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Success 200 {object} Response
// @Router /reading/stats [get]
func (h *ReadingHandler) GetReadingStats(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	stats, err := h.readingService.GetUserReadingStats(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取阅读统计失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": stats})
}

// GetRecommendedMaterials 获取推荐阅读材料
// @Summary 获取推荐阅读材料
// @Description 根据用户阅读历史推荐合适的阅读材料
// @Tags 阅读理解
// @Accept json
// @Produce json
// @Param limit query int false "推荐数量" default(5)
// @Success 200 {object} Response
// @Router /reading/recommendations [get]
func (h *ReadingHandler) GetRecommendedMaterials(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户未认证"})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "5"))
	if limit < 1 || limit > 20 {
		limit = 5
	}

	materials, err := h.readingService.GetRecommendedMaterials(userID.(string), limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取推荐材料失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": materials})
}