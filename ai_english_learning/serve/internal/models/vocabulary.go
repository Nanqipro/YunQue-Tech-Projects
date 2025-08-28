package models

import (
	"time"

	"gorm.io/gorm"
)

// VocabularyCategory 词汇分类模型
type VocabularyCategory struct {
	ID          string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:分类ID"`
	Name        string    `json:"name" gorm:"type:varchar(100);not null;comment:分类名称"`
	Description *string   `json:"description" gorm:"type:text;comment:分类描述"`
	Level       string    `json:"level" gorm:"type:enum('beginner','intermediate','advanced');not null;comment:难度级别"`
	Icon        *string   `json:"icon" gorm:"type:varchar(255);comment:图标URL"`
	Color       *string   `json:"color" gorm:"type:varchar(7);comment:主题色"`
	SortOrder   int       `json:"sort_order" gorm:"type:int;default:0;comment:排序"`
	IsActive    bool      `json:"is_active" gorm:"type:boolean;default:true;comment:是否启用"`
	CreatedAt   time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt   time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	Vocabularies []Vocabulary `json:"vocabularies,omitempty" gorm:"many2many:vocabulary_category_relations;"`
}

// Vocabulary 词汇模型
type Vocabulary struct {
	ID             string                `json:"id" gorm:"type:varchar(36);primaryKey;comment:词汇ID"`
	Word           string                `json:"word" gorm:"type:varchar(100);uniqueIndex;not null;comment:单词"`
	Phonetic       *string               `json:"phonetic" gorm:"type:varchar(200);comment:音标"`
	AudioURL       *string               `json:"audio_url" gorm:"type:varchar(500);comment:音频URL"`
	Level          string                `json:"level" gorm:"type:enum('beginner','intermediate','advanced');not null;comment:难度级别"`
	Frequency      int                   `json:"frequency" gorm:"type:int;default:0;comment:使用频率"`
	IsActive       bool                  `json:"is_active" gorm:"type:boolean;default:true;comment:是否启用"`
	CreatedAt      time.Time             `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt      time.Time             `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	DeletedAt      gorm.DeletedAt        `json:"-" gorm:"index;comment:删除时间"`
	
	// 关联关系
	Definitions    []VocabularyDefinition `json:"definitions,omitempty" gorm:"foreignKey:VocabularyID"`
	Examples       []VocabularyExample    `json:"examples,omitempty" gorm:"foreignKey:VocabularyID"`
	Images         []VocabularyImage      `json:"images,omitempty" gorm:"foreignKey:VocabularyID"`
	Categories     []VocabularyCategory   `json:"categories,omitempty" gorm:"many2many:vocabulary_category_relations;"`
	UserProgress   []UserVocabularyProgress `json:"user_progress,omitempty" gorm:"foreignKey:VocabularyID"`
}

// VocabularyDefinition 词汇定义模型
type VocabularyDefinition struct {
	ID           string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:定义ID"`
	VocabularyID string    `json:"vocabulary_id" gorm:"type:varchar(36);not null;index;comment:词汇ID"`
	PartOfSpeech string    `json:"part_of_speech" gorm:"type:varchar(20);not null;comment:词性"`
	Definition   string    `json:"definition" gorm:"type:text;not null;comment:定义"`
	Translation  *string   `json:"translation" gorm:"type:text;comment:中文翻译"`
	SortOrder    int       `json:"sort_order" gorm:"type:int;default:0;comment:排序"`
	CreatedAt    time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt    time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	Vocabulary Vocabulary `json:"-" gorm:"foreignKey:VocabularyID"`
}

// VocabularyExample 词汇例句模型
type VocabularyExample struct {
	ID           string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:例句ID"`
	VocabularyID string    `json:"vocabulary_id" gorm:"type:varchar(36);not null;index;comment:词汇ID"`
	Example      string    `json:"example" gorm:"type:text;not null;comment:例句"`
	Translation  *string   `json:"translation" gorm:"type:text;comment:例句翻译"`
	AudioURL     *string   `json:"audio_url" gorm:"type:varchar(500);comment:音频URL"`
	SortOrder    int       `json:"sort_order" gorm:"type:int;default:0;comment:排序"`
	CreatedAt    time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt    time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	Vocabulary Vocabulary `json:"-" gorm:"foreignKey:VocabularyID"`
}

// VocabularyImage 词汇图片模型
type VocabularyImage struct {
	ID           string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:图片ID"`
	VocabularyID string    `json:"vocabulary_id" gorm:"type:varchar(36);not null;index;comment:词汇ID"`
	ImageURL     string    `json:"image_url" gorm:"type:varchar(500);not null;comment:图片URL"`
	AltText      *string   `json:"alt_text" gorm:"type:varchar(255);comment:替代文本"`
	Caption      *string   `json:"caption" gorm:"type:text;comment:图片说明"`
	SortOrder    int       `json:"sort_order" gorm:"type:int;default:0;comment:排序"`
	CreatedAt    time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt    time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	Vocabulary Vocabulary `json:"-" gorm:"foreignKey:VocabularyID"`
}

// VocabularyCategoryRelation 词汇分类关系模型
type VocabularyCategoryRelation struct {
	VocabularyID string    `json:"vocabulary_id" gorm:"type:varchar(36);primaryKey;comment:词汇ID"`
	CategoryID   string    `json:"category_id" gorm:"type:varchar(36);primaryKey;comment:分类ID"`
	CreatedAt    time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
}

// UserVocabularyProgress 用户词汇学习进度模型
type UserVocabularyProgress struct {
	ID                string     `json:"id" gorm:"type:varchar(36);primaryKey;comment:进度ID"`
	UserID            string     `json:"user_id" gorm:"type:varchar(36);not null;index;comment:用户ID"`
	VocabularyID      string     `json:"vocabulary_id" gorm:"type:varchar(36);not null;index;comment:词汇ID"`
	MasteryLevel      int        `json:"mastery_level" gorm:"type:int;default:0;comment:掌握程度(0-100)"`
	StudyCount        int        `json:"study_count" gorm:"type:int;default:0;comment:学习次数"`
	CorrectCount      int        `json:"correct_count" gorm:"type:int;default:0;comment:正确次数"`
	IncorrectCount    int        `json:"incorrect_count" gorm:"type:int;default:0;comment:错误次数"`
	LastStudiedAt     *time.Time `json:"last_studied_at" gorm:"type:timestamp;comment:最后学习时间"`
	NextReviewAt      *time.Time `json:"next_review_at" gorm:"type:timestamp;comment:下次复习时间"`
	IsMarkedDifficult bool       `json:"is_marked_difficult" gorm:"type:boolean;default:false;comment:是否标记为困难"`
	IsFavorite        bool       `json:"is_favorite" gorm:"type:boolean;default:false;comment:是否收藏"`
	Notes             *string    `json:"notes" gorm:"type:text;comment:学习笔记"`
	CreatedAt         time.Time  `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt         time.Time  `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	User       User       `json:"-" gorm:"foreignKey:UserID"`
	Vocabulary Vocabulary `json:"-" gorm:"foreignKey:VocabularyID"`
}

// VocabularyTest 词汇测试模型
type VocabularyTest struct {
	ID          string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:测试ID"`
	UserID      string    `json:"user_id" gorm:"type:varchar(36);not null;index;comment:用户ID"`
	TestType    string    `json:"test_type" gorm:"type:enum('placement','progress','review');not null;comment:测试类型"`
	Level       string    `json:"level" gorm:"type:enum('beginner','intermediate','advanced');comment:测试级别"`
	TotalWords  int       `json:"total_words" gorm:"type:int;not null;comment:总词汇数"`
	CorrectWords int      `json:"correct_words" gorm:"type:int;default:0;comment:正确词汇数"`
	Score       float64   `json:"score" gorm:"type:decimal(5,2);comment:得分"`
	Duration    int       `json:"duration" gorm:"type:int;comment:测试时长(秒)"`
	StartedAt   time.Time `json:"started_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:开始时间"`
	CompletedAt *time.Time `json:"completed_at" gorm:"type:timestamp;comment:完成时间"`
	CreatedAt   time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt   time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	User User `json:"-" gorm:"foreignKey:UserID"`
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