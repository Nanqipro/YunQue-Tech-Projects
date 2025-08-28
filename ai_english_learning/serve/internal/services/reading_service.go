package services

import (
	"database/sql"
	"errors"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ReadingService 阅读理解服务
type ReadingService struct {
	db *gorm.DB
}

// NewReadingService 创建阅读理解服务实例
func NewReadingService(db *gorm.DB) *ReadingService {
	return &ReadingService{db: db}
}

// ===== 阅读材料管理 =====

// GetReadingMaterials 获取阅读材料列表
func (s *ReadingService) GetReadingMaterials(level, category string, page, pageSize int) ([]models.ReadingMaterial, int64, error) {
	var materials []models.ReadingMaterial
	var total int64

	query := s.db.Model(&models.ReadingMaterial{}).Where("is_active = ?", true)

	// 按难度级别筛选
	if level != "" {
		query = query.Where("level = ?", level)
	}

	// 按分类筛选
	if category != "" {
		query = query.Where("category = ?", category)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * pageSize
	if err := query.Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&materials).Error; err != nil {
		return nil, 0, err
	}

	return materials, total, nil
}

// GetReadingMaterial 获取单个阅读材料
func (s *ReadingService) GetReadingMaterial(id string) (*models.ReadingMaterial, error) {
	var material models.ReadingMaterial
	if err := s.db.Where("id = ? AND is_active = ?", id, true).First(&material).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("阅读材料不存在")
		}
		return nil, err
	}
	return &material, nil
}

// CreateReadingMaterial 创建阅读材料
func (s *ReadingService) CreateReadingMaterial(material *models.ReadingMaterial) error {
	material.ID = uuid.New().String()
	material.CreatedAt = time.Now()
	material.UpdatedAt = time.Now()
	material.IsActive = true

	return s.db.Create(material).Error
}

// UpdateReadingMaterial 更新阅读材料
func (s *ReadingService) UpdateReadingMaterial(id string, updates map[string]interface{}) error {
	updates["updated_at"] = time.Now()
	result := s.db.Model(&models.ReadingMaterial{}).Where("id = ?", id).Updates(updates)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("阅读材料不存在")
	}
	return nil
}

// DeleteReadingMaterial 删除阅读材料（软删除）
func (s *ReadingService) DeleteReadingMaterial(id string) error {
	result := s.db.Model(&models.ReadingMaterial{}).Where("id = ?", id).Update("is_active", false)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("阅读材料不存在")
	}
	return nil
}

// SearchReadingMaterials 搜索阅读材料
func (s *ReadingService) SearchReadingMaterials(keyword string, level, category string, page, pageSize int) ([]models.ReadingMaterial, int64, error) {
	var materials []models.ReadingMaterial
	var total int64

	query := s.db.Model(&models.ReadingMaterial{}).Where("is_active = ?", true)

	// 关键词搜索
	if keyword != "" {
		query = query.Where("title LIKE ? OR content LIKE ? OR summary LIKE ?", 
			"%"+keyword+"%", "%"+keyword+"%", "%"+keyword+"%")
	}

	// 按难度级别筛选
	if level != "" {
		query = query.Where("level = ?", level)
	}

	// 按分类筛选
	if category != "" {
		query = query.Where("category = ?", category)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * pageSize
	if err := query.Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&materials).Error; err != nil {
		return nil, 0, err
	}

	return materials, total, nil
}

// ===== 阅读记录管理 =====

// CreateReadingRecord 创建阅读记录
func (s *ReadingService) CreateReadingRecord(record *models.ReadingRecord) error {
	record.ID = uuid.New().String()
	record.StartedAt = time.Now()
	record.CreatedAt = time.Now()
	record.UpdatedAt = time.Now()

	return s.db.Create(record).Error
}

// UpdateReadingRecord 更新阅读记录
func (s *ReadingService) UpdateReadingRecord(id string, updates map[string]interface{}) error {
	updates["updated_at"] = time.Now()
	result := s.db.Model(&models.ReadingRecord{}).Where("id = ?", id).Updates(updates)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("阅读记录不存在")
	}
	return nil
}

// GetUserReadingRecords 获取用户阅读记录
func (s *ReadingService) GetUserReadingRecords(userID string, page, pageSize int) ([]models.ReadingRecord, int64, error) {
	var records []models.ReadingRecord
	var total int64

	query := s.db.Model(&models.ReadingRecord{}).Where("user_id = ?", userID)

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询，预加载材料信息
	offset := (page - 1) * pageSize
	if err := query.Preload("Material").Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&records).Error; err != nil {
		return nil, 0, err
	}

	return records, total, nil
}

// GetReadingRecord 获取单个阅读记录
func (s *ReadingService) GetReadingRecord(id string) (*models.ReadingRecord, error) {
	var record models.ReadingRecord
	if err := s.db.Preload("Material").Where("id = ?", id).First(&record).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("阅读记录不存在")
		}
		return nil, err
	}
	return &record, nil
}

// GetReadingProgress 获取用户对特定材料的阅读进度
func (s *ReadingService) GetReadingProgress(userID, materialID string) (*models.ReadingRecord, error) {
	var record models.ReadingRecord
	if err := s.db.Where("user_id = ? AND material_id = ?", userID, materialID).First(&record).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil // 没有阅读记录
		}
		return nil, err
	}
	return &record, nil
}

// ===== 阅读统计 =====

// ReadingStats 阅读统计结构
type ReadingStats struct {
	TotalMaterials    int64   `json:"total_materials"`    // 总阅读材料数
	CompletedMaterials int64  `json:"completed_materials"` // 已完成材料数
	TotalReadingTime  int64   `json:"total_reading_time"`  // 总阅读时间(秒)
	AverageScore      float64 `json:"average_score"`      // 平均理解得分
	AverageSpeed      float64 `json:"average_speed"`      // 平均阅读速度(词/分钟)
	ContinuousDays    int     `json:"continuous_days"`    // 连续阅读天数
	LevelStats        []LevelStat `json:"level_stats"`    // 各难度级别统计
}

// LevelStat 难度级别统计
type LevelStat struct {
	Level             string  `json:"level"`
	CompletedCount    int64   `json:"completed_count"`
	AverageScore      float64 `json:"average_score"`
	AverageSpeed      float64 `json:"average_speed"`
}

// GetUserReadingStats 获取用户阅读统计
func (s *ReadingService) GetUserReadingStats(userID string) (*ReadingStats, error) {
	stats := &ReadingStats{}

	// 获取总阅读材料数
	if err := s.db.Model(&models.ReadingMaterial{}).Where("is_active = ?", true).Count(&stats.TotalMaterials).Error; err != nil {
		return nil, err
	}

	// 获取已完成材料数
	if err := s.db.Model(&models.ReadingRecord{}).Where("user_id = ? AND completed_at IS NOT NULL", userID).Count(&stats.CompletedMaterials).Error; err != nil {
		return nil, err
	}

	// 获取总阅读时间
	var totalTime sql.NullInt64
	if err := s.db.Model(&models.ReadingRecord{}).Where("user_id = ?", userID).Select("SUM(reading_time)").Scan(&totalTime).Error; err != nil {
		return nil, err
	}
	if totalTime.Valid {
		stats.TotalReadingTime = totalTime.Int64
	}

	// 获取平均理解得分
	var avgScore sql.NullFloat64
	if err := s.db.Model(&models.ReadingRecord{}).Where("user_id = ? AND comprehension_score IS NOT NULL", userID).Select("AVG(comprehension_score)").Scan(&avgScore).Error; err != nil {
		return nil, err
	}
	if avgScore.Valid {
		stats.AverageScore = avgScore.Float64
	}

	// 获取平均阅读速度
	var avgSpeed sql.NullFloat64
	if err := s.db.Model(&models.ReadingRecord{}).Where("user_id = ? AND reading_speed IS NOT NULL", userID).Select("AVG(reading_speed)").Scan(&avgSpeed).Error; err != nil {
		return nil, err
	}
	if avgSpeed.Valid {
		stats.AverageSpeed = avgSpeed.Float64
	}

	// 计算连续阅读天数
	continuousDays, err := s.calculateContinuousReadingDays(userID)
	if err != nil {
		return nil, err
	}
	stats.ContinuousDays = continuousDays

	// 获取各难度级别统计
	levelStats, err := s.getLevelStats(userID)
	if err != nil {
		return nil, err
	}
	stats.LevelStats = levelStats

	return stats, nil
}

// calculateContinuousReadingDays 计算连续阅读天数
func (s *ReadingService) calculateContinuousReadingDays(userID string) (int, error) {
	// 获取最近的阅读记录日期
	var dates []time.Time
	if err := s.db.Model(&models.ReadingRecord{}).Where("user_id = ?", userID).Select("DATE(created_at) as date").Group("DATE(created_at)").Order("date DESC").Limit(365).Scan(&dates).Error; err != nil {
		return 0, err
	}

	if len(dates) == 0 {
		return 0, nil
	}

	// 计算连续天数
	continuousDays := 1
	today := time.Now().Truncate(24 * time.Hour)
	lastDate := dates[0].Truncate(24 * time.Hour)

	// 如果最后一次阅读不是今天或昨天，连续天数为0
	if lastDate.Before(today.AddDate(0, 0, -1)) {
		return 0, nil
	}

	for i := 1; i < len(dates); i++ {
		currentDate := dates[i].Truncate(24 * time.Hour)
		expectedDate := lastDate.AddDate(0, 0, -1)

		if currentDate.Equal(expectedDate) {
			continuousDays++
			lastDate = currentDate
		} else {
			break
		}
	}

	return continuousDays, nil
}

// getLevelStats 获取各难度级别统计
func (s *ReadingService) getLevelStats(userID string) ([]LevelStat, error) {
	var levelStats []LevelStat

	query := `
		SELECT 
			m.level,
			COUNT(r.id) as completed_count,
			AVG(r.comprehension_score) as average_score,
			AVG(r.reading_speed) as average_speed
		FROM reading_records r
		JOIN reading_materials m ON r.material_id = m.id
		WHERE r.user_id = ? AND r.completed_at IS NOT NULL
		GROUP BY m.level
	`

	if err := s.db.Raw(query, userID).Scan(&levelStats).Error; err != nil {
		return nil, err
	}

	return levelStats, nil
}

// GetRecommendedMaterials 获取推荐阅读材料
func (s *ReadingService) GetRecommendedMaterials(userID string, limit int) ([]models.ReadingMaterial, error) {
	// 获取用户最近的阅读记录，分析偏好
	var userLevel string
	var userCategory string

	// 获取用户最常阅读的难度级别
	if err := s.db.Raw(`
		SELECT m.level 
		FROM reading_records r 
		JOIN reading_materials m ON r.material_id = m.id 
		WHERE r.user_id = ? 
		GROUP BY m.level 
		ORDER BY COUNT(*) DESC 
		LIMIT 1
	`, userID).Scan(&userLevel).Error; err != nil {
		userLevel = "intermediate" // 默认中级
	}

	// 获取用户最常阅读的分类
	if err := s.db.Raw(`
		SELECT m.category 
		FROM reading_records r 
		JOIN reading_materials m ON r.material_id = m.id 
		WHERE r.user_id = ? 
		GROUP BY m.category 
		ORDER BY COUNT(*) DESC 
		LIMIT 1
	`, userID).Scan(&userCategory).Error; err != nil {
		userCategory = "" // 不限制分类
	}

	// 获取用户未读过的材料
	var materials []models.ReadingMaterial
	query := s.db.Model(&models.ReadingMaterial{}).Where(`
		is_active = ? AND id NOT IN (
			SELECT material_id FROM reading_records WHERE user_id = ?
		)
	`, true, userID)

	// 优先推荐相同难度级别的材料
	if userLevel != "" {
		query = query.Where("level = ?", userLevel)
	}

	// 如果有偏好分类，优先推荐
	if userCategory != "" {
		query = query.Where("category = ?", userCategory)
	}

	if err := query.Order("created_at DESC").Limit(limit).Find(&materials).Error; err != nil {
		return nil, err
	}

	// 如果推荐材料不足，补充其他材料
	if len(materials) < limit {
		var additionalMaterials []models.ReadingMaterial
		remaining := limit - len(materials)
		
		// 获取已推荐材料的ID列表
		excludeIDs := make([]string, len(materials))
		for i, m := range materials {
			excludeIDs[i] = m.ID
		}

		additionalQuery := s.db.Model(&models.ReadingMaterial{}).Where(`
			is_active = ? AND id NOT IN (
				SELECT material_id FROM reading_records WHERE user_id = ?
			)
		`, true, userID)

		if len(excludeIDs) > 0 {
			additionalQuery = additionalQuery.Where("id NOT IN ?", excludeIDs)
		}

		if err := additionalQuery.Order("created_at DESC").Limit(remaining).Find(&additionalMaterials).Error; err != nil {
			return materials, nil // 返回已有的推荐
		}

		materials = append(materials, additionalMaterials...)
	}

	return materials, nil
}