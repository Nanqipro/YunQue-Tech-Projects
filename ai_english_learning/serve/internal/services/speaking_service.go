package services

import (
	"errors"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"gorm.io/gorm"
)

// SpeakingService 口语练习服务
type SpeakingService struct {
	db *gorm.DB
}

// NewSpeakingService 创建口语练习服务实例
func NewSpeakingService(db *gorm.DB) *SpeakingService {
	return &SpeakingService{
		db: db,
	}
}

// ==================== 口语场景管理 ====================

// GetSpeakingScenarios 获取口语场景列表
func (s *SpeakingService) GetSpeakingScenarios(level, category string, page, pageSize int) ([]models.SpeakingScenario, int64, error) {
	var scenarios []models.SpeakingScenario
	var total int64

	query := s.db.Model(&models.SpeakingScenario{}).Where("is_active = ?", true)

	// 添加过滤条件
	if level != "" {
		query = query.Where("level = ?", level)
	}
	if category != "" {
		query = query.Where("category = ?", category)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * pageSize
	if err := query.Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&scenarios).Error; err != nil {
		return nil, 0, err
	}

	return scenarios, total, nil
}

// GetSpeakingScenario 根据ID获取口语场景
func (s *SpeakingService) GetSpeakingScenario(id string) (*models.SpeakingScenario, error) {
	var scenario models.SpeakingScenario
	if err := s.db.Where("id = ? AND is_active = ?", id, true).First(&scenario).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("口语场景不存在")
		}
		return nil, err
	}
	return &scenario, nil
}

// CreateSpeakingScenario 创建口语场景
func (s *SpeakingService) CreateSpeakingScenario(scenario *models.SpeakingScenario) error {
	scenario.CreatedAt = time.Now()
	scenario.UpdatedAt = time.Now()
	return s.db.Create(scenario).Error
}

// UpdateSpeakingScenario 更新口语场景
func (s *SpeakingService) UpdateSpeakingScenario(id string, updateData *models.SpeakingScenario) error {
	updateData.UpdatedAt = time.Now()
	result := s.db.Model(&models.SpeakingScenario{}).Where("id = ? AND is_active = ?", id, true).Updates(updateData)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("口语场景不存在")
	}
	return nil
}

// DeleteSpeakingScenario 删除口语场景（软删除）
func (s *SpeakingService) DeleteSpeakingScenario(id string) error {
	result := s.db.Model(&models.SpeakingScenario{}).Where("id = ?", id).Update("is_active", false)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("口语场景不存在")
	}
	return nil
}

// SearchSpeakingScenarios 搜索口语场景
func (s *SpeakingService) SearchSpeakingScenarios(keyword string, level, category string, page, pageSize int) ([]models.SpeakingScenario, int64, error) {
	var scenarios []models.SpeakingScenario
	var total int64

	query := s.db.Model(&models.SpeakingScenario{}).Where("is_active = ?", true)

	// 关键词搜索
	if keyword != "" {
		query = query.Where("title LIKE ? OR description LIKE ?", "%"+keyword+"%", "%"+keyword+"%")
	}

	// 添加过滤条件
	if level != "" {
		query = query.Where("level = ?", level)
	}
	if category != "" {
		query = query.Where("category = ?", category)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * pageSize
	if err := query.Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&scenarios).Error; err != nil {
		return nil, 0, err
	}

	return scenarios, total, nil
}

// GetRecommendedScenarios 获取推荐的口语场景
func (s *SpeakingService) GetRecommendedScenarios(userID string, limit int) ([]models.SpeakingScenario, error) {
	var scenarios []models.SpeakingScenario

	// 简单的推荐逻辑：基于用户水平和最近练习情况
	// 这里可以根据实际需求实现更复杂的推荐算法
	query := `
		SELECT DISTINCT s.* FROM speaking_scenarios s
		LEFT JOIN speaking_records sr ON s.id = sr.scenario_id AND sr.user_id = ?
		WHERE s.is_active = true
		ORDER BY 
			CASE WHEN sr.id IS NULL THEN 0 ELSE 1 END,
			s.created_at DESC
		LIMIT ?
	`

	if err := s.db.Raw(query, userID, limit).Scan(&scenarios).Error; err != nil {
		return nil, err
	}

	return scenarios, nil
}

// ==================== 口语练习记录管理 ====================

// CreateSpeakingRecord 创建口语练习记录
func (s *SpeakingService) CreateSpeakingRecord(record *models.SpeakingRecord) error {
	record.CreatedAt = time.Now()
	record.UpdatedAt = time.Now()
	return s.db.Create(record).Error
}

// UpdateSpeakingRecord 更新口语练习记录
func (s *SpeakingService) UpdateSpeakingRecord(id string, updateData *models.SpeakingRecord) error {
	updateData.UpdatedAt = time.Now()
	result := s.db.Model(&models.SpeakingRecord{}).Where("id = ?", id).Updates(updateData)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("口语练习记录不存在")
	}
	return nil
}

// GetSpeakingRecord 根据ID获取口语练习记录
func (s *SpeakingService) GetSpeakingRecord(id string) (*models.SpeakingRecord, error) {
	var record models.SpeakingRecord
	if err := s.db.Preload("SpeakingScenario").Where("id = ?", id).First(&record).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("口语练习记录不存在")
		}
		return nil, err
	}
	return &record, nil
}

// GetUserSpeakingRecords 获取用户的口语练习记录
func (s *SpeakingService) GetUserSpeakingRecords(userID string, page, pageSize int) ([]models.SpeakingRecord, int64, error) {
	var records []models.SpeakingRecord
	var total int64

	query := s.db.Model(&models.SpeakingRecord{}).Where("user_id = ?", userID)

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * pageSize
	if err := query.Preload("SpeakingScenario").Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&records).Error; err != nil {
		return nil, 0, err
	}

	return records, total, nil
}

// SubmitSpeaking 提交口语练习
func (s *SpeakingService) SubmitSpeaking(recordID string, audioURL, transcript string) error {
	updateData := map[string]interface{}{
		"audio_url":   audioURL,
		"transcript":  transcript,
		"submitted_at": time.Now(),
		"updated_at":  time.Now(),
	}

	result := s.db.Model(&models.SpeakingRecord{}).Where("id = ?", recordID).Updates(updateData)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("口语练习记录不存在")
	}
	return nil
}

// GradeSpeaking 评分口语练习
func (s *SpeakingService) GradeSpeaking(recordID string, pronunciationScore, fluencyScore, accuracyScore, overallScore float64, feedback, suggestions string) error {
	updateData := map[string]interface{}{
		"pronunciation_score": pronunciationScore,
		"fluency_score":       fluencyScore,
		"accuracy_score":      accuracyScore,
		"overall_score":       overallScore,
		"feedback":            feedback,
		"suggestions":         suggestions,
		"graded_at":           time.Now(),
		"updated_at":          time.Now(),
	}

	result := s.db.Model(&models.SpeakingRecord{}).Where("id = ?", recordID).Updates(updateData)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("口语练习记录不存在")
	}
	return nil
}

// ==================== 口语学习统计 ====================

// GetUserSpeakingStats 获取用户口语学习统计
func (s *SpeakingService) GetUserSpeakingStats(userID string) (map[string]interface{}, error) {
	stats := make(map[string]interface{})

	// 总练习次数
	var totalRecords int64
	if err := s.db.Model(&models.SpeakingRecord{}).Where("user_id = ?", userID).Count(&totalRecords).Error; err != nil {
		return nil, err
	}
	stats["total_records"] = totalRecords

	// 已完成练习次数
	var completedRecords int64
	if err := s.db.Model(&models.SpeakingRecord{}).Where("user_id = ? AND submitted_at IS NOT NULL", userID).Count(&completedRecords).Error; err != nil {
		return nil, err
	}
	stats["completed_records"] = completedRecords

	// 已评分练习次数
	var gradedRecords int64
	if err := s.db.Model(&models.SpeakingRecord{}).Where("user_id = ? AND overall_score IS NOT NULL", userID).Count(&gradedRecords).Error; err != nil {
		return nil, err
	}
	stats["graded_records"] = gradedRecords

	// 平均分数
	var avgScores struct {
		Pronunciation float64 `json:"pronunciation"`
		Fluency       float64 `json:"fluency"`
		Accuracy      float64 `json:"accuracy"`
		Overall       float64 `json:"overall"`
	}
	if err := s.db.Model(&models.SpeakingRecord{}).Where("user_id = ? AND overall_score IS NOT NULL", userID).Select(
		"AVG(pronunciation_score) as pronunciation, AVG(fluency_score) as fluency, AVG(accuracy_score) as accuracy, AVG(overall_score) as overall",
	).Scan(&avgScores).Error; err != nil {
		return nil, err
	}
	stats["average_scores"] = avgScores

	// 总练习时长
	var totalDuration int64
	if err := s.db.Model(&models.SpeakingRecord{}).Where("user_id = ? AND duration IS NOT NULL", userID).Select("SUM(duration)").Scan(&totalDuration).Error; err != nil {
		return nil, err
	}
	stats["total_duration"] = totalDuration

	// 平均练习时长
	var avgDuration float64
	if completedRecords > 0 {
		avgDuration = float64(totalDuration) / float64(completedRecords)
	}
	stats["average_duration"] = avgDuration

	// 连续练习天数
	continuousDays, err := s.calculateContinuousSpeakingDays(userID)
	if err != nil {
		return nil, err
	}
	stats["continuous_days"] = continuousDays

	// 按难度级别统计
	levelStats, err := s.getSpeakingStatsByLevel(userID)
	if err != nil {
		return nil, err
	}
	stats["stats_by_level"] = levelStats

	return stats, nil
}

// calculateContinuousSpeakingDays 计算连续练习天数
func (s *SpeakingService) calculateContinuousSpeakingDays(userID string) (int, error) {
	var dates []time.Time
	if err := s.db.Model(&models.SpeakingRecord{}).Where("user_id = ? AND submitted_at IS NOT NULL", userID).Select("DATE(created_at) as date").Group("DATE(created_at)").Order("date DESC").Pluck("date", &dates).Error; err != nil {
		return 0, err
	}

	if len(dates) == 0 {
		return 0, nil
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

	return continuousDays, nil
}

// getSpeakingStatsByLevel 获取按难度级别的统计
func (s *SpeakingService) getSpeakingStatsByLevel(userID string) (map[string]interface{}, error) {
	var results []struct {
		Level string  `json:"level"`
		Count int64   `json:"count"`
		Score float64 `json:"avg_score"`
	}

	query := `
		SELECT 
			ss.level,
			COUNT(sr.id) as count,
			AVG(sr.overall_score) as avg_score
		FROM speaking_records sr
		JOIN speaking_scenarios ss ON sr.scenario_id = ss.id
		WHERE sr.user_id = ? AND sr.overall_score IS NOT NULL
		GROUP BY ss.level
	`

	if err := s.db.Raw(query, userID).Scan(&results).Error; err != nil {
		return nil, err
	}

	stats := make(map[string]interface{})
	for _, result := range results {
		stats[result.Level] = map[string]interface{}{
			"count":     result.Count,
			"avg_score": result.Score,
		}
	}

	return stats, nil
}

// GetSpeakingProgress 获取口语学习进度
func (s *SpeakingService) GetSpeakingProgress(userID, scenarioID string) (map[string]interface{}, error) {
	progress := make(map[string]interface{})

	// 该场景的练习记录
	var records []models.SpeakingRecord
	if err := s.db.Where("user_id = ? AND scenario_id = ?", userID, scenarioID).Order("created_at ASC").Find(&records).Error; err != nil {
		return nil, err
	}

	progress["total_attempts"] = len(records)

	if len(records) == 0 {
		progress["completed"] = false
		progress["best_score"] = 0
		progress["latest_score"] = 0
		progress["improvement"] = 0
		return progress, nil
	}

	// 最佳分数
	var bestScore float64
	for _, record := range records {
		if record.OverallScore != nil && *record.OverallScore > bestScore {
			bestScore = *record.OverallScore
		}
	}
	progress["best_score"] = bestScore

	// 最新分数
	latestRecord := records[len(records)-1]
	latestScore := 0.0
	if latestRecord.OverallScore != nil {
		latestScore = *latestRecord.OverallScore
	}
	progress["latest_score"] = latestScore

	// 是否完成（有评分记录）
	progress["completed"] = latestRecord.OverallScore != nil

	// 进步情况（最新分数与第一次分数的差值）
	improvement := 0.0
	if len(records) > 1 && records[0].OverallScore != nil && latestRecord.OverallScore != nil {
		improvement = *latestRecord.OverallScore - *records[0].OverallScore
	}
	progress["improvement"] = improvement

	return progress, nil
}