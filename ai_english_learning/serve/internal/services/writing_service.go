package services

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"gorm.io/gorm"
)

// WritingService 写作练习服务
type WritingService struct {
	db *gorm.DB
}

// NewWritingService 创建写作练习服务实例
func NewWritingService(db *gorm.DB) *WritingService {
	return &WritingService{
		db: db,
	}
}

// ===== 写作题目管理 =====

// GetWritingPrompts 获取写作题目列表
func (s *WritingService) GetWritingPrompts(difficulty string, category string, limit, offset int) ([]*models.WritingPrompt, error) {
	var prompts []*models.WritingPrompt
	query := s.db.Where("is_active = ?", true)

	if difficulty != "" {
		query = query.Where("difficulty = ?", difficulty)
	}
	if category != "" {
		query = query.Where("category = ?", category)
	}

	err := query.Order("created_at DESC").Limit(limit).Offset(offset).Find(&prompts).Error
	return prompts, err
}

// GetWritingPrompt 获取单个写作题目
func (s *WritingService) GetWritingPrompt(id string) (*models.WritingPrompt, error) {
	var prompt models.WritingPrompt
	err := s.db.Where("id = ? AND is_active = ?", id, true).First(&prompt).Error
	if err != nil {
		return nil, err
	}
	return &prompt, nil
}

// CreateWritingPrompt 创建写作题目
func (s *WritingService) CreateWritingPrompt(prompt *models.WritingPrompt) error {
	return s.db.Create(prompt).Error
}

// UpdateWritingPrompt 更新写作题目
func (s *WritingService) UpdateWritingPrompt(id string, prompt *models.WritingPrompt) error {
	return s.db.Where("id = ?", id).Updates(prompt).Error
}

// DeleteWritingPrompt 删除写作题目（软删除）
func (s *WritingService) DeleteWritingPrompt(id string) error {
	return s.db.Model(&models.WritingPrompt{}).Where("id = ?", id).Update("is_active", false).Error
}

// SearchWritingPrompts 搜索写作题目
func (s *WritingService) SearchWritingPrompts(keyword string, difficulty string, category string, limit, offset int) ([]*models.WritingPrompt, error) {
	var prompts []*models.WritingPrompt
	query := s.db.Where("is_active = ?", true)

	if keyword != "" {
		query = query.Where("title LIKE ? OR description LIKE ?", "%"+keyword+"%", "%"+keyword+"%")
	}
	if difficulty != "" {
		query = query.Where("difficulty = ?", difficulty)
	}
	if category != "" {
		query = query.Where("category = ?", category)
	}

	err := query.Order("created_at DESC").Limit(limit).Offset(offset).Find(&prompts).Error
	return prompts, err
}

// GetRecommendedPrompts 获取推荐写作题目
func (s *WritingService) GetRecommendedPrompts(userID string, limit int) ([]*models.WritingPrompt, error) {
	// 基于用户历史表现推荐合适难度的题目
	var prompts []*models.WritingPrompt
	
	// 获取用户最近的写作记录，分析难度偏好
	var avgScore sql.NullFloat64
	s.db.Model(&models.WritingSubmission{}).
		Where("user_id = ? AND score IS NOT NULL", userID).
		Select("AVG(score)").Scan(&avgScore)

	// 根据平均分推荐合适难度
	var difficulty string
	if !avgScore.Valid || avgScore.Float64 < 60 {
		difficulty = "beginner"
	} else if avgScore.Float64 < 80 {
		difficulty = "intermediate"
	} else {
		difficulty = "advanced"
	}

	err := s.db.Where("difficulty = ? AND is_active = ?", difficulty, true).
		Order("RAND()").Limit(limit).Find(&prompts).Error
	return prompts, err
}

// ===== 写作提交管理 =====

// CreateWritingSubmission 创建写作提交
func (s *WritingService) CreateWritingSubmission(submission *models.WritingSubmission) error {
	return s.db.Create(submission).Error
}

// UpdateWritingSubmission 更新写作提交
func (s *WritingService) UpdateWritingSubmission(id string, submission *models.WritingSubmission) error {
	return s.db.Where("id = ?", id).Updates(submission).Error
}

// GetWritingSubmission 获取写作提交详情
func (s *WritingService) GetWritingSubmission(id string) (*models.WritingSubmission, error) {
	var submission models.WritingSubmission
	err := s.db.Preload("Prompt").Where("id = ?", id).First(&submission).Error
	if err != nil {
		return nil, err
	}
	return &submission, nil
}

// GetUserWritingSubmissions 获取用户写作提交列表
func (s *WritingService) GetUserWritingSubmissions(userID string, limit, offset int) ([]*models.WritingSubmission, error) {
	var submissions []*models.WritingSubmission
	err := s.db.Preload("Prompt").Where("user_id = ?", userID).
		Order("created_at DESC").Limit(limit).Offset(offset).Find(&submissions).Error
	return submissions, err
}

// SubmitWriting 提交写作作业
func (s *WritingService) SubmitWriting(submissionID string, content string, timeSpent int) error {
	now := time.Now()
	updates := map[string]interface{}{
		"content":      content,
		"word_count":   len(content), // 简单字数统计，实际可能需要更复杂的逻辑
		"time_spent":   timeSpent,
		"submitted_at": &now,
	}

	return s.db.Model(&models.WritingSubmission{}).Where("id = ?", submissionID).Updates(updates).Error
}

// GradeWriting AI批改写作
func (s *WritingService) GradeWriting(submissionID string, score, grammarScore, vocabScore, coherenceScore float64, feedback, suggestions string) error {
	now := time.Now()
	updates := map[string]interface{}{
		"score":           score,
		"grammar_score":   grammarScore,
		"vocab_score":     vocabScore,
		"coherence_score": coherenceScore,
		"feedback":        feedback,
		"suggestions":     suggestions,
		"graded_at":       &now,
	}

	return s.db.Model(&models.WritingSubmission{}).Where("id = ?", submissionID).Updates(updates).Error
}

// ===== 写作统计分析 =====

// GetUserWritingStats 获取用户写作统计
func (s *WritingService) GetUserWritingStats(userID string) (map[string]interface{}, error) {
	stats := make(map[string]interface{})

	// 总提交数
	var totalSubmissions int64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ?", userID).Count(&totalSubmissions)
	stats["total_submissions"] = totalSubmissions

	// 已完成提交数
	var completedSubmissions int64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND submitted_at IS NOT NULL", userID).Count(&completedSubmissions)
	stats["completed_submissions"] = completedSubmissions

	// 已批改提交数
	var gradedSubmissions int64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND graded_at IS NOT NULL", userID).Count(&gradedSubmissions)
	stats["graded_submissions"] = gradedSubmissions

	// 平均分数
	var avgScore sql.NullFloat64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND score IS NOT NULL", userID).Select("AVG(score)").Scan(&avgScore)
	if avgScore.Valid {
		stats["average_score"] = fmt.Sprintf("%.2f", avgScore.Float64)
	} else {
		stats["average_score"] = "0.00"
	}

	// 平均语法分数
	var avgGrammarScore sql.NullFloat64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND grammar_score IS NOT NULL", userID).Select("AVG(grammar_score)").Scan(&avgGrammarScore)
	if avgGrammarScore.Valid {
		stats["average_grammar_score"] = fmt.Sprintf("%.2f", avgGrammarScore.Float64)
	} else {
		stats["average_grammar_score"] = "0.00"
	}

	// 平均词汇分数
	var avgVocabScore sql.NullFloat64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND vocab_score IS NOT NULL", userID).Select("AVG(vocab_score)").Scan(&avgVocabScore)
	if avgVocabScore.Valid {
		stats["average_vocab_score"] = fmt.Sprintf("%.2f", avgVocabScore.Float64)
	} else {
		stats["average_vocab_score"] = "0.00"
	}

	// 平均连贯性分数
	var avgCoherenceScore sql.NullFloat64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND coherence_score IS NOT NULL", userID).Select("AVG(coherence_score)").Scan(&avgCoherenceScore)
	if avgCoherenceScore.Valid {
		stats["average_coherence_score"] = fmt.Sprintf("%.2f", avgCoherenceScore.Float64)
	} else {
		stats["average_coherence_score"] = "0.00"
	}

	// 总写作时间
	var totalTimeSpent sql.NullInt64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND time_spent IS NOT NULL", userID).Select("SUM(time_spent)").Scan(&totalTimeSpent)
	if totalTimeSpent.Valid {
		stats["total_time_spent"] = totalTimeSpent.Int64
	} else {
		stats["total_time_spent"] = 0
	}

	// 平均写作时间
	var avgTimeSpent sql.NullFloat64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND time_spent IS NOT NULL", userID).Select("AVG(time_spent)").Scan(&avgTimeSpent)
	if avgTimeSpent.Valid {
		stats["average_time_spent"] = fmt.Sprintf("%.2f", avgTimeSpent.Float64)
	} else {
		stats["average_time_spent"] = "0.00"
	}

	// 总字数
	var totalWordCount sql.NullInt64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND word_count IS NOT NULL", userID).Select("SUM(word_count)").Scan(&totalWordCount)
	if totalWordCount.Valid {
		stats["total_word_count"] = totalWordCount.Int64
	} else {
		stats["total_word_count"] = 0
	}

	// 平均字数
	var avgWordCount sql.NullFloat64
	s.db.Model(&models.WritingSubmission{}).Where("user_id = ? AND word_count IS NOT NULL", userID).Select("AVG(word_count)").Scan(&avgWordCount)
	if avgWordCount.Valid {
		stats["average_word_count"] = fmt.Sprintf("%.2f", avgWordCount.Float64)
	} else {
		stats["average_word_count"] = "0.00"
	}

	// 连续写作天数
	continuousDays := s.calculateContinuousWritingDays(userID)
	stats["continuous_writing_days"] = continuousDays

	// 按难度统计
	difficultyStats := s.getWritingStatsByDifficulty(userID)
	stats["difficulty_stats"] = difficultyStats

	return stats, nil
}

// calculateContinuousWritingDays 计算连续写作天数
func (s *WritingService) calculateContinuousWritingDays(userID string) int {
	var dates []time.Time
	s.db.Model(&models.WritingSubmission{}).
		Where("user_id = ? AND submitted_at IS NOT NULL", userID).
		Select("DATE(submitted_at) as date").
		Group("DATE(submitted_at)").
		Order("date DESC").
		Pluck("date", &dates)

	if len(dates) == 0 {
		return 0
	}

	continuousDays := 1
	for i := 1; i < len(dates); i++ {
		diff := dates[i-1].Sub(dates[i]).Hours() / 24
		if diff == 1 {
			continuousDays++
		} else {
			break
		}
	}

	return continuousDays
}

// getWritingStatsByDifficulty 按难度获取写作统计
func (s *WritingService) getWritingStatsByDifficulty(userID string) map[string]interface{} {
	type DifficultyStats struct {
		Difficulty string  `json:"difficulty"`
		Count      int64   `json:"count"`
		AvgScore   float64 `json:"avg_score"`
	}

	var stats []DifficultyStats
	s.db.Model(&models.WritingSubmission{}).
		Select("p.difficulty, COUNT(*) as count, COALESCE(AVG(ws.score), 0) as avg_score").
		Joins("JOIN writing_prompts p ON writing_submissions.prompt_id = p.id").
		Where("writing_submissions.user_id = ? AND writing_submissions.submitted_at IS NOT NULL", userID).
		Group("p.difficulty").
		Scan(&stats)

	result := make(map[string]interface{})
	for _, stat := range stats {
		result[stat.Difficulty] = map[string]interface{}{
			"count":     stat.Count,
			"avg_score": fmt.Sprintf("%.2f", stat.AvgScore),
		}
	}

	return result
}

// GetWritingProgress 获取写作进度
func (s *WritingService) GetWritingProgress(userID string, promptID string) (*models.WritingSubmission, error) {
	var submission models.WritingSubmission
	err := s.db.Where("user_id = ? AND prompt_id = ?", userID, promptID).First(&submission).Error
	if err != nil {
		return nil, err
	}
	return &submission, nil
}