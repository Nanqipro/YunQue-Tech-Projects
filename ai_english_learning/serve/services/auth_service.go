package services

import (
	"errors"
	"fmt"
	"time"

	"ai_english_learning/config"
	"ai_english_learning/models"
	"ai_english_learning/utils"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthService struct {
	db *gorm.DB
}

func NewAuthService(db *gorm.DB) *AuthService {
	return &AuthService{db: db}
}

// Register 用户注册
func (s *AuthService) Register(req *models.UserRegisterRequest) (*models.UserResponse, error) {
	// 检查用户名是否已存在
	var existingUser models.User
	if err := s.db.Where("username = ?", req.Username).First(&existingUser).Error; err == nil {
		return nil, errors.New("用户名已存在")
	}

	// 检查邮箱是否已存在
	if err := s.db.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
		return nil, errors.New("邮箱已被注册")
	}

	// 密码加密
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, fmt.Errorf("密码加密失败: %v", err)
	}

	// 解析生日日期
	var birthDate *time.Time
	if req.BirthDate != "" {
		if parsedDate, err := time.Parse("2006-01-02", req.BirthDate); err == nil {
			birthDate = &parsedDate
		}
	}

	// 创建用户
	user := &models.User{
		Username:      req.Username,
		Email:         req.Email,
		PasswordHash:  hashedPassword,
		Phone:         req.Phone,
		Gender:        req.Gender,
		BirthDate:     birthDate,
		LearningLevel: req.LearningLevel,
		IsActive:      true,
	}

	if err := s.db.Create(user).Error; err != nil {
		return nil, fmt.Errorf("创建用户失败: %v", err)
	}

	// 创建默认用户偏好设置
	preference := &models.UserPreference{
		UserID:                user.ID,
		LearningMode:          "visual",
		PreferredStudyTime:    "evening",
		DailyGoalMinutes:      30,
		ReminderEnabled:       true,
		ReminderTime:          "20:00:00",
		AutoPlayPronunciation: true,
		ShowChineseMeaning:    true,
		DifficultyPreference:  "adaptive",
	}

	if err := s.db.Create(preference).Error; err != nil {
		// 如果创建偏好设置失败，记录日志但不影响注册流程
		fmt.Printf("创建用户偏好设置失败: %v\n", err)
	}

	// 返回用户信息（不包含密码）
	return &models.UserResponse{
		ID:                 user.ID,
		Username:           user.Username,
		Email:              user.Email,
		Nickname:           user.Nickname,
		AvatarURL:          user.AvatarURL,
		Phone:              user.Phone,
		Gender:             user.Gender,
		BirthDate:          user.BirthDate,
		LearningLevel:      user.LearningLevel,
		LearningGoals:      user.LearningGoals,
		Motto:              user.Motto,
		Timezone:           user.Timezone,
		LanguagePreference: user.LanguagePreference,
		IsActive:           user.IsActive,
		IsPremium:          user.IsPremium,
		CreatedAt:          user.CreatedAt,
		UpdatedAt:          user.UpdatedAt,
		LastLoginAt:        user.LastLoginAt,
	}, nil
}

// Login 用户登录
func (s *AuthService) Login(req *models.UserLoginRequest) (*models.LoginResponse, error) {
	var user models.User
	
	// 根据用户名或邮箱查找用户
	query := s.db.Where("username = ? OR email = ?", req.UsernameOrEmail, req.UsernameOrEmail)
	if err := query.First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, fmt.Errorf("查询用户失败: %v", err)
	}

	// 检查用户状态
	if user.Status != "active" {
		return nil, errors.New("账户已被禁用")
	}

	// 验证密码
	if !utils.CheckPassword(req.Password, user.Password) {
		return nil, errors.New("密码错误")
	}

	// 更新最后登录时间
	now := time.Now()
	user.LastLoginAt = &now
	s.db.Save(&user)

	// 生成JWT token
	cfg := config.GetConfig()
	token, err := utils.GenerateToken(user.ID, user.Username, user.Email, cfg.JWT.Secret, cfg.JWT.ExpirationHours)
	if err != nil {
		return nil, fmt.Errorf("生成token失败: %v", err)
	}

	// 生成刷新token
	refreshToken, err := utils.GenerateRefreshToken(user.ID, cfg.JWT.Secret, cfg.JWT.RefreshExpirationDays)
	if err != nil {
		return nil, fmt.Errorf("生成刷新token失败: %v", err)
	}

	return &models.LoginResponse{
		User: models.UserResponse{
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
		},
		Token:        token,
		RefreshToken: refreshToken,
		ExpiresAt:    time.Now().Add(time.Duration(cfg.JWT.ExpirationHours) * time.Hour),
	}, nil
}

// RefreshToken 刷新访问令牌
func (s *AuthService) RefreshToken(refreshToken string) (*models.RefreshTokenResponse, error) {
	cfg := config.GetConfig()
	
	// 验证刷新token
	claims, err := utils.ParseRefreshToken(refreshToken, cfg.JWT.Secret)
	if err != nil {
		return nil, errors.New("无效的刷新token")
	}

	// 查找用户
	var user models.User
	if err := s.db.First(&user, claims.UserID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, fmt.Errorf("查询用户失败: %v", err)
	}

	// 检查用户状态
	if user.Status != "active" {
		return nil, errors.New("账户已被禁用")
	}

	// 生成新的访问token
	newToken, err := utils.GenerateToken(user.ID, user.Username, user.Email, cfg.JWT.Secret, cfg.JWT.ExpirationHours)
	if err != nil {
		return nil, fmt.Errorf("生成新token失败: %v", err)
	}

	return &models.RefreshTokenResponse{
		Token:     newToken,
		ExpiresAt: time.Now().Add(time.Duration(cfg.JWT.ExpirationHours) * time.Hour),
	}, nil
}

// ChangePassword 修改密码
func (s *AuthService) ChangePassword(userID uint, req *models.ChangePasswordRequest) error {
	// 查找用户
	var user models.User
	if err := s.db.First(&user, userID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("用户不存在")
		}
		return fmt.Errorf("查询用户失败: %v", err)
	}

	// 验证旧密码
	if !utils.CheckPassword(req.OldPassword, user.Password) {
		return errors.New("旧密码错误")
	}

	// 加密新密码
	hashedPassword, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		return fmt.Errorf("密码加密失败: %v", err)
	}

	// 更新密码
	user.Password = hashedPassword
	if err := s.db.Save(&user).Error; err != nil {
		return fmt.Errorf("更新密码失败: %v", err)
	}

	return nil
}

// ResetPassword 重置密码（通过邮箱）
func (s *AuthService) ResetPassword(email string) error {
	// 查找用户
	var user models.User
	if err := s.db.Where("email = ?", email).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("邮箱未注册")
		}
		return fmt.Errorf("查询用户失败: %v", err)
	}

	// 生成临时密码（实际项目中应该发送邮件验证码）
	tempPassword := utils.GenerateRandomString(8)
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(tempPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("密码加密失败: %v", err)
	}

	// 更新密码
	user.Password = string(hashedPassword)
	if err := s.db.Save(&user).Error; err != nil {
		return fmt.Errorf("重置密码失败: %v", err)
	}

	// TODO: 发送邮件通知用户新密码
	fmt.Printf("用户 %s 的临时密码: %s\n", email, tempPassword)

	return nil
}

// Logout 用户登出（可以在这里实现token黑名单等逻辑）
func (s *AuthService) Logout(userID uint) error {
	// 这里可以实现token黑名单逻辑
	// 目前只是简单返回成功
	return nil
}

// ValidateUser 验证用户是否存在且状态正常
func (s *AuthService) ValidateUser(userID uint) (*models.User, error) {
	var user models.User
	if err := s.db.First(&user, userID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, fmt.Errorf("查询用户失败: %v", err)
	}

	if user.Status != "active" {
		return nil, errors.New("账户已被禁用")
	}

	return &user, nil
}