package models

import (
	"time"

	"gorm.io/gorm"
)

// ListeningExercise 听力练习表
type ListeningExercise struct {
	ID          uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Title       string    `json:"title" gorm:"size:200;not null"`
	Description string    `json:"description" gorm:"type:text"`
	AudioURL    string    `json:"audio_url" gorm:"size:500;not null"`
	Transcript  string    `json:"transcript" gorm:"type:text;comment:听力原文"`
	Duration    int       `json:"duration" gorm:"comment:音频时长(秒)"`
	Difficulty  int       `json:"difficulty" gorm:"default:1;comment:难度等级1-5"`
	Level       string    `json:"level" gorm:"size:20;comment:beginner,intermediate,advanced"`
	Category    string    `json:"category" gorm:"size:50;comment:对话,新闻,讲座等"`
	Tags        string    `json:"tags" gorm:"type:json;comment:标签JSON数组"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联关系
	Questions []ListeningQuestion `json:"questions,omitempty" gorm:"foreignKey:ExerciseID"`
	Records   []ListeningRecord   `json:"records,omitempty" gorm:"foreignKey:ExerciseID"`
}

// ListeningQuestion 听力题目表
type ListeningQuestion struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	ExerciseID   uint      `json:"exercise_id" gorm:"not null;index"`
	QuestionType string    `json:"question_type" gorm:"size:20;not null;comment:choice,fill,true_false"`
	Question     string    `json:"question" gorm:"type:text;not null"`
	Options      string    `json:"options" gorm:"type:json;comment:选择题选项JSON"`
	CorrectAnswer string   `json:"correct_answer" gorm:"type:text;not null"`
	Explanation  string    `json:"explanation" gorm:"type:text;comment:答案解析"`
	StartTime    float64   `json:"start_time" gorm:"comment:题目对应音频开始时间(秒)"`
	EndTime      float64   `json:"end_time" gorm:"comment:题目对应音频结束时间(秒)"`
	SortOrder    int       `json:"sort_order" gorm:"default:0"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	Exercise ListeningExercise `json:"-" gorm:"foreignKey:ExerciseID;constraint:OnDelete:CASCADE"`
}

// ListeningRecord 听力练习记录表
type ListeningRecord struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       uint      `json:"user_id" gorm:"not null;index"`
	ExerciseID   uint      `json:"exercise_id" gorm:"not null;index"`
	Score        int       `json:"score" gorm:"comment:得分"`
	TotalQuestions int     `json:"total_questions" gorm:"comment:总题数"`
	CorrectAnswers int     `json:"correct_answers" gorm:"comment:答对题数"`
	CompletionTime int     `json:"completion_time" gorm:"comment:完成时间(秒)"`
	Answers      string    `json:"answers" gorm:"type:json;comment:用户答案JSON"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	User     User              `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Exercise ListeningExercise `json:"exercise,omitempty" gorm:"foreignKey:ExerciseID;constraint:OnDelete:CASCADE"`
}

// ReadingExercise 阅读理解练习表
type ReadingExercise struct {
	ID          uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Title       string    `json:"title" gorm:"size:200;not null"`
	Content     string    `json:"content" gorm:"type:longtext;not null;comment:阅读文章内容"`
	Summary     string    `json:"summary" gorm:"type:text;comment:文章摘要"`
	WordCount   int       `json:"word_count" gorm:"comment:文章字数"`
	ReadingTime int       `json:"reading_time" gorm:"comment:预计阅读时间(分钟)"`
	Difficulty  int       `json:"difficulty" gorm:"default:1;comment:难度等级1-5"`
	Level       string    `json:"level" gorm:"size:20;comment:beginner,intermediate,advanced"`
	Category    string    `json:"category" gorm:"size:50;comment:新闻,小说,科技等"`
	Source      string    `json:"source" gorm:"size:200;comment:文章来源"`
	Tags        string    `json:"tags" gorm:"type:json;comment:标签JSON数组"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联关系
	Questions []ReadingQuestion `json:"questions,omitempty" gorm:"foreignKey:ExerciseID"`
	Records   []ReadingRecord   `json:"records,omitempty" gorm:"foreignKey:ExerciseID"`
}

// ReadingQuestion 阅读理解题目表
type ReadingQuestion struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	ExerciseID   uint      `json:"exercise_id" gorm:"not null;index"`
	QuestionType string    `json:"question_type" gorm:"size:20;not null;comment:choice,fill,true_false,short_answer"`
	Question     string    `json:"question" gorm:"type:text;not null"`
	Options      string    `json:"options" gorm:"type:json;comment:选择题选项JSON"`
	CorrectAnswer string   `json:"correct_answer" gorm:"type:text;not null"`
	Explanation  string    `json:"explanation" gorm:"type:text;comment:答案解析"`
	RelatedParagraph int   `json:"related_paragraph" gorm:"comment:相关段落号"`
	SortOrder    int       `json:"sort_order" gorm:"default:0"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	Exercise ReadingExercise `json:"-" gorm:"foreignKey:ExerciseID;constraint:OnDelete:CASCADE"`
}

// ReadingRecord 阅读练习记录表
type ReadingRecord struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       uint      `json:"user_id" gorm:"not null;index"`
	ExerciseID   uint      `json:"exercise_id" gorm:"not null;index"`
	Score        int       `json:"score" gorm:"comment:得分"`
	TotalQuestions int     `json:"total_questions" gorm:"comment:总题数"`
	CorrectAnswers int     `json:"correct_answers" gorm:"comment:答对题数"`
	ReadingTime  int       `json:"reading_time" gorm:"comment:阅读时间(秒)"`
	CompletionTime int     `json:"completion_time" gorm:"comment:完成时间(秒)"`
	Answers      string    `json:"answers" gorm:"type:json;comment:用户答案JSON"`
	CreatedAt    time.Time `json:"created_at"`

	// 外键关联
	User     User            `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Exercise ReadingExercise `json:"exercise,omitempty" gorm:"foreignKey:ExerciseID;constraint:OnDelete:CASCADE"`
}

// WritingExercise 写作练习表
type WritingExercise struct {
	ID          uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Title       string    `json:"title" gorm:"size:200;not null"`
	Prompt      string    `json:"prompt" gorm:"type:text;not null;comment:写作提示"`
	Instructions string   `json:"instructions" gorm:"type:text;comment:写作要求"`
	MinWords    int       `json:"min_words" gorm:"default:100;comment:最少字数"`
	MaxWords    int       `json:"max_words" gorm:"default:500;comment:最多字数"`
	TimeLimit   int       `json:"time_limit" gorm:"comment:时间限制(分钟)"`
	Difficulty  int       `json:"difficulty" gorm:"default:1;comment:难度等级1-5"`
	Level       string    `json:"level" gorm:"size:20;comment:beginner,intermediate,advanced"`
	Category    string    `json:"category" gorm:"size:50;comment:议论文,记叙文,应用文等"`
	Tags        string    `json:"tags" gorm:"type:json;comment:标签JSON数组"`
	SampleEssay string    `json:"sample_essay" gorm:"type:longtext;comment:范文"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联关系
	Submissions []WritingSubmission `json:"submissions,omitempty" gorm:"foreignKey:ExerciseID"`
}

// WritingSubmission 写作提交表
type WritingSubmission struct {
	ID           uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       uint      `json:"user_id" gorm:"not null;index"`
	ExerciseID   uint      `json:"exercise_id" gorm:"not null;index"`
	Content      string    `json:"content" gorm:"type:longtext;not null;comment:写作内容"`
	WordCount    int       `json:"word_count" gorm:"comment:字数统计"`
	WritingTime  int       `json:"writing_time" gorm:"comment:写作时间(秒)"`
	Score        int       `json:"score" gorm:"comment:总分"`
	GrammarScore int       `json:"grammar_score" gorm:"comment:语法分数"`
	VocabScore   int       `json:"vocab_score" gorm:"comment:词汇分数"`
	StructureScore int     `json:"structure_score" gorm:"comment:结构分数"`
	ContentScore int       `json:"content_score" gorm:"comment:内容分数"`
	Feedback     string    `json:"feedback" gorm:"type:text;comment:AI反馈"`
	Suggestions  string    `json:"suggestions" gorm:"type:json;comment:改进建议JSON"`
	Status       string    `json:"status" gorm:"size:20;default:submitted;comment:submitted,graded,reviewed"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`

	// 外键关联
	User     User            `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Exercise WritingExercise `json:"exercise,omitempty" gorm:"foreignKey:ExerciseID;constraint:OnDelete:CASCADE"`
}

// SpeakingExercise 口语练习表
type SpeakingExercise struct {
	ID          uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Title       string    `json:"title" gorm:"size:200;not null"`
	Prompt      string    `json:"prompt" gorm:"type:text;not null;comment:口语提示"`
	Instructions string   `json:"instructions" gorm:"type:text;comment:练习要求"`
	TimeLimit   int       `json:"time_limit" gorm:"comment:时间限制(秒)"`
	Difficulty  int       `json:"difficulty" gorm:"default:1;comment:难度等级1-5"`
	Level       string    `json:"level" gorm:"size:20;comment:beginner,intermediate,advanced"`
	Category    string    `json:"category" gorm:"size:50;comment:日常对话,演讲,描述等"`
	Tags        string    `json:"tags" gorm:"type:json;comment:标签JSON数组"`
	SampleAudio string    `json:"sample_audio" gorm:"size:500;comment:示例音频URL"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联关系
	Recordings []SpeakingRecording `json:"recordings,omitempty" gorm:"foreignKey:ExerciseID"`
}

// SpeakingRecording 口语录音表
type SpeakingRecording struct {
	ID              uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID          uint      `json:"user_id" gorm:"not null;index"`
	ExerciseID      uint      `json:"exercise_id" gorm:"not null;index"`
	AudioURL        string    `json:"audio_url" gorm:"size:500;not null;comment:录音文件URL"`
	Duration        int       `json:"duration" gorm:"comment:录音时长(秒)"`
	Transcript      string    `json:"transcript" gorm:"type:text;comment:语音识别文本"`
	Score           int       `json:"score" gorm:"comment:总分"`
	PronunciationScore int    `json:"pronunciation_score" gorm:"comment:发音分数"`
	FluencyScore    int       `json:"fluency_score" gorm:"comment:流利度分数"`
	AccuracyScore   int       `json:"accuracy_score" gorm:"comment:准确度分数"`
	CompletenessScore int     `json:"completeness_score" gorm:"comment:完整度分数"`
	Feedback        string    `json:"feedback" gorm:"type:text;comment:AI反馈"`
	Suggestions     string    `json:"suggestions" gorm:"type:json;comment:改进建议JSON"`
	Status          string    `json:"status" gorm:"size:20;default:submitted;comment:submitted,analyzed,reviewed"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`

	// 外键关联
	User     User             `json:"-" gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Exercise SpeakingExercise `json:"exercise,omitempty" gorm:"foreignKey:ExerciseID;constraint:OnDelete:CASCADE"`
}

// 请求和响应结构体

// ExerciseListRequest 练习列表请求
type ExerciseListRequest struct {
	Level      string `json:"level" form:"level" validate:"omitempty,oneof=beginner intermediate advanced"`
	Difficulty int    `json:"difficulty" form:"difficulty" validate:"omitempty,min=1,max=5"`
	Category   string `json:"category" form:"category"`
	Keyword    string `json:"keyword" form:"keyword"`
	Page       int    `json:"page" form:"page" validate:"omitempty,min=1"`
	PageSize   int    `json:"page_size" form:"page_size" validate:"omitempty,min=1,max=100"`
	SortBy     string `json:"sort_by" form:"sort_by" validate:"omitempty,oneof=title difficulty created_at"`
	SortOrder  string `json:"sort_order" form:"sort_order" validate:"omitempty,oneof=asc desc"`
}

// ExerciseSubmitRequest 练习提交请求
type ExerciseSubmitRequest struct {
	ExerciseID uint   `json:"exercise_id" validate:"required"`
	Answers    string `json:"answers" validate:"required"`
	TimeSpent  int    `json:"time_spent" validate:"omitempty,min=0"`
}

// WritingSubmitRequest 写作提交请求
type WritingSubmitRequest struct {
	ExerciseID  uint   `json:"exercise_id" validate:"required"`
	Content     string `json:"content" validate:"required,min=10"`
	WritingTime int    `json:"writing_time" validate:"omitempty,min=0"`
}

// SpeakingSubmitRequest 口语提交请求
type SpeakingSubmitRequest struct {
	ExerciseID uint   `json:"exercise_id" validate:"required"`
	AudioURL   string `json:"audio_url" validate:"required,url"`
	Duration   int    `json:"duration" validate:"required,min=1"`
}

// TableName 指定表名
func (ListeningExercise) TableName() string {
	return "listening_exercises"
}

func (ListeningQuestion) TableName() string {
	return "listening_questions"
}

func (ListeningRecord) TableName() string {
	return "listening_records"
}

func (ReadingExercise) TableName() string {
	return "reading_exercises"
}

func (ReadingQuestion) TableName() string {
	return "reading_questions"
}

func (ReadingRecord) TableName() string {
	return "reading_records"
}

func (WritingExercise) TableName() string {
	return "writing_exercises"
}

func (WritingSubmission) TableName() string {
	return "writing_submissions"
}

func (SpeakingExercise) TableName() string {
	return "speaking_exercises"
}

func (SpeakingRecording) TableName() string {
	return "speaking_recordings"
}

// GORM钩子
func (le *ListeningExercise) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	le.CreatedAt = now
	le.UpdatedAt = now
	return nil
}

func (le *ListeningExercise) BeforeUpdate(tx *gorm.DB) error {
	le.UpdatedAt = time.Now()
	return nil
}

func (re *ReadingExercise) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	re.CreatedAt = now
	re.UpdatedAt = now
	return nil
}

func (re *ReadingExercise) BeforeUpdate(tx *gorm.DB) error {
	re.UpdatedAt = time.Now()
	return nil
}

func (we *WritingExercise) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	we.CreatedAt = now
	we.UpdatedAt = now
	return nil
}

func (we *WritingExercise) BeforeUpdate(tx *gorm.DB) error {
	we.UpdatedAt = time.Now()
	return nil
}

func (se *SpeakingExercise) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	se.CreatedAt = now
	se.UpdatedAt = now
	return nil
}

func (se *SpeakingExercise) BeforeUpdate(tx *gorm.DB) error {
	se.UpdatedAt = time.Now()
	return nil
}

func (ws *WritingSubmission) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	ws.CreatedAt = now
	ws.UpdatedAt = now
	return nil
}

func (ws *WritingSubmission) BeforeUpdate(tx *gorm.DB) error {
	ws.UpdatedAt = time.Now()
	return nil
}

func (sr *SpeakingRecording) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	sr.CreatedAt = now
	sr.UpdatedAt = now
	return nil
}

func (sr *SpeakingRecording) BeforeUpdate(tx *gorm.DB) error {
	sr.UpdatedAt = time.Now()
	return nil
}