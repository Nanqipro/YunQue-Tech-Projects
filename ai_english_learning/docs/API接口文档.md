# AI英语学习平台 - API接口文档

## 目录
- [1. 接口概述](#1-接口概述)
- [2. 认证与授权](#2-认证与授权)
- [3. 用户管理模块](#3-用户管理模块)
- [4. 词汇学习模块](#4-词汇学习模块)
- [5. 听力训练模块](#5-听力训练模块)
- [6. 阅读理解模块](#6-阅读理解模块)
- [7. 写作练习模块](#7-写作练习模块)
- [8. 口语练习模块](#8-口语练习模块)
- [9. AI智能助手模块](#9-ai智能助手模块)
- [10. 数据统计与分析模块](#10-数据统计与分析模块)
- [11. 系统配置模块](#11-系统配置模块)
- [12. 错误码说明](#12-错误码说明)

## 1. 接口概述

### 1.1 基础信息
- **API版本**: v1.0
- **基础URL**: `https://api.aienglish.com/v1`
- **协议**: HTTPS
- **数据格式**: JSON
- **字符编码**: UTF-8

### 1.2 通用响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### 1.3 分页格式
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total": 100,
      "total_pages": 5
    }
  },
  "timestamp": "2024-01-01T12:00:00Z"
}
```

## 2. 认证与授权

### 2.1 用户注册
**POST** `/auth/register`

**请求参数:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "confirm_password": "string",
  "phone": "string",
  "birth_date": "2000-01-01",
  "gender": "male|female|other",
  "learning_level": "beginner|intermediate|advanced"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "user_id": "uuid",
    "username": "string",
    "email": "string",
    "access_token": "jwt_token",
    "refresh_token": "jwt_token",
    "expires_in": 3600
  }
}
```

### 2.2 用户登录
**POST** `/auth/login`

**请求参数:**
```json
{
  "email": "string",
  "password": "string"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "user_id": "uuid",
    "username": "string",
    "email": "string",
    "access_token": "jwt_token",
    "refresh_token": "jwt_token",
    "expires_in": 3600,
    "profile": {
      "avatar_url": "string",
      "learning_level": "string",
      "total_words_learned": 1500,
      "consecutive_days": 30
    }
  }
}
```

### 2.3 刷新Token
**POST** `/auth/refresh`

**请求参数:**
```json
{
  "refresh_token": "jwt_token"
}
```

### 2.4 用户登出
**POST** `/auth/logout`

**请求头:**
```
Authorization: Bearer {access_token}
```

## 3. 用户管理模块

### 3.1 获取用户信息
**GET** `/users/profile`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "user_id": "uuid",
    "username": "string",
    "email": "string",
    "avatar_url": "string",
    "phone": "string",
    "birth_date": "2000-01-01",
    "gender": "male",
    "learning_level": "intermediate",
    "bio": "string",
    "created_at": "2024-01-01T12:00:00Z",
    "updated_at": "2024-01-01T12:00:00Z",
    "learning_stats": {
      "total_words_learned": 1500,
      "consecutive_days": 30,
      "total_study_time": 7200,
      "average_score": 85.5,
      "level_progress": {
        "current_level": 5,
        "experience_points": 2500,
        "next_level_points": 3000
      }
    }
  }
}
```

### 3.2 更新用户信息
**PUT** `/users/profile`

**请求参数:**
```json
{
  "username": "string",
  "avatar_url": "string",
  "phone": "string",
  "birth_date": "2000-01-01",
  "gender": "male|female|other",
  "learning_level": "beginner|intermediate|advanced",
  "bio": "string"
}
```

### 3.3 获取学习统计
**GET** `/users/stats`

**查询参数:**
- `period`: `daily|weekly|monthly|yearly`
- `start_date`: `2024-01-01`
- `end_date`: `2024-01-31`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "overview": {
      "total_words_learned": 1500,
      "consecutive_days": 30,
      "total_study_time": 7200,
      "average_score": 85.5
    },
    "skill_progress": {
      "vocabulary": 85,
      "listening": 78,
      "reading": 82,
      "writing": 75,
      "speaking": 70
    },
    "daily_stats": [
      {
        "date": "2024-01-01",
        "words_learned": 50,
        "study_time": 120,
        "exercises_completed": 10,
        "average_score": 88
      }
    ]
  }
}
```

### 3.4 获取学习进度
**GET** `/users/progress`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "vocabulary_books": [
      {
        "book_id": "uuid",
        "book_name": "托福核心词汇",
        "total_words": 5000,
        "learned_words": 1200,
        "progress_percentage": 24.0,
        "mastery_level": "intermediate"
      }
    ],
    "skill_levels": {
      "vocabulary": {
        "level": 5,
        "progress": 75,
        "next_level_requirement": 1800
      },
      "listening": {
        "level": 4,
        "progress": 60,
        "next_level_requirement": 1500
      }
    }
  }
}
```

## 4. 词汇学习模块

### 4.1 获取词库列表
**GET** `/vocabulary/books`

**查询参数:**
- `category`: `basic|exam|professional|daily`
- `level`: `elementary|middle|high|college|professional`
- `page`: `1`
- `page_size`: `20`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "book_id": "uuid",
        "book_name": "托福核心词汇",
        "description": "托福考试必备词汇",
        "category": "exam",
        "level": "college",
        "total_words": 5000,
        "difficulty_level": 7,
        "estimated_days": 100,
        "cover_image": "string",
        "is_subscribed": true,
        "progress": {
          "learned_words": 1200,
          "progress_percentage": 24.0
        }
      }
    ],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total": 50,
      "total_pages": 3
    }
  }
}
```

### 4.2 词汇量测试
**POST** `/vocabulary/assessment/start`

**请求参数:**
```json
{
  "test_type": "quick|comprehensive|specific",
  "target_book_id": "uuid",
  "estimated_time": 20
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "测试开始",
  "data": {
    "session_id": "uuid",
    "test_type": "quick",
    "estimated_questions": 50,
    "time_limit": 1200,
    "first_question": {
      "question_id": "uuid",
      "word": "abandon",
      "options": [
        "放弃",
        "获得",
        "保持",
        "继续"
      ],
      "question_type": "multiple_choice"
    }
  }
}
```

### 4.3 提交测试答案
**POST** `/vocabulary/assessment/answer`

**请求参数:**
```json
{
  "session_id": "uuid",
  "question_id": "uuid",
  "answer": "放弃",
  "response_time": 3.5
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "答案已提交",
  "data": {
    "is_correct": true,
    "next_question": {
      "question_id": "uuid",
      "word": "ability",
      "options": [
        "能力",
        "责任",
        "机会",
        "困难"
      ],
      "question_type": "multiple_choice"
    },
    "progress": {
      "current_question": 2,
      "total_questions": 50,
      "correct_answers": 1
    }
  }
}
```

### 4.4 获取测试结果
**GET** `/vocabulary/assessment/{session_id}/result`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "session_id": "uuid",
    "vocabulary_level": "intermediate",
    "estimated_vocabulary": 4500,
    "accuracy_rate": 78.5,
    "level_breakdown": {
      "elementary": 95,
      "middle_school": 88,
      "high_school": 75,
      "college": 65,
      "professional": 45
    },
    "weak_areas": [
      "学术词汇",
      "商务英语",
      "科技词汇"
    ],
    "recommendations": [
      {
        "book_id": "uuid",
        "book_name": "大学英语四级词汇",
        "reason": "适合您当前水平的词汇书"
      }
    ],
    "detailed_analysis": {
      "total_questions": 50,
      "correct_answers": 39,
      "average_response_time": 4.2,
      "difficulty_distribution": {
        "easy": {"total": 15, "correct": 14},
        "medium": {"total": 20, "correct": 16},
        "hard": {"total": 15, "correct": 9}
      }
    }
  }
}
```

### 4.5 获取单词详情
**GET** `/vocabulary/words/{word_id}`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "word_id": "uuid",
    "word": "abandon",
    "phonetic": {
      "us": "/əˈbændən/",
      "uk": "/əˈbændən/"
    },
    "pronunciations": {
      "us_audio": "https://audio.com/abandon_us.mp3",
      "uk_audio": "https://audio.com/abandon_uk.mp3"
    },
    "definitions": [
      {
        "part_of_speech": "verb",
        "definition_en": "to leave completely and finally",
        "definition_cn": "放弃；抛弃",
        "examples": [
          {
            "sentence_en": "He abandoned his car in the snow.",
            "sentence_cn": "他把车丢弃在雪地里。",
            "audio_url": "https://audio.com/example1.mp3"
          }
        ]
      }
    ],
    "etymology": {
      "origin": "Middle English",
      "root_words": ["a-", "bandon"],
      "description": "来自古法语 abandoner"
    },
    "related_words": {
      "synonyms": ["desert", "forsake", "leave"],
      "antonyms": ["keep", "maintain", "continue"],
      "word_family": ["abandonment", "abandoned"]
    },
    "images": [
      {
        "image_url": "https://images.com/abandon1.jpg",
        "description": "abandoned building",
        "image_type": "scene"
      }
    ],
    "difficulty_level": 6,
    "frequency_rank": 2500,
    "learning_status": {
      "is_learned": true,
      "mastery_level": "familiar",
      "last_reviewed": "2024-01-01T12:00:00Z",
      "next_review": "2024-01-03T12:00:00Z",
      "review_count": 5
    }
  }
}
```

### 4.6 开始学习单词
**POST** `/vocabulary/study/start`

**请求参数:**
```json
{
  "book_id": "uuid",
  "study_mode": "new|review|mixed",
  "word_count": 20,
  "study_type": "recognition|recall|context"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "学习开始",
  "data": {
    "session_id": "uuid",
    "study_mode": "new",
    "total_words": 20,
    "current_word": {
      "word_id": "uuid",
      "word": "abandon",
      "show_word_only": true,
      "step": 1,
      "total_steps": 4
    },
    "progress": {
      "current_index": 1,
      "total_words": 20
    }
  }
}
```

### 4.7 学习单词操作
**POST** `/vocabulary/study/action`

**请求参数:**
```json
{
  "session_id": "uuid",
  "word_id": "uuid",
  "action": "next_step|know|vague|unknown|play_audio",
  "knowledge_level": "know|vague|unknown"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "current_word": {
      "word_id": "uuid",
      "word": "abandon",
      "step": 2,
      "show_pronunciation": true,
      "phonetic": "/əˈbændən/",
      "audio_url": "https://audio.com/abandon_us.mp3"
    },
    "next_word": {
      "word_id": "uuid",
      "word": "ability"
    }
  }
}
```

### 4.8 单词测试
**POST** `/vocabulary/test/start`

**请求参数:**
```json
{
  "book_id": "uuid",
  "test_type": "spelling|multiple_choice|fill_blank|translation",
  "word_count": 10,
  "difficulty": "easy|medium|hard"
}
```

### 4.9 提交测试答案
**POST** `/vocabulary/test/submit`

**请求参数:**
```json
{
  "session_id": "uuid",
  "answers": [
    {
      "question_id": "uuid",
      "answer": "abandon",
      "response_time": 5.2
    }
  ]
}
```

## 5. 听力训练模块

### 5.1 获取听力材料列表
**GET** `/listening/materials`

**查询参数:**
- `level`: `beginner|intermediate|advanced`
- `category`: `daily|news|academic|business|entertainment`
- `duration`: `short|medium|long`
- `page`: `1`
- `page_size`: `20`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "material_id": "uuid",
        "title": "Daily Conversation: At the Restaurant",
        "description": "Learn common phrases used in restaurants",
        "level": "intermediate",
        "category": "daily",
        "duration": 180,
        "audio_url": "https://audio.com/restaurant.mp3",
        "thumbnail": "https://images.com/restaurant.jpg",
        "transcript_available": true,
        "exercises_count": 5,
        "difficulty_score": 6.5,
        "tags": ["restaurant", "food", "ordering"],
        "created_at": "2024-01-01T12:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total": 150,
      "total_pages": 8
    }
  }
}
```

### 5.2 获取听力材料详情
**GET** `/listening/materials/{material_id}`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "material_id": "uuid",
    "title": "Daily Conversation: At the Restaurant",
    "description": "Learn common phrases used in restaurants",
    "level": "intermediate",
    "category": "daily",
    "duration": 180,
    "audio_url": "https://audio.com/restaurant.mp3",
    "transcript": {
      "full_text": "Welcome to our restaurant. How many people?",
      "segments": [
        {
          "start_time": 0.0,
          "end_time": 2.5,
          "text": "Welcome to our restaurant.",
          "speaker": "Waiter"
        },
        {
          "start_time": 2.5,
          "end_time": 4.0,
          "text": "How many people?",
          "speaker": "Waiter"
        }
      ]
    },
    "vocabulary_highlights": [
      {
        "word": "restaurant",
        "definition": "a place where meals are prepared and served",
        "timestamp": 1.2
      }
    ],
    "exercises": [
      {
        "exercise_id": "uuid",
        "type": "comprehension",
        "title": "Understanding the Conversation"
      }
    ]
  }
}
```

### 5.3 开始听力练习
**POST** `/listening/practice/start`

**请求参数:**
```json
{
  "material_id": "uuid",
  "practice_mode": "full|segment|repeat",
  "show_transcript": false,
  "playback_speed": 1.0
}
```

### 5.4 听力理解测试
**POST** `/listening/test/start`

**请求参数:**
```json
{
  "material_id": "uuid",
  "test_type": "comprehension|dictation|fill_blank"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "测试开始",
  "data": {
    "session_id": "uuid",
    "test_type": "comprehension",
    "questions": [
      {
        "question_id": "uuid",
        "type": "multiple_choice",
        "question": "What does the waiter ask first?",
        "options": [
          "What would you like to drink?",
          "How many people?",
          "Do you have a reservation?",
          "What's your name?"
        ],
        "audio_segment": {
          "start_time": 0.0,
          "end_time": 4.0,
          "audio_url": "https://audio.com/segment1.mp3"
        }
      }
    ]
  }
}
```

### 5.5 提交听力测试答案
**POST** `/listening/test/submit`

**请求参数:**
```json
{
  "session_id": "uuid",
  "answers": [
    {
      "question_id": "uuid",
      "answer": "How many people?",
      "response_time": 8.5
    }
  ]
}
```

## 6. 阅读理解模块

### 6.1 获取阅读材料列表
**GET** `/reading/materials`

**查询参数:**
- `level`: `beginner|intermediate|advanced`
- `category`: `news|literature|science|business|culture`
- `length`: `short|medium|long`
- `page`: `1`
- `page_size`: `20`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "article_id": "uuid",
        "title": "The Future of Artificial Intelligence",
        "summary": "An exploration of AI's impact on society",
        "level": "advanced",
        "category": "science",
        "word_count": 800,
        "reading_time": 5,
        "difficulty_score": 8.2,
        "thumbnail": "https://images.com/ai.jpg",
        "tags": ["technology", "AI", "future"],
        "published_at": "2024-01-01T12:00:00Z",
        "source": "Tech Magazine",
        "has_audio": true
      }
    ],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total": 200,
      "total_pages": 10
    }
  }
}
```

### 6.2 获取阅读材料详情
**GET** `/reading/materials/{article_id}`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "article_id": "uuid",
    "title": "The Future of Artificial Intelligence",
    "content": "Artificial intelligence is rapidly transforming...",
    "paragraphs": [
      {
        "paragraph_id": "uuid",
        "content": "Artificial intelligence is rapidly transforming our world.",
        "order": 1,
        "key_vocabulary": [
          {
            "word": "artificial",
            "definition": "made by humans, not natural",
            "position": 0
          }
        ]
      }
    ],
    "metadata": {
      "level": "advanced",
      "category": "science",
      "word_count": 800,
      "reading_time": 5,
      "difficulty_score": 8.2,
      "source": "Tech Magazine",
      "published_at": "2024-01-01T12:00:00Z"
    },
    "audio_url": "https://audio.com/ai_article.mp3",
    "comprehension_questions": [
      {
        "question_id": "uuid",
        "type": "multiple_choice",
        "question": "What is the main topic of this article?",
        "options": [
          "The history of AI",
          "The future impact of AI",
          "AI programming languages",
          "AI hardware requirements"
        ]
      }
    ]
  }
}
```

### 6.3 开始阅读练习
**POST** `/reading/practice/start`

**请求参数:**
```json
{
  "article_id": "uuid",
  "reading_mode": "guided|free|timed",
  "enable_ai_assistant": true,
  "show_vocabulary_hints": true
}
```

### 6.4 AI阅读助手提问
**POST** `/reading/ai-assistant/ask`

**请求参数:**
```json
{
  "article_id": "uuid",
  "question": "What does this paragraph mean?",
  "paragraph_id": "uuid",
  "context": "selected text"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "answer": "This paragraph explains how AI is changing various industries...",
    "explanation_type": "summary",
    "related_vocabulary": [
      {
        "word": "transform",
        "definition": "to change completely",
        "example": "AI will transform the way we work."
      }
    ],
    "follow_up_questions": [
      "Would you like me to explain any specific terms?",
      "Do you want to know more about AI applications?"
    ]
  }
}
```

### 6.5 阅读理解测试
**POST** `/reading/test/start`

**请求参数:**
```json
{
  "article_id": "uuid",
  "test_type": "comprehension|vocabulary|summary"
}
```

## 7. 写作练习模块

### 7.1 获取写作任务列表
**GET** `/writing/tasks`

**查询参数:**
- `type`: `translation|topic|exam|grammar`
- `level`: `beginner|intermediate|advanced`
- `category`: `daily|academic|business|creative`
- `page`: `1`
- `page_size`: `20`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "task_id": "uuid",
        "title": "Describe Your Ideal Vacation",
        "description": "Write about your dream vacation destination",
        "type": "topic",
        "level": "intermediate",
        "category": "daily",
        "estimated_time": 30,
        "word_limit": {"min": 150, "max": 300},
        "requirements": [
          "Use at least 3 different tenses",
          "Include descriptive adjectives",
          "Organize into clear paragraphs"
        ],
        "tags": ["travel", "description", "personal"]
      }
    ],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

### 7.2 获取写作任务详情
**GET** `/writing/tasks/{task_id}`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "task_id": "uuid",
    "title": "Describe Your Ideal Vacation",
    "description": "Write about your dream vacation destination and explain why it appeals to you.",
    "type": "topic",
    "level": "intermediate",
    "category": "daily",
    "estimated_time": 30,
    "word_limit": {"min": 150, "max": 300},
    "requirements": [
      "Use at least 3 different tenses",
      "Include descriptive adjectives",
      "Organize into clear paragraphs"
    ],
    "prompt": "Think about a place you've always wanted to visit. Describe this destination in detail, including what you would do there, what makes it special, and why it's your ideal vacation spot.",
    "sample_response": "My ideal vacation would be...",
    "vocabulary_suggestions": [
      {
        "word": "breathtaking",
        "definition": "extremely beautiful or amazing",
        "example": "The view from the mountain was breathtaking."
      }
    ],
    "grammar_focus": [
      "Future tense (would, will)",
      "Descriptive adjectives",
      "Conditional sentences"
    ]
  }
}
```

### 7.3 开始写作练习
**POST** `/writing/practice/start`

**请求参数:**
```json
{
  "task_id": "uuid",
  "practice_mode": "guided|free|timed",
  "enable_ai_assistance": true,
  "auto_save": true
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "写作练习开始",
  "data": {
    "session_id": "uuid",
    "task_id": "uuid",
    "start_time": "2024-01-01T12:00:00Z",
    "time_limit": 1800,
    "current_draft": "",
    "word_count": 0,
    "suggestions": {
      "opening_sentences": [
        "My dream vacation destination is...",
        "If I could travel anywhere in the world..."
      ]
    }
  }
}
```

### 7.4 保存写作草稿
**POST** `/writing/practice/save`

**请求参数:**
```json
{
  "session_id": "uuid",
  "content": "My ideal vacation would be to visit Japan...",
  "auto_save": true
}
```

### 7.5 AI写作助手
**POST** `/writing/ai-assistant/help`

**请求参数:**
```json
{
  "session_id": "uuid",
  "request_type": "grammar_check|vocabulary_suggestion|structure_advice|content_idea",
  "content": "My ideal vacation would be to visit Japan because it have beautiful culture.",
  "specific_question": "How can I improve this sentence?"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "request_type": "grammar_check",
    "corrections": [
      {
        "original": "it have beautiful culture",
        "corrected": "it has a beautiful culture",
        "error_type": "subject_verb_agreement",
        "explanation": "Use 'has' with third person singular 'it', and add article 'a' before 'beautiful culture'"
      }
    ],
    "vocabulary_suggestions": [
      {
        "word": "fascinating",
        "replacement_for": "beautiful",
        "reason": "More specific and sophisticated"
      }
    ],
    "structure_advice": "Consider adding specific examples of Japanese culture that interest you.",
    "improved_version": "My ideal vacation would be to visit Japan because it has a fascinating culture."
  }
}
```

### 7.6 提交写作作品
**POST** `/writing/practice/submit`

**请求参数:**
```json
{
  "session_id": "uuid",
  "final_content": "My ideal vacation would be to visit Japan...",
  "request_feedback": true
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "作品提交成功",
  "data": {
    "submission_id": "uuid",
    "submitted_at": "2024-01-01T12:30:00Z",
    "word_count": 245,
    "estimated_score": 85,
    "feedback": {
      "overall_score": 85,
      "criteria_scores": {
        "grammar": 88,
        "vocabulary": 82,
        "structure": 87,
        "content": 84,
        "fluency": 86
      },
      "strengths": [
        "Good use of descriptive language",
        "Clear paragraph structure",
        "Appropriate use of different tenses"
      ],
      "areas_for_improvement": [
        "Consider using more varied sentence structures",
        "Add more specific details to support your points"
      ],
      "detailed_feedback": {
        "grammar_errors": [
          {
            "sentence": "Japan have many temples.",
            "error": "Subject-verb disagreement",
            "correction": "Japan has many temples.",
            "explanation": "Use 'has' with singular subject 'Japan'"
          }
        ],
        "vocabulary_suggestions": [
          {
            "original": "very beautiful",
            "suggested": "stunning, breathtaking, magnificent",
            "reason": "More sophisticated vocabulary"
          }
        ]
      }
    }
  }
}
```

### 7.7 中译英练习
**POST** `/writing/translation/start`

**请求参数:**
```json
{
  "difficulty": "beginner|intermediate|advanced",
  "topic": "daily|business|academic|news",
  "sentence_count": 10
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "翻译练习开始",
  "data": {
    "session_id": "uuid",
    "sentences": [
      {
        "sentence_id": "uuid",
        "chinese_text": "我每天早上七点起床。",
        "difficulty": "beginner",
        "key_vocabulary": ["起床", "每天", "早上"],
        "grammar_points": ["时间表达", "日常动作"]
      }
    ]
  }
}
```

### 7.8 提交翻译答案
**POST** `/writing/translation/submit`

**请求参数:**
```json
{
  "session_id": "uuid",
  "translations": [
    {
      "sentence_id": "uuid",
      "translation": "I get up at seven o'clock every morning."
    }
  ]
}
```

## 8. 口语练习模块

### 8.1 获取对话场景列表
**GET** `/speaking/scenarios`

**查询参数:**
- `category`: `daily|business|academic|travel|social`
- `level`: `beginner|intermediate|advanced`
- `duration`: `short|medium|long`
- `page`: `1`
- `page_size`: `20`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "scenario_id": "uuid",
        "title": "Ordering Food at a Restaurant",
        "description": "Practice ordering food and drinks",
        "category": "daily",
        "level": "intermediate",
        "estimated_duration": 10,
        "thumbnail": "https://images.com/restaurant.jpg",
        "key_phrases": [
          "I'd like to order...",
          "Could I have...",
          "What do you recommend?"
        ],
        "learning_objectives": [
          "Learn restaurant vocabulary",
          "Practice polite requests",
          "Understand menu descriptions"
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total": 80,
      "total_pages": 4
    }
  }
}
```

### 8.2 开始AI对话练习
**POST** `/speaking/conversation/start`

**请求参数:**
```json
{
  "scenario_id": "uuid",
  "ai_personality": "friendly|professional|casual",
  "difficulty_level": "beginner|intermediate|advanced",
  "enable_pronunciation_feedback": true
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "对话开始",
  "data": {
    "session_id": "uuid",
    "scenario": {
      "title": "Ordering Food at a Restaurant",
      "setting": "You are at a restaurant and the waiter is ready to take your order."
    },
    "ai_introduction": {
      "text": "Good evening! Welcome to our restaurant. How many people will be dining tonight?",
      "audio_url": "https://audio.com/intro.mp3"
    },
    "suggested_responses": [
      "Table for two, please.",
      "Just one person.",
      "We have a reservation for four."
    ],
    "conversation_tips": [
      "Speak clearly and at a moderate pace",
      "Don't worry about perfect pronunciation",
      "Use the suggested phrases if you need help"
    ]
  }
}
```

### 8.3 发送语音回复
**POST** `/speaking/conversation/respond`

**请求参数:**
```json
{
  "session_id": "uuid",
  "audio_data": "base64_encoded_audio",
  "audio_format": "wav|mp3|m4a",
  "duration": 3.5
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "语音处理完成",
  "data": {
    "transcription": {
      "text": "Table for two please",
      "confidence": 0.95
    },
    "pronunciation_feedback": {
      "overall_score": 85,
      "fluency_score": 88,
      "accuracy_score": 82,
      "word_feedback": [
        {
          "word": "table",
          "score": 90,
          "feedback": "Excellent pronunciation"
        },
        {
          "word": "please",
          "score": 75,
          "feedback": "Try to emphasize the 'ee' sound more",
          "audio_example": "https://audio.com/please_correct.mp3"
        }
      ]
    },
    "ai_response": {
      "text": "Perfect! Right this way. Here are your menus. Can I start you off with something to drink?",
      "audio_url": "https://audio.com/response1.mp3"
    },
    "conversation_progress": {
      "current_turn": 2,
      "total_turns": 8,
      "completion_percentage": 25
    }
  }
}
```

### 8.4 发音练习
**POST** `/speaking/pronunciation/start`

**请求参数:**
```json
{
  "practice_type": "word|sentence|paragraph",
  "content_id": "uuid",
  "target_accent": "american|british|neutral"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "发音练习开始",
  "data": {
    "session_id": "uuid",
    "practice_content": {
      "text": "The weather is beautiful today.",
      "phonetic": "/ðə ˈweðər ɪz ˈbjuːtɪfəl təˈdeɪ/",
      "reference_audio": "https://audio.com/reference.mp3",
      "breakdown": [
        {
          "word": "weather",
          "phonetic": "/ˈweðər/",
          "audio": "https://audio.com/weather.mp3",
          "tips": "Focus on the 'th' sound"
        }
      ]
    },
    "practice_instructions": [
      "Listen to the reference audio first",
      "Practice each word individually",
      "Then try the complete sentence"
    ]
  }
}
```

### 8.5 提交发音录音
**POST** `/speaking/pronunciation/submit`

**请求参数:**
```json
{
  "session_id": "uuid",
  "audio_data": "base64_encoded_audio",
  "audio_format": "wav",
  "attempt_number": 1
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "发音评估完成",
  "data": {
    "overall_score": 88,
    "detailed_scores": {
      "accuracy": 85,
      "fluency": 90,
      "completeness": 95,
      "prosody": 82
    },
    "word_scores": [
      {
        "word": "weather",
        "score": 78,
        "feedback": "Good attempt! Try to make the 'th' sound more distinct.",
        "phoneme_scores": [
          {"phoneme": "w", "score": 95},
          {"phoneme": "e", "score": 88},
          {"phoneme": "ð", "score": 65},
          {"phoneme": "ər", "score": 85}
        ]
      }
    ],
    "improvement_suggestions": [
      "Practice the 'th' sound by placing your tongue between your teeth",
      "Try to speak more slowly to improve clarity"
    ],
    "next_practice": {
      "recommended_content": "Practice more words with 'th' sounds",
      "difficulty_adjustment": "maintain"
    }
  }
}
```

### 8.6 获取发音练习历史
**GET** `/speaking/pronunciation/history`

**查询参数:**
- `start_date`: `2024-01-01`
- `end_date`: `2024-01-31`
- `page`: `1`
- `page_size`: `20`

## 9. AI智能助手模块

### 9.1 发送消息给AI助手
**POST** `/ai-assistant/chat`

**请求参数:**
```json
{
  "message": "How can I improve my English pronunciation?",
  "context": {
    "current_module": "speaking",
    "user_level": "intermediate",
    "recent_activities": ["pronunciation_practice", "conversation"]
  },
  "message_type": "question|request_explanation|ask_for_help"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "response": "To improve your pronunciation, I recommend focusing on these key areas: 1) Practice individual sounds (phonemes) that are challenging for your native language background, 2) Use the pronunciation exercises in our app regularly, 3) Record yourself and compare with native speakers, 4) Focus on word stress and sentence rhythm.",
    "suggestions": [
      {
        "type": "practice_recommendation",
        "title": "Phoneme Practice",
        "description": "Practice the 'th' sound which seems to be challenging for you",
        "action_url": "/speaking/pronunciation/phonemes/th"
      },
      {
        "type": "content_recommendation",
        "title": "Pronunciation Course",
        "description": "Complete our 7-day pronunciation improvement course",
        "action_url": "/courses/pronunciation-basics"
      }
    ],
    "related_resources": [
      {
        "title": "IPA Chart",
        "url": "/resources/ipa-chart",
        "description": "Interactive phonetic alphabet chart"
      }
    ],
    "follow_up_questions": [
      "Would you like me to create a personalized pronunciation practice plan?",
      "Do you have specific sounds you find difficult?"
    ]
  }
}
```

### 9.2 获取个性化推荐
**GET** `/ai-assistant/recommendations`

**查询参数:**
- `type`: `study_plan|content|practice|review`
- `limit`: `10`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "recommendations": [
      {
        "id": "uuid",
        "type": "vocabulary_review",
        "title": "Review 15 words from last week",
        "description": "These words are due for review based on your learning curve",
        "priority": "high",
        "estimated_time": 10,
        "action": {
          "type": "start_review",
          "url": "/vocabulary/review/session",
          "params": {"word_ids": ["uuid1", "uuid2"]}
        },
        "reason": "Memory retention optimization"
      },
      {
        "id": "uuid",
        "type": "listening_practice",
        "title": "Daily Conversation: At the Bank",
        "description": "Practice banking vocabulary and phrases",
        "priority": "medium",
        "estimated_time": 15,
        "action": {
          "type": "start_listening",
          "url": "/listening/materials/uuid"
        },
        "reason": "Matches your learning goals and current level"
      }
    ],
    "study_insights": {
      "streak_days": 15,
      "weekly_goal_progress": 75,
      "strongest_skill": "vocabulary",
      "improvement_area": "speaking"
    }
  }
}
```

### 9.3 学习分析与诊断
**GET** `/ai-assistant/analysis`

**查询参数:**
- `period`: `week|month|quarter`
- `focus_area`: `vocabulary|listening|reading|writing|speaking`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "analysis_period": "month",
    "overall_progress": {
      "score_improvement": 12.5,
      "consistency_rating": 85,
      "goal_achievement": 78
    },
    "skill_analysis": {
      "vocabulary": {
        "current_level": 6.5,
        "progress_rate": "good",
        "strengths": ["Word recognition", "Basic definitions"],
        "weaknesses": ["Advanced synonyms", "Idiomatic expressions"],
        "recommendations": [
          "Focus on context-based learning",
          "Practice with advanced reading materials"
        ]
      },
      "speaking": {
        "current_level": 5.2,
        "progress_rate": "slow",
        "strengths": ["Basic conversation", "Vocabulary usage"],
        "weaknesses": ["Pronunciation accuracy", "Fluency"],
        "recommendations": [
          "Increase daily speaking practice",
          "Focus on pronunciation drills"
        ]
      }
    },
    "learning_patterns": {
      "most_active_time": "evening",
      "preferred_content_type": "interactive",
      "average_session_length": 25,
      "completion_rate": 82
    },
    "personalized_advice": [
      "Your vocabulary is progressing well, but speaking needs more attention",
      "Consider joining conversation practice sessions",
      "Set aside 15 minutes daily for pronunciation practice"
    ]
  }
}
```

### 9.4 设置学习提醒
**POST** `/ai-assistant/reminders`

**请求参数:**
```json
{
  "reminder_type": "daily_study|review_words|practice_speaking|weekly_goal",
  "schedule": {
    "time": "19:00",
    "days": ["monday", "tuesday", "wednesday", "thursday", "friday"],
    "timezone": "Asia/Shanghai"
  },
  "message": "Time for your daily English practice!",
  "enabled": true
}
```

### 9.5 获取学习建议
**GET** `/ai-assistant/suggestions`

**查询参数:**
- `context`: `struggling_with_pronunciation|low_motivation|time_constraints`
- `goal`: `exam_preparation|daily_communication|business_english`

## 10. 数据统计与分析模块

### 10.1 获取学习报告
**GET** `/analytics/reports`

**查询参数:**
- `report_type`: `weekly|monthly|quarterly|yearly`
- `start_date`: `2024-01-01`
- `end_date`: `2024-01-31`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "report_id": "uuid",
    "report_type": "monthly",
    "period": {
      "start_date": "2024-01-01",
      "end_date": "2024-01-31"
    },
    "summary": {
      "total_study_time": 1800,
      "words_learned": 150,
      "exercises_completed": 85,
      "average_score": 87.5,
      "streak_days": 25,
      "goal_achievement_rate": 85
    },
    "skill_progress": {
      "vocabulary": {
        "start_level": 6.0,
        "end_level": 6.8,
        "improvement": 0.8,
        "exercises_completed": 45,
        "average_score": 89
      },
      "listening": {
        "start_level": 5.5,
        "end_level": 6.1,
        "improvement": 0.6,
        "exercises_completed": 20,
        "average_score": 84
      }
    },
    "daily_breakdown": [
      {
        "date": "2024-01-01",
        "study_time": 45,
        "words_learned": 8,
        "exercises_completed": 3,
        "average_score": 85
      }
    ],
    "achievements": [
      {
        "title": "Vocabulary Master",
        "description": "Learned 100+ words this month",
        "earned_date": "2024-01-25",
        "badge_url": "https://images.com/badges/vocabulary_master.png"
      }
    ],
    "insights": [
      "Your vocabulary learning pace has increased by 25% this month",
      "Speaking practice time is below recommended levels",
      "Best performance time: 7-9 PM"
    ],
    "recommendations": [
      "Increase speaking practice to 15 minutes daily",
      "Focus on advanced vocabulary for next month",
      "Join conversation groups for more practice"
    ]
  }
}
```

### 10.2 获取学习数据统计
**GET** `/analytics/stats`

**查询参数:**
- `metric`: `study_time|words_learned|exercises|scores|streaks`
- `period`: `daily|weekly|monthly`
- `start_date`: `2024-01-01`
- `end_date`: `2024-01-31`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "metrics": {
      "study_time": {
        "total": 1800,
        "average_daily": 58,
        "trend": "increasing",
        "data_points": [
          {"date": "2024-01-01", "value": 45},
          {"date": "2024-01-02", "value": 60}
        ]
      },
      "words_learned": {
        "total": 150,
        "average_daily": 5,
        "trend": "stable",
        "data_points": [
          {"date": "2024-01-01", "value": 8},
          {"date": "2024-01-02", "value": 5}
        ]
      }
    },
    "comparisons": {
      "vs_previous_period": {
        "study_time": "+15%",
        "words_learned": "+8%",
        "average_score": "+3%"
      },
      "vs_user_average": {
        "study_time": "+22%",
        "consistency": "+18%"
      }
    }
  }
}
```

### 10.3 获取技能分析
**GET** `/analytics/skills`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "skill_levels": {
      "vocabulary": {
        "current_level": 6.8,
        "progress_this_month": 0.8,
        "mastery_distribution": {
          "mastered": 1200,
          "familiar": 800,
          "learning": 300,
          "new": 150
        }
      },
      "listening": {
        "current_level": 6.1,
        "progress_this_month": 0.6,
        "accuracy_by_speed": {
          "0.8x": 95,
          "1.0x": 85,
          "1.2x": 72
        }
      },
      "reading": {
        "current_level": 6.5,
        "progress_this_month": 0.4,
        "comprehension_by_length": {
          "short": 92,
          "medium": 85,
          "long": 78
        }
      },
      "writing": {
        "current_level": 5.8,
        "progress_this_month": 0.3,
        "score_breakdown": {
          "grammar": 85,
          "vocabulary": 82,
          "structure": 78,
          "fluency": 75
        }
      },
      "speaking": {
        "current_level": 5.2,
        "progress_this_month": 0.2,
        "pronunciation_accuracy": 78,
        "fluency_score": 72
      }
    },
    "improvement_trends": [
      {
        "skill": "vocabulary",
        "trend": "accelerating",
        "prediction": "Will reach level 7 in 2 months"
      },
      {
        "skill": "speaking",
        "trend": "slow",
        "prediction": "Needs more focused practice"
      }
    ]
  }
}
```

## 11. 系统配置模块

### 11.1 获取系统配置
**GET** `/system/config`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "app_version": "1.0.0",
    "supported_languages": ["zh-CN", "en-US"],
    "features": {
      "ai_assistant": true,
      "voice_recognition": true,
      "offline_mode": false,
      "social_features": true
    },
    "limits": {
      "daily_study_time": 180,
      "max_words_per_session": 50,
      "max_file_upload_size": 10485760
    },
    "ai_models": {
      "speech_recognition": "whisper-v3",
      "text_generation": "gpt-4",
      "pronunciation_assessment": "azure-speech"
    }
  }
}
```

### 11.2 获取内容分类
**GET** `/system/categories`

**查询参数:**
- `type`: `vocabulary|listening|reading|writing|speaking`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "categories": [
      {
        "id": "daily",
        "name": "日常生活",
        "description": "日常对话和生活场景",
        "icon": "https://icons.com/daily.svg",
        "subcategories": [
          {"id": "shopping", "name": "购物"},
          {"id": "dining", "name": "用餐"},
          {"id": "transportation", "name": "交通"}
        ]
      },
      {
        "id": "business",
        "name": "商务英语",
        "description": "职场和商务场景",
        "icon": "https://icons.com/business.svg",
        "subcategories": [
          {"id": "meetings", "name": "会议"},
          {"id": "presentations", "name": "演示"},
          {"id": "negotiations", "name": "谈判"}
        ]
      }
    ]
  }
}
```

### 11.3 获取难度等级
**GET** `/system/levels`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "levels": [
      {
        "id": "beginner",
        "name": "初级",
        "description": "适合英语初学者",
        "vocabulary_range": "1000-2000",
        "cefr_level": "A1-A2",
        "characteristics": [
          "基础词汇和语法",
          "简单句型",
          "日常话题"
        ]
      },
      {
        "id": "intermediate",
        "name": "中级",
        "description": "有一定英语基础",
        "vocabulary_range": "2000-5000",
        "cefr_level": "B1-B2",
        "characteristics": [
          "复合句型",
          "抽象概念",
          "专业话题"
        ]
      },
      {
        "id": "advanced",
        "name": "高级",
        "description": "英语水平较高",
        "vocabulary_range": "5000+",
        "cefr_level": "C1-C2",
        "characteristics": [
          "复杂语法结构",
          "学术词汇",
          "专业领域"
        ]
      }
    ]
  }
}
```

## 12. 错误码说明

### 12.1 通用错误码

| 错误码 | 说明 | 描述 |
|--------|------|------|
| 200 | 成功 | 请求成功处理 |
| 400 | 请求参数错误 | 请求参数格式不正确或缺少必需参数 |
| 401 | 未授权 | 需要用户认证或token无效 |
| 403 | 禁止访问 | 用户权限不足 |
| 404 | 资源不存在 | 请求的资源未找到 |
| 409 | 资源冲突 | 资源已存在或状态冲突 |
| 422 | 参数验证失败 | 请求参数不符合业务规则 |
| 429 | 请求过于频繁 | 超出API调用频率限制 |
| 500 | 服务器内部错误 | 服务器处理请求时发生错误 |
| 503 | 服务不可用 | 服务器暂时无法处理请求 |

### 12.2 业务错误码

| 错误码 | 说明 | 模块 |
|--------|------|------|
| 1001 | 用户名已存在 | 用户管理 |
| 1002 | 邮箱已注册 | 用户管理 |
| 1003 | 密码格式不正确 | 用户管理 |
| 1004 | 验证码错误 | 用户管理 |
| 2001 | 词库不存在 | 词汇学习 |
| 2002 | 单词不存在 | 词汇学习 |
| 2003 | 测试会话已过期 | 词汇学习 |
| 3001 | 听力材料不存在 | 听力训练 |
| 3002 | 音频文件损坏 | 听力训练 |
| 4001 | 阅读材料不存在 | 阅读理解 |
| 4002 | 文章内容为空 | 阅读理解 |
| 5001 | 写作任务不存在 | 写作练习 |
| 5002 | 内容长度超限 | 写作练习 |
| 6001 | 对话场景不存在 | 口语练习 |
| 6002 | 音频格式不支持 | 口语练习 |
| 6003 | 语音识别失败 | 口语练习 |
| 7001 | AI服务暂不可用 | AI助手 |
| 7002 | 请求内容过长 | AI助手 |

### 12.3 错误响应格式

```json
{
  "code": 400,
  "message": "请求参数错误",
  "error": {
    "error_code": "INVALID_PARAMETER",
    "details": "参数 'email' 格式不正确",
    "field": "email",
    "value": "invalid-email"
  },
  "timestamp": "2024-01-01T12:00:00Z"
}
```

---

## 附录

### A. 认证说明

所有需要用户身份验证的接口都需要在请求头中包含访问令牌：

```
Authorization: Bearer {access_token}
```

### B. 分页说明

支持分页的接口使用以下查询参数：
- `page`: 页码，从1开始
- `page_size`: 每页数量，默认20，最大100

### C. 时间格式

所有时间字段使用ISO 8601格式：`2024-01-01T12:00:00Z`

### D. 文件上传

音频文件上传支持以下格式：
- WAV (推荐)
- MP3
- M4A
- 最大文件大小：10MB

### E. 速率限制

- 普通接口：每分钟100次请求
- AI相关接口：每分钟20次请求
- 文件上传接口：每分钟10次请求

### F. 版本控制

API版本通过URL路径指定：`/v1/`

当前版本：v1.0

---

*文档最后更新时间：2024-01-01*
*API版本：v1.0*