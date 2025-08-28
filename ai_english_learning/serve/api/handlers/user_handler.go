package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/services"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/utils"
)

// UserHandler 用户处理器
type UserHandler struct {
	userService *services.UserService
	validator   *validator.Validate
}

// NewUserHandler 创建用户处理器实例
func NewUserHandler(userService *services.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
		validator:   validator.New(),
	}
}

// UpdateUserRequest 更新用户信息请求结构
type UpdateUserRequest struct {
	Username string `json:"username" validate:"omitempty,min=3,max=20"`
	Email    string `json:"email" validate:"omitempty,email"`
	Nickname string `json:"nickname" validate:"omitempty,min=1,max=50"`
	Avatar   string `json:"avatar" validate:"omitempty,url"`
	Timezone string `json:"timezone" validate:"omitempty"`
	Language string `json:"language" validate:"omitempty"`
}

// UpdateUserPreferencesRequest 更新用户偏好设置请求结构
type UpdateUserPreferencesRequest struct {
	DailyGoal       int    `json:"daily_goal" validate:"omitempty,min=1,max=1000"`
	WeeklyGoal      int    `json:"weekly_goal" validate:"omitempty,min=1,max=7000"`
	ReminderEnabled bool   `json:"reminder_enabled"`
	DifficultyLevel string `json:"difficulty_level" validate:"omitempty,oneof=beginner intermediate advanced"`
	LearningMode    string `json:"learning_mode" validate:"omitempty,oneof=casual intensive exam"`
}

// UserStatsResponse 用户学习统计响应结构
type UserStatsResponse struct {
	TotalWords      int `json:"total_words"`
	LearnedWords    int `json:"learned_words"`
	MasteredWords   int `json:"mastered_words"`
	StudyDays       int `json:"study_days"`
	ConsecutiveDays int `json:"consecutive_days"`
	TotalStudyTime  int `json:"total_study_time"` // 分钟
}

// GetUserProfile 获取用户信息
func (h *UserHandler) GetUserProfile(c *gin.Context) {
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	user, err := h.userService.GetUserByID(userID)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "获取用户信息失败")
		return
	}

	// 获取用户偏好设置
	preferences, err := h.userService.GetUserPreferences(userID)
	if err != nil {
		// 偏好设置获取失败不影响用户信息返回，记录日志即可
		preferences = nil
	}

	// 构造响应数据
	response := map[string]interface{}{
		"id":         user.ID,
		"username":   user.Username,
		"email":      user.Email,
		"nickname":   user.Nickname,
		"avatar":     user.Avatar,
		"timezone":   user.Timezone,
		"language":   user.Language,
		"status":     user.Status,
		"created_at": user.CreatedAt,
		"updated_at": user.UpdatedAt,
	}

	if preferences != nil {
		response["preferences"] = map[string]interface{}{
			"daily_goal":       preferences.DailyGoal,
			"weekly_goal":      preferences.WeeklyGoal,
			"reminder_enabled": preferences.ReminderEnabled,
			"difficulty_level": preferences.DifficultyLevel,
			"learning_mode":    preferences.LearningMode,
		}
	}

	common.SuccessResponse(c, response)
}

// UpdateUserProfile 更新用户信息
func (h *UserHandler) UpdateUserProfile(c *gin.Context) {
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	var req UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 构造更新数据
	updates := make(map[string]interface{})
	if req.Username != "" {
		updates["username"] = req.Username
	}
	if req.Email != "" {
		updates["email"] = req.Email
	}
	if req.Nickname != "" {
		updates["nickname"] = req.Nickname
	}
	if req.Avatar != "" {
		updates["avatar"] = req.Avatar
	}
	if req.Timezone != "" {
		updates["timezone"] = req.Timezone
	}
	if req.Language != "" {
		updates["language"] = req.Language
	}

	if len(updates) == 0 {
		common.BadRequestResponse(c, "没有需要更新的字段")
		return
	}

	// 更新用户信息
	user, err := h.userService.UpdateUser(userID, updates)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "更新用户信息失败")
		return
	}

	common.SuccessResponse(c, user)
}

// UpdateUserPreferences 更新用户偏好设置
func (h *UserHandler) UpdateUserPreferences(c *gin.Context) {
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	var req UpdateUserPreferencesRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 构造更新数据
	updates := make(map[string]interface{})
	if req.DailyGoal > 0 {
		updates["daily_goal"] = req.DailyGoal
	}
	if req.WeeklyGoal > 0 {
		updates["weekly_goal"] = req.WeeklyGoal
	}
	updates["reminder_enabled"] = req.ReminderEnabled
	if req.DifficultyLevel != "" {
		updates["difficulty_level"] = req.DifficultyLevel
	}
	if req.LearningMode != "" {
		updates["learning_mode"] = req.LearningMode
	}

	// 更新用户偏好设置
	preferences, err := h.userService.UpdateUserPreferences(userID, updates)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "更新偏好设置失败")
		return
	}

	common.SuccessResponse(c, preferences)
}

// GetUserStats 获取用户学习统计
func (h *UserHandler) GetUserStats(c *gin.Context) {
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	// 获取时间范围参数
	timeRange := c.DefaultQuery("time_range", "all") // all, week, month, year

	// 这里需要实现具体的统计逻辑，暂时返回模拟数据
	// TODO: 实现真实的统计查询，使用userID和timeRange参数
	_ = userID    // 避免未使用变量错误
	_ = timeRange // 避免未使用变量错误
	stats := &UserStatsResponse{
		TotalWords:      1000,
		LearnedWords:    750,
		MasteredWords:   500,
		StudyDays:       30,
		ConsecutiveDays: 7,
		TotalStudyTime:  1800, // 30小时
	}

	common.SuccessResponse(c, stats)
}

// GetUserLearningProgress 获取用户学习进度
func (h *UserHandler) GetUserLearningProgress(c *gin.Context) {
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	// 获取分页参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}

	// 获取过滤参数
	masteryLevel := c.Query("mastery_level")
	categoryID := c.Query("category_id")

	// 这里需要调用词汇服务获取用户的学习进度
	// TODO: 实现获取用户学习进度的逻辑，使用userID参数
	_ = userID // 避免未使用变量错误
	response := map[string]interface{}{
		"progress": []interface{}{},
		"pagination": map[string]interface{}{
			"page":       page,
			"limit":      limit,
			"total":      0,
			"total_page": 0,
		},
		"filters": map[string]interface{}{
			"mastery_level": masteryLevel,
			"category_id":   categoryID,
		},
	}

	common.SuccessResponse(c, response)
}