package models

import (
	"time"

	"gorm.io/gorm"
)

// VocabularyCategory 词汇分类表
type VocabularyCategory struct {
	ID          uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Name        string    `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string    `json:"description" gorm:"type:text"`
	Level       string    `json:"level" gorm:"size:20;comment:beginner,intermediate,advanced"`
	IconURL     string    `json:"icon_url" gorm:"size:500"`
	SortOrder   int       `json:"sort_order" gorm:"default:0"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联关系
	Vocabularies []Vocabulary `json:"vocabularies,omitempty" gorm:"many2many:vocabulary_category_relations;"`
}

// Vocabulary 词汇表
type Vocabulary struct {
	ID               uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Word             string    `json:"word" gorm:"size:100;not null;uniqueIndex"`
	PhoneticUS       string    `json:"phonetic_us" gorm:"size:100;comment:美式音标"`
	PhoneticUK       string    `json:"phonetic_uk" gorm:"size:100;comment:英式音标"`
	AudioUS          string    `json:"audio_us" gorm:"size:500;comment:美式发音音频URL"`
	AudioUK          string    `json:"audio_uk" gorm:"size:500;comment:英式发音音频URL"`
	DifficultyLevel  int       `json:"difficulty_level" gorm:"default:1;comment:1-10难度等级"`
	FrequencyRank    int       `json:"frequency_rank" gorm:"default:0;comment:词频排名"`
	WordType         string    `json:"word_type" gorm:"size:50;comment:词性类型"`
	Etymology        string    `json:"etymology" gorm:"type:text;comment:词源"`
	MemoryTip        string    `json:"memory_tip" gorm:"type:text;comment:记忆技巧"`
	IsActive         bool      `json:"is_active" gorm:"default:true"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`

	// 关联关系
	Definitions []VocabularyDefinition `json:"definitions,omitempty" gorm:"foreignKey:VocabularyID"`
	Examples    []VocabularyExample    `json:"examples,omitempty" gorm:"foreignKey:VocabularyID"`
	Images      []VocabularyImage      `json:"images,omitempty" gorm:"foreignKey:VocabularyID"`
	Categories  []VocabularyCategory   `json:"categories,omitempty" gorm:"many2many:vocabulary_category_relations;"`
	UserProgress []UserVocabularyProgress `json:"user_progress,omitempty" gorm:"foreignKey:VocabularyID"`
}

// VocabularyDefinition 词汇释义表
type VocabularyDefinition struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	VocabularyID uint      `json:"vocabulary_id" gorm:"not null;index"`
	PartOfSpeech string    `json:"part_of_speech" gorm:"size:20;comment:词性:n,v,adj,adv等"`
	Definition   string    `json:"definition" gorm:"type:text;not null;comment:英文释义"`
	Chinese      string    `json:"chinese" gorm:"type:text;comment:中文释义"`
	SortOrder    int       `json:"sort_order" gorm:"default:0"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	Vocabulary Vocabulary `json:"-" gorm:"foreignKey:VocabularyID;constraint:OnDelete:CASCADE"`
}

// VocabularyExample 词汇例句表
type VocabularyExample struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	VocabularyID uint      `json:"vocabulary_id" gorm:"not null;index"`
	Sentence     string    `json:"sentence" gorm:"type:text;not null;comment:英文例句"`
	Translation  string    `json:"translation" gorm:"type:text;comment:中文翻译"`
	AudioURL     string    `json:"audio_url" gorm:"size:500;comment:例句音频URL"`
	Source       string    `json:"source" gorm:"size:200;comment:例句来源"`
	Difficulty   int       `json:"difficulty" gorm:"default:1;comment:例句难度1-5"`
	SortOrder    int       `json:"sort_order" gorm:"default:0"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	Vocabulary Vocabulary `json:"-" gorm:"foreignKey:VocabularyID;constraint:OnDelete:CASCADE"`
}

// VocabularyImage 词汇图片表
type VocabularyImage struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	VocabularyID uint      `json:"vocabulary_id" gorm:"not null;index"`
	ImageURL     string    `json:"image_url" gorm:"size:500;not null"`
	Description  string    `json:"description" gorm:"type:text;comment:图片描述"`
	AltText      string    `json:"alt_text" gorm:"size:200;comment:替代文本"`
	SortOrder    int       `json:"sort_order" gorm:"default:0"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	Vocabulary Vocabulary `json:"-" gorm:"foreignKey:VocabularyID;constraint:OnDelete:CASCADE"`
}

// VocabularyCategoryRelation 词汇分类关联表
type VocabularyCategoryRelation struct {
	VocabularyID uint      `json:"vocabulary_id" gorm:"primaryKey"`
	CategoryID   uint      `json:"category_id" gorm:"primaryKey"`
	CreatedAt    time.Time `json:"created_at"`
}

// UserVocabularyProgress 用户词汇学习进度表
type UserVocabularyProgress struct {
	ID                uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID            uint      `json:"user_id" gorm:"not null;index"`
	VocabularyID      uint      `json:"vocabulary_id" gorm:"not null;index"`
	MasteryLevel      int       `json:"mastery_level" gorm:"default:0;comment:掌握程度0-5"`
	CorrectCount      int       `json:"correct_count" gorm:"default:0;comment:答对次数"`
	IncorrectCount    int       `json:"incorrect_count" gorm:"default:0;comment:答错次数"`
	LastReviewAt      *time.Time `json:"last_review_at" gorm:"comment:最后复习时间"`
	NextReviewAt      *time.Time `json:"next_review_at" gorm:"comment:下次复习时间"`
	ReviewInterval    int       `json:"review_interval" gorm:"default:1;comment:复习间隔(天)"`
	EasinessFactor    float64   `json:"easiness_factor" gorm:"default:2.5;comment:遗忘曲线系数"`
	ConsecutiveCorrect int      `json:"consecutive_correct" gorm:"default:0;comment:连续答对次数"`
	FirstLearnedAt    *time.Time `json:"first_learned_at" gorm:"comment:首次学习时间"`
	TotalStudyTime    int       `json:"total_study_time" gorm:"default:0;comment:总学习时间(秒)"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`

	// 外键关联
	User       User       `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Vocabulary Vocabulary `json:"vocabulary,omitempty" gorm:"foreignKey:VocabularyID;constraint:OnDelete:CASCADE"`

	// 唯一索引
	_ struct{} `gorm:"uniqueIndex:idx_user_vocabulary,priority:1"`
}

// VocabularyTest 词汇测试表
type VocabularyTest struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       uint      `json:"user_id" gorm:"not null;index"`
	VocabularyID uint      `json:"vocabulary_id" gorm:"not null;index"`
	TestType     string    `json:"test_type" gorm:"size:20;not null;comment:choice,fill,listen,spell"`
	Question     string    `json:"question" gorm:"type:text;not null"`
	Options      string    `json:"options" gorm:"type:json;comment:选择题选项JSON"`
	CorrectAnswer string   `json:"correct_answer" gorm:"type:text;not null"`
	UserAnswer   string    `json:"user_answer" gorm:"type:text"`
	IsCorrect    bool      `json:"is_correct" gorm:"default:false"`
	ResponseTime int       `json:"response_time" gorm:"default:0;comment:响应时间(毫秒)"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	User       User       `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Vocabulary Vocabulary `json:"vocabulary,omitempty" gorm:"foreignKey:VocabularyID;constraint:OnDelete:CASCADE"`
}

// 请求和响应结构体

// VocabularyListRequest 词汇列表请求
type VocabularyListRequest struct {
	CategoryID   uint   `json:"category_id" form:"category_id"`
	Level        string `json:"level" form:"level" validate:"omitempty,oneof=beginner intermediate advanced"`
	Difficulty   int    `json:"difficulty" form:"difficulty" validate:"omitempty,min=1,max=10"`
	Keyword      string `json:"keyword" form:"keyword"`
	Page         int    `json:"page" form:"page" validate:"omitempty,min=1"`
	PageSize     int    `json:"page_size" form:"page_size" validate:"omitempty,min=1,max=100"`
	SortBy       string `json:"sort_by" form:"sort_by" validate:"omitempty,oneof=word difficulty frequency created_at"`
	SortOrder    string `json:"sort_order" form:"sort_order" validate:"omitempty,oneof=asc desc"`
	OnlyLearned  bool   `json:"only_learned" form:"only_learned"`
	OnlyUnlearned bool  `json:"only_unlearned" form:"only_unlearned"`
}

// VocabularyResponse 词汇响应
type VocabularyResponse struct {
	ID               uint                      `json:"id"`
	Word             string                    `json:"word"`
	PhoneticUS       string                    `json:"phonetic_us"`
	PhoneticUK       string                    `json:"phonetic_uk"`
	AudioUS          string                    `json:"audio_us"`
	AudioUK          string                    `json:"audio_uk"`
	DifficultyLevel  int                       `json:"difficulty_level"`
	FrequencyRank    int                       `json:"frequency_rank"`
	WordType         string                    `json:"word_type"`
	Etymology        string                    `json:"etymology"`
	MemoryTip        string                    `json:"memory_tip"`
	Definitions      []VocabularyDefinition    `json:"definitions"`
	Examples         []VocabularyExample       `json:"examples"`
	Images           []VocabularyImage         `json:"images"`
	Categories       []VocabularyCategory      `json:"categories"`
	UserProgress     *UserVocabularyProgress   `json:"user_progress,omitempty"`
	CreatedAt        time.Time                 `json:"created_at"`
	UpdatedAt        time.Time                 `json:"updated_at"`
}

// VocabularyTestRequest 词汇测试请求
type VocabularyTestRequest struct {
	VocabularyID uint   `json:"vocabulary_id" validate:"required"`
	TestType     string `json:"test_type" validate:"required,oneof=choice fill listen spell"`
	UserAnswer   string `json:"user_answer" validate:"required"`
	ResponseTime int    `json:"response_time" validate:"omitempty,min=0"`
}

// VocabularyTestResponse 词汇测试响应
type VocabularyTestResponse struct {
	ID            uint   `json:"id"`
	IsCorrect     bool   `json:"is_correct"`
	CorrectAnswer string `json:"correct_answer"`
	Explanation   string `json:"explanation,omitempty"`
	Score         int    `json:"score"`
	MasteryLevel  int    `json:"mastery_level"`
	NextReviewAt  *time.Time `json:"next_review_at"`
}

// TableName 指定表名
func (VocabularyCategory) TableName() string {
	return "vocabulary_categories"
}

func (Vocabulary) TableName() string {
	return "vocabulary"
}

func (VocabularyDefinition) TableName() string {
	return "vocabulary_definitions"
}

func (VocabularyExample) TableName() string {
	return "vocabulary_examples"
}

func (VocabularyImage) TableName() string {
	return "vocabulary_images"
}

func (VocabularyCategoryRelation) TableName() string {
	return "vocabulary_category_relations"
}

func (UserVocabularyProgress) TableName() string {
	return "user_vocabulary_progress"
}

func (VocabularyTest) TableName() string {
	return "vocabulary_tests"
}

// GORM钩子
func (v *Vocabulary) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	v.CreatedAt = now
	v.UpdatedAt = now
	return nil
}

func (v *Vocabulary) BeforeUpdate(tx *gorm.DB) error {
	v.UpdatedAt = time.Now()
	return nil
}

func (uvp *UserVocabularyProgress) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	uvp.CreatedAt = now
	uvp.UpdatedAt = now
	if uvp.FirstLearnedAt == nil {
		uvp.FirstLearnedAt = &now
	}
	return nil
}

func (uvp *UserVocabularyProgress) BeforeUpdate(tx *gorm.DB) error {
	uvp.UpdatedAt = time.Now()
	return nil
}