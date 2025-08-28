package models

import (
	"time"

	"gorm.io/gorm"
)

// ListeningMaterial 听力材料模型
type ListeningMaterial struct {
	ID          string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:材料ID"`
	Title       string    `json:"title" gorm:"type:varchar(200);not null;comment:标题"`
	Description *string   `json:"description" gorm:"type:text;comment:描述"`
	AudioURL    string    `json:"audio_url" gorm:"type:varchar(500);not null;comment:音频URL"`
	Transcript  *string   `json:"transcript" gorm:"type:longtext;comment:音频文本"`
	Duration    int       `json:"duration" gorm:"type:int;comment:时长(秒)"`
	Level       string    `json:"level" gorm:"type:enum('beginner','intermediate','advanced');not null;comment:难度级别"`
	Category    string    `json:"category" gorm:"type:varchar(50);comment:分类"`
	Tags        *string   `json:"tags" gorm:"type:json;comment:标签(JSON数组)"`
	IsActive    bool      `json:"is_active" gorm:"type:boolean;default:true;comment:是否启用"`
	CreatedAt   time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt   time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index;comment:删除时间"`
	
	// 关联关系
	ListeningRecords []ListeningRecord `json:"listening_records,omitempty" gorm:"foreignKey:MaterialID"`
}

// ListeningRecord 听力练习记录模型
type ListeningRecord struct {
	ID           string     `json:"id" gorm:"type:varchar(36);primaryKey;comment:记录ID"`
	UserID       string     `json:"user_id" gorm:"type:varchar(36);not null;index;comment:用户ID"`
	MaterialID   string     `json:"material_id" gorm:"type:varchar(36);not null;index;comment:材料ID"`
	Score        *float64   `json:"score" gorm:"type:decimal(5,2);comment:得分"`
	Accuracy     *float64   `json:"accuracy" gorm:"type:decimal(5,2);comment:准确率"`
	CompletionRate *float64 `json:"completion_rate" gorm:"type:decimal(5,2);comment:完成率"`
	TimeSpent    int        `json:"time_spent" gorm:"type:int;comment:用时(秒)"`
	Answers      *string    `json:"answers" gorm:"type:json;comment:答案(JSON对象)"`
	Feedback     *string    `json:"feedback" gorm:"type:text;comment:AI反馈"`
	StartedAt    time.Time  `json:"started_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:开始时间"`
	CompletedAt  *time.Time `json:"completed_at" gorm:"type:timestamp;comment:完成时间"`
	CreatedAt    time.Time  `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt    time.Time  `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	User     User              `json:"-" gorm:"foreignKey:UserID"`
	Material ListeningMaterial `json:"-" gorm:"foreignKey:MaterialID"`
}

// ReadingMaterial 阅读材料模型
type ReadingMaterial struct {
	ID          string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:材料ID"`
	Title       string    `json:"title" gorm:"type:varchar(200);not null;comment:标题"`
	Content     string    `json:"content" gorm:"type:longtext;not null;comment:内容"`
	Summary     *string   `json:"summary" gorm:"type:text;comment:摘要"`
	WordCount   int       `json:"word_count" gorm:"type:int;comment:字数"`
	Level       string    `json:"level" gorm:"type:enum('beginner','intermediate','advanced');not null;comment:难度级别"`
	Category    string    `json:"category" gorm:"type:varchar(50);comment:分类"`
	Tags        *string   `json:"tags" gorm:"type:json;comment:标签(JSON数组)"`
	Source      *string   `json:"source" gorm:"type:varchar(200);comment:来源"`
	Author      *string   `json:"author" gorm:"type:varchar(100);comment:作者"`
	IsActive    bool      `json:"is_active" gorm:"type:boolean;default:true;comment:是否启用"`
	CreatedAt   time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt   time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index;comment:删除时间"`
	
	// 关联关系
	ReadingRecords []ReadingRecord `json:"reading_records,omitempty" gorm:"foreignKey:MaterialID"`
}

// ReadingRecord 阅读练习记录模型
type ReadingRecord struct {
	ID             string     `json:"id" gorm:"type:varchar(36);primaryKey;comment:记录ID"`
	UserID         string     `json:"user_id" gorm:"type:varchar(36);not null;index;comment:用户ID"`
	MaterialID     string     `json:"material_id" gorm:"type:varchar(36);not null;index;comment:材料ID"`
	ReadingTime    int        `json:"reading_time" gorm:"type:int;comment:阅读时间(秒)"`
	ComprehensionScore *float64 `json:"comprehension_score" gorm:"type:decimal(5,2);comment:理解得分"`
	ReadingSpeed   *float64   `json:"reading_speed" gorm:"type:decimal(8,2);comment:阅读速度(词/分钟)"`
	Progress       float64    `json:"progress" gorm:"type:decimal(5,2);default:0;comment:阅读进度"`
	Bookmarks      *string    `json:"bookmarks" gorm:"type:json;comment:书签(JSON数组)"`
	Notes          *string    `json:"notes" gorm:"type:text;comment:笔记"`
	QuizAnswers    *string    `json:"quiz_answers" gorm:"type:json;comment:测验答案(JSON对象)"`
	StartedAt      time.Time  `json:"started_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:开始时间"`
	CompletedAt    *time.Time `json:"completed_at" gorm:"type:timestamp;comment:完成时间"`
	CreatedAt      time.Time  `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt      time.Time  `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	User     User            `json:"-" gorm:"foreignKey:UserID"`
	Material ReadingMaterial `json:"-" gorm:"foreignKey:MaterialID"`
}

// WritingPrompt 写作题目模型
type WritingPrompt struct {
	ID          string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:题目ID"`
	Title       string    `json:"title" gorm:"type:varchar(200);not null;comment:标题"`
	Prompt      string    `json:"prompt" gorm:"type:text;not null;comment:题目内容"`
	Instructions *string  `json:"instructions" gorm:"type:text;comment:写作要求"`
	MinWords    *int      `json:"min_words" gorm:"type:int;comment:最少字数"`
	MaxWords    *int      `json:"max_words" gorm:"type:int;comment:最多字数"`
	TimeLimit   *int      `json:"time_limit" gorm:"type:int;comment:时间限制(分钟)"`
	Level       string    `json:"level" gorm:"type:enum('beginner','intermediate','advanced');not null;comment:难度级别"`
	Category    string    `json:"category" gorm:"type:varchar(50);comment:分类"`
	Tags        *string   `json:"tags" gorm:"type:json;comment:标签(JSON数组)"`
	SampleAnswer *string  `json:"sample_answer" gorm:"type:longtext;comment:参考答案"`
	Rubric      *string   `json:"rubric" gorm:"type:json;comment:评分标准(JSON对象)"`
	IsActive    bool      `json:"is_active" gorm:"type:boolean;default:true;comment:是否启用"`
	CreatedAt   time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt   time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index;comment:删除时间"`
	
	// 关联关系
	WritingSubmissions []WritingSubmission `json:"writing_submissions,omitempty" gorm:"foreignKey:PromptID"`
}

// WritingSubmission 写作提交模型
type WritingSubmission struct {
	ID           string     `json:"id" gorm:"type:varchar(36);primaryKey;comment:提交ID"`
	UserID       string     `json:"user_id" gorm:"type:varchar(36);not null;index;comment:用户ID"`
	PromptID     string     `json:"prompt_id" gorm:"type:varchar(36);not null;index;comment:题目ID"`
	Content      string     `json:"content" gorm:"type:longtext;not null;comment:写作内容"`
	WordCount    int        `json:"word_count" gorm:"type:int;comment:字数"`
	TimeSpent    int        `json:"time_spent" gorm:"type:int;comment:用时(秒)"`
	Score        *float64   `json:"score" gorm:"type:decimal(5,2);comment:总分"`
	GrammarScore *float64   `json:"grammar_score" gorm:"type:decimal(5,2);comment:语法得分"`
	VocabScore   *float64   `json:"vocab_score" gorm:"type:decimal(5,2);comment:词汇得分"`
	CoherenceScore *float64 `json:"coherence_score" gorm:"type:decimal(5,2);comment:连贯性得分"`
	Feedback     *string    `json:"feedback" gorm:"type:longtext;comment:AI反馈"`
	Suggestions  *string    `json:"suggestions" gorm:"type:json;comment:改进建议(JSON数组)"`
	StartedAt    time.Time  `json:"started_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:开始时间"`
	SubmittedAt  *time.Time `json:"submitted_at" gorm:"type:timestamp;comment:提交时间"`
	GradedAt     *time.Time `json:"graded_at" gorm:"type:timestamp;comment:批改时间"`
	CreatedAt    time.Time  `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt    time.Time  `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	User   User          `json:"-" gorm:"foreignKey:UserID"`
	Prompt WritingPrompt `json:"-" gorm:"foreignKey:PromptID"`
}

// SpeakingScenario 口语场景模型
type SpeakingScenario struct {
	ID          string    `json:"id" gorm:"type:varchar(36);primaryKey;comment:场景ID"`
	Title       string    `json:"title" gorm:"type:varchar(200);not null;comment:标题"`
	Description string    `json:"description" gorm:"type:text;not null;comment:场景描述"`
	Context     *string   `json:"context" gorm:"type:text;comment:背景信息"`
	Level       string    `json:"level" gorm:"type:enum('beginner','intermediate','advanced');not null;comment:难度级别"`
	Category    string    `json:"category" gorm:"type:varchar(50);comment:分类"`
	Tags        *string   `json:"tags" gorm:"type:json;comment:标签(JSON数组)"`
	Dialogue    *string   `json:"dialogue" gorm:"type:json;comment:对话模板(JSON数组)"`
	KeyPhrases  *string   `json:"key_phrases" gorm:"type:json;comment:关键短语(JSON数组)"`
	IsActive    bool      `json:"is_active" gorm:"type:boolean;default:true;comment:是否启用"`
	CreatedAt   time.Time `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt   time.Time `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index;comment:删除时间"`
	
	// 关联关系
	SpeakingRecords []SpeakingRecord `json:"speaking_records,omitempty" gorm:"foreignKey:ScenarioID"`
}

// SpeakingRecord 口语练习记录模型
type SpeakingRecord struct {
	ID                string     `json:"id" gorm:"type:varchar(36);primaryKey;comment:记录ID"`
	UserID            string     `json:"user_id" gorm:"type:varchar(36);not null;index;comment:用户ID"`
	ScenarioID        string     `json:"scenario_id" gorm:"type:varchar(36);not null;index;comment:场景ID"`
	AudioURL          *string    `json:"audio_url" gorm:"type:varchar(500);comment:录音URL"`
	Transcript        *string    `json:"transcript" gorm:"type:longtext;comment:语音识别文本"`
	Duration          int        `json:"duration" gorm:"type:int;comment:录音时长(秒)"`
	PronunciationScore *float64  `json:"pronunciation_score" gorm:"type:decimal(5,2);comment:发音得分"`
	FluencyScore      *float64   `json:"fluency_score" gorm:"type:decimal(5,2);comment:流利度得分"`
	AccuracyScore     *float64   `json:"accuracy_score" gorm:"type:decimal(5,2);comment:准确度得分"`
	OverallScore      *float64   `json:"overall_score" gorm:"type:decimal(5,2);comment:总分"`
	Feedback          *string    `json:"feedback" gorm:"type:longtext;comment:AI反馈"`
	Suggestions       *string    `json:"suggestions" gorm:"type:json;comment:改进建议(JSON数组)"`
	StartedAt         time.Time  `json:"started_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:开始时间"`
	CompletedAt       *time.Time `json:"completed_at" gorm:"type:timestamp;comment:完成时间"`
	CreatedAt         time.Time  `json:"created_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP;comment:创建时间"`
	UpdatedAt         time.Time  `json:"updated_at" gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;comment:更新时间"`
	
	// 关联关系
	User     User             `json:"-" gorm:"foreignKey:UserID"`
	Scenario SpeakingScenario `json:"-" gorm:"foreignKey:ScenarioID"`
}

// TableName 指定表名
func (ListeningMaterial) TableName() string {
	return "listening_materials"
}

func (ListeningRecord) TableName() string {
	return "listening_records"
}

func (ReadingMaterial) TableName() string {
	return "reading_materials"
}

func (ReadingRecord) TableName() string {
	return "reading_records"
}

func (WritingPrompt) TableName() string {
	return "writing_prompts"
}

func (WritingSubmission) TableName() string {
	return "writing_submissions"
}

func (SpeakingScenario) TableName() string {
	return "speaking_scenarios"
}

func (SpeakingRecord) TableName() string {
	return "speaking_records"
}