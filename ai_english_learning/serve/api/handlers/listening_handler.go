package handlers

import (
	"net/http"
	"strconv"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

// ListeningHandler 听力训练处理器
type ListeningHandler struct {
	listeningService *services.ListeningService
	validate         *validator.Validate
}

// NewListeningHandler 创建听力训练处理器实例
func NewListeningHandler(listeningService *services.ListeningService, validate *validator.Validate) *ListeningHandler {
	return &ListeningHandler{
		listeningService: listeningService,
		validate:         validate,
	}
}

// CreateMaterialRequest 创建听力材料请求
type CreateMaterialRequest struct {
	Title       string  `json:"title" validate:"required,max=200"`
	Description *string `json:"description"`
	AudioURL    string  `json:"audio_url" validate:"required,url,max=500"`
	Transcript  *string `json:"transcript"`
	Duration    int     `json:"duration" validate:"min=0"`
	Level       string  `json:"level" validate:"required,oneof=beginner intermediate advanced"`
	Category    string  `json:"category" validate:"max=50"`
	Tags        *string `json:"tags"`
}

// UpdateMaterialRequest 更新听力材料请求
type UpdateMaterialRequest struct {
	Title       *string `json:"title" validate:"omitempty,max=200"`
	Description *string `json:"description"`
	AudioURL    *string `json:"audio_url" validate:"omitempty,url,max=500"`
	Transcript  *string `json:"transcript"`
	Duration    *int    `json:"duration" validate:"omitempty,min=0"`
	Level       *string `json:"level" validate:"omitempty,oneof=beginner intermediate advanced"`
	Category    *string `json:"category" validate:"omitempty,max=50"`
	Tags        *string `json:"tags"`
}

// CreateRecordRequest 创建听力练习记录请求
type CreateRecordRequest struct {
	MaterialID string `json:"material_id" validate:"required"`
}

// UpdateRecordRequest 更新听力练习记录请求
type UpdateRecordRequest struct {
	Score          *float64 `json:"score" validate:"omitempty,min=0,max=100"`
	Accuracy       *float64 `json:"accuracy" validate:"omitempty,min=0,max=100"`
	CompletionRate *float64 `json:"completion_rate" validate:"omitempty,min=0,max=100"`
	TimeSpent      *int     `json:"time_spent" validate:"omitempty,min=0"`
	Answers        *string  `json:"answers"`
	Feedback       *string  `json:"feedback"`
	Completed      *bool    `json:"completed"`
}

// GetListeningMaterials 获取听力材料列表
func (h *ListeningHandler) GetListeningMaterials(c *gin.Context) {
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

	materials, total, err := h.listeningService.GetListeningMaterials(level, category, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "获取听力材料失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data": gin.H{
			"materials":  materials,
			"total":      total,
			"page":       page,
			"page_size":  pageSize,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	})
}

// GetListeningMaterial 获取单个听力材料
func (h *ListeningHandler) GetListeningMaterial(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "材料ID不能为空",
		})
		return
	}

	material, err := h.listeningService.GetListeningMaterial(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"code":    404,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data":    material,
	})
}

// CreateListeningMaterial 创建听力材料
func (h *ListeningHandler) CreateListeningMaterial(c *gin.Context) {
	var req CreateMaterialRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "请求参数错误",
			"error":   err.Error(),
		})
		return
	}

	if err := h.validate.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "参数验证失败",
			"error":   err.Error(),
		})
		return
	}

	material := &models.ListeningMaterial{
		Title:       req.Title,
		Description: req.Description,
		AudioURL:    req.AudioURL,
		Transcript:  req.Transcript,
		Duration:    req.Duration,
		Level:       req.Level,
		Category:    req.Category,
		Tags:        req.Tags,
	}

	if err := h.listeningService.CreateListeningMaterial(material); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "创建听力材料失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "创建成功",
		"data":    material,
	})
}

// UpdateListeningMaterial 更新听力材料
func (h *ListeningHandler) UpdateListeningMaterial(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "材料ID不能为空",
		})
		return
	}

	var req UpdateMaterialRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "请求参数错误",
			"error":   err.Error(),
		})
		return
	}

	if err := h.validate.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "参数验证失败",
			"error":   err.Error(),
		})
		return
	}

	updates := make(map[string]interface{})
	if req.Title != nil {
		updates["title"] = *req.Title
	}
	if req.Description != nil {
		updates["description"] = *req.Description
	}
	if req.AudioURL != nil {
		updates["audio_url"] = *req.AudioURL
	}
	if req.Transcript != nil {
		updates["transcript"] = *req.Transcript
	}
	if req.Duration != nil {
		updates["duration"] = *req.Duration
	}
	if req.Level != nil {
		updates["level"] = *req.Level
	}
	if req.Category != nil {
		updates["category"] = *req.Category
	}
	if req.Tags != nil {
		updates["tags"] = *req.Tags
	}

	if err := h.listeningService.UpdateListeningMaterial(id, updates); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "更新听力材料失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "更新成功",
	})
}

// DeleteListeningMaterial 删除听力材料
func (h *ListeningHandler) DeleteListeningMaterial(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "材料ID不能为空",
		})
		return
	}

	if err := h.listeningService.DeleteListeningMaterial(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "删除听力材料失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "删除成功",
	})
}

// SearchListeningMaterials 搜索听力材料
func (h *ListeningHandler) SearchListeningMaterials(c *gin.Context) {
	keyword := c.Query("q")
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

	materials, total, err := h.listeningService.SearchListeningMaterials(keyword, level, category, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "搜索听力材料失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "搜索成功",
		"data": gin.H{
			"materials":  materials,
			"total":      total,
			"page":       page,
			"page_size":  pageSize,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	})
}

// CreateListeningRecord 创建听力练习记录
func (h *ListeningHandler) CreateListeningRecord(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "未授权访问",
		})
		return
	}

	var req CreateRecordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "请求参数错误",
			"error":   err.Error(),
		})
		return
	}

	if err := h.validate.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "参数验证失败",
			"error":   err.Error(),
		})
		return
	}

	record := &models.ListeningRecord{
		UserID:     userID.(string),
		MaterialID: req.MaterialID,
	}

	if err := h.listeningService.CreateListeningRecord(record); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "创建听力练习记录失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "创建成功",
		"data":    record,
	})
}

// UpdateListeningRecord 更新听力练习记录
func (h *ListeningHandler) UpdateListeningRecord(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "记录ID不能为空",
		})
		return
	}

	var req UpdateRecordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "请求参数错误",
			"error":   err.Error(),
		})
		return
	}

	if err := h.validate.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "参数验证失败",
			"error":   err.Error(),
		})
		return
	}

	updates := make(map[string]interface{})
	if req.Score != nil {
		updates["score"] = *req.Score
	}
	if req.Accuracy != nil {
		updates["accuracy"] = *req.Accuracy
	}
	if req.CompletionRate != nil {
		updates["completion_rate"] = *req.CompletionRate
	}
	if req.TimeSpent != nil {
		updates["time_spent"] = *req.TimeSpent
	}
	if req.Answers != nil {
		updates["answers"] = *req.Answers
	}
	if req.Feedback != nil {
		updates["feedback"] = *req.Feedback
	}
	if req.Completed != nil && *req.Completed {
		updates["completed_at"] = true // 这会在service中被处理为实际时间
	}

	if err := h.listeningService.UpdateListeningRecord(id, updates); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "更新听力练习记录失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "更新成功",
	})
}

// GetUserListeningRecords 获取用户听力练习记录
func (h *ListeningHandler) GetUserListeningRecords(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "未授权访问",
		})
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

	records, total, err := h.listeningService.GetUserListeningRecords(userID.(string), page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "获取听力练习记录失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data": gin.H{
			"records":    records,
			"total":      total,
			"page":       page,
			"page_size":  pageSize,
			"total_pages": (total + int64(pageSize) - 1) / int64(pageSize),
		},
	})
}

// GetListeningRecord 获取单个听力练习记录
func (h *ListeningHandler) GetListeningRecord(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "记录ID不能为空",
		})
		return
	}

	record, err := h.listeningService.GetListeningRecord(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"code":    404,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data":    record,
	})
}

// GetUserListeningStats 获取用户听力学习统计
func (h *ListeningHandler) GetUserListeningStats(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "未授权访问",
		})
		return
	}

	stats, err := h.listeningService.GetUserListeningStats(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "获取听力学习统计失败",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data":    stats,
	})
}

// GetListeningProgress 获取用户在特定材料上的学习进度
func (h *ListeningHandler) GetListeningProgress(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": "未授权访问",
		})
		return
	}

	materialID := c.Param("material_id")
	if materialID == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "材料ID不能为空",
		})
		return
	}

	progress, err := h.listeningService.GetListeningProgress(userID.(string), materialID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    500,
			"message": "获取学习进度失败",
			"error":   err.Error(),
		})
		return
	}

	if progress == nil {
		c.JSON(http.StatusOK, gin.H{
			"code":    200,
			"message": "暂无学习记录",
			"data":    nil,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取成功",
		"data":    progress,
	})
}