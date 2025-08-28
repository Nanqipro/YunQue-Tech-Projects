package services

import (
	"errors"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ListeningService 听力训练服务
type ListeningService struct {
	db *gorm.DB
}

// NewListeningService 创建听力训练服务实例
func NewListeningService(db *gorm.DB) *ListeningService {
	return &ListeningService{db: db}
}

// GetListeningMaterials 获取听力材料列表
func (s *ListeningService) GetListeningMaterials(level, category string, page, pageSize int) ([]models.ListeningMaterial, int64, error) {
	var materials []models.ListeningMaterial
	var total int64

	query := s.db.Model(&models.ListeningMaterial{}).Where("is_active = ?", true)

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
	if err := query.Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&materials).Error; err != nil {
		return nil, 0, err
	}

	return materials, total, nil
}

// GetListeningMaterial 获取单个听力材料
func (s *ListeningService) GetListeningMaterial(id string) (*models.ListeningMaterial, error) {
	var material models.ListeningMaterial
	if err := s.db.Where("id = ? AND is_active = ?", id, true).First(&material).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("听力材料不存在")
		}
		return nil, err
	}
	return &material, nil
}

// CreateListeningMaterial 创建听力材料
func (s *ListeningService) CreateListeningMaterial(material *models.ListeningMaterial) error {
	material.ID = uuid.New().String()
	material.CreatedAt = time.Now()
	material.UpdatedAt = time.Now()
	material.IsActive = true

	return s.db.Create(material).Error
}

// UpdateListeningMaterial 更新听力材料
func (s *ListeningService) UpdateListeningMaterial(id string, updates map[string]interface{}) error {
	updates["updated_at"] = time.Now()
	result := s.db.Model(&models.ListeningMaterial{}).Where("id = ?", id).Updates(updates)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("听力材料不存在")
	}
	return nil
}

// DeleteListeningMaterial 删除听力材料（软删除）
func (s *ListeningService) DeleteListeningMaterial(id string) error {
	result := s.db.Model(&models.ListeningMaterial{}).Where("id = ?", id).Update("is_active", false)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("听力材料不存在")
	}
	return nil
}

// SearchListeningMaterials 搜索听力材料
func (s *ListeningService) SearchListeningMaterials(keyword, level, category string, page, pageSize int) ([]models.ListeningMaterial, int64, error) {
	var materials []models.ListeningMaterial
	var total int64

	query := s.db.Model(&models.ListeningMaterial{}).Where("is_active = ?", true)

	if keyword != "" {
		query = query.Where("title LIKE ? OR description LIKE ?", "%"+keyword+"%", "%"+keyword+"%")
	}
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
	if err := query.Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&materials).Error; err != nil {
		return nil, 0, err
	}

	return materials, total, nil
}

// CreateListeningRecord 创建听力练习记录
func (s *ListeningService) CreateListeningRecord(record *models.ListeningRecord) error {
	record.ID = uuid.New().String()
	record.StartedAt = time.Now()
	record.CreatedAt = time.Now()
	record.UpdatedAt = time.Now()

	return s.db.Create(record).Error
}

// UpdateListeningRecord 更新听力练习记录
func (s *ListeningService) UpdateListeningRecord(id string, updates map[string]interface{}) error {
	updates["updated_at"] = time.Now()
	if _, exists := updates["completed_at"]; exists {
		now := time.Now()
		updates["completed_at"] = &now
	}

	result := s.db.Model(&models.ListeningRecord{}).Where("id = ?", id).Updates(updates)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("听力练习记录不存在")
	}
	return nil
}

// GetUserListeningRecords 获取用户听力练习记录
func (s *ListeningService) GetUserListeningRecords(userID string, page, pageSize int) ([]models.ListeningRecord, int64, error) {
	var records []models.ListeningRecord
	var total int64

	query := s.db.Model(&models.ListeningRecord{}).Where("user_id = ?", userID)

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询，包含关联的材料信息
	offset := (page - 1) * pageSize
	if err := query.Preload("Material").Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&records).Error; err != nil {
		return nil, 0, err
	}

	return records, total, nil
}

// GetListeningRecord 获取单个听力练习记录
func (s *ListeningService) GetListeningRecord(id string) (*models.ListeningRecord, error) {
	var record models.ListeningRecord
	if err := s.db.Preload("Material").Where("id = ?", id).First(&record).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("听力练习记录不存在")
		}
		return nil, err
	}
	return &record, nil
}

// GetUserListeningStats 获取用户听力学习统计
func (s *ListeningService) GetUserListeningStats(userID string) (map[string]interface{}, error) {
	stats := make(map[string]interface{})

	// 总练习次数
	var totalRecords int64
	if err := s.db.Model(&models.ListeningRecord{}).Where("user_id = ?", userID).Count(&totalRecords).Error; err != nil {
		return nil, err
	}
	stats["total_records"] = totalRecords

	// 已完成练习次数
	var completedRecords int64
	if err := s.db.Model(&models.ListeningRecord{}).Where("user_id = ? AND completed_at IS NOT NULL", userID).Count(&completedRecords).Error; err != nil {
		return nil, err
	}
	stats["completed_records"] = completedRecords

	// 平均得分
	var avgScore float64
	if err := s.db.Model(&models.ListeningRecord{}).Where("user_id = ? AND score IS NOT NULL", userID).Select("AVG(score)").Scan(&avgScore).Error; err != nil {
		return nil, err
	}
	stats["average_score"] = avgScore

	// 平均准确率
	var avgAccuracy float64
	if err := s.db.Model(&models.ListeningRecord{}).Where("user_id = ? AND accuracy IS NOT NULL", userID).Select("AVG(accuracy)").Scan(&avgAccuracy).Error; err != nil {
		return nil, err
	}
	stats["average_accuracy"] = avgAccuracy

	// 总学习时间（分钟）
	var totalTimeSpent int64
	if err := s.db.Model(&models.ListeningRecord{}).Where("user_id = ?", userID).Select("SUM(time_spent)").Scan(&totalTimeSpent).Error; err != nil {
		return nil, err
	}
	stats["total_time_spent"] = totalTimeSpent / 60 // 转换为分钟

	// 连续学习天数
	continuousDays, err := s.calculateContinuousLearningDays(userID)
	if err != nil {
		return nil, err
	}
	stats["continuous_days"] = continuousDays

	// 按难度级别统计
	levelStats := make(map[string]int64)
	rows, err := s.db.Raw(`
		SELECT lm.level, COUNT(*) as count 
		FROM listening_records lr 
		JOIN listening_materials lm ON lr.material_id = lm.id 
		WHERE lr.user_id = ? AND lr.completed_at IS NOT NULL
		GROUP BY lm.level
	`, userID).Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var level string
		var count int64
		if err := rows.Scan(&level, &count); err != nil {
			return nil, err
		}
		levelStats[level] = count
	}
	stats["level_stats"] = levelStats

	return stats, nil
}

// calculateContinuousLearningDays 计算连续学习天数
func (s *ListeningService) calculateContinuousLearningDays(userID string) (int, error) {
	// 获取最近的学习记录日期
	rows, err := s.db.Raw(`
		SELECT DISTINCT DATE(created_at) as learning_date 
		FROM listening_records 
		WHERE user_id = ? AND completed_at IS NOT NULL
		ORDER BY learning_date DESC
		LIMIT 30
	`, userID).Rows()
	if err != nil {
		return 0, err
	}
	defer rows.Close()

	var dates []time.Time
	for rows.Next() {
		var date time.Time
		if err := rows.Scan(&date); err != nil {
			return 0, err
		}
		dates = append(dates, date)
	}

	if len(dates) == 0 {
		return 0, nil
	}

	// 计算连续天数
	continuousDays := 1
	today := time.Now().Truncate(24 * time.Hour)
	lastDate := dates[0].Truncate(24 * time.Hour)

	// 如果最后一次学习不是今天或昨天，连续天数为0
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

// GetListeningProgress 获取用户在特定材料上的学习进度
func (s *ListeningService) GetListeningProgress(userID, materialID string) (*models.ListeningRecord, error) {
	var record models.ListeningRecord
	if err := s.db.Where("user_id = ? AND material_id = ?", userID, materialID).Order("created_at DESC").First(&record).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil // 没有学习记录
		}
		return nil, err
	}
	return &record, nil
}