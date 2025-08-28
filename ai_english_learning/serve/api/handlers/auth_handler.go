package handlers

import (
	"net/http"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/middleware"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/services"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/utils"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

type AuthHandler struct {
	userService *services.UserService
	validator   *validator.Validate
}

func NewAuthHandler(userService *services.UserService) *AuthHandler {
	return &AuthHandler{
		userService: userService,
		validator:   validator.New(),
	}
}

// RegisterRequest 注册请求结构
type RegisterRequest struct {
	Username string `json:"username" validate:"required,min=3,max=20"`
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
	Nickname string `json:"nickname" validate:"required,min=1,max=50"`
}

// LoginRequest 登录请求结构
type LoginRequest struct {
	Account  string `json:"account" validate:"required"` // 用户名或邮箱
	Password string `json:"password" validate:"required"`
}

// RefreshTokenRequest 刷新令牌请求结构
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

// ChangePasswordRequest 修改密码请求结构
type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" validate:"required"`
	NewPassword string `json:"new_password" validate:"required,min=6"`
}

// AuthResponse 认证响应结构
type AuthResponse struct {
	User         *UserInfo `json:"user"`
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
	ExpiresIn    int64     `json:"expires_in"`
}

// UserInfo 用户信息结构
type UserInfo struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Nickname string `json:"nickname"`
	Avatar   string `json:"avatar"`
	Level    string `json:"level"`
	Status   string `json:"status"`
}

// Register 用户注册
func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 验证邮箱格式
	if !utils.IsValidEmail(req.Email) {
		common.BadRequestResponse(c, "邮箱格式不正确")
		return
	}

	// 验证密码强度
	if !utils.IsStrongPassword(req.Password) {
		common.BadRequestResponse(c, "密码强度不足，至少8位且包含大小写字母、数字和特殊字符")
		return
	}

	// 创建用户
	user, err := h.userService.CreateUser(req.Username, req.Email, req.Password)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "用户创建失败")
		return
	}

	// 生成令牌
	accessToken, refreshToken, err := middleware.GenerateTokens(user.ID, user.Username, user.Email)
	if err != nil {
		common.InternalServerErrorResponse(c, "令牌生成失败")
		return
	}

	// 更新用户登录信息
	h.userService.UpdateLoginInfo(user.ID, utils.GetClientIP(c))

	// 构造响应
	nickname := ""
	if user.Nickname != nil {
		nickname = *user.Nickname
	}
	avatar := ""
	if user.Avatar != nil {
		avatar = *user.Avatar
	}

	userInfo := &UserInfo{
		ID:       user.ID,
		Username: user.Username,
		Email:    user.Email,
		Nickname: nickname,
		Avatar:   avatar,
		Level:    "beginner",
		Status:   user.Status,
	}

	response := &AuthResponse{
		User:         userInfo,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    7200, // 2小时
	}

	common.SuccessResponse(c, response)
}

// Login 用户登录
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 根据账号类型获取用户
	var user *models.User
	var err error

	if utils.IsValidEmail(req.Account) {
		user, err = h.userService.GetUserByEmail(req.Account)
	} else {
		user, err = h.userService.GetUserByUsername(req.Account)
	}

	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "用户查询失败")
		return
	}

	// 验证密码
	if !utils.CheckPasswordHash(req.Password, user.PasswordHash) {
		common.BadRequestResponse(c, "密码错误")
		return
	}

	// 检查用户状态
	if user.Status != "active" {
		common.BadRequestResponse(c, "用户已被禁用")
		return
	}

	// 生成令牌
	accessToken, refreshToken, err := middleware.GenerateTokens(user.ID, user.Username, user.Email)
	if err != nil {
		common.InternalServerErrorResponse(c, "令牌生成失败")
		return
	}

	// 更新用户登录信息
	h.userService.UpdateLoginInfo(user.ID, utils.GetClientIP(c))

	// 构造响应
	nickname := ""
	if user.Nickname != nil {
		nickname = *user.Nickname
	}
	avatar := ""
	if user.Avatar != nil {
		avatar = *user.Avatar
	}

	userInfo := &UserInfo{
		ID:       user.ID,
		Username: user.Username,
		Email:    user.Email,
		Nickname: nickname,
		Avatar:   avatar,
		Level:    "beginner",
		Status:   user.Status,
	}

	response := &AuthResponse{
		User:         userInfo,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    7200, // 2小时
	}

	common.SuccessResponse(c, response)
}

// RefreshToken 刷新访问令牌
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var req RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 验证刷新令牌
	claims, err := middleware.ParseToken(req.RefreshToken)
	if err != nil {
		common.BadRequestResponse(c, "无效的刷新令牌")
		return
	}

	// 检查令牌类型
	if claims.Type != "refresh" {
		common.BadRequestResponse(c, "令牌类型错误")
		return
	}

	// 生成新的令牌
	accessToken, newRefreshToken, err := middleware.GenerateTokens(claims.UserID, claims.Username, claims.Email)
	if err != nil {
		common.InternalServerErrorResponse(c, "令牌生成失败")
		return
	}

	response := map[string]interface{}{
		"access_token":  accessToken,
		"refresh_token": newRefreshToken,
		"expires_in":    7200,
	}

	common.SuccessResponse(c, response)
}

// Logout 用户登出
func (h *AuthHandler) Logout(c *gin.Context) {
	// 这里可以实现令牌黑名单机制
	// 目前简单返回成功
	common.SuccessResponse(c, map[string]string{"message": "登出成功"})
}

// GetProfile 获取用户资料
func (h *AuthHandler) GetProfile(c *gin.Context) {
	// 获取当前用户ID
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
		common.InternalServerErrorResponse(c, "用户查询失败")
		return
	}

	nickname := ""
	if user.Nickname != nil {
		nickname = *user.Nickname
	}
	avatar := ""
	if user.Avatar != nil {
		avatar = *user.Avatar
	}

	userInfo := &UserInfo{
		ID:       user.ID,
		Username: user.Username,
		Email:    user.Email,
		Nickname: nickname,
		Avatar:   avatar,
		Level:    "beginner",
		Status:   user.Status,
	}

	common.SuccessResponse(c, userInfo)
}

// ChangePassword 修改密码
func (h *AuthHandler) ChangePassword(c *gin.Context) {
	// 获取当前用户ID
	userID, exists := utils.GetUserIDFromContext(c)
	if !exists {
		common.BadRequestResponse(c, "请先登录")
		return
	}

	var req ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		common.ValidationErrorResponse(c, err)
		return
	}

	// 验证新密码强度
	if !utils.IsStrongPassword(req.NewPassword) {
		common.BadRequestResponse(c, "新密码强度不够")
		return
	}

	// 更新密码
	err := h.userService.UpdatePassword(userID, req.OldPassword, req.NewPassword)
	if err != nil {
		if businessErr, ok := err.(*common.BusinessError); ok {
			common.ErrorResponse(c, http.StatusBadRequest, businessErr.Message)
			return
		}
		common.InternalServerErrorResponse(c, "密码更新失败")
		return
	}

	common.SuccessResponse(c, map[string]string{"message": "密码修改成功"})
}