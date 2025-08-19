package com.nanqipro.service;

import com.nanqipro.entity.Article;
import com.nanqipro.entity.ReadingProgress;
import com.nanqipro.entity.ReadingQuestion;
import com.nanqipro.entity.ReadingSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 文章服务接口
 * 提供文章管理、阅读进度跟踪、题目系统等功能
 */
public interface ArticleService {
    
    // ==================== 文章基础管理 ====================
    
    /**
     * 添加文章
     * @param article 文章信息
     * @return 创建的文章
     */
    Article addArticle(Article article);
    
    /**
     * 批量添加文章
     * @param articles 文章列表
     * @return 创建的文章列表
     */
    List<Article> addArticles(List<Article> articles);
    
    /**
     * 更新文章
     * @param articleId 文章ID
     * @param article 文章信息
     * @return 更新后的文章
     */
    Article updateArticle(Long articleId, Article article);
    
    /**
     * 删除文章
     * @param articleId 文章ID
     */
    void deleteArticle(Long articleId);
    
    /**
     * 批量删除文章
     * @param articleIds 文章ID列表
     */
    void deleteArticles(List<Long> articleIds);
    
    /**
     * 根据ID获取文章
     * @param articleId 文章ID
     * @return 文章信息
     */
    Article getArticleById(Long articleId);
    
    /**
     * 根据标题获取文章
     * @param title 文章标题
     * @return 文章信息
     */
    Article getArticleByTitle(String title);
    
    /**
     * 检查文章是否存在
     * @param title 文章标题
     * @return 是否存在
     */
    boolean existsByTitle(String title);
    
    // ==================== 文章查询和搜索 ====================
    
    /**
     * 分页获取文章列表
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> getArticles(Pageable pageable);
    
    /**
     * 根据难度级别获取文章
     * @param level 难度级别
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> getArticlesByLevel(Article.DifficultyLevel level, Pageable pageable);
    
    /**
     * 根据分类获取文章
     * @param category 分类
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> getArticlesByCategory(String category, Pageable pageable);
    
    /**
     * 根据类型获取文章
     * @param category 文章类型
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> getArticlesByType(Article.Category category, Pageable pageable);
    
    /**
     * 搜索文章
     * @param keyword 关键词
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> searchArticles(String keyword, Pageable pageable);
    
    /**
     * 高级搜索文章
     * @param title 标题
     * @param author 作者
     * @param category 分类
     * @param level 难度级别
     * @param type 文章类型
     * @param tags 标签列表
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> advancedSearchArticles(String title, String author, String category, 
                                       Article.DifficultyLevel level, Article.Category type, 
                                       List<String> tags, Pageable pageable);
    
    /**
     * 获取推荐文章
     * @param userId 用户ID
     * @param limit 数量限制
     * @return 推荐文章列表
     */
    List<Article> getRecommendedArticles(Long userId, int limit);
    
    /**
     * 获取热门文章
     * @param limit 数量限制
     * @return 热门文章列表
     */
    List<Article> getPopularArticles(int limit);
    
    /**
     * 获取最新文章
     * @param limit 数量限制
     * @return 最新文章列表
     */
    List<Article> getLatestArticles(int limit);
    
    /**
     * 根据标签获取文章
     * @param tag 标签
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> getArticlesByTag(String tag, Pageable pageable);
    
    // ==================== 阅读进度管理 ====================
    
    /**
     * 开始阅读文章
     * @param userId 用户ID
     * @param articleId 文章ID
     * @return 阅读会话
     */
    ReadingSession startReading(Long userId, Long articleId);
    
    /**
     * 更新阅读进度
     * @param userId 用户ID
     * @param articleId 文章ID
     * @param progress 阅读进度（百分比）
     * @param currentPosition 当前位置
     * @return 阅读进度记录
     */
    ReadingProgress updateReadingProgress(Long userId, Long articleId, int progress, int currentPosition);
    
    /**
     * 完成阅读
     * @param userId 用户ID
     * @param articleId 文章ID
     * @param readingTime 阅读时间（秒）
     * @return 阅读会话
     */
    ReadingSession completeReading(Long userId, Long articleId, int readingTime);
    
    /**
     * 获取用户阅读进度
     * @param userId 用户ID
     * @param articleId 文章ID
     * @return 阅读进度
     */
    ReadingProgress getUserReadingProgress(Long userId, Long articleId);
    
    /**
     * 获取用户阅读历史
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 阅读历史分页列表
     */
    Page<ReadingSession> getUserReadingHistory(Long userId, Pageable pageable);
    
    /**
     * 获取用户正在阅读的文章
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 正在阅读的文章列表
     */
    Page<ReadingProgress> getUserCurrentReading(Long userId, Pageable pageable);
    
    /**
     * 获取用户已完成阅读的文章
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 已完成阅读的文章列表
     */
    Page<ReadingSession> getUserCompletedReading(Long userId, Pageable pageable);
    
    // ==================== 题目系统 ====================
    
    /**
     * 为文章添加题目
     * @param articleId 文章ID
     * @param question 题目信息
     * @return 创建的题目
     */
    ReadingQuestion addQuestionToArticle(Long articleId, ReadingQuestion question);
    
    /**
     * 批量为文章添加题目
     * @param articleId 文章ID
     * @param questions 题目列表
     * @return 创建的题目列表
     */
    List<ReadingQuestion> addQuestionsToArticle(Long articleId, List<ReadingQuestion> questions);
    
    /**
     * 更新题目
     * @param questionId 题目ID
     * @param question 题目信息
     * @return 更新后的题目
     */
    ReadingQuestion updateQuestion(Long questionId, ReadingQuestion question);
    
    /**
     * 删除题目
     * @param questionId 题目ID
     */
    void deleteQuestion(Long questionId);
    
    /**
     * 获取文章的所有题目
     * @param articleId 文章ID
     * @return 题目列表
     */
    List<ReadingQuestion> getQuestionsByArticle(Long articleId);
    
    /**
     * 根据类型获取文章题目
     * @param articleId 文章ID
     * @param questionType 题目类型
     * @return 题目列表
     */
    List<ReadingQuestion> getQuestionsByType(Long articleId, ReadingQuestion.QuestionType questionType);
    
    /**
     * 提交答案
     * @param userId 用户ID
     * @param questionId 题目ID
     * @param answer 用户答案
     * @return 答题结果
     */
    Map<String, Object> submitAnswer(Long userId, Long questionId, String answer);
    
    /**
     * 批量提交答案
     * @param userId 用户ID
     * @param answers 答案映射（题目ID -> 答案）
     * @return 答题结果
     */
    Map<String, Object> submitAnswers(Long userId, Map<Long, String> answers);
    
    /**
     * 获取用户答题记录
     * @param userId 用户ID
     * @param articleId 文章ID
     * @return 答题记录
     */
    Map<String, Object> getUserAnswerRecord(Long userId, Long articleId);
    
    /**
     * 获取用户答题统计
     * @param userId 用户ID
     * @return 答题统计
     */
    Map<String, Object> getUserAnswerStatistics(Long userId);
    
    // ==================== 文章收藏和标签 ====================
    
    /**
     * 收藏文章
     * @param userId 用户ID
     * @param articleId 文章ID
     */
    void favoriteArticle(Long userId, Long articleId);
    
    /**
     * 取消收藏文章
     * @param userId 用户ID
     * @param articleId 文章ID
     */
    void unfavoriteArticle(Long userId, Long articleId);
    
    /**
     * 获取用户收藏的文章
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 收藏文章分页列表
     */
    Page<Article> getUserFavoriteArticles(Long userId, Pageable pageable);
    
    /**
     * 为文章添加标签
     * @param articleId 文章ID
     * @param tags 标签列表
     * @return 更新后的文章
     */
    Article addTagsToArticle(Long articleId, List<String> tags);
    
    /**
     * 从文章移除标签
     * @param articleId 文章ID
     * @param tags 标签列表
     * @return 更新后的文章
     */
    Article removeTagsFromArticle(Long articleId, List<String> tags);
    
    /**
     * 获取所有文章标签
     * @return 标签列表
     */
    List<String> getAllArticleTags();
    
    // ==================== 文章导入导出 ====================
    
    /**
     * 从文件导入文章
     * @param file 文件
     * @param category 分类
     * @return 导入结果
     */
    Map<String, Object> importArticlesFromFile(MultipartFile file, String category);
    
    /**
     * 导出文章
     * @param articleIds 文章ID列表
     * @param format 导出格式
     * @return 导出数据
     */
    byte[] exportArticles(List<Long> articleIds, String format);
    
    /**
     * 导出用户阅读数据
     * @param userId 用户ID
     * @param format 导出格式
     * @return 导出数据
     */
    byte[] exportUserReadingData(Long userId, String format);
    
    // ==================== 文章分析和统计 ====================
    
    /**
     * 获取文章统计信息
     * @return 统计信息
     */
    Map<String, Object> getArticleStatistics();
    
    /**
     * 获取分类统计
     * @return 分类统计
     */
    Map<String, Long> getCategoryStatistics();
    
    /**
     * 获取难度级别统计
     * @return 难度级别统计
     */
    Map<Article.DifficultyLevel, Long> getLevelStatistics();
    
    /**
     * 获取文章类型统计
     * @return 文章类型统计
     */
    Map<Article.Category, Long> getTypeStatistics();
    
    /**
     * 获取用户阅读趋势
     * @param userId 用户ID
     * @param days 天数
     * @return 阅读趋势数据
     */
    List<Map<String, Object>> getUserReadingTrend(Long userId, int days);
    
    /**
     * 获取用户阅读统计
     * @param userId 用户ID
     * @return 阅读统计
     */
    Map<String, Object> getUserReadingStatistics(Long userId);
    
    /**
     * 获取文章阅读排行
     * @param limit 数量限制
     * @return 阅读排行
     */
    List<Map<String, Object>> getArticleReadingRanking(int limit);
    
    /**
     * 获取用户阅读能力分析
     * @param userId 用户ID
     * @return 阅读能力分析
     */
    Map<String, Object> getUserReadingAbilityAnalysis(Long userId);
}