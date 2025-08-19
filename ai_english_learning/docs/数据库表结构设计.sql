-- AI英语学习平台 - MySQL数据库表结构设计
-- 创建时间：2024年
-- 数据库版本：MySQL 8.0+

-- 创建数据库
CREATE DATABASE IF NOT EXISTS ai_english_learning 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_unicode_ci;

USE ai_english_learning;

-- ========================================
-- 1. 用户管理模块
-- ========================================

-- 用户基础信息表
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    nickname VARCHAR(50) COMMENT '昵称',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    gender TINYINT DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
    birth_date DATE COMMENT '出生日期',
    learning_level ENUM('primary', 'junior', 'senior', 'cet4', 'cet6', 'toefl', 'ielts', 'adult') DEFAULT 'primary' COMMENT '学习阶段',
    learning_goal TEXT COMMENT '学习目标',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
    last_login_time TIMESTAMP NULL COMMENT '最后登录时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_learning_level (learning_level)
) COMMENT '用户基础信息表';

-- 用户学习档案表
CREATE TABLE user_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '档案ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    total_study_days INT DEFAULT 0 COMMENT '总学习天数',
    continuous_study_days INT DEFAULT 0 COMMENT '连续学习天数',
    total_study_time INT DEFAULT 0 COMMENT '总学习时长（分钟）',
    vocabulary_mastered INT DEFAULT 0 COMMENT '已掌握词汇数',
    reading_articles_count INT DEFAULT 0 COMMENT '已读文章数',
    current_vocabulary_level VARCHAR(20) DEFAULT 'beginner' COMMENT '当前词汇水平',
    current_reading_level VARCHAR(20) DEFAULT 'R' COMMENT '当前阅读级别',
    learning_preferences JSON COMMENT '学习偏好设置',
    achievement_badges JSON COMMENT '成就徽章',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) COMMENT '用户学习档案表';

-- ========================================
-- 2. 词汇管理模块
-- ========================================

-- 词库分类表
CREATE TABLE vocabulary_categories (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    category_code VARCHAR(20) NOT NULL UNIQUE COMMENT '分类代码',
    category_name VARCHAR(50) NOT NULL COMMENT '分类名称',
    description TEXT COMMENT '分类描述',
    target_level ENUM('primary', 'junior', 'senior', 'cet4', 'cet6', 'toefl', 'ielts', 'adult') COMMENT '目标学习阶段',
    word_count INT DEFAULT 0 COMMENT '词汇数量',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_category_code (category_code),
    INDEX idx_target_level (target_level)
) COMMENT '词库分类表';

-- 词汇主表
CREATE TABLE vocabularies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '词汇ID',
    word VARCHAR(100) NOT NULL COMMENT '单词',
    phonetic_us VARCHAR(200) COMMENT '美式音标',
    phonetic_uk VARCHAR(200) COMMENT '英式音标',
    audio_us_url VARCHAR(500) COMMENT '美式发音URL',
    audio_uk_url VARCHAR(500) COMMENT '英式发音URL',
    part_of_speech VARCHAR(50) COMMENT '词性',
    definition_en TEXT COMMENT '英文释义',
    definition_cn TEXT COMMENT '中文释义',
    difficulty_level TINYINT DEFAULT 1 COMMENT '难度等级：1-5',
    frequency_rank INT COMMENT '词频排名',
    word_root VARCHAR(100) COMMENT '词根',
    etymology TEXT COMMENT '词源信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_word (word),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_frequency_rank (frequency_rank),
    INDEX idx_word_root (word_root),
    FULLTEXT KEY ft_word_definition (word, definition_en, definition_cn)
) COMMENT '词汇主表';

-- 词汇分类关联表
CREATE TABLE vocabulary_category_relations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '关联ID',
    vocabulary_id BIGINT NOT NULL COMMENT '词汇ID',
    category_id INT NOT NULL COMMENT '分类ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES vocabulary_categories(id) ON DELETE CASCADE,
    UNIQUE KEY uk_vocab_category (vocabulary_id, category_id),
    INDEX idx_vocabulary_id (vocabulary_id),
    INDEX idx_category_id (category_id)
) COMMENT '词汇分类关联表';

-- 例句表
CREATE TABLE vocabulary_examples (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '例句ID',
    vocabulary_id BIGINT NOT NULL COMMENT '词汇ID',
    sentence_en TEXT NOT NULL COMMENT '英文例句',
    sentence_cn TEXT COMMENT '中文翻译',
    audio_url VARCHAR(500) COMMENT '例句发音URL',
    difficulty_level TINYINT DEFAULT 1 COMMENT '难度等级：1-5',
    usage_frequency INT DEFAULT 0 COMMENT '使用频率',
    source VARCHAR(100) COMMENT '例句来源',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE,
    INDEX idx_vocabulary_id (vocabulary_id),
    INDEX idx_difficulty_level (difficulty_level)
) COMMENT '例句表';

-- 同义词反义词表
CREATE TABLE vocabulary_relations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '关系ID',
    vocabulary_id BIGINT NOT NULL COMMENT '主词汇ID',
    related_vocabulary_id BIGINT NOT NULL COMMENT '关联词汇ID',
    relation_type ENUM('synonym', 'antonym', 'derivative', 'root_related') NOT NULL COMMENT '关系类型：同义词、反义词、派生词、词根关联',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE,
    FOREIGN KEY (related_vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_vocab_relation (vocabulary_id, related_vocabulary_id, relation_type),
    INDEX idx_vocabulary_id (vocabulary_id),
    INDEX idx_related_vocabulary_id (related_vocabulary_id),
    INDEX idx_relation_type (relation_type)
) COMMENT '同义词反义词关系表';

-- 主题词包表
CREATE TABLE theme_word_packages (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '主题包ID',
    package_name VARCHAR(100) NOT NULL COMMENT '主题包名称',
    package_code VARCHAR(50) NOT NULL UNIQUE COMMENT '主题包代码',
    description TEXT COMMENT '主题包描述',
    cover_image_url VARCHAR(500) COMMENT '封面图片URL',
    word_count INT DEFAULT 0 COMMENT '词汇数量',
    difficulty_level TINYINT DEFAULT 1 COMMENT '难度等级：1-5',
    target_audience VARCHAR(100) COMMENT '目标用户群体',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_package_code (package_code),
    INDEX idx_difficulty_level (difficulty_level)
) COMMENT '主题词包表';

-- 主题词包词汇关联表
CREATE TABLE theme_package_vocabularies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '关联ID',
    package_id INT NOT NULL COMMENT '主题包ID',
    vocabulary_id BIGINT NOT NULL COMMENT '词汇ID',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (package_id) REFERENCES theme_word_packages(id) ON DELETE CASCADE,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_package_vocab (package_id, vocabulary_id),
    INDEX idx_package_id (package_id),
    INDEX idx_vocabulary_id (vocabulary_id)
) COMMENT '主题词包词汇关联表';

-- ========================================
-- 3. 阅读内容模块
-- ========================================

-- 阅读文章表
CREATE TABLE reading_articles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '文章ID',
    title VARCHAR(200) NOT NULL COMMENT '文章标题',
    subtitle VARCHAR(300) COMMENT '副标题',
    content LONGTEXT NOT NULL COMMENT '文章内容',
    content_summary TEXT COMMENT '文章摘要',
    author VARCHAR(100) COMMENT '作者',
    source VARCHAR(100) COMMENT '来源',
    reading_level VARCHAR(10) NOT NULL COMMENT '阅读级别：R-Z',
    difficulty_score DECIMAL(3,1) COMMENT '难度评分：1.0-10.0',
    word_count INT NOT NULL COMMENT '字数',
    estimated_reading_time INT COMMENT '预估阅读时间（分钟）',
    category ENUM('literature', 'science', 'news', 'history', 'business', 'technology', 'culture') NOT NULL COMMENT '文章分类',
    tags JSON COMMENT '标签',
    cover_image_url VARCHAR(500) COMMENT '封面图片URL',
    audio_url VARCHAR(500) COMMENT '音频URL',
    view_count INT DEFAULT 0 COMMENT '浏览次数',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-发布',
    published_at TIMESTAMP NULL COMMENT '发布时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_reading_level (reading_level),
    INDEX idx_difficulty_score (difficulty_score),
    INDEX idx_category (category),
    INDEX idx_word_count (word_count),
    INDEX idx_published_at (published_at),
    FULLTEXT KEY ft_title_content (title, content)
) COMMENT '阅读文章表';

-- 文章段落表
CREATE TABLE article_paragraphs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '段落ID',
    article_id BIGINT NOT NULL COMMENT '文章ID',
    paragraph_order INT NOT NULL COMMENT '段落顺序',
    content TEXT NOT NULL COMMENT '段落内容',
    main_idea TEXT COMMENT '段落中心思想',
    key_vocabulary JSON COMMENT '关键词汇',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (article_id) REFERENCES reading_articles(id) ON DELETE CASCADE,
    INDEX idx_article_id (article_id),
    INDEX idx_paragraph_order (paragraph_order)
) COMMENT '文章段落表';

-- 阅读理解题目表
CREATE TABLE reading_questions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '题目ID',
    article_id BIGINT NOT NULL COMMENT '文章ID',
    question_type ENUM('keyword_completion', 'main_idea', 'translation', 'information_matching', 'multiple_choice', 'true_false') NOT NULL COMMENT '题目类型',
    question_text TEXT NOT NULL COMMENT '题目内容',
    options JSON COMMENT '选项（JSON格式）',
    correct_answer TEXT NOT NULL COMMENT '正确答案',
    explanation TEXT COMMENT '答案解析',
    difficulty_level TINYINT DEFAULT 1 COMMENT '难度等级：1-5',
    points INT DEFAULT 1 COMMENT '分值',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (article_id) REFERENCES reading_articles(id) ON DELETE CASCADE,
    INDEX idx_article_id (article_id),
    INDEX idx_question_type (question_type),
    INDEX idx_difficulty_level (difficulty_level)
) COMMENT '阅读理解题目表';

-- ========================================
-- 4. 用户学习记录模块
-- ========================================

-- 词汇学习记录表
CREATE TABLE user_vocabulary_learning (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '学习记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    vocabulary_id BIGINT NOT NULL COMMENT '词汇ID',
    mastery_level TINYINT DEFAULT 0 COMMENT '掌握程度：0-未学习，1-认识，2-熟悉，3-掌握，4-精通',
    learning_count INT DEFAULT 0 COMMENT '学习次数',
    correct_count INT DEFAULT 0 COMMENT '正确次数',
    wrong_count INT DEFAULT 0 COMMENT '错误次数',
    last_review_time TIMESTAMP NULL COMMENT '最后复习时间',
    next_review_time TIMESTAMP NULL COMMENT '下次复习时间',
    review_interval_days INT DEFAULT 1 COMMENT '复习间隔天数',
    forgetting_curve_factor DECIMAL(3,2) DEFAULT 2.50 COMMENT '遗忘曲线因子',
    first_learned_at TIMESTAMP NULL COMMENT '首次学习时间',
    last_learned_at TIMESTAMP NULL COMMENT '最后学习时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_vocabulary (user_id, vocabulary_id),
    INDEX idx_user_id (user_id),
    INDEX idx_vocabulary_id (vocabulary_id),
    INDEX idx_mastery_level (mastery_level),
    INDEX idx_next_review_time (next_review_time)
) COMMENT '用户词汇学习记录表';

-- 阅读学习记录表
CREATE TABLE user_reading_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '阅读记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    article_id BIGINT NOT NULL COMMENT '文章ID',
    reading_status ENUM('not_started', 'reading', 'completed', 'abandoned') DEFAULT 'not_started' COMMENT '阅读状态',
    reading_progress DECIMAL(5,2) DEFAULT 0.00 COMMENT '阅读进度百分比',
    reading_time_seconds INT DEFAULT 0 COMMENT '阅读时长（秒）',
    reading_speed_wpm INT COMMENT '阅读速度（词/分钟）',
    comprehension_score DECIMAL(5,2) COMMENT '理解得分',
    vocabulary_coverage_rate DECIMAL(5,2) COMMENT '词汇覆盖率',
    new_words_count INT DEFAULT 0 COMMENT '生词数量',
    questions_answered INT DEFAULT 0 COMMENT '已答题目数',
    questions_correct INT DEFAULT 0 COMMENT '正确题目数',
    started_at TIMESTAMP NULL COMMENT '开始阅读时间',
    completed_at TIMESTAMP NULL COMMENT '完成阅读时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES reading_articles(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_article (user_id, article_id),
    INDEX idx_user_id (user_id),
    INDEX idx_article_id (article_id),
    INDEX idx_reading_status (reading_status),
    INDEX idx_completed_at (completed_at)
) COMMENT '用户阅读记录表';

-- 学习测试记录表
CREATE TABLE user_test_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '测试记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    test_type ENUM('vocabulary_spelling', 'vocabulary_meaning', 'sentence_making', 'error_correction', 'translation', 'reading_comprehension') NOT NULL COMMENT '测试类型',
    related_id BIGINT COMMENT '关联ID（词汇ID或文章ID）',
    question_content TEXT COMMENT '题目内容',
    user_answer TEXT COMMENT '用户答案',
    correct_answer TEXT COMMENT '正确答案',
    is_correct TINYINT NOT NULL COMMENT '是否正确：0-错误，1-正确',
    score DECIMAL(5,2) COMMENT '得分',
    time_spent_seconds INT COMMENT '用时（秒）',
    ai_feedback TEXT COMMENT 'AI反馈',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_test_type (test_type),
    INDEX idx_related_id (related_id),
    INDEX idx_is_correct (is_correct),
    INDEX idx_created_at (created_at)
) COMMENT '用户测试记录表';

-- 学习会话记录表
CREATE TABLE user_study_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会话ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    session_type ENUM('vocabulary', 'reading', 'mixed') NOT NULL COMMENT '学习类型',
    start_time TIMESTAMP NOT NULL COMMENT '开始时间',
    end_time TIMESTAMP NULL COMMENT '结束时间',
    duration_seconds INT DEFAULT 0 COMMENT '学习时长（秒）',
    words_learned INT DEFAULT 0 COMMENT '学习词汇数',
    articles_read INT DEFAULT 0 COMMENT '阅读文章数',
    tests_completed INT DEFAULT 0 COMMENT '完成测试数',
    correct_rate DECIMAL(5,2) COMMENT '正确率',
    experience_gained INT DEFAULT 0 COMMENT '获得经验值',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_session_type (session_type),
    INDEX idx_start_time (start_time)
) COMMENT '用户学习会话记录表';

-- ========================================
-- 5. AI功能模块
-- ========================================

-- AI推荐记录表
CREATE TABLE ai_recommendations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '推荐记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    recommendation_type ENUM('vocabulary', 'article', 'exercise', 'study_plan') NOT NULL COMMENT '推荐类型',
    recommended_item_id BIGINT NOT NULL COMMENT '推荐项目ID',
    recommendation_reason TEXT COMMENT '推荐理由',
    confidence_score DECIMAL(3,2) COMMENT '置信度评分：0.00-1.00',
    user_feedback ENUM('accepted', 'rejected', 'ignored') COMMENT '用户反馈',
    is_clicked TINYINT DEFAULT 0 COMMENT '是否点击：0-否，1-是',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_recommendation_type (recommendation_type),
    INDEX idx_confidence_score (confidence_score),
    INDEX idx_created_at (created_at)
) COMMENT 'AI推荐记录表';

-- AI问答记录表
CREATE TABLE ai_qa_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '问答记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    article_id BIGINT COMMENT '相关文章ID',
    question_text TEXT NOT NULL COMMENT '用户问题',
    question_language ENUM('en', 'zh') NOT NULL COMMENT '问题语言',
    answer_text TEXT NOT NULL COMMENT 'AI回答',
    answer_language ENUM('en', 'zh') NOT NULL COMMENT '回答语言',
    context_info JSON COMMENT '上下文信息',
    response_time_ms INT COMMENT '响应时间（毫秒）',
    user_satisfaction TINYINT COMMENT '用户满意度：1-5',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES reading_articles(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_article_id (article_id),
    INDEX idx_question_language (question_language),
    INDEX idx_created_at (created_at)
) COMMENT 'AI问答记录表';

-- 语音评估记录表
CREATE TABLE speech_evaluation_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评估记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    content_type ENUM('word', 'sentence', 'paragraph') NOT NULL COMMENT '内容类型',
    content_text TEXT NOT NULL COMMENT '朗读内容',
    audio_url VARCHAR(500) NOT NULL COMMENT '用户录音URL',
    pronunciation_score DECIMAL(5,2) COMMENT '发音得分',
    fluency_score DECIMAL(5,2) COMMENT '流利度得分',
    accuracy_score DECIMAL(5,2) COMMENT '准确度得分',
    overall_score DECIMAL(5,2) COMMENT '综合得分',
    detailed_feedback JSON COMMENT '详细反馈',
    improvement_suggestions TEXT COMMENT '改进建议',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_content_type (content_type),
    INDEX idx_overall_score (overall_score),
    INDEX idx_created_at (created_at)
) COMMENT '语音评估记录表';

-- ========================================
-- 6. 社交功能模块
-- ========================================

-- 阅读挑战赛表
CREATE TABLE reading_challenges (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '挑战赛ID',
    challenge_name VARCHAR(100) NOT NULL COMMENT '挑战赛名称',
    description TEXT COMMENT '挑战赛描述',
    challenge_type ENUM('daily', 'weekly', 'monthly', 'custom') NOT NULL COMMENT '挑战类型',
    start_time TIMESTAMP NOT NULL COMMENT '开始时间',
    end_time TIMESTAMP NOT NULL COMMENT '结束时间',
    target_articles_count INT COMMENT '目标阅读文章数',
    target_words_count INT COMMENT '目标词汇数',
    target_study_time INT COMMENT '目标学习时长（分钟）',
    reward_points INT DEFAULT 0 COMMENT '奖励积分',
    participant_count INT DEFAULT 0 COMMENT '参与人数',
    status ENUM('upcoming', 'active', 'completed', 'cancelled') DEFAULT 'upcoming' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_challenge_type (challenge_type),
    INDEX idx_start_time (start_time),
    INDEX idx_status (status)
) COMMENT '阅读挑战赛表';

-- 用户挑战参与记录表
CREATE TABLE user_challenge_participations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '参与记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    challenge_id INT NOT NULL COMMENT '挑战赛ID',
    join_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '参与时间',
    articles_read INT DEFAULT 0 COMMENT '已读文章数',
    words_learned INT DEFAULT 0 COMMENT '已学词汇数',
    study_time_minutes INT DEFAULT 0 COMMENT '学习时长（分钟）',
    progress_percentage DECIMAL(5,2) DEFAULT 0.00 COMMENT '完成进度百分比',
    final_rank INT COMMENT '最终排名',
    is_completed TINYINT DEFAULT 0 COMMENT '是否完成：0-否，1-是',
    reward_received TINYINT DEFAULT 0 COMMENT '是否领取奖励：0-否，1-是',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (challenge_id) REFERENCES reading_challenges(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_challenge (user_id, challenge_id),
    INDEX idx_user_id (user_id),
    INDEX idx_challenge_id (challenge_id),
    INDEX idx_progress_percentage (progress_percentage)
) COMMENT '用户挑战参与记录表';

-- 用户每日打卡记录表
CREATE TABLE user_daily_checkins (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '打卡记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    checkin_date DATE NOT NULL COMMENT '打卡日期',
    study_time_minutes INT DEFAULT 0 COMMENT '学习时长（分钟）',
    words_learned INT DEFAULT 0 COMMENT '学习词汇数',
    articles_read INT DEFAULT 0 COMMENT '阅读文章数',
    points_earned INT DEFAULT 0 COMMENT '获得积分',
    is_continuous TINYINT DEFAULT 0 COMMENT '是否连续打卡：0-否，1-是',
    continuous_days INT DEFAULT 1 COMMENT '连续天数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_date (user_id, checkin_date),
    INDEX idx_user_id (user_id),
    INDEX idx_checkin_date (checkin_date),
    INDEX idx_continuous_days (continuous_days)
) COMMENT '用户每日打卡记录表';

-- ========================================
-- 7. 系统配置模块
-- ========================================

-- 系统配置表
CREATE TABLE system_configs (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '配置ID',
    config_key VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    config_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string' COMMENT '配置类型',
    description TEXT COMMENT '配置描述',
    is_editable TINYINT DEFAULT 1 COMMENT '是否可编辑：0-否，1-是',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_config_key (config_key)
) COMMENT '系统配置表';

-- 操作日志表
CREATE TABLE operation_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id BIGINT COMMENT '用户ID',
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型',
    operation_module VARCHAR(50) NOT NULL COMMENT '操作模块',
    operation_description TEXT COMMENT '操作描述',
    request_data JSON COMMENT '请求数据',
    response_data JSON COMMENT '响应数据',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    user_agent TEXT COMMENT '用户代理',
    execution_time_ms INT COMMENT '执行时间（毫秒）',
    status ENUM('success', 'failure', 'error') NOT NULL COMMENT '执行状态',
    error_message TEXT COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operation_module (operation_module),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) COMMENT '操作日志表';

-- ========================================
-- 8. 初始化数据
-- ========================================

-- 插入词库分类初始数据
INSERT INTO vocabulary_categories (category_code, category_name, description, target_level, sort_order) VALUES
('primary_basic', '小学基础词汇', '小学阶段必掌握的基础词汇', 'primary', 1),
('junior_core', '初中核心词汇', '初中阶段核心词汇', 'junior', 2),
('senior_essential', '高中必备词汇', '高中阶段必备词汇', 'senior', 3),
('cet4_standard', '大学英语四级', '大学英语四级标准词汇', 'cet4', 4),
('cet6_advanced', '大学英语六级', '大学英语六级高级词汇', 'cet6', 5),
('toefl_academic', '托福学术词汇', '托福考试学术词汇', 'toefl', 6),
('ielts_general', '雅思通用词汇', '雅思考试通用词汇', 'ielts', 7),
('business_professional', '商务专业词汇', '商务英语专业词汇', 'adult', 8);

-- 插入主题词包初始数据
INSERT INTO theme_word_packages (package_name, package_code, description, difficulty_level, target_audience) VALUES
('环境保护主题', 'environment', '环境保护相关词汇', 3, '中高级学习者'),
('科技创新主题', 'technology', '科技创新相关词汇', 4, '高级学习者'),
('商务办公主题', 'business', '商务办公相关词汇', 4, '职场人士'),
('医疗健康主题', 'health', '医疗健康相关词汇', 3, '中高级学习者'),
('旅游出行主题', 'travel', '旅游出行相关词汇', 2, '初中级学习者'),
('教育学习主题', 'education', '教育学习相关词汇', 3, '学生群体');

-- 插入系统配置初始数据
INSERT INTO system_configs (config_key, config_value, config_type, description) VALUES
('default_review_interval', '1', 'number', '默认复习间隔天数'),
('max_daily_new_words', '20', 'number', '每日最大新词学习数量'),
('ai_recommendation_enabled', 'true', 'boolean', '是否启用AI推荐功能'),
('speech_evaluation_enabled', 'true', 'boolean', '是否启用语音评估功能'),
('daily_checkin_points', '10', 'number', '每日打卡获得积分'),
('reading_speed_threshold', '200', 'number', '阅读速度阈值（词/分钟）'),
('vocabulary_mastery_threshold', '0.8', 'number', '词汇掌握度阈值'),
('ai_response_timeout', '5000', 'number', 'AI响应超时时间（毫秒）');

-- ========================================
-- 9. 创建视图
-- ========================================

-- 用户学习统计视图
CREATE VIEW user_learning_stats AS
SELECT 
    u.id as user_id,
    u.username,
    u.learning_level,
    up.total_study_days,
    up.continuous_study_days,
    up.total_study_time,
    up.vocabulary_mastered,
    up.reading_articles_count,
    COUNT(DISTINCT uvl.vocabulary_id) as words_in_progress,
    AVG(uvl.mastery_level) as avg_mastery_level,
    COUNT(DISTINCT urr.article_id) as articles_read,
    AVG(urr.comprehension_score) as avg_comprehension_score
FROM users u
LEFT JOIN user_profiles up ON u.id = up.user_id
LEFT JOIN user_vocabulary_learning uvl ON u.id = uvl.user_id
LEFT JOIN user_reading_records urr ON u.id = urr.user_id AND urr.reading_status = 'completed'
GROUP BY u.id;

-- 词汇学习进度视图
CREATE VIEW vocabulary_learning_progress AS
SELECT 
    v.id as vocabulary_id,
    v.word,
    v.difficulty_level,
    COUNT(uvl.user_id) as learner_count,
    AVG(uvl.mastery_level) as avg_mastery_level,
    SUM(CASE WHEN uvl.mastery_level >= 3 THEN 1 ELSE 0 END) as mastered_count,
    (SUM(CASE WHEN uvl.mastery_level >= 3 THEN 1 ELSE 0 END) / COUNT(uvl.user_id) * 100) as mastery_rate
FROM vocabularies v
LEFT JOIN user_vocabulary_learning uvl ON v.id = uvl.vocabulary_id
GROUP BY v.id;

-- 文章阅读统计视图
CREATE VIEW article_reading_stats AS
SELECT 
    ra.id as article_id,
    ra.title,
    ra.reading_level,
    ra.category,
    ra.word_count,
    COUNT(urr.user_id) as reader_count,
    AVG(urr.reading_time_seconds) as avg_reading_time,
    AVG(urr.reading_speed_wpm) as avg_reading_speed,
    AVG(urr.comprehension_score) as avg_comprehension_score,
    SUM(CASE WHEN urr.reading_status = 'completed' THEN 1 ELSE 0 END) as completion_count
FROM reading_articles ra
LEFT JOIN user_reading_records urr ON ra.id = urr.article_id
GROUP BY ra.id;

-- ========================================
-- 10. 创建存储过程
-- ========================================

DELIMITER //

-- 更新用户词汇掌握度的存储过程
CREATE PROCEDURE UpdateVocabularyMastery(
    IN p_user_id BIGINT,
    IN p_vocabulary_id BIGINT,
    IN p_is_correct TINYINT
)
BEGIN
    DECLARE v_current_level TINYINT DEFAULT 0;
    DECLARE v_learning_count INT DEFAULT 0;
    DECLARE v_correct_count INT DEFAULT 0;
    DECLARE v_wrong_count INT DEFAULT 0;
    DECLARE v_new_level TINYINT;
    DECLARE v_next_review TIMESTAMP;
    DECLARE v_interval_days INT;
    
    -- 获取当前学习状态
    SELECT mastery_level, learning_count, correct_count, wrong_count
    INTO v_current_level, v_learning_count, v_correct_count, v_wrong_count
    FROM user_vocabulary_learning
    WHERE user_id = p_user_id AND vocabulary_id = p_vocabulary_id;
    
    -- 更新计数
    SET v_learning_count = v_learning_count + 1;
    IF p_is_correct = 1 THEN
        SET v_correct_count = v_correct_count + 1;
    ELSE
        SET v_wrong_count = v_wrong_count + 1;
    END IF;
    
    -- 计算新的掌握度
    IF v_correct_count = 0 THEN
        SET v_new_level = 0;
    ELSE
        SET v_new_level = LEAST(4, FLOOR((v_correct_count / v_learning_count) * 5));
    END IF;
    
    -- 计算下次复习时间
    SET v_interval_days = POWER(2, v_new_level);
    SET v_next_review = DATE_ADD(NOW(), INTERVAL v_interval_days DAY);
    
    -- 更新或插入记录
    INSERT INTO user_vocabulary_learning (
        user_id, vocabulary_id, mastery_level, learning_count, 
        correct_count, wrong_count, last_review_time, next_review_time, 
        review_interval_days, last_learned_at
    ) VALUES (
        p_user_id, p_vocabulary_id, v_new_level, v_learning_count,
        v_correct_count, v_wrong_count, NOW(), v_next_review,
        v_interval_days, NOW()
    ) ON DUPLICATE KEY UPDATE
        mastery_level = v_new_level,
        learning_count = v_learning_count,
        correct_count = v_correct_count,
        wrong_count = v_wrong_count,
        last_review_time = NOW(),
        next_review_time = v_next_review,
        review_interval_days = v_interval_days,
        last_learned_at = NOW();
END //

-- 获取用户待复习词汇的存储过程
CREATE PROCEDURE GetUserReviewVocabularies(
    IN p_user_id BIGINT,
    IN p_limit INT
)
BEGIN
    SELECT 
        v.id,
        v.word,
        v.phonetic_us,
        v.definition_cn,
        uvl.mastery_level,
        uvl.next_review_time
    FROM user_vocabulary_learning uvl
    JOIN vocabularies v ON uvl.vocabulary_id = v.id
    WHERE uvl.user_id = p_user_id 
        AND uvl.next_review_time <= NOW()
        AND uvl.mastery_level < 4
    ORDER BY uvl.next_review_time ASC
    LIMIT p_limit;
END //

DELIMITER ;

-- ========================================
-- 11. 创建索引优化
-- ========================================

-- 为高频查询创建复合索引
CREATE INDEX idx_user_vocabulary_review ON user_vocabulary_learning(user_id, next_review_time, mastery_level);
CREATE INDEX idx_article_level_category ON reading_articles(reading_level, category, status);
CREATE INDEX idx_user_reading_status ON user_reading_records(user_id, reading_status, completed_at);
CREATE INDEX idx_test_user_type_time ON user_test_records(user_id, test_type, created_at);
CREATE INDEX idx_recommendation_user_type ON ai_recommendations(user_id, recommendation_type, created_at);

-- ========================================
-- 数据库表结构设计完成
-- ========================================

/*
设计说明：

1. 用户管理模块：
   - users: 用户基础信息
   - user_profiles: 用户学习档案和统计数据

2. 词汇管理模块：
   - vocabulary_categories: 词库分类
   - vocabularies: 词汇主表
   - vocabulary_examples: 例句
   - vocabulary_relations: 词汇关系（同义词、反义词等）
   - theme_word_packages: 主题词包

3. 阅读内容模块：
   - reading_articles: 阅读文章
   - article_paragraphs: 文章段落
   - reading_questions: 阅读理解题目

4. 学习记录模块：
   - user_vocabulary_learning: 词汇学习记录（支持艾宾浩斯记忆曲线）
   - user_reading_records: 阅读记录
   - user_test_records: 测试记录
   - user_study_sessions: 学习会话记录

5. AI功能模块：
   - ai_recommendations: AI推荐记录
   - ai_qa_records: AI问答记录
   - speech_evaluation_records: 语音评估记录

6. 社交功能模块：
   - reading_challenges: 阅读挑战赛
   - user_challenge_participations: 用户挑战参与记录
   - user_daily_checkins: 每日打卡记录

7. 系统配置模块：
   - system_configs: 系统配置
   - operation_logs: 操作日志

8. 性能优化：
   - 创建了多个视图用于常用统计查询
   - 创建了存储过程处理复杂业务逻辑
   - 添加了复合索引优化查询性能

9. 数据完整性：
   - 使用外键约束保证数据一致性
   - 添加了唯一约束防止重复数据
   - 使用适当的数据类型和长度限制

10. 扩展性：
    - 使用JSON字段存储灵活的配置数据
    - 预留了足够的字段用于功能扩展
    - 支持多种学习模式和测试类型
*/