package models

import (
	"time"

	"gorm.io/gorm"
)

// User 用户基础信息表
type User struct {
	ID                 uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Username           string    `json:"username" gorm:"uniqueIndex;size:50;not null" validate:"required,min=3,max=50"`
	Email              string    `json:"email" gorm:"uniqueIndex;size:100;not null" validate:"required,email"`
	PasswordHash       string    `json:"-" gorm:"size:255;not null"`
	Nickname           string    `json:"nickname" gorm:"size:50"`
	AvatarURL          string    `json:"avatar_url" gorm:"size:500"`
	Phone              string    `json:"phone" gorm:"size:20"`
	Gender             int8      `json:"gender" gorm:"default:0;comment:0:未知,1:男,2:女"`
	BirthDate          *time.Time `json:"birth_date" gorm:"type:date"`
	LearningLevel      string    `json:"learning_level" gorm:"size:20;default:beginner;comment:beginner,intermediate,advanced"`
	LearningGoals      string    `json:"learning_goals" gorm:"type:text"`
	Motto              string    `json:"motto" gorm:"size:200;comment:学习座右铭"`
	Timezone           string    `json:"timezone" gorm:"size:50;default:UTC"`
	LanguagePreference string    `json:"language_preference" gorm:"size:10;default:zh-CN"`
	IsActive           bool      `json:"is_active" gorm:"default:true"`
	IsPremium          bool      `json:"is_premium" gorm:"default:false"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
	LastLoginAt        *time.Time `json:"last_login_at"`

	// 关联关系
	SocialLinks    []UserSocialLink    `json:"social_links,omitempty" gorm:"foreignKey:UserID"`
	Preferences    *UserPreference     `json:"preferences,omitempty" gorm:"foreignKey:UserID"`
	VocabularyProgress []UserVocabularyProgress `json:"vocabulary_progress,omitempty" gorm:"foreignKey:UserID"`
}

// UserSocialLink 用户社交链接表
type UserSocialLink struct {
	ID        uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    uint      `json:"user_id" gorm:"not null;index"`
	Platform  string    `json:"platform" gorm:"size:20;not null;comment:wechat,weibo,github,etc."`
	LinkURL   string    `json:"link_url" gorm:"size:500;not null"`
	IsPublic  bool      `json:"is_public" gorm:"default:false"`
	CreatedAt time.Time `json:"created_at"`

	// 外键关联
	User User `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

// UserPreference 用户学习偏好表
type UserPreference struct {
	ID                     uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID                 uint      `json:"user_id" gorm:"uniqueIndex;not null"`
	LearningMode           string    `json:"learning_mode" gorm:"size:20;default:visual;comment:visual,auditory,kinesthetic"`
	PreferredStudyTime     string    `json:"preferred_study_time" gorm:"size:20;comment:morning,afternoon,evening,night"`
	DailyGoalMinutes       int       `json:"daily_goal_minutes" gorm:"default:30"`
	ReminderEnabled        bool      `json:"reminder_enabled" gorm:"default:true"`
	ReminderTime           string    `json:"reminder_time" gorm:"type:time;default:20:00:00"`
	AutoPlayPronunciation  bool      `json:"auto_play_pronunciation" gorm:"default:true"`
	ShowChineseMeaning     bool      `json:"show_chinese_meaning" gorm:"default:true"`
	DifficultyPreference   string    `json:"difficulty_preference" gorm:"size:20;default:adaptive;comment:easy,medium,hard,adaptive"`
	CreatedAt              time.Time `json:"created_at"`
	UpdatedAt              time.Time `json:"updated_at"`

	// 外键关联
	User User `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

// UserRegisterRequest 用户注册请求
type UserRegisterRequest struct {
	Username        string `json:"username" validate:"required,min=3,max=50"`
	Email           string `json:"email" validate:"required,email"`
	Password        string `json:"password" validate:"required,min=6,max=50"`
	ConfirmPassword string `json:"confirm_password" validate:"required,eqfield=Password"`
	Phone           string `json:"phone" validate:"omitempty,len=11"`
	BirthDate       string `json:"birth_date" validate:"omitempty"`
	Gender          int8   `json:"gender" validate:"omitempty,oneof=0 1 2"`
	LearningLevel   string `json:"learning_level" validate:"omitempty,oneof=beginner intermediate advanced"`
}

// UserLoginRequest 用户登录请求
type UserLoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

// UserUpdateRequest 用户信息更新请求
type UserUpdateRequest struct {
	Username      string `json:"username" validate:"omitempty,min=3,max=50"`
	Nickname      string `json:"nickname" validate:"omitempty,max=50"`
	AvatarURL     string `json:"avatar_url" validate:"omitempty,url"`
	Phone         string `json:"phone" validate:"omitempty,len=11"`
	BirthDate     string `json:"birth_date" validate:"omitempty"`
	Gender        int8   `json:"gender" validate:"omitempty,oneof=0 1 2"`
	LearningLevel string `json:"learning_level" validate:"omitempty,oneof=beginner intermediate advanced"`
	LearningGoals string `json:"learning_goals" validate:"omitempty,max=1000"`
	Motto         string `json:"motto" validate:"omitempty,max=200"`
}

// UserResponse 用户响应结构
type UserResponse struct {
	ID                 uint                `json:"id"`
	Username           string              `json:"username"`
	Email              string              `json:"email"`
	Nickname           string              `json:"nickname"`
	AvatarURL          string              `json:"avatar_url"`
	Phone              string              `json:"phone"`
	Gender             int8                `json:"gender"`
	BirthDate          *time.Time          `json:"birth_date"`
	LearningLevel      string              `json:"learning_level"`
	LearningGoals      string              `json:"learning_goals"`
	Motto              string              `json:"motto"`
	Timezone           string              `json:"timezone"`
	LanguagePreference string              `json:"language_preference"`
	IsActive           bool                `json:"is_active"`
	IsPremium          bool                `json:"is_premium"`
	CreatedAt          time.Time           `json:"created_at"`
	UpdatedAt          time.Time           `json:"updated_at"`
	LastLoginAt        *time.Time          `json:"last_login_at"`
	SocialLinks        []UserSocialLink    `json:"social_links,omitempty"`
	Preferences        *UserPreference     `json:"preferences,omitempty"`
	LearningStats      *UserLearningStats  `json:"learning_stats,omitempty"`
}

// 登录响应结构体
type LoginResponse struct {
	User         UserResponse `json:"user"`
	Token        string       `json:"token"`
	RefreshToken string       `json:"refresh_token"`
	ExpiresAt    time.Time    `json:"expires_at"`
}

// 刷新令牌请求结构体
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

// 刷新令牌响应结构体
type RefreshTokenResponse struct {
	Token     string    `json:"token"`
	ExpiresAt time.Time `json:"expires_at"`
}

// 修改密码请求结构体
type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" validate:"required,min=6"`
	NewPassword string `json:"new_password" validate:"required,min=6"`
}

// 重置密码请求结构体
type ResetPasswordRequest struct {
	Email string `json:"email" validate:"required,email"`
}

// UserLearningStats 用户学习统计
type UserLearningStats struct {
	TotalWordsLearned int     `json:"total_words_learned"`
	ConsecutiveDays   int     `json:"consecutive_days"`
	TotalStudyTime    int     `json:"total_study_time"`
	AverageScore      float64 `json:"average_score"`
	LevelProgress     struct {
		CurrentLevel     int `json:"current_level"`
		ExperiencePoints int `json:"experience_points"`
		NextLevelPoints  int `json:"next_level_points"`
	} `json:"level_progress"`
}

// TableName 指定表名
func (User) TableName() string {
	return "users"
}

func (UserSocialLink) TableName() string {
	return "user_social_links"
}

func (UserPreference) TableName() string {
	return "user_preferences"
}

// BeforeCreate GORM钩子：创建前
func (u *User) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	u.CreatedAt = now
	u.UpdatedAt = now
	return nil
}

// BeforeUpdate GORM钩子：更新前
func (u *User) BeforeUpdate(tx *gorm.DB) error {
	u.UpdatedAt = time.Now()
	return nil
}