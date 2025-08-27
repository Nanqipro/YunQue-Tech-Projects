-- AI英语学习平台数据库表结构设计
-- 数据库: MySQL 8.0+
-- 字符集: utf8mb4
-- 排序规则: utf8mb4_unicode_ci
-- 创建时间: 2024

-- 设置字符集和排序规则
SET NAMES utf8mb4;
SET character_set_client = utf8mb4;

-- ============================================
-- 1. 用户管理模块
-- ============================================

-- 用户基础信息表
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(50),
    avatar_url VARCHAR(500),
    phone VARCHAR(20),
    gender TINYINT DEFAULT 0 COMMENT '0:未知, 1:男, 2:女',
    birth_date DATE,
    learning_level VARCHAR(20) DEFAULT 'beginner' COMMENT 'beginner, intermediate, advanced',
    learning_goals TEXT,
    motto VARCHAR(200) COMMENT '学习座右铭',
    timezone VARCHAR(50) DEFAULT 'UTC',
    language_preference VARCHAR(10) DEFAULT 'zh-CN',
    is_active BOOLEAN DEFAULT true,
    is_premium BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_learning_level (learning_level),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户基础信息表';

-- 用户社交链接表
CREATE TABLE user_social_links (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    platform VARCHAR(20) NOT NULL COMMENT 'wechat, weibo, github, etc.',
    link_url VARCHAR(500) NOT NULL,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_platform (platform)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户社交链接表';

-- 用户学习偏好表
CREATE TABLE user_preferences (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    learning_mode VARCHAR(20) DEFAULT 'visual' COMMENT 'visual, auditory, kinesthetic',
    preferred_study_time VARCHAR(20) COMMENT 'morning, afternoon, evening, night',
    daily_goal_minutes INT DEFAULT 30,
    reminder_enabled BOOLEAN DEFAULT true,
    reminder_time TIME DEFAULT '20:00:00',
    auto_play_pronunciation BOOLEAN DEFAULT true,
    show_chinese_meaning BOOLEAN DEFAULT true,
    difficulty_preference VARCHAR(20) DEFAULT 'adaptive' COMMENT 'easy, medium, hard, adaptive',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习偏好表';

-- ============================================
-- 2. 词汇学习模块
-- ============================================

-- 词库分类表
CREATE TABLE vocabulary_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    level VARCHAR(20) NOT NULL COMMENT 'primary, middle, high, cet4, cet6, toefl, ielts, gre, etc.',
    total_words INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_level (level),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词库分类表';

-- 词汇表
CREATE TABLE vocabulary (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    word VARCHAR(100) NOT NULL UNIQUE,
    phonetic_us VARCHAR(200) COMMENT '美式音标',
    phonetic_uk VARCHAR(200) COMMENT '英式音标',
    audio_us_url VARCHAR(500) COMMENT '美式发音音频URL',
    audio_uk_url VARCHAR(500) COMMENT '英式发音音频URL',
    frequency_rank INT COMMENT '词频排名',
    difficulty_level INT DEFAULT 1 COMMENT '1-10难度等级',
    word_forms JSON COMMENT '词形变化 {"plural": "words", "past": "worked"}',
    etymology TEXT COMMENT '词源',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_word (word),
    INDEX idx_frequency_rank (frequency_rank),
    INDEX idx_difficulty_level (difficulty_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词汇表';

-- 词汇释义表
CREATE TABLE vocabulary_definitions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vocabulary_id BIGINT NOT NULL,
    part_of_speech VARCHAR(20) NOT NULL COMMENT 'noun, verb, adjective, etc.',
    definition_en TEXT NOT NULL,
    definition_cn TEXT NOT NULL,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabulary(id) ON DELETE CASCADE,
    INDEX idx_vocabulary_id (vocabulary_id),
    INDEX idx_part_of_speech (part_of_speech)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词汇释义表';

-- 词汇例句表
CREATE TABLE vocabulary_examples (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vocabulary_id BIGINT NOT NULL,
    sentence_en TEXT NOT NULL,
    sentence_cn TEXT NOT NULL,
    audio_url VARCHAR(500),
    difficulty_level INT DEFAULT 1,
    source VARCHAR(100) COMMENT '例句来源',
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabulary(id) ON DELETE CASCADE,
    INDEX idx_vocabulary_id (vocabulary_id),
    INDEX idx_difficulty_level (difficulty_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词汇例句表';

-- 词汇图片表（百词斩风格）
CREATE TABLE vocabulary_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vocabulary_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    image_type VARCHAR(20) DEFAULT 'scene' COMMENT 'scene, abstract, animation',
    description TEXT,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabulary(id) ON DELETE CASCADE,
    INDEX idx_vocabulary_id (vocabulary_id),
    INDEX idx_image_type (image_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词汇图片表';

-- 词汇分类关联表
CREATE TABLE vocabulary_category_relations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vocabulary_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabulary(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES vocabulary_categories(id) ON DELETE CASCADE,
    UNIQUE KEY uk_vocabulary_category (vocabulary_id, category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词汇分类关联表';

-- 用户词汇学习记录表
CREATE TABLE user_vocabulary_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    vocabulary_id BIGINT NOT NULL,
    mastery_level INT DEFAULT 0 COMMENT '0:未学习, 1:认识, 2:模糊, 3:掌握, 4:熟练',
    first_learned_at TIMESTAMP NULL,
    last_reviewed_at TIMESTAMP NULL,
    next_review_at TIMESTAMP NULL,
    review_count INT DEFAULT 0,
    correct_count INT DEFAULT 0,
    wrong_count INT DEFAULT 0,
    learning_source VARCHAR(50) COMMENT 'manual, reading, listening, etc.',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabulary(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_vocabulary (user_id, vocabulary_id),
    INDEX idx_user_id (user_id),
    INDEX idx_mastery_level (mastery_level),
    INDEX idx_next_review_at (next_review_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户词汇学习记录表';

-- 词汇量测试记录表
CREATE TABLE vocabulary_tests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    test_type VARCHAR(20) NOT NULL COMMENT 'quick, precise, specific',
    total_questions INT NOT NULL,
    correct_answers INT NOT NULL,
    estimated_vocabulary_size INT,
    test_duration_seconds INT,
    difficulty_distribution JSON COMMENT '{"beginner": 20, "intermediate": 30, "advanced": 50}',
    detailed_results JSON COMMENT '详细测试结果',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_test_type (test_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='词汇量测试记录表';

-- ============================================
-- 3. 听力训练模块
-- ============================================

-- 听力材料分类表
CREATE TABLE listening_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    level VARCHAR(20) NOT NULL COMMENT 'A1, A2, B1, B2, C1, C2',
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_level (level),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='听力材料分类表';

-- 听力材料表
CREATE TABLE listening_materials (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category_id BIGINT NOT NULL,
    content_type VARCHAR(50) NOT NULL COMMENT 'conversation, news, business, academic, entertainment',
    difficulty_level VARCHAR(10) NOT NULL COMMENT 'A1, A2, B1, B2, C1, C2',
    duration_seconds INT NOT NULL,
    word_count INT,
    speaking_rate INT COMMENT '语速(词/分钟)',
    audio_url VARCHAR(500) NOT NULL,
    transcript TEXT COMMENT '听力原文',
    is_premium BOOLEAN DEFAULT false,
    source VARCHAR(100) COMMENT 'BBC, CNN, etc.',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES listening_categories(id),
    INDEX idx_category_id (category_id),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_content_type (content_type),
    INDEX idx_is_premium (is_premium)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='听力材料表';

-- 听力练习题目表
CREATE TABLE listening_questions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    material_id BIGINT NOT NULL,
    question_type VARCHAR(20) NOT NULL COMMENT 'multiple_choice, fill_blank, true_false, ordering, matching',
    question_text TEXT NOT NULL,
    question_audio_url VARCHAR(500),
    start_time_seconds DECIMAL(10,2) COMMENT '题目对应音频开始时间',
    end_time_seconds DECIMAL(10,2) COMMENT '题目对应音频结束时间',
    options JSON COMMENT '选择题选项',
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (material_id) REFERENCES listening_materials(id) ON DELETE CASCADE,
    INDEX idx_material_id (material_id),
    INDEX idx_question_type (question_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='听力练习题目表';

-- 用户听力练习记录表
CREATE TABLE user_listening_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    completion_status VARCHAR(20) DEFAULT 'not_started' COMMENT 'not_started, in_progress, completed',
    total_questions INT DEFAULT 0,
    correct_answers INT DEFAULT 0,
    completion_time_seconds INT,
    last_position_seconds INT DEFAULT 0 COMMENT '上次播放位置',
    play_count INT DEFAULT 0,
    notes TEXT,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES listening_materials(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_material_id (material_id),
    INDEX idx_completion_status (completion_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户听力练习记录表';

-- ============================================
-- 4. 阅读理解模块
-- ============================================

-- 阅读材料分类表
CREATE TABLE reading_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    level VARCHAR(20) NOT NULL COMMENT 'R-Z分级标准',
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_level (level),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='阅读材料分类表';

-- 阅读材料表
CREATE TABLE reading_materials (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100),
    category_id BIGINT NOT NULL,
    content_type VARCHAR(50) NOT NULL COMMENT 'literature, science, news, history, business',
    difficulty_level VARCHAR(10) NOT NULL COMMENT 'R-Z级别',
    word_count INT NOT NULL,
    estimated_reading_time INT COMMENT '预估阅读时间(分钟)',
    content TEXT NOT NULL,
    summary TEXT,
    audio_url VARCHAR(500) COMMENT '朗读音频',
    is_premium BOOLEAN DEFAULT false,
    source VARCHAR(100),
    tags JSON COMMENT '标签数组',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES reading_categories(id),
    INDEX idx_category_id (category_id),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_content_type (content_type),
    INDEX idx_is_premium (is_premium),
    FULLTEXT idx_content (content)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='阅读材料表';

-- 阅读理解题目表
CREATE TABLE reading_questions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    material_id BIGINT NOT NULL,
    question_type VARCHAR(20) NOT NULL COMMENT 'main_idea, detail, inference, vocabulary, attitude',
    question_text TEXT NOT NULL,
    paragraph_reference INT COMMENT '相关段落编号',
    options JSON COMMENT '选择题选项',
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    difficulty_level INT DEFAULT 1 COMMENT '1-5难度等级',
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (material_id) REFERENCES reading_materials(id) ON DELETE CASCADE,
    INDEX idx_material_id (material_id),
    INDEX idx_question_type (question_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='阅读理解题目表';

-- 用户阅读进度表
CREATE TABLE user_reading_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    reading_status VARCHAR(20) DEFAULT 'not_started' COMMENT 'not_started, reading, completed',
    reading_progress DECIMAL(5,2) DEFAULT 0.00 COMMENT '阅读进度百分比',
    reading_time_seconds INT DEFAULT 0,
    total_questions INT DEFAULT 0,
    correct_answers INT DEFAULT 0,
    reading_speed_wpm INT COMMENT '阅读速度(词/分钟)',
    comprehension_score DECIMAL(5,2) COMMENT '理解得分',
    bookmarks JSON COMMENT '书签位置',
    notes TEXT,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES reading_materials(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_material_id (material_id),
    INDEX idx_reading_status (reading_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户阅读进度表';

-- ============================================
-- 5. 写作练习模块
-- ============================================

-- 写作题目分类表
CREATE TABLE writing_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category_type VARCHAR(50) NOT NULL COMMENT 'translation, topic_writing, exam_writing',
    exam_type VARCHAR(20) COMMENT 'cet4, cet6, toefl, ielts, etc.',
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category_type (category_type),
    INDEX idx_exam_type (exam_type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='写作题目分类表';

-- 写作题目表
CREATE TABLE writing_prompts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    prompt_text TEXT NOT NULL,
    prompt_type VARCHAR(50) NOT NULL COMMENT 'translation, argumentative, narrative, application',
    difficulty_level INT DEFAULT 1 COMMENT '1-5难度等级',
    word_limit_min INT DEFAULT 150,
    word_limit_max INT DEFAULT 500,
    time_limit_minutes INT DEFAULT 30,
    reference_materials JSON COMMENT '参考材料',
    sample_answers JSON COMMENT '范文',
    evaluation_criteria JSON COMMENT '评分标准',
    tags JSON,
    is_premium BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES writing_categories(id),
    INDEX idx_category_id (category_id),
    INDEX idx_prompt_type (prompt_type),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_is_premium (is_premium)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='写作题目表';

-- 用户写作记录表
CREATE TABLE user_writing_submissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    prompt_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    word_count INT NOT NULL,
    writing_time_seconds INT,
    submission_status VARCHAR(20) DEFAULT 'submitted' COMMENT 'draft, submitted, graded',
    ai_score DECIMAL(5,2) COMMENT 'AI评分(0-100)',
    grammar_score DECIMAL(5,2) COMMENT '语法得分',
    vocabulary_score DECIMAL(5,2) COMMENT '词汇得分',
    fluency_score DECIMAL(5,2) COMMENT '流畅度得分',
    content_score DECIMAL(5,2) COMMENT '内容得分',
    ai_feedback JSON COMMENT 'AI反馈详情',
    teacher_score DECIMAL(5,2) COMMENT '教师评分',
    teacher_feedback TEXT COMMENT '教师反馈',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (prompt_id) REFERENCES writing_prompts(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_prompt_id (prompt_id),
    INDEX idx_submission_status (submission_status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户写作记录表';

-- ============================================
-- 6. 口语练习模块
-- ============================================

-- 口语场景分类表
CREATE TABLE speaking_scenarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    scenario_type VARCHAR(50) NOT NULL COMMENT 'daily, business, travel, academic',
    difficulty_level VARCHAR(10) NOT NULL COMMENT 'A1, A2, B1, B2, C1, C2',
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_scenario_type (scenario_type),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='口语场景分类表';

-- AI对话伙伴表
CREATE TABLE ai_tutors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500),
    personality_description TEXT,
    specialization VARCHAR(100) COMMENT 'business, daily, travel, academic',
    accent VARCHAR(20) DEFAULT 'american' COMMENT 'american, british',
    voice_model VARCHAR(100) COMMENT 'AI语音模型标识',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_specialization (specialization),
    INDEX idx_accent (accent),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI对话伙伴表';

-- 口语对话模板表
CREATE TABLE speaking_dialogues (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    scenario_id BIGINT NOT NULL,
    tutor_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    dialogue_flow JSON NOT NULL COMMENT '对话流程定义',
    estimated_duration_minutes INT DEFAULT 10,
    learning_objectives JSON,
    key_phrases JSON,
    is_premium BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (scenario_id) REFERENCES speaking_scenarios(id),
    FOREIGN KEY (tutor_id) REFERENCES ai_tutors(id),
    INDEX idx_scenario_id (scenario_id),
    INDEX idx_tutor_id (tutor_id),
    INDEX idx_is_premium (is_premium)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='口语对话模板表';

-- 用户口语练习记录表
CREATE TABLE user_speaking_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    dialogue_id BIGINT NOT NULL,
    session_status VARCHAR(20) DEFAULT 'completed' COMMENT 'in_progress, completed, abandoned',
    duration_seconds INT NOT NULL,
    total_utterances INT DEFAULT 0,
    pronunciation_score DECIMAL(5,2) COMMENT '发音得分',
    fluency_score DECIMAL(5,2) COMMENT '流利度得分',
    grammar_score DECIMAL(5,2) COMMENT '语法得分',
    vocabulary_score DECIMAL(5,2) COMMENT '词汇得分',
    overall_score DECIMAL(5,2) COMMENT '总体得分',
    ai_feedback JSON COMMENT 'AI反馈',
    audio_recording_url VARCHAR(500) COMMENT '录音文件URL',
    transcript TEXT COMMENT '对话转录',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (dialogue_id) REFERENCES speaking_dialogues(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_dialogue_id (dialogue_id),
    INDEX idx_session_status (session_status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户口语练习记录表';

-- ============================================
-- 7. 学习统计与分析模块
-- ============================================

-- 用户学习统计表
CREATE TABLE user_learning_stats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    stat_date DATE NOT NULL,
    vocabulary_learned INT DEFAULT 0,
    vocabulary_reviewed INT DEFAULT 0,
    listening_time_seconds INT DEFAULT 0,
    reading_time_seconds INT DEFAULT 0,
    writing_count INT DEFAULT 0,
    speaking_time_seconds INT DEFAULT 0,
    total_study_time_seconds INT DEFAULT 0,
    login_count INT DEFAULT 0,
    streak_days INT DEFAULT 0 COMMENT '连续学习天数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_date (user_id, stat_date),
    INDEX idx_user_id (user_id),
    INDEX idx_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户学习统计表';

-- 用户能力评估表
CREATE TABLE user_ability_assessments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    assessment_type VARCHAR(50) NOT NULL COMMENT 'comprehensive, vocabulary, listening, reading, writing, speaking',
    vocabulary_level INT DEFAULT 0 COMMENT '词汇水平(1-10)',
    listening_level INT DEFAULT 0 COMMENT '听力水平(1-10)',
    reading_level INT DEFAULT 0 COMMENT '阅读水平(1-10)',
    writing_level INT DEFAULT 0 COMMENT '写作水平(1-10)',
    speaking_level INT DEFAULT 0 COMMENT '口语水平(1-10)',
    overall_level DECIMAL(3,1) DEFAULT 0.0 COMMENT '综合水平',
    assessment_details JSON COMMENT '详细评估结果',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_assessment_type (assessment_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户能力评估表';

-- 学习目标表
CREATE TABLE user_learning_goals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    goal_type VARCHAR(50) NOT NULL COMMENT 'daily, weekly, monthly, exam',
    goal_description TEXT NOT NULL,
    target_value INT NOT NULL,
    current_value INT DEFAULT 0,
    unit VARCHAR(20) NOT NULL COMMENT 'words, minutes, articles, etc.',
    deadline DATE,
    status VARCHAR(20) DEFAULT 'active' COMMENT 'active, completed, paused, cancelled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_goal_type (goal_type),
    INDEX idx_status (status),
    INDEX idx_deadline (deadline)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习目标表';

-- ============================================
-- 8. AI助手与推荐系统
-- ============================================

-- AI对话历史表
CREATE TABLE ai_chat_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_title VARCHAR(200),
    session_type VARCHAR(50) DEFAULT 'general' COMMENT 'general, grammar, vocabulary, learning_guidance',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_session_type (session_type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI对话历史表';

-- AI对话消息表
CREATE TABLE ai_chat_messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT NOT NULL,
    message_type VARCHAR(20) NOT NULL COMMENT 'user, assistant',
    content TEXT NOT NULL,
    message_metadata JSON COMMENT '消息元数据',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES ai_chat_sessions(id) ON DELETE CASCADE,
    INDEX idx_session_id (session_id),
    INDEX idx_message_type (message_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI对话消息表';

-- 学习推荐记录表
CREATE TABLE learning_recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    recommendation_type VARCHAR(50) NOT NULL COMMENT 'vocabulary, material, study_plan',
    content_type VARCHAR(50) NOT NULL COMMENT 'vocabulary, listening, reading, writing, speaking',
    content_id BIGINT COMMENT '推荐内容的ID',
    recommendation_reason TEXT,
    priority_score DECIMAL(5,2) DEFAULT 0.0,
    status VARCHAR(20) DEFAULT 'pending' COMMENT 'pending, accepted, rejected, completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_recommendation_type (recommendation_type),
    INDEX idx_content_type (content_type),
    INDEX idx_status (status),
    INDEX idx_priority_score (priority_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习推荐记录表';

-- ============================================
-- 9. 系统配置与内容管理
-- ============================================

-- 系统配置表
CREATE TABLE system_configs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT NOT NULL,
    config_type VARCHAR(20) DEFAULT 'string' COMMENT 'string, number, boolean, json',
    description TEXT,
    is_public BOOLEAN DEFAULT false COMMENT '是否对客户端公开',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_config_key (config_key),
    INDEX idx_is_public (is_public)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 内容分类表
CREATE TABLE content_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_type VARCHAR(50) NOT NULL COMMENT 'vocabulary, listening, reading, writing, speaking',
    parent_id BIGINT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES content_categories(id),
    INDEX idx_category_type (category_type),
    INDEX idx_parent_id (parent_id),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='内容分类表';

-- 难度等级表
CREATE TABLE difficulty_levels (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    level_code VARCHAR(10) NOT NULL UNIQUE COMMENT 'A1, A2, B1, B2, C1, C2, etc.',
    level_name VARCHAR(50) NOT NULL,
    description TEXT,
    numeric_value INT NOT NULL COMMENT '数值表示，用于排序和比较',
    color_code VARCHAR(7) COMMENT '颜色代码，用于UI显示',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_level_code (level_code),
    INDEX idx_numeric_value (numeric_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='难度等级表';

-- ============================================
-- 初始数据插入
-- ============================================

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, config_type, description, is_public) VALUES
('app_version', '1.0.0', 'string', '应用版本号', true),
('maintenance_mode', 'false', 'boolean', '维护模式开关', true),
('max_daily_study_time', '480', 'number', '每日最大学习时间(分钟)', false),
('default_vocabulary_review_interval', '24', 'number', '默认词汇复习间隔(小时)', false),
('ai_model_config', '{"model": "gpt-3.5-turbo", "temperature": 0.7}', 'json', 'AI模型配置', false);

-- 插入难度等级
INSERT INTO difficulty_levels (level_code, level_name, description, numeric_value, color_code) VALUES
('A1', '入门级', '能够理解并使用熟悉的日常表达和基本短语', 1, '#4CAF50'),
('A2', '初级', '能够理解直接关于切身环境的句子和常用语', 2, '#8BC34A'),
('B1', '中级', '能够理解工作、学校、娱乐等熟悉话题的要点', 3, '#FFC107'),
('B2', '中高级', '能够理解复杂文本的主要内容', 4, '#FF9800'),
('C1', '高级', '能够理解广泛的长篇复杂文本', 5, '#FF5722'),
('C2', '精通级', '能够毫不费力地理解几乎所有听到或读到的内容', 6, '#F44336');

-- 插入词库分类
INSERT INTO vocabulary_categories (name, description, level, total_words) VALUES
('小学词汇', '小学阶段必备英语词汇', 'primary', 800),
('初中词汇', '初中阶段核心英语词汇', 'middle', 1600),
('高中词汇', '高中阶段重点英语词汇', 'high', 3500),
('大学四级', '大学英语四级考试词汇', 'cet4', 4500),
('大学六级', '大学英语六级考试词汇', 'cet6', 6000),
('托福词汇', 'TOEFL考试核心词汇', 'toefl', 8000),
('雅思词汇', 'IELTS考试核心词汇', 'ielts', 7000),
('GRE词汇', 'GRE考试高频词汇', 'gre', 12000);

-- 插入听力分类
INSERT INTO listening_categories (name, description, level) VALUES
('日常对话', '日常生活场景对话', 'A1'),
('校园生活', '学校和学习相关对话', 'A2'),
('工作场景', '职场和商务对话', 'B1'),
('新闻资讯', '新闻播报和时事讨论', 'B2'),
('学术讲座', '学术演讲和专业讲座', 'C1'),
('文化艺术', '文化、艺术、历史话题', 'C2');

-- 插入阅读分类
INSERT INTO reading_categories (name, description, level) VALUES
('简单故事', '简单的故事和寓言', 'R'),
('生活文章', '日常生活相关文章', 'S'),
('科普文章', '科学普及类文章', 'T'),
('新闻报道', '新闻和时事报道', 'U'),
('学术文章', '学术研究和专业文章', 'V'),
('文学作品', '经典文学作品节选', 'W');

-- 插入写作分类
INSERT INTO writing_categories (name, description, category_type, exam_type) VALUES
('中译英练习', '中文翻译成英文的练习', 'translation', NULL),
('话题写作', '根据给定话题进行写作', 'topic_writing', NULL),
('四级写作', '大学英语四级写作练习', 'exam_writing', 'cet4'),
('六级写作', '大学英语六级写作练习', 'exam_writing', 'cet6'),
('托福写作', 'TOEFL写作练习', 'exam_writing', 'toefl'),
('雅思写作', 'IELTS写作练习', 'exam_writing', 'ielts');

-- 插入口语场景
INSERT INTO speaking_scenarios (name, description, scenario_type, difficulty_level) VALUES
('日常问候', '基本的问候和自我介绍', 'daily', 'A1'),
('购物场景', '商店购物和讨价还价', 'daily', 'A2'),
('餐厅用餐', '餐厅点餐和用餐交流', 'daily', 'B1'),
('商务会议', '商务会议和工作讨论', 'business', 'B2'),
('旅行出行', '旅行计划和旅途交流', 'travel', 'B1'),
('学术讨论', '学术话题和研究讨论', 'academic', 'C1');

-- 插入AI导师
INSERT INTO ai_tutors (name, personality_description, specialization, accent, voice_model) VALUES
('Emma', '友善耐心的日常英语导师，擅长生活场景对话', 'daily', 'american', 'voice_emma_us'),
('James', '专业的商务英语导师，具有丰富的职场经验', 'business', 'british', 'voice_james_uk'),
('Sophia', '热情的旅行英语导师，了解各国文化', 'travel', 'american', 'voice_sophia_us'),
('Oliver', '严谨的学术英语导师，专注于学术交流', 'academic', 'british', 'voice_oliver_uk');

-- ============================================
-- 创建视图
-- ============================================

-- 用户学习概览视图
CREATE VIEW user_learning_overview AS
SELECT 
    u.id as user_id,
    u.username,
    u.learning_level,
    COUNT(DISTINCT uvp.vocabulary_id) as learned_words,
    COALESCE(MAX(uls.streak_days), 0) as current_streak,
    COALESCE(SUM(uls.total_study_time_seconds), 0) as total_study_time,
    COALESCE(AVG(uaa.overall_level), 0) as avg_ability_level
FROM users u
LEFT JOIN user_vocabulary_progress uvp ON u.id = uvp.user_id AND uvp.mastery_level >= 3
LEFT JOIN user_learning_stats uls ON u.id = uls.user_id
LEFT JOIN user_ability_assessments uaa ON u.id = uaa.user_id
WHERE u.is_active = true
GROUP BY u.id, u.username, u.learning_level;

-- 词汇学习进度视图
CREATE VIEW vocabulary_learning_progress AS
SELECT 
    vc.name as category_name,
    vc.level,
    COUNT(v.id) as total_words,
    COUNT(CASE WHEN uvp.mastery_level >= 1 THEN 1 END) as recognized_words,
    COUNT(CASE WHEN uvp.mastery_level >= 3 THEN 1 END) as mastered_words,
    uvp.user_id
FROM vocabulary_categories vc
LEFT JOIN vocabulary_category_relations vcr ON vc.id = vcr.category_id
LEFT JOIN vocabulary v ON vcr.vocabulary_id = v.id
LEFT JOIN user_vocabulary_progress uvp ON v.id = uvp.vocabulary_id
WHERE vc.is_active = true
GROUP BY vc.id, vc.name, vc.level, uvp.user_id;

-- ============================================
-- 创建触发器
-- ============================================

DELIMITER //

-- 更新词库总词数的触发器
CREATE TRIGGER update_category_word_count
AFTER INSERT ON vocabulary_category_relations
FOR EACH ROW
BEGIN
    UPDATE vocabulary_categories 
    SET total_words = (
        SELECT COUNT(*) 
        FROM vocabulary_category_relations 
        WHERE category_id = NEW.category_id
    )
    WHERE id = NEW.category_id;
END//

-- 用户学习统计更新触发器
CREATE TRIGGER update_learning_stats_on_vocabulary
AFTER UPDATE ON user_vocabulary_progress
FOR EACH ROW
BEGIN
    IF NEW.mastery_level > OLD.mastery_level THEN
        INSERT INTO user_learning_stats (user_id, stat_date, vocabulary_learned)
        VALUES (NEW.user_id, CURDATE(), 1)
        ON DUPLICATE KEY UPDATE 
        vocabulary_learned = vocabulary_learned + 1,
        updated_at = CURRENT_TIMESTAMP;
    END IF;
END//

DELIMITER ;

-- ============================================
-- 创建索引优化
-- ============================================

-- 复合索引优化查询性能
CREATE INDEX idx_user_vocabulary_mastery ON user_vocabulary_progress(user_id, mastery_level, next_review_at);
CREATE INDEX idx_learning_stats_user_date ON user_learning_stats(user_id, stat_date DESC);
CREATE INDEX idx_vocabulary_difficulty_frequency ON vocabulary(difficulty_level, frequency_rank);
CREATE INDEX idx_materials_category_level ON listening_materials(category_id, difficulty_level);
CREATE INDEX idx_reading_materials_category_level ON reading_materials(category_id, difficulty_level);

-- ============================================
-- 数据库设计说明
-- ============================================

/*
数据库设计特点：
1. 基于MySQL 8.0，充分利用JSON数据类型和现代特性
2. 采用InnoDB存储引擎，支持事务和外键约束
3. 使用utf8mb4字符集，完整支持Unicode字符
4. 合理的索引设计，优化查询性能
5. 触发器自动维护统计数据
6. 视图简化复杂查询
7. 支持水平扩展和分库分表
8. 完整的数据完整性约束
9. 考虑了数据安全和隐私保护
10. 支持多种学习模式和个性化需求

性能优化建议：
1. 定期分析和优化慢查询
2. 根据业务增长考虑分库分表
3. 使用Redis缓存热点数据
4. 定期清理历史数据
5. 监控数据库性能指标
*/