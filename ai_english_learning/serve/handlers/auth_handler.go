package handlers

import (
	"net/http"
	"strconv"

	"ai_english_learning/models"
	"ai_english_learning/services"
	"ai_english_learning/utils"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

type AuthHandler struct {
	authService *services.AuthService
	validator   *validator.Validate
}

func NewAuthHandler(authService *services.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
		validator:   validator.New(),
	}
}

// Register 用户注册
// @Summary 用户注册
// @Description 用户注册接口
// @Tags 认证
// @Accept json
// @Produce json
// @Param request body models.UserRegisterRequest true "注册信息"
// @Success 200 {object} utils.Response{data=models.UserResponse} "注册成功"
// @Failure 400 {object} utils.Response "请求参数错误"
// @Failure 409 {object} utils.Response "用户已存在"
// @Failure 500 {object} utils.Response "服务器内部错误"
// @Router /api/auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.UserRegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("请求参数错误", err.Error()))
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("参数验证失败", err.Error()))
		return
	}

	// 调用服务层注册用户
	user, err := h.authService.Register(&req)
	if err != nil {
		if err.Error() == "用户名已存在" || err.Error() == "邮箱已被注册" {
			c.JSON(http.StatusConflict, utils.ErrorResponse("注册失败", err.Error()))
		} else {
			c.JSON(http.StatusInternalServerError, utils.ErrorResponse("注册失败", err.Error()))
		}
		return
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("注册成功", user))
}

// Login 用户登录
// @Summary 用户登录
// @Description 用户登录接口
// @Tags 认证
// @Accept json
// @Produce json
// @Param request body models.UserLoginRequest true "登录信息"
// @Success 200 {object} utils.Response{data=models.LoginResponse} "登录成功"
// @Failure 400 {object} utils.Response "请求参数错误"
// @Failure 401 {object} utils.Response "认证失败"
// @Failure 500 {object} utils.Response "服务器内部错误"
// @Router /api/auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.UserLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("请求参数错误", err.Error()))
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("参数验证失败", err.Error()))
		return
	}

	// 调用服务层登录
	loginResp, err := h.authService.Login(&req)
	if err != nil {
		if err.Error() == "用户不存在" || err.Error() == "密码错误" || err.Error() == "账户已被禁用" {
			c.JSON(http.StatusUnauthorized, utils.ErrorResponse("登录失败", err.Error()))
		} else {
			c.JSON(http.StatusInternalServerError, utils.ErrorResponse("登录失败", err.Error()))
		}
		return
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("登录成功", loginResp))
}

// RefreshToken 刷新访问令牌
// @Summary 刷新访问令牌
// @Description 使用刷新令牌获取新的访问令牌
// @Tags 认证
// @Accept json
// @Produce json
// @Param request body models.RefreshTokenRequest true "刷新令牌"
// @Success 200 {object} utils.Response{data=models.RefreshTokenResponse} "刷新成功"
// @Failure 400 {object} utils.Response "请求参数错误"
// @Failure 401 {object} utils.Response "令牌无效"
// @Failure 500 {object} utils.Response "服务器内部错误"
// @Router /api/auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var req models.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("请求参数错误", err.Error()))
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("参数验证失败", err.Error()))
		return
	}

	// 调用服务层刷新token
	refreshResp, err := h.authService.RefreshToken(req.RefreshToken)
	if err != nil {
		if err.Error() == "无效的刷新token" || err.Error() == "用户不存在" || err.Error() == "账户已被禁用" {
			c.JSON(http.StatusUnauthorized, utils.ErrorResponse("刷新失败", err.Error()))
		} else {
			c.JSON(http.StatusInternalServerError, utils.ErrorResponse("刷新失败", err.Error()))
		}
		return
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("刷新成功", refreshResp))
}

// ChangePassword 修改密码
// @Summary 修改密码
// @Description 用户修改密码接口
// @Tags 认证
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param request body models.ChangePasswordRequest true "修改密码信息"
// @Success 200 {object} utils.Response "修改成功"
// @Failure 400 {object} utils.Response "请求参数错误"
// @Failure 401 {object} utils.Response "认证失败"
// @Failure 500 {object} utils.Response "服务器内部错误"
// @Router /api/auth/change-password [post]
func (h *AuthHandler) ChangePassword(c *gin.Context) {
	// 获取当前用户ID
	userIDStr, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, utils.ErrorResponse("未授权", "用户未登录"))
		return
	}

	userID, ok := userIDStr.(uint)
	if !ok {
		c.JSON(http.StatusInternalServerError, utils.ErrorResponse("服务器错误", "用户ID格式错误"))
		return
	}

	var req models.ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("请求参数错误", err.Error()))
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("参数验证失败", err.Error()))
		return
	}

	// 调用服务层修改密码
	if err := h.authService.ChangePassword(userID, &req); err != nil {
		if err.Error() == "用户不存在" || err.Error() == "旧密码错误" {
			c.JSON(http.StatusBadRequest, utils.ErrorResponse("修改失败", err.Error()))
		} else {
			c.JSON(http.StatusInternalServerError, utils.ErrorResponse("修改失败", err.Error()))
		}
		return
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("密码修改成功", nil))
}

// ResetPassword 重置密码
// @Summary 重置密码
// @Description 通过邮箱重置密码
// @Tags 认证
// @Accept json
// @Produce json
// @Param request body models.ResetPasswordRequest true "重置密码信息"
// @Success 200 {object} utils.Response "重置成功"
// @Failure 400 {object} utils.Response "请求参数错误"
// @Failure 404 {object} utils.Response "邮箱未注册"
// @Failure 500 {object} utils.Response "服务器内部错误"
// @Router /api/auth/reset-password [post]
func (h *AuthHandler) ResetPassword(c *gin.Context) {
	var req models.ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("请求参数错误", err.Error()))
		return
	}

	// 验证请求参数
	if err := h.validator.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("参数验证失败", err.Error()))
		return
	}

	// 调用服务层重置密码
	if err := h.authService.ResetPassword(req.Email); err != nil {
		if err.Error() == "邮箱未注册" {
			c.JSON(http.StatusNotFound, utils.ErrorResponse("重置失败", err.Error()))
		} else {
			c.JSON(http.StatusInternalServerError, utils.ErrorResponse("重置失败", err.Error()))
		}
		return
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("密码重置成功，请查看邮箱获取新密码", nil))
}

// Logout 用户登出
// @Summary 用户登出
// @Description 用户登出接口
// @Tags 认证
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} utils.Response "登出成功"
// @Failure 401 {object} utils.Response "认证失败"
// @Failure 500 {object} utils.Response "服务器内部错误"
// @Router /api/auth/logout [post]
func (h *AuthHandler) Logout(c *gin.Context) {
	// 获取当前用户ID
	userIDStr, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, utils.ErrorResponse("未授权", "用户未登录"))
		return
	}

	userID, ok := userIDStr.(uint)
	if !ok {
		c.JSON(http.StatusInternalServerError, utils.ErrorResponse("服务器错误", "用户ID格式错误"))
		return
	}

	// 调用服务层登出
	if err := h.authService.Logout(userID); err != nil {
		c.JSON(http.StatusInternalServerError, utils.ErrorResponse("登出失败", err.Error()))
		return
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("登出成功", nil))
}

// GetProfile 获取当前用户信息
// @Summary 获取当前用户信息
// @Description 获取当前登录用户的详细信息
// @Tags 认证
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} utils.Response{data=models.UserResponse} "获取成功"
// @Failure 401 {object} utils.Response "认证失败"
// @Failure 500 {object} utils.Response "服务器内部错误"
// @Router /api/auth/profile [get]
func (h *AuthHandler) GetProfile(c *gin.Context) {
	// 获取当前用户ID
	userIDStr, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, utils.ErrorResponse("未授权", "用户未登录"))
		return
	}

	userID, ok := userIDStr.(uint)
	if !ok {
		c.JSON(http.StatusInternalServerError, utils.ErrorResponse("服务器错误", "用户ID格式错误"))
		return
	}

	// 验证用户并获取用户信息
	user, err := h.authService.ValidateUser(userID)
	if err != nil {
		if err.Error() == "用户不存在" || err.Error() == "账户已被禁用" {
			c.JSON(http.StatusUnauthorized, utils.ErrorResponse("获取失败", err.Error()))
		} else {
			c.JSON(http.StatusInternalServerError, utils.ErrorResponse("获取失败", err.Error()))
		}
		return
	}

	// 构造响应数据
	userResp := &models.UserResponse{
		ID:          user.ID,
		Username:    user.Username,
		Email:       user.Email,
		Nickname:    user.Nickname,
		Avatar:      user.Avatar,
		Gender:      user.Gender,
		BirthDate:   user.BirthDate,
		PhoneNumber: user.PhoneNumber,
		Bio:         user.Bio,
		Status:      user.Status,
		Role:        user.Role,
		CreatedAt:   user.CreatedAt,
		UpdatedAt:   user.UpdatedAt,
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("获取成功", userResp))
}

// ValidateToken 验证token有效性
// @Summary 验证token有效性
// @Description 验证当前token是否有效
// @Tags 认证
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} utils.Response "token有效"
// @Failure 401 {object} utils.Response "token无效"
// @Router /api/auth/validate [get]
func (h *AuthHandler) ValidateToken(c *gin.Context) {
	// 如果能到达这里，说明中间件已经验证了token的有效性
	userID, _ := c.Get("user_id")
	username, _ := c.Get("username")
	email, _ := c.Get("email")

	data := gin.H{
		"user_id":  userID,
		"username": username,
		"email":    email,
		"valid":    true,
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("token有效", data))
}