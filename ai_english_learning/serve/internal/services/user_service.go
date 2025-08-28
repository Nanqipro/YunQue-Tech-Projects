package services

import (
	"errors"
	"time"

	"gorm.io/gorm"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/utils"
)

// UserService 用户服务
type UserService struct {
	db *gorm.DB
}

// NewUserService 创建用户服务实例
func NewUserService(db *gorm.DB) *UserService {
	return &UserService{db: db}
}

// CreateUser 创建用户
func (s *UserService) CreateUser(username, email, password string) (*models.User, error) {
	// 检查用户名是否已存在
	var existingUser models.User
	if err := s.db.Where("username = ? OR email = ?", username, email).First(&existingUser).Error; err == nil {
		if existingUser.Username == username {
			return nil, common.ErrUsernameExists
		}
		if existingUser.Email == email {
			return nil, common.ErrEmailExists
		}
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}
	
	// 生成密码哈希
	passwordHash, err := utils.HashPassword(password)
	if err != nil {
		return nil, err
	}
	
	// 创建用户
	user := &models.User{
		ID:           utils.GenerateUUID(),
		Username:     username,
		Email:        email,
		PasswordHash: passwordHash,
		Status:       "active",
		Timezone:     "Asia/Shanghai",
		Language:     "zh-CN",
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}
	
	if err := s.db.Create(user).Error; err != nil {
		return nil, err
	}
	
	// 创建用户偏好设置
	preference := &models.UserPreference{
		ID:              utils.GenerateUUID(),
		UserID:          user.ID,
		DailyGoal:       50,
		WeeklyGoal:      350,
		ReminderEnabled: true,
		DifficultyLevel: "beginner",
		LearningMode:    "casual",
		CreatedAt:       time.Now(),
		UpdatedAt:       time.Now(),
	}
	
	if err := s.db.Create(preference).Error; err != nil {
		// 如果创建偏好设置失败，记录日志但不影响用户创建
		// 可以在这里添加日志记录
	}
	
	return user, nil
}

// GetUserByID 根据ID获取用户
func (s *UserService) GetUserByID(userID string) (*models.User, error) {
	var user models.User
	if err := s.db.Preload("Preferences").Preload("SocialLinks").Where("id = ?", userID).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, common.ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

// GetUserByEmail 根据邮箱获取用户
func (s *UserService) GetUserByEmail(email string) (*models.User, error) {
	var user models.User
	if err := s.db.Where("email = ?", email).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, common.ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

// GetUserByUsername 根据用户名获取用户
func (s *UserService) GetUserByUsername(username string) (*models.User, error) {
	var user models.User
	if err := s.db.Where("username = ?", username).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, common.ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

// UpdateUser 更新用户信息
func (s *UserService) UpdateUser(userID string, updates map[string]interface{}) (*models.User, error) {
	// 检查用户是否存在
	var user models.User
	if err := s.db.Where("id = ?", userID).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, common.ErrUserNotFound
		}
		return nil, err
	}
	
	// 如果更新邮箱，检查邮箱是否已被其他用户使用
	if email, ok := updates["email"]; ok {
		var existingUser models.User
		if err := s.db.Where("email = ? AND id != ?", email, userID).First(&existingUser).Error; err == nil {
			return nil, common.ErrEmailExists
		} else if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, err
		}
	}
	
	// 如果更新用户名，检查用户名是否已被其他用户使用
	if username, ok := updates["username"]; ok {
		var existingUser models.User
		if err := s.db.Where("username = ? AND id != ?", username, userID).First(&existingUser).Error; err == nil {
			return nil, common.ErrUsernameExists
		} else if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, err
		}
	}
	
	// 更新时间戳
	updates["updated_at"] = time.Now()
	
	// 执行更新
	if err := s.db.Model(&user).Updates(updates).Error; err != nil {
		return nil, err
	}
	
	// 重新获取更新后的用户信息
	return s.GetUserByID(userID)
}

// UpdatePassword 更新用户密码
func (s *UserService) UpdatePassword(userID, oldPassword, newPassword string) error {
	// 获取用户
	var user models.User
	if err := s.db.Where("id = ?", userID).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return common.ErrUserNotFound
		}
		return err
	}
	
	// 验证旧密码
	if !utils.CheckPasswordHash(oldPassword, user.PasswordHash) {
		return common.ErrInvalidPassword
	}
	
	// 生成新密码哈希
	newPasswordHash, err := utils.HashPassword(newPassword)
	if err != nil {
		return err
	}
	
	// 更新密码
	return s.db.Model(&user).Updates(map[string]interface{}{
		"password_hash": newPasswordHash,
		"updated_at":    time.Now(),
	}).Error
}

// UpdateLoginInfo 更新登录信息
func (s *UserService) UpdateLoginInfo(userID, loginIP string) error {
	now := time.Now()
	return s.db.Model(&models.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"last_login_at": &now,
		"last_login_ip": loginIP,
		"login_count":   gorm.Expr("login_count + 1"),
		"updated_at":    now,
	}).Error
}

// VerifyPassword 验证用户密码
func (s *UserService) VerifyPassword(userID, password string) error {
	var user models.User
	if err := s.db.Where("id = ?", userID).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return common.ErrUserNotFound
		}
		return err
	}
	
	if !utils.CheckPasswordHash(password, user.PasswordHash) {
		return common.ErrInvalidPassword
	}
	
	return nil
}

// DeleteUser 删除用户（软删除）
func (s *UserService) DeleteUser(userID string) error {
	// 检查用户是否存在
	var user models.User
	if err := s.db.Where("id = ?", userID).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return common.ErrUserNotFound
		}
		return err
	}
	
	// 软删除用户
	return s.db.Delete(&user).Error
}

// GetUserPreferences 获取用户偏好设置
func (s *UserService) GetUserPreferences(userID string) (*models.UserPreference, error) {
	var preference models.UserPreference
	if err := s.db.Where("user_id = ?", userID).First(&preference).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, common.ErrUserNotFound
		}
		return nil, err
	}
	return &preference, nil
}

// UpdateUserPreferences 更新用户偏好设置
func (s *UserService) UpdateUserPreferences(userID string, updates map[string]interface{}) (*models.UserPreference, error) {
	// 检查偏好设置是否存在
	var preference models.UserPreference
	if err := s.db.Where("user_id = ?", userID).First(&preference).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, common.ErrUserNotFound
		}
		return nil, err
	}
	
	// 更新时间戳
	updates["updated_at"] = time.Now()
	
	// 执行更新
	if err := s.db.Model(&preference).Updates(updates).Error; err != nil {
		return nil, err
	}
	
	// 重新获取更新后的偏好设置
	return s.GetUserPreferences(userID)
}