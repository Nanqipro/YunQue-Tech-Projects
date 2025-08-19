-- AI英语学习平台数据库初始化脚本
-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS ai_english_learning CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ai_english_learning;

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    avatar_url VARCHAR(255),
    bio TEXT,
    level VARCHAR(20) DEFAULT 'BEGINNER',
    total_points INT DEFAULT 0,
    streak_days INT DEFAULT 0,
    last_login_date DATETIME,
    is_active BOOLEAN DEFAULT TRUE,
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_level (level)
);

-- 词汇表
CREATE TABLE IF NOT EXISTS vocabularies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    word VARCHAR(100) NOT NULL UNIQUE,
    phonetic_us VARCHAR(100),
    phonetic_uk VARCHAR(100),
    audio_us_url VARCHAR(255),
    audio_uk_url VARCHAR(255),
    word_type VARCHAR(20) NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL,
    frequency_rank INT,
    etymology TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_word (word),
    INDEX idx_word_type (word_type),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_frequency_rank (frequency_rank)
);

-- 词汇释义表
CREATE TABLE IF NOT EXISTS vocabulary_definitions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vocabulary_id BIGINT NOT NULL,
    part_of_speech VARCHAR(20),
    definition TEXT NOT NULL,
    example_sentence TEXT,
    chinese_translation VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE,
    INDEX idx_vocabulary_id (vocabulary_id)
);

-- 文章表
CREATE TABLE IF NOT EXISTS articles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content LONGTEXT NOT NULL,
    summary TEXT,
    author VARCHAR(100),
    source_url VARCHAR(255),
    cover_image_url VARCHAR(255),
    category VARCHAR(50) NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL,
    estimated_reading_time INT,
    word_count INT,
    tags JSON,
    keywords JSON,
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    favorite_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'PUBLISHED',
    is_featured BOOLEAN DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    published_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_status (status),
    INDEX idx_published_at (published_at),
    INDEX idx_is_featured (is_featured)
);

-- 学习会话表
CREATE TABLE IF NOT EXISTS learning_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_type VARCHAR(50) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    duration_minutes INT,
    points_earned INT DEFAULT 0,
    words_learned INT DEFAULT 0,
    accuracy_rate DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_session_type (session_type),
    INDEX idx_start_time (start_time)
);

-- 挑战赛表
CREATE TABLE IF NOT EXISTS challenges (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    challenge_type VARCHAR(50) NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    max_participants INT,
    current_participants INT DEFAULT 0,
    reward_points INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'UPCOMING',
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_challenge_type (challenge_type),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_start_date (start_date),
    INDEX idx_status (status)
);

-- 挑战赛参与记录表
CREATE TABLE IF NOT EXISTS challenge_participations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    challenge_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    joined_at DATETIME NOT NULL,
    completed_at DATETIME,
    score INT DEFAULT 0,
    rank_position INT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_challenge_user (challenge_id, user_id),
    INDEX idx_challenge_id (challenge_id),
    INDEX idx_user_id (user_id),
    INDEX idx_score (score)
);

-- 打卡表
CREATE TABLE IF NOT EXISTS check_ins (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    check_in_type VARCHAR(50) NOT NULL,
    target_value INT NOT NULL,
    reward_points INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_check_in_type (check_in_type),
    INDEX idx_is_active (is_active)
);

-- 打卡记录表
CREATE TABLE IF NOT EXISTS check_in_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    check_in_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    check_in_date DATE NOT NULL,
    actual_value INT NOT NULL,
    points_earned INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'COMPLETED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (check_in_id) REFERENCES check_ins(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_checkin_user_date (check_in_id, user_id, check_in_date),
    INDEX idx_check_in_id (check_in_id),
    INDEX idx_user_id (user_id),
    INDEX idx_check_in_date (check_in_date)
);

-- 插入示例数据

-- 示例用户
INSERT INTO users (username, email, password, first_name, last_name, level) VALUES
('admin', 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Admin', 'User', 'ADVANCED'),
('testuser', 'test@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Test', 'User', 'BEGINNER');

-- 示例词汇
INSERT INTO vocabularies (word, phonetic_us, phonetic_uk, word_type, difficulty_level, frequency_rank) VALUES
('hello', '/həˈloʊ/', '/həˈləʊ/', 'INTERJECTION', 'BEGINNER', 100),
('world', '/wɜːrld/', '/wɜːld/', 'NOUN', 'BEGINNER', 200),
('example', '/ɪɡˈzæmpəl/', '/ɪɡˈzɑːmpəl/', 'NOUN', 'INTERMEDIATE', 500),
('challenge', '/ˈtʃælɪndʒ/', '/ˈtʃælɪndʒ/', 'NOUN', 'INTERMEDIATE', 800),
('sophisticated', '/səˈfɪstɪkeɪtɪd/', '/səˈfɪstɪkeɪtɪd/', 'ADJECTIVE', 'ADVANCED', 2000);

-- 示例词汇释义
INSERT INTO vocabulary_definitions (vocabulary_id, part_of_speech, definition, example_sentence, chinese_translation) VALUES
(1, 'interjection', 'Used as a greeting or to begin a phone conversation', 'Hello, how are you?', '你好'),
(2, 'noun', 'The earth, together with all of its countries and peoples', 'The world is a beautiful place', '世界'),
(3, 'noun', 'A thing characteristic of its kind or illustrating a general rule', 'This is a good example', '例子'),
(4, 'noun', 'A call to take part in a contest or competition', 'I accept your challenge', '挑战'),
(5, 'adjective', 'Having great knowledge or experience', 'A sophisticated analysis', '复杂的，精密的');

-- 示例文章
INSERT INTO articles (title, content, summary, author, category, difficulty_level, estimated_reading_time, word_count, status, published_at) VALUES
('Welcome to English Learning', 'This is your first article in our English learning platform. Learning English can be fun and rewarding...', 'An introduction to English learning', 'System', 'EDUCATION', 'BEGINNER', 5, 150, 'PUBLISHED', NOW()),
('Advanced Grammar Tips', 'Understanding complex grammatical structures is essential for advanced English learners...', 'Tips for mastering advanced grammar', 'Expert Teacher', 'GRAMMAR', 'ADVANCED', 15, 800, 'PUBLISHED', NOW());

-- 示例挑战赛
INSERT INTO challenges (title, description, challenge_type, difficulty_level, start_date, end_date, max_participants, reward_points, status) VALUES
('Daily Vocabulary Challenge', 'Learn 10 new words every day for a week', 'VOCABULARY', 'BEGINNER', DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 8 DAY), 100, 500, 'UPCOMING'),
('Reading Comprehension Marathon', 'Read and answer questions about 5 articles', 'READING', 'INTERMEDIATE', DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 10 DAY), 50, 1000, 'UPCOMING');

-- 示例打卡任务
INSERT INTO check_ins (name, description, check_in_type, target_value, reward_points) VALUES
('Daily Study', 'Study for at least 30 minutes every day', 'STUDY_TIME', 30, 50),
('Vocabulary Practice', 'Learn at least 5 new words', 'VOCABULARY_COUNT', 5, 30),
('Reading Practice', 'Read at least 1 article', 'ARTICLE_COUNT', 1, 40);

COMMIT;