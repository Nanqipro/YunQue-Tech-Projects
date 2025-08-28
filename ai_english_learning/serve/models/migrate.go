package models

import (
	"log"

	"gorm.io/gorm"
)

// AutoMigrate 自动迁移所有数据表
func AutoMigrate(db *gorm.DB) error {
	log.Println("开始数据库迁移...")

	// 用户相关表
	err := db.AutoMigrate(
		&User{},
		&UserSocialLink{},
		&UserPreference{},
	)
	if err != nil {
		return err
	}
	log.Println("用户相关表迁移完成")

	// 词汇学习相关表
	err = db.AutoMigrate(
		&VocabularyCategory{},
		&Vocabulary{},
		&VocabularyDefinition{},
		&VocabularyExample{},
		&VocabularyImage{},
		&VocabularyCategoryRelation{},
		&UserVocabularyProgress{},
		&VocabularyTest{},
	)
	if err != nil {
		return err
	}
	log.Println("词汇学习相关表迁移完成")

	// 练习相关表
	err = db.AutoMigrate(
		&ListeningExercise{},
		&ListeningQuestion{},
		&ListeningRecord{},
		&ReadingExercise{},
		&ReadingQuestion{},
		&ReadingRecord{},
		&WritingExercise{},
		&WritingSubmission{},
		&SpeakingExercise{},
		&SpeakingRecording{},
	)
	if err != nil {
		return err
	}
	log.Println("练习相关表迁移完成")

	// 统计分析相关表
	err = db.AutoMigrate(
		&UserLearningSession{},
		&UserDailyStats{},
		&UserWeeklyStats{},
		&UserMonthlyStats{},
		&Achievement{},
		&UserAchievement{},
		&UserLevel{},
	)
	if err != nil {
		return err
	}
	log.Println("统计分析相关表迁移完成")

	// 创建索引
	err = createIndexes(db)
	if err != nil {
		return err
	}
	log.Println("索引创建完成")

	log.Println("数据库迁移完成")
	return nil
}

// createIndexes 创建额外的索引
func createIndexes(db *gorm.DB) error {
	// 用户表索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at)")

	// 词汇表索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_vocabulary_word ON vocabulary(word)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_vocabulary_difficulty ON vocabulary(difficulty_level)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_vocabulary_frequency ON vocabulary(frequency_rank)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_vocabulary_is_active ON vocabulary(is_active)")

	// 用户词汇进度表索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_vocabulary_progress_user_id ON user_vocabulary_progress(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_vocabulary_progress_vocabulary_id ON user_vocabulary_progress(vocabulary_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_vocabulary_progress_mastery_level ON user_vocabulary_progress(mastery_level)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_vocabulary_progress_next_review ON user_vocabulary_progress(next_review_at)")

	// 练习记录表索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_listening_records_user_id ON listening_records(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_listening_records_exercise_id ON listening_records(exercise_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_listening_records_created_at ON listening_records(created_at)")

	db.Exec("CREATE INDEX IF NOT EXISTS idx_reading_records_user_id ON reading_records(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_reading_records_exercise_id ON reading_records(exercise_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_reading_records_created_at ON reading_records(created_at)")

	db.Exec("CREATE INDEX IF NOT EXISTS idx_writing_submissions_user_id ON writing_submissions(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_writing_submissions_exercise_id ON writing_submissions(exercise_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_writing_submissions_status ON writing_submissions(status)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_writing_submissions_created_at ON writing_submissions(created_at)")

	db.Exec("CREATE INDEX IF NOT EXISTS idx_speaking_recordings_user_id ON speaking_recordings(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_speaking_recordings_exercise_id ON speaking_recordings(exercise_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_speaking_recordings_status ON speaking_recordings(status)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_speaking_recordings_created_at ON speaking_recordings(created_at)")

	// 统计表索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_daily_stats_user_id ON user_daily_stats(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_daily_stats_date ON user_daily_stats(date)")

	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_weekly_stats_user_id ON user_weekly_stats(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_weekly_stats_year_week ON user_weekly_stats(year, week)")

	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_monthly_stats_user_id ON user_monthly_stats(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_monthly_stats_year_month ON user_monthly_stats(year, month)")

	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_learning_sessions_user_id ON user_learning_sessions(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_learning_sessions_session_type ON user_learning_sessions(session_type)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_learning_sessions_start_time ON user_learning_sessions(start_time)")

	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement_id ON user_achievements(achievement_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_achievements_is_completed ON user_achievements(is_completed)")

	return nil
}

// SeedData 初始化基础数据
func SeedData(db *gorm.DB) error {
	log.Println("开始初始化基础数据...")

	// 创建默认词汇分类
	categories := []VocabularyCategory{
		{Name: "基础词汇", Description: "日常生活中最常用的基础词汇", Level: "beginner", SortOrder: 1},
		{Name: "学术词汇", Description: "学术写作和阅读中常见的词汇", Level: "intermediate", SortOrder: 2},
		{Name: "商务词汇", Description: "商务场景中使用的专业词汇", Level: "intermediate", SortOrder: 3},
		{Name: "高级词汇", Description: "高级英语水平所需的词汇", Level: "advanced", SortOrder: 4},
		{Name: "托福词汇", Description: "托福考试必备词汇", Level: "advanced", SortOrder: 5},
		{Name: "雅思词汇", Description: "雅思考试必备词汇", Level: "advanced", SortOrder: 6},
	}

	for _, category := range categories {
		var existingCategory VocabularyCategory
		result := db.Where("name = ?", category.Name).First(&existingCategory)
		if result.Error != nil {
			if err := db.Create(&category).Error; err != nil {
				log.Printf("创建词汇分类失败: %v", err)
				return err
			}
		}
	}
	log.Println("词汇分类初始化完成")

	// 创建默认成就
	achievements := []Achievement{
		{Name: "初学者", Description: "完成第一次学习", Category: "general", Type: "count", TargetValue: 1, RewardExp: 10, Rarity: "common", SortOrder: 1},
		{Name: "词汇新手", Description: "学习10个单词", Category: "vocabulary", Type: "count", TargetValue: 10, RewardExp: 50, Rarity: "common", SortOrder: 2},
		{Name: "词汇达人", Description: "学习100个单词", Category: "vocabulary", Type: "count", TargetValue: 100, RewardExp: 200, Rarity: "rare", SortOrder: 3},
		{Name: "词汇大师", Description: "学习1000个单词", Category: "vocabulary", Type: "count", TargetValue: 1000, RewardExp: 1000, Rarity: "epic", SortOrder: 4},
		{Name: "坚持不懈", Description: "连续学习7天", Category: "general", Type: "streak", TargetValue: 7, RewardExp: 100, Rarity: "rare", SortOrder: 5},
		{Name: "学习狂人", Description: "连续学习30天", Category: "general", Type: "streak", TargetValue: 30, RewardExp: 500, Rarity: "epic", SortOrder: 6},
		{Name: "听力入门", Description: "完成10次听力练习", Category: "listening", Type: "count", TargetValue: 10, RewardExp: 100, Rarity: "common", SortOrder: 7},
		{Name: "阅读爱好者", Description: "完成10次阅读练习", Category: "reading", Type: "count", TargetValue: 10, RewardExp: 100, Rarity: "common", SortOrder: 8},
		{Name: "写作新手", Description: "完成5次写作练习", Category: "writing", Type: "count", TargetValue: 5, RewardExp: 150, Rarity: "common", SortOrder: 9},
		{Name: "口语练习者", Description: "完成5次口语练习", Category: "speaking", Type: "count", TargetValue: 5, RewardExp: 150, Rarity: "common", SortOrder: 10},
	}

	for _, achievement := range achievements {
		var existingAchievement Achievement
		result := db.Where("name = ?", achievement.Name).First(&existingAchievement)
		if result.Error != nil {
			if err := db.Create(&achievement).Error; err != nil {
				log.Printf("创建成就失败: %v", err)
				return err
			}
		}
	}
	log.Println("成就初始化完成")

	log.Println("基础数据初始化完成")
	return nil
}