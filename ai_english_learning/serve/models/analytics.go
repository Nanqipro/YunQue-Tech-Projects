package models

import (
	"time"

	"gorm.io/gorm"
)

// UserLearningSession 用户学习会话表
type UserLearningSession struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       uint      `json:"user_id" gorm:"not null;index"`
	SessionType  string    `json:"session_type" gorm:"size:20;not null;comment:vocabulary,listening,reading,writing,speaking"`
	StartTime    time.Time `json:"start_time" gorm:"not null"`
	EndTime      *time.Time `json:"end_time"`
	Duration     int       `json:"duration" gorm:"comment:学习时长(秒)"`
	ItemsStudied int       `json:"items_studied" gorm:"default:0;comment:学习项目数"`
	CorrectCount int       `json:"correct_count" gorm:"default:0;comment:答对数量"`
	TotalCount   int       `json:"total_count" gorm:"default:0;comment:总题数"`
	Score        float64   `json:"score" gorm:"comment:得分"`
	Experience   int       `json:"experience" gorm:"default:0;comment:获得经验值"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	User User `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

// UserDailyStats 用户每日统计表
type UserDailyStats struct {
	ID                uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID            uint      `json:"user_id" gorm:"not null;index"`
	Date              time.Time `json:"date" gorm:"type:date;not null"`
	TotalStudyTime    int       `json:"total_study_time" gorm:"default:0;comment:总学习时间(秒)"`
	VocabularyTime    int       `json:"vocabulary_time" gorm:"default:0;comment:词汇学习时间(秒)"`
	ListeningTime     int       `json:"listening_time" gorm:"default:0;comment:听力练习时间(秒)"`
	ReadingTime       int       `json:"reading_time" gorm:"default:0;comment:阅读练习时间(秒)"`
	WritingTime       int       `json:"writing_time" gorm:"default:0;comment:写作练习时间(秒)"`
	SpeakingTime      int       `json:"speaking_time" gorm:"default:0;comment:口语练习时间(秒)"`
	WordsLearned      int       `json:"words_learned" gorm:"default:0;comment:学习单词数"`
	ExercisesCompleted int      `json:"exercises_completed" gorm:"default:0;comment:完成练习数"`
	TotalScore        float64   `json:"total_score" gorm:"default:0;comment:总得分"`
	ExperienceGained  int       `json:"experience_gained" gorm:"default:0;comment:获得经验值"`
	StreakDays        int       `json:"streak_days" gorm:"default:0;comment:连续学习天数"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`

	// 外键关联
	User User `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`

	// 唯一索引
	_ struct{} `gorm:"uniqueIndex:idx_user_date,priority:1"`
}

// UserWeeklyStats 用户每周统计表
type UserWeeklyStats struct {
	ID                uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID            uint      `json:"user_id" gorm:"not null;index"`
	Year              int       `json:"year" gorm:"not null"`
	Week              int       `json:"week" gorm:"not null;comment:第几周"`
	StartDate         time.Time `json:"start_date" gorm:"type:date;not null"`
	EndDate           time.Time `json:"end_date" gorm:"type:date;not null"`
	TotalStudyTime    int       `json:"total_study_time" gorm:"default:0;comment:总学习时间(秒)"`
	VocabularyTime    int       `json:"vocabulary_time" gorm:"default:0;comment:词汇学习时间(秒)"`
	ListeningTime     int       `json:"listening_time" gorm:"default:0;comment:听力练习时间(秒)"`
	ReadingTime       int       `json:"reading_time" gorm:"default:0;comment:阅读练习时间(秒)"`
	WritingTime       int       `json:"writing_time" gorm:"default:0;comment:写作练习时间(秒)"`
	SpeakingTime      int       `json:"speaking_time" gorm:"default:0;comment:口语练习时间(秒)"`
	WordsLearned      int       `json:"words_learned" gorm:"default:0;comment:学习单词数"`
	ExercisesCompleted int      `json:"exercises_completed" gorm:"default:0;comment:完成练习数"`
	AverageScore      float64   `json:"average_score" gorm:"default:0;comment:平均得分"`
	ExperienceGained  int       `json:"experience_gained" gorm:"default:0;comment:获得经验值"`
	ActiveDays        int       `json:"active_days" gorm:"default:0;comment:活跃天数"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`

	// 外键关联
	User User `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`

	// 唯一索引
	_ struct{} `gorm:"uniqueIndex:idx_user_year_week,priority:1"`
}

// UserMonthlyStats 用户每月统计表
type UserMonthlyStats struct {
	ID                uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID            uint      `json:"user_id" gorm:"not null;index"`
	Year              int       `json:"year" gorm:"not null"`
	Month             int       `json:"month" gorm:"not null"`
	TotalStudyTime    int       `json:"total_study_time" gorm:"default:0;comment:总学习时间(秒)"`
	VocabularyTime    int       `json:"vocabulary_time" gorm:"default:0;comment:词汇学习时间(秒)"`
	ListeningTime     int       `json:"listening_time" gorm:"default:0;comment:听力练习时间(秒)"`
	ReadingTime       int       `json:"reading_time" gorm:"default:0;comment:阅读练习时间(秒)"`
	WritingTime       int       `json:"writing_time" gorm:"default:0;comment:写作练习时间(秒)"`
	SpeakingTime      int       `json:"speaking_time" gorm:"default:0;comment:口语练习时间(秒)"`
	WordsLearned      int       `json:"words_learned" gorm:"default:0;comment:学习单词数"`
	ExercisesCompleted int      `json:"exercises_completed" gorm:"default:0;comment:完成练习数"`
	AverageScore      float64   `json:"average_score" gorm:"default:0;comment:平均得分"`
	ExperienceGained  int       `json:"experience_gained" gorm:"default:0;comment:获得经验值"`
	ActiveDays        int       `json:"active_days" gorm:"default:0;comment:活跃天数"`
	MaxStreakDays     int       `json:"max_streak_days" gorm:"default:0;comment:最大连续天数"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`

	// 外键关联
	User User `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`

	// 唯一索引
	_ struct{} `gorm:"uniqueIndex:idx_user_year_month,priority:1"`
}

// UserAchievement 用户成就表
type UserAchievement struct {
	ID            uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID        uint      `json:"user_id" gorm:"not null;index"`
	AchievementID uint      `json:"achievement_id" gorm:"not null;index"`
	UnlockedAt    time.Time `json:"unlocked_at" gorm:"not null"`
	Progress      int       `json:"progress" gorm:"default:0;comment:进度值"`
	IsCompleted   bool      `json:"is_completed" gorm:"default:false"`
	CreatedAt     time.Time `json:"created_at"`

	// 外键关联
	User        User        `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Achievement Achievement `json:"achievement,omitempty" gorm:"foreignKey:AchievementID;constraint:OnDelete:CASCADE"`

	// 唯一索引
	_ struct{} `gorm:"uniqueIndex:idx_user_achievement,priority:1"`
}

// Achievement 成就表
type Achievement struct {
	ID          uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Name        string    `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string    `json:"description" gorm:"type:text;not null"`
	IconURL     string    `json:"icon_url" gorm:"size:500"`
	Category    string    `json:"category" gorm:"size:50;comment:vocabulary,listening,reading,writing,speaking,general"`
	Type        string    `json:"type" gorm:"size:20;not null;comment:count,streak,score,time"`
	TargetValue int       `json:"target_value" gorm:"not null;comment:目标值"`
	RewardExp   int       `json:"reward_exp" gorm:"default:0;comment:奖励经验值"`
	Rarity      string    `json:"rarity" gorm:"size:20;default:common;comment:common,rare,epic,legendary"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`
	SortOrder   int       `json:"sort_order" gorm:"default:0"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联关系
	UserAchievements []UserAchievement `json:"user_achievements,omitempty" gorm:"foreignKey:AchievementID"`
}

// UserLevel 用户等级表
type UserLevel struct {
	ID               uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID           uint      `json:"user_id" gorm:"uniqueIndex;not null"`
	CurrentLevel     int       `json:"current_level" gorm:"default:1"`
	CurrentExp       int       `json:"current_exp" gorm:"default:0"`
	TotalExp         int       `json:"total_exp" gorm:"default:0"`
	NextLevelExp     int       `json:"next_level_exp" gorm:"default:100"`
	VocabularyLevel  int       `json:"vocabulary_level" gorm:"default:1"`
	ListeningLevel   int       `json:"listening_level" gorm:"default:1"`
	ReadingLevel     int       `json:"reading_level" gorm:"default:1"`
	WritingLevel     int       `json:"writing_level" gorm:"default:1"`
	SpeakingLevel    int       `json:"speaking_level" gorm:"default:1"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`

	// 外键关联
	User User `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

// 请求和响应结构体

// LearningStatsRequest 学习统计请求
type LearningStatsRequest struct {
	Period    string `json:"period" form:"period" validate:"required,oneof=daily weekly monthly yearly"`
	StartDate string `json:"start_date" form:"start_date" validate:"omitempty"`
	EndDate   string `json:"end_date" form:"end_date" validate:"omitempty"`
	Type      string `json:"type" form:"type" validate:"omitempty,oneof=vocabulary listening reading writing speaking"`
}

// LearningStatsResponse 学习统计响应
type LearningStatsResponse struct {
	Period     string                   `json:"period"`
	StartDate  string                   `json:"start_date"`
	EndDate    string                   `json:"end_date"`
	TotalTime  int                      `json:"total_time"`
	TotalScore float64                  `json:"total_score"`
	TotalExp   int                      `json:"total_exp"`
	Breakdown  map[string]interface{}   `json:"breakdown"`
	Trends     []map[string]interface{} `json:"trends"`
}

// UserProgressResponse 用户进度响应
type UserProgressResponse struct {
	Level            UserLevel                `json:"level"`
	RecentStats      UserDailyStats           `json:"recent_stats"`
	WeeklyProgress   []UserDailyStats         `json:"weekly_progress"`
	MonthlyProgress  UserMonthlyStats         `json:"monthly_progress"`
	Achievements     []UserAchievement        `json:"achievements"`
	StreakInfo       map[string]interface{}   `json:"streak_info"`
	LearningGoals    map[string]interface{}   `json:"learning_goals"`
	Recommendations  []map[string]interface{} `json:"recommendations"`
}

// AchievementResponse 成就响应
type AchievementResponse struct {
	ID          uint      `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	IconURL     string    `json:"icon_url"`
	Category    string    `json:"category"`
	Rarity      string    `json:"rarity"`
	Progress    int       `json:"progress"`
	TargetValue int       `json:"target_value"`
	IsCompleted bool      `json:"is_completed"`
	UnlockedAt  *time.Time `json:"unlocked_at"`
	RewardExp   int       `json:"reward_exp"`
}

// TableName 指定表名
func (UserLearningSession) TableName() string {
	return "user_learning_sessions"
}

func (UserDailyStats) TableName() string {
	return "user_daily_stats"
}

func (UserWeeklyStats) TableName() string {
	return "user_weekly_stats"
}

func (UserMonthlyStats) TableName() string {
	return "user_monthly_stats"
}

func (UserAchievement) TableName() string {
	return "user_achievements"
}

func (Achievement) TableName() string {
	return "achievements"
}

func (UserLevel) TableName() string {
	return "user_levels"
}

// GORM钩子
func (uds *UserDailyStats) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	uds.CreatedAt = now
	uds.UpdatedAt = now
	return nil
}

func (uds *UserDailyStats) BeforeUpdate(tx *gorm.DB) error {
	uds.UpdatedAt = time.Now()
	return nil
}

func (uws *UserWeeklyStats) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	uws.CreatedAt = now
	uws.UpdatedAt = now
	return nil
}

func (uws *UserWeeklyStats) BeforeUpdate(tx *gorm.DB) error {
	uws.UpdatedAt = time.Now()
	return nil
}

func (ums *UserMonthlyStats) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	ums.CreatedAt = now
	ums.UpdatedAt = now
	return nil
}

func (ums *UserMonthlyStats) BeforeUpdate(tx *gorm.DB) error {
	ums.UpdatedAt = time.Now()
	return nil
}

func (ul *UserLevel) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	ul.CreatedAt = now
	ul.UpdatedAt = now
	return nil
}

func (ul *UserLevel) BeforeUpdate(tx *gorm.DB) error {
	ul.UpdatedAt = time.Now()
	return nil
}

func (a *Achievement) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	a.CreatedAt = now
	a.UpdatedAt = now
	return nil
}

func (a *Achievement) BeforeUpdate(tx *gorm.DB) error {
	a.UpdatedAt = time.Now()
	return nil
}