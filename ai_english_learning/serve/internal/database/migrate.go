package database

import (
	"log"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/models"
	"gorm.io/gorm"
)

// AutoMigrate 自动迁移数据库表结构
func AutoMigrate(db *gorm.DB) error {
	log.Println("开始数据库迁移...")
	
	// 用户相关表
	err := db.AutoMigrate(
		&models.User{},
		&models.UserSocialLink{},
		&models.UserPreference{},
	)
	if err != nil {
		return err
	}
	
	// 词汇相关表
	err = db.AutoMigrate(
		&models.VocabularyCategory{},
		&models.Vocabulary{},
		&models.VocabularyDefinition{},
		&models.VocabularyExample{},
		&models.VocabularyImage{},
		&models.VocabularyCategoryRelation{},
		&models.UserVocabularyProgress{},
		&models.VocabularyTest{},
	)
	if err != nil {
		return err
	}
	
	// 学习相关表
	err = db.AutoMigrate(
		&models.ListeningMaterial{},
		&models.ListeningRecord{},
		&models.ReadingMaterial{},
		&models.ReadingRecord{},
		&models.WritingPrompt{},
		&models.WritingSubmission{},
		&models.SpeakingScenario{},
		&models.SpeakingRecord{},
	)
	if err != nil {
		return err
	}
	
	log.Println("数据库迁移完成")
	return nil
}

// CreateIndexes 创建额外的索引
func CreateIndexes(db *gorm.DB) error {
	log.Println("开始创建索引...")
	
	// 用户表索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_email_verified ON users(email_verified)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_status ON users(status)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at)")
	
	// 词汇表索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_vocabulary_level ON vocabulary(level)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_vocabulary_frequency ON vocabulary(frequency)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_vocabulary_is_active ON vocabulary(is_active)")
	
	// 用户词汇进度索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_vocabulary_progress_user_vocab ON user_vocabulary_progress(user_id, vocabulary_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_vocabulary_progress_mastery ON user_vocabulary_progress(mastery_level)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_user_vocabulary_progress_next_review ON user_vocabulary_progress(next_review_at)")
	
	// 学习记录索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_listening_records_user_material ON listening_records(user_id, material_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_reading_records_user_material ON reading_records(user_id, material_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_writing_submissions_user_prompt ON writing_submissions(user_id, prompt_id)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_speaking_records_user_scenario ON speaking_records(user_id, scenario_id)")
	
	// 材料表索引
	db.Exec("CREATE INDEX IF NOT EXISTS idx_listening_materials_level ON listening_materials(level)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_reading_materials_level ON reading_materials(level)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_writing_prompts_level ON writing_prompts(level)")
	db.Exec("CREATE INDEX IF NOT EXISTS idx_speaking_scenarios_level ON speaking_scenarios(level)")
	
	log.Println("索引创建完成")
	return nil
}