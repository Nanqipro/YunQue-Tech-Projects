package models

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID                string                 `json:"id" gorm:"type:varchar(36);primaryKey;comment:用户ID"`
	Username          string                 `json:"username" gorm:"type:varchar(50);uniqueIndex;not null;comment:用户名"`
	Email             string                 `json:"email" gorm:"type:varchar(100);uniqueIndex;not null;comment:邮箱"`
	Phone             *string                `json:"phone" gorm:"type:varchar(20);uniqueIndex;comment:手机号"`
	PasswordHash      string                 `json:"-" gorm:"type:varchar(255);not null;comment:密码哈希"`
	Nickname          *string                `json:"nickname" gorm:"type:varchar(100);comment:昵称"`
	Avatar            *string                `json:"avatar" gorm:"type:varchar(500);comment:头像URL"`
	Gender            *string                `json:"gender" gorm:"type:enum('male','female','other');comment:性别"`
	BirthDate         *time.Time             `json:"birth_date" gorm:"type:date;comment:出生日期"`
	Bio               *string                `json:"bio" gorm:"type:text;comment:个人简介"`
	Location          *string                `json:"location" gorm:"type:varchar(100);comment:所在地"`
	Timezone          string                 `json:"timezone" gorm:"type:varchar(50);default:'Asia/Shanghai';comment:时区"`
	Language          string                 `json:"language" gorm:"type:varchar(10);default:'zh-CN';comment:界面语言"`
	EmailVerified     bool                   `json:"email_verified" gorm:"type:boolean;default:false;comment:邮箱是否验证"`
	PhoneVerified     bool                   `json:"phone_verified" gorm:"type:boolean;default:false;comment:手机是否验证"`
	Status            string                 `json:"status" gorm:"type:enum('active','inactive','suspended','deleted');default:'active';comment:账户状态"`
	LastLoginAt       *time.Time             `json:"last_login_at" gorm:"type:timestamp;comment:最后登录时间"`
	LastLoginIP       *string                `json:"last_login_ip" gorm:"type:varchar(45);comment:最后登录IP"`
	LoginCount        int                    `json:"login_count" gorm:"type:int;default:0;comment:登录次数"`
	CreatedAt         time.Time              `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt         time.Time              `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	DeletedAt         gorm.DeletedAt         `json:"-" gorm:"index;comment:删除时间"`
	
	// 关联关系
	SocialLinks       []UserSocialLink       `json:"social_links,omitempty" gorm:"foreignKey:UserID"`
	Preferences       *UserPreference        `json:"preferences,omitempty" gorm:"foreignKey:UserID"`
	VocabularyProgress []UserVocabularyProgress `json:"vocabulary_progress,omitempty" gorm:"foreignKey:UserID"`
}

// UserSocialLink 用户社交链接模型
type UserSocialLink struct {
	ID        string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:ID"`
	UserID    string    `json:"user_id" gorm:"type:varchar(36);not null;index;comment:用户ID"`
	Platform  string    `json:"platform" gorm:"type:varchar(50);not null;comment:平台名称"`
	URL       string    `json:"url" gorm:"type:varchar(500);not null;comment:链接地址"`
	CreatedAt time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	User User `json:"-" gorm:"foreignKey:UserID"`
}

// UserPreference 用户偏好设置模型
type UserPreference struct {
	ID                    string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:ID"`
	UserID                string    `json:"user_id" gorm:"type:varchar(36);uniqueIndex;not null;comment:用户ID"`
	DailyGoal             int       `json:"daily_goal" gorm:"type:int;default:50;comment:每日学习目标(分钟)"`
	WeeklyGoal            int       `json:"weekly_goal" gorm:"type:int;default:350;comment:每周学习目标(分钟)"`
	ReminderEnabled       bool      `json:"reminder_enabled" gorm:"type:boolean;default:true;comment:是否启用提醒"`
	ReminderTime          *string   `json:"reminder_time" gorm:"type:time;comment:提醒时间"`
	DifficultyLevel       string    `json:"difficulty_level" gorm:"type:enum('beginner','intermediate','advanced');default:'beginner';comment:难度级别"`
	LearningMode          string    `json:"learning_mode" gorm:"type:enum('casual','intensive','exam_prep');default:'casual';comment:学习模式"`
	PreferredTopics       *string   `json:"preferred_topics" gorm:"type:json;comment:偏好话题(JSON数组)"`
	NotificationSettings  *string   `json:"notification_settings" gorm:"type:json;comment:通知设置(JSON对象)"`
	PrivacySettings       *string   `json:"privacy_settings" gorm:"type:json;comment:隐私设置(JSON对象)"`
	CreatedAt             time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt             time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	User User `json:"-" gorm:"foreignKey:UserID"`
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