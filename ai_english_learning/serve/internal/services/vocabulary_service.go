package services

import (
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/utils"
	"gorm.io/gorm"
)

type VocabularyService struct {
	db *gorm.DB
}

func NewVocabularyService(db *gorm.DB) *VocabularyService {
	return &VocabularyService{db: db}
}

// GetCategories 获取词汇分类列表
func (s *VocabularyService) GetCategories(page, pageSize int, level string) (*common.PaginationData, error) {
	var categories []*models.VocabularyCategory
	var total int64

	query := s.db.Model(&models.VocabularyCategory{})
	if level != "" {
		query = query.Where("level = ?", level)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, err
	}

	offset := utils.CalculateOffset(page, pageSize)
	if err := query.Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&categories).Error; err != nil {
		return nil, err
	}

	totalPages := utils.CalculateTotalPages(int(total), pageSize)

	return &common.PaginationData{
		Items: categories,
		Pagination: &common.Pagination{
			Page:       page,
			PageSize:   pageSize,
			Total:      int(total),
			TotalPages: totalPages,
		},
	}, nil
}

// CreateCategory 创建词汇分类
func (s *VocabularyService) CreateCategory(name, description, level string) (*models.VocabularyCategory, error) {
	// 检查分类名称是否已存在
	var existingCategory models.VocabularyCategory
	if err := s.db.Where("name = ?", name).First(&existingCategory).Error; err == nil {
		return nil, common.NewBusinessError(common.ErrCodeUserExists, "分类名称已存在")
	} else if err != gorm.ErrRecordNotFound {
		return nil, err
	}

	category := &models.VocabularyCategory{
		ID:          utils.GenerateUUID(),
		Name:        name,
		Description: &description,
		Level:       level,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if err := s.db.Create(category).Error; err != nil {
		return nil, err
	}

	return category, nil
}

// UpdateCategory 更新词汇分类
func (s *VocabularyService) UpdateCategory(categoryID string, updates map[string]interface{}) (*models.VocabularyCategory, error) {
	var category models.VocabularyCategory
	if err := s.db.Where("id = ?", categoryID).First(&category).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, common.NewBusinessError(common.ErrCodeCategoryNotFound, "分类不存在")
		}
		return nil, err
	}

	// 如果更新名称，检查是否重复
	if name, ok := updates["name"]; ok {
		var existingCategory models.VocabularyCategory
		if err := s.db.Where("name = ? AND id != ?", name, categoryID).First(&existingCategory).Error; err == nil {
			return nil, common.NewBusinessError(common.ErrCodeUserExists, "分类名称已存在")
		} else if err != gorm.ErrRecordNotFound {
			return nil, err
		}
	}

	updates["updated_at"] = time.Now()
	if err := s.db.Model(&category).Updates(updates).Error; err != nil {
		return nil, err
	}

	return &category, nil
}

// DeleteCategory 删除词汇分类
func (s *VocabularyService) DeleteCategory(categoryID string) error {
	// 检查分类是否存在
	var category models.VocabularyCategory
	if err := s.db.Where("id = ?", categoryID).First(&category).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return common.NewBusinessError(common.ErrCodeCategoryNotFound, "分类不存在")
		}
		return err
	}

	// 检查是否有词汇使用该分类
	var count int64
	if err := s.db.Model(&models.Vocabulary{}).Where("category_id = ?", categoryID).Count(&count).Error; err != nil {
		return err
	}
	if count > 0 {
		return common.NewBusinessError(common.ErrCodeBadRequest, "该分类下还有词汇，无法删除")
	}

	if err := s.db.Delete(&category).Error; err != nil {
		return err
	}

	return nil
}

// GetVocabulariesByCategory 根据分类获取词汇列表
func (s *VocabularyService) GetVocabulariesByCategory(categoryID string, page, pageSize int, level string) (*common.PaginationData, error) {
	offset := utils.CalculateOffset(page, pageSize)
	
	query := s.db.Where("category_id = ?", categoryID)
	if level != "" {
		query = query.Where("level = ?", level)
	}
	
	// 获取总数
	var total int64
	if err := query.Model(&models.Vocabulary{}).Count(&total).Error; err != nil {
		return nil, err
	}
	
	// 获取词汇列表
	var vocabularies []models.Vocabulary
	if err := query.Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&vocabularies).Error; err != nil {
		return nil, err
	}
	
	totalPages := utils.CalculateTotalPages(int(total), pageSize)
	
	return &common.PaginationData{
		Items: vocabularies,
		Pagination: &common.Pagination{
			Page:       page,
			PageSize:   pageSize,
			Total:      int(total),
			TotalPages: totalPages,
		},
	}, nil
}

// GetVocabularyByID 根据ID获取词汇详情
func (s *VocabularyService) GetVocabularyByID(vocabularyID string) (*models.Vocabulary, error) {
	var vocabulary models.Vocabulary
	if err := s.db.Where("id = ?", vocabularyID).First(&vocabulary).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, common.NewBusinessError(common.ErrCodeVocabularyNotFound, "词汇不存在")
		}
		return nil, err
	}
	return &vocabulary, nil
}

// CreateVocabulary 创建词汇
func (s *VocabularyService) CreateVocabulary(word, phonetic, level string, frequency int, categoryID string, definitions, examples, images []string) (*models.Vocabulary, error) {
	// 检查词汇是否已存在
	var existingVocabulary models.Vocabulary
	if err := s.db.Where("word = ?", word).First(&existingVocabulary).Error; err == nil {
		return nil, common.NewBusinessError(common.ErrCodeWordExists, "词汇已存在")
	} else if err != gorm.ErrRecordNotFound {
		return nil, err
	}
	
	// 检查分类是否存在
	var category models.VocabularyCategory
	if err := s.db.Where("id = ?", categoryID).First(&category).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, common.NewBusinessError(common.ErrCodeCategoryNotFound, "分类不存在")
		}
		return nil, err
	}
	
	// 创建词汇
	vocabulary := &models.Vocabulary{
		ID:        utils.GenerateUUID(),
		Word:      word,
		Level:     level,
		Frequency: frequency,
		IsActive:  true,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	
	// 设置音标（可选）
	if phonetic != "" {
		vocabulary.Phonetic = &phonetic
	}
	
	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()
	
	// 创建词汇记录
	if err := tx.Create(vocabulary).Error; err != nil {
		tx.Rollback()
		return nil, err
	}
	
	// 关联分类
	if err := tx.Model(vocabulary).Association("Categories").Append(&category); err != nil {
		tx.Rollback()
		return nil, err
	}
	
	// 创建定义
	for i, def := range definitions {
		definition := &models.VocabularyDefinition{
			ID:           utils.GenerateUUID(),
			VocabularyID: vocabulary.ID,
			PartOfSpeech: "n", // 默认词性，可以后续优化
			Definition:   def,
			SortOrder:    i,
			CreatedAt:    time.Now(),
			UpdatedAt:    time.Now(),
		}
		if err := tx.Create(definition).Error; err != nil {
			tx.Rollback()
			return nil, err
		}
	}
	
	// 创建例句
	for i, ex := range examples {
		example := &models.VocabularyExample{
			ID:           utils.GenerateUUID(),
			VocabularyID: vocabulary.ID,
			Example:      ex,
			SortOrder:    i,
			CreatedAt:    time.Now(),
			UpdatedAt:    time.Now(),
		}
		if err := tx.Create(example).Error; err != nil {
			tx.Rollback()
			return nil, err
		}
	}
	
	// 创建图片
	for i, img := range images {
		image := &models.VocabularyImage{
			ID:           utils.GenerateUUID(),
			VocabularyID: vocabulary.ID,
			ImageURL:     img,
			SortOrder:    i,
			CreatedAt:    time.Now(),
			UpdatedAt:    time.Now(),
		}
		if err := tx.Create(image).Error; err != nil {
			tx.Rollback()
			return nil, err
		}
	}
	
	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return nil, err
	}
	
	return vocabulary, nil
}

// UpdateVocabulary 更新词汇
func (s *VocabularyService) UpdateVocabulary(id string, vocabulary *models.Vocabulary) error {
	return s.db.Model(&models.Vocabulary{}).Where("id = ?", id).Updates(vocabulary).Error
}

// DeleteVocabulary 删除词汇
func (s *VocabularyService) DeleteVocabulary(id string) error {
	return s.db.Delete(&models.Vocabulary{}, id).Error
}

// GetUserVocabularyProgress 获取用户词汇学习进度
func (s *VocabularyService) GetUserVocabularyProgress(userID, vocabularyID string) (*models.UserVocabularyProgress, error) {
	var progress models.UserVocabularyProgress
	if err := s.db.Where("user_id = ? AND vocabulary_id = ?", userID, vocabularyID).First(&progress).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, common.NewBusinessError(common.ErrCodeProgressNotFound, "学习进度不存在")
		}
		return nil, err
	}
	return &progress, nil
}

// UpdateUserVocabularyProgress 更新用户词汇学习进度
func (s *VocabularyService) UpdateUserVocabularyProgress(userID, vocabularyID string, updates map[string]interface{}) (*models.UserVocabularyProgress, error) {
	// 查找或创建进度记录
	var progress models.UserVocabularyProgress
	err := s.db.Where("user_id = ? AND vocabulary_id = ?", userID, vocabularyID).First(&progress).Error
	
	if err == gorm.ErrRecordNotFound {
		// 创建新的进度记录
		now := time.Now()
		progress = models.UserVocabularyProgress{
			ID:           utils.GenerateUUID(),
			UserID:       userID,
			VocabularyID: vocabularyID,
			StudyCount:   1,
			LastStudiedAt: &now,
			CreatedAt:    now,
			UpdatedAt:    now,
		}
		
		// 应用更新
		if masteryLevel, ok := updates["mastery_level"].(int); ok {
			progress.MasteryLevel = masteryLevel
		}
		
		if err := s.db.Create(&progress).Error; err != nil {
			return nil, err
		}
		return &progress, nil
	} else if err != nil {
		return nil, err
	}
	
	// 更新现有进度记录
	now := time.Now()
	updateData := map[string]interface{}{
		"study_count":    progress.StudyCount + 1,
		"last_studied_at": &now,
		"updated_at":     now,
	}
	
	// 合并传入的更新数据
	for key, value := range updates {
		updateData[key] = value
	}
	
	if err := s.db.Model(&progress).Updates(updateData).Error; err != nil {
		return nil, err
	}
	
	// 重新查询更新后的记录
	if err := s.db.Where("user_id = ? AND vocabulary_id = ?", userID, vocabularyID).First(&progress).Error; err != nil {
		return nil, err
	}
	
	return &progress, nil
}

// GetUserVocabularyStats 获取用户词汇学习统计
func (s *VocabularyService) GetUserVocabularyStats(userID string) (map[string]interface{}, error) {
	stats := make(map[string]interface{})
	
	// 总学习词汇数
	var totalStudied int64
	if err := s.db.Model(&models.UserVocabularyProgress{}).Where("user_id = ?", userID).Count(&totalStudied).Error; err != nil {
		return nil, err
	}
	stats["total_studied"] = totalStudied
	
	// 掌握程度统计
	var masteryStats []struct {
		Level string `json:"level"`
		Count int64  `json:"count"`
	}
	if err := s.db.Model(&models.UserVocabularyProgress{}).
		Select("CASE WHEN mastery_level >= 80 THEN 'mastered' WHEN mastery_level >= 60 THEN 'familiar' WHEN mastery_level >= 40 THEN 'learning' ELSE 'new' END as level, COUNT(*) as count").
		Where("user_id = ?", userID).
		Group("level").
		Scan(&masteryStats).Error; err != nil {
		return nil, err
	}
	stats["mastery_stats"] = masteryStats
	
	// 学习准确率
	var accuracyResult struct {
		TotalCorrect   int64 `json:"total_correct"`
		TotalIncorrect int64 `json:"total_incorrect"`
	}
	if err := s.db.Model(&models.UserVocabularyProgress{}).
		Select("SUM(correct_count) as total_correct, SUM(incorrect_count) as total_incorrect").
		Where("user_id = ?", userID).
		Scan(&accuracyResult).Error; err != nil {
		return nil, err
	}
	
	totalAttempts := accuracyResult.TotalCorrect + accuracyResult.TotalIncorrect
	if totalAttempts > 0 {
		stats["accuracy_rate"] = float64(accuracyResult.TotalCorrect) / float64(totalAttempts) * 100
	} else {
		stats["accuracy_rate"] = 0.0
	}
	
	// 最近学习的词汇
	var recentVocabularies []models.Vocabulary
	if err := s.db.Table("vocabularies v").
		Joins("JOIN user_vocabulary_progress uvp ON v.id = uvp.vocabulary_id").
		Where("uvp.user_id = ?", userID).
		Order("uvp.last_studied_at DESC").
		Limit(5).
		Find(&recentVocabularies).Error; err != nil {
		return nil, err
	}
	stats["recent_vocabularies"] = recentVocabularies
	
	return stats, nil
}

// GetVocabularyTest 获取词汇测试
func (s *VocabularyService) GetVocabularyTest(testID string) (*models.VocabularyTest, error) {
	var test models.VocabularyTest
	if err := s.db.Where("id = ?", testID).First(&test).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, common.NewBusinessError(common.ErrCodeTestNotFound, "测试不存在")
		}
		return nil, err
	}
	return &test, nil
}

// CreateVocabularyTest 创建词汇测试
func (s *VocabularyService) CreateVocabularyTest(userID, testType, level string, totalWords int) (*models.VocabularyTest, error) {
	test := &models.VocabularyTest{
		ID:         utils.GenerateUUID(),
		UserID:     userID,
		TestType:   testType,
		Level:      level,
		TotalWords: totalWords,
		StartedAt:  time.Now(),
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}
	
	if err := s.db.Create(test).Error; err != nil {
		return nil, err
	}
	
	return test, nil
}

// UpdateVocabularyTestResult 更新词汇测试结果
func (s *VocabularyService) UpdateVocabularyTestResult(testID string, correctWords int, score float64, duration int) error {
	now := time.Now()
	updates := map[string]interface{}{
		"correct_words": correctWords,
		"score":         score,
		"duration":      duration,
		"completed_at":  &now,
		"updated_at":    now,
	}
	
	result := s.db.Model(&models.VocabularyTest{}).Where("id = ?", testID).Updates(updates)
	if result.Error != nil {
		return result.Error
	}
	
	if result.RowsAffected == 0 {
		return common.NewBusinessError(common.ErrCodeTestNotFound, "测试不存在")
	}
	
	return nil
}

// SearchVocabularies 搜索词汇
func (s *VocabularyService) SearchVocabularies(keyword string, level string, page, pageSize int) (*common.PaginationData, error) {
	offset := utils.CalculateOffset(page, pageSize)
	
	query := s.db.Model(&models.Vocabulary{})
	
	// 关键词搜索
	if keyword != "" {
		query = query.Where("word LIKE ? OR phonetic LIKE ?", "%"+keyword+"%", "%"+keyword+"%")
	}
	
	// 级别过滤
	if level != "" {
		query = query.Where("level = ?", level)
	}
	
	// 只查询启用的词汇
	query = query.Where("is_active = ?", true)
	
	// 获取总数
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, err
	}
	
	// 获取词汇列表
	var vocabularies []models.Vocabulary
	if err := query.Preload("Definitions").Preload("Examples").Preload("Images").Preload("Categories").
		Offset(offset).Limit(pageSize).Order("created_at DESC").Find(&vocabularies).Error; err != nil {
		return nil, err
	}
	
	totalPages := utils.CalculateTotalPages(int(total), pageSize)
	
	return &common.PaginationData{
		Items: vocabularies,
		Pagination: &common.Pagination{
			Page:       page,
			PageSize:   pageSize,
			Total:      int(total),
			TotalPages: totalPages,
		},
	}, nil
}