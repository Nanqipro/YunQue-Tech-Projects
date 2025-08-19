package com.nanqipro.service.impl;

import com.nanqipro.entity.Article;
import com.nanqipro.entity.ReadingProgress;
import com.nanqipro.entity.ReadingQuestion;
import com.nanqipro.entity.ReadingSession;
import com.nanqipro.repository.ArticleRepository;
import com.nanqipro.repository.ReadingProgressRepository;
import com.nanqipro.repository.ReadingQuestionRepository;
import com.nanqipro.repository.ReadingSessionRepository;
import com.nanqipro.service.ArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 文章服务实现类
 */
@Service
public class ArticleServiceImpl implements ArticleService {
    
    @Autowired
    private ArticleRepository articleRepository;
    
    @Autowired
    private ReadingProgressRepository readingProgressRepository;
    
    @Autowired
    private ReadingQuestionRepository readingQuestionRepository;
    
    @Autowired
    private ReadingSessionRepository readingSessionRepository;
    
    // ==================== 文章基础管理 ====================
    
    @Override
    public Article addArticle(Article article) {
        article.setViewCount(0L);
        article.setLikeCount(0L);
        article.setFavoriteCount(0L);
        article.setCommentCount(0L);
        return articleRepository.save(article);
    }
    
    @Override
    public List<Article> addArticles(List<Article> articles) {
        articles.forEach(article -> {
            article.setViewCount(0L);
            article.setLikeCount(0L);
            article.setFavoriteCount(0L);
            article.setCommentCount(0L);
        });
        return articleRepository.saveAll(articles);
    }
    
    @Override
    public Article updateArticle(Long articleId, Article article) {
        Article existingArticle = articleRepository.findById(articleId)
                .orElseThrow(() -> new RuntimeException("Article not found with id: " + articleId));
        
        existingArticle.setTitle(article.getTitle());
        existingArticle.setContent(article.getContent());
        existingArticle.setAuthor(article.getAuthor());
        existingArticle.setCategory(article.getCategory());
        existingArticle.setDifficultyLevel(article.getDifficultyLevel());
        existingArticle.setEstimatedReadingTime(article.getEstimatedReadingTime());
        existingArticle.setWordCount(article.getWordCount());
        existingArticle.setTags(article.getTags());
        existingArticle.setKeywords(article.getKeywords());
        existingArticle.setStatus(article.getStatus());
        // updatedAt is automatically set by @UpdateTimestamp
        
        return articleRepository.save(existingArticle);
    }
    
    @Override
    public void deleteArticle(Long articleId) {
        articleRepository.deleteById(articleId);
    }
    
    @Override
    public void deleteArticles(List<Long> articleIds) {
        articleRepository.deleteAllById(articleIds);
    }
    
    @Override
    public Article getArticleById(Long articleId) {
        return articleRepository.findById(articleId).orElse(null);
    }
    
    @Override
    public Article getArticleByTitle(String title) {
        return articleRepository.findByTitle(title).orElse(null);
    }
    
    @Override
    public boolean existsByTitle(String title) {
        return articleRepository.existsByTitle(title);
    }
    
    // ==================== 文章查询和搜索 ====================
    
    @Override
    public Page<Article> getArticles(Pageable pageable) {
        return articleRepository.findAll(pageable);
    }
    
    @Override
    public Page<Article> getArticlesByLevel(Article.DifficultyLevel level, Pageable pageable) {
        return articleRepository.findByDifficultyLevel(level, pageable);
    }
    
    @Override
    public Page<Article> getArticlesByCategory(String category, Pageable pageable) {
        try {
            Article.Category categoryEnum = Article.Category.valueOf(category.toUpperCase());
            return articleRepository.findByCategory(categoryEnum, pageable);
        } catch (IllegalArgumentException e) {
            return Page.empty(pageable);
        }
    }
    
    @Override
    public Page<Article> getArticlesByType(Article.Category category, Pageable pageable) {
        return articleRepository.findByCategory(category, pageable);
    }
    
    @Override
    public Page<Article> searchArticles(String keyword, Pageable pageable) {
        return articleRepository.searchByKeyword(keyword, pageable);
    }
    
    @Override
    public Page<Article> advancedSearchArticles(String title, String author, String category, 
                                              Article.DifficultyLevel level, Article.Category type, 
                                              List<String> tags, Pageable pageable) {
        // 使用高级搜索方法
        return articleRepository.advancedSearch(title, author, type, level, pageable);
    }
    
    @Override
    public List<Article> getRecommendedArticles(Long userId, int limit) {
        // 简化实现，返回最新文章
        return articleRepository.findLatestArticles(PageRequest.of(0, limit));
    }
    
    @Override
    public List<Article> getPopularArticles(int limit) {
        return articleRepository.findPopularArticles(PageRequest.of(0, limit));
    }
    
    @Override
    public List<Article> getLatestArticles(int limit) {
        return articleRepository.findLatestArticles(PageRequest.of(0, limit));
    }
    
    @Override
    public Page<Article> getArticlesByTag(String tag, Pageable pageable) {
        return articleRepository.findByTag(tag, pageable);
    }
    
    // ==================== 阅读进度管理 ====================
    
    @Override
    public ReadingSession startReading(Long userId, Long articleId) {
        ReadingSession session = new ReadingSession();
        session.setUserId(userId);
        session.setArticleId(articleId);
        session.setSessionStartTime(LocalDateTime.now());
        session.setStartPosition(0);
        session.setReadingDuration(0);
        return readingSessionRepository.save(session);
    }
    
    @Override
    public ReadingProgress updateReadingProgress(Long userId, Long articleId, int progress, int currentPosition) {
        ReadingProgress readingProgress = readingProgressRepository
                .findByUserIdAndArticleId(userId, articleId)
                .orElse(new ReadingProgress());
        
        if (readingProgress.getId() == null) {
            readingProgress.setUserId(userId);
            readingProgress.setArticleId(articleId);
        }
        
        readingProgress.updateProgress(progress, currentPosition);
        
        return readingProgressRepository.save(readingProgress);
    }
    
    @Override
    public ReadingSession completeReading(Long userId, Long articleId, int readingTime) {
        ReadingSession session = new ReadingSession();
        session.setUserId(userId);
        session.setArticleId(articleId);
        session.setReadingDuration(readingTime);
        session.setSessionStartTime(LocalDateTime.now().minusSeconds(readingTime));
        session.setSessionEndTime(LocalDateTime.now());
        return readingSessionRepository.save(session);
    }
    
    @Override
    public ReadingProgress getUserReadingProgress(Long userId, Long articleId) {
        return readingProgressRepository.findByUserIdAndArticleId(userId, articleId).orElse(null);
    }
    
    @Override
    public Page<ReadingSession> getUserReadingHistory(Long userId, Pageable pageable) {
        return readingSessionRepository.findByUserIdOrderByStartTimeDesc(userId, pageable);
    }
    
    @Override
    public Page<ReadingProgress> getUserCurrentReading(Long userId, Pageable pageable) {
        return readingProgressRepository.findByUserIdAndStatusOrderByLastReadAtDesc(
                userId, ReadingProgress.Status.IN_PROGRESS, pageable);
    }
    
    @Override
    public Page<ReadingSession> getUserCompletedReading(Long userId, Pageable pageable) {
        return readingSessionRepository.findByUserIdOrderByStartTimeDesc(userId, pageable);
    }
    
    // ==================== 题目系统 ====================
    
    @Override
    public ReadingQuestion addQuestionToArticle(Long articleId, ReadingQuestion question) {
        question.setArticleId(articleId);
        // createdAt is automatically set by @CreationTimestamp
        return readingQuestionRepository.save(question);
    }
    
    @Override
    public List<ReadingQuestion> addQuestionsToArticle(Long articleId, List<ReadingQuestion> questions) {
        questions.forEach(question -> {
            question.setArticleId(articleId);
            // createdAt is automatically set by @CreationTimestamp
        });
        return readingQuestionRepository.saveAll(questions);
    }
    
    @Override
    public ReadingQuestion updateQuestion(Long questionId, ReadingQuestion question) {
        ReadingQuestion existingQuestion = readingQuestionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found with id: " + questionId));
        
        existingQuestion.setQuestion(question.getQuestion());
        existingQuestion.setQuestionType(question.getQuestionType());
        existingQuestion.setOptions(question.getOptions());
        existingQuestion.setCorrectAnswer(question.getCorrectAnswer());
        existingQuestion.setExplanation(question.getExplanation());
        existingQuestion.setDifficultyLevel(question.getDifficultyLevel());
        existingQuestion.setPoints(question.getPoints());
        existingQuestion.setTags(question.getTags());
        // updatedAt is automatically set by @UpdateTimestamp
        
        return readingQuestionRepository.save(existingQuestion);
    }
    
    @Override
    public void deleteQuestion(Long questionId) {
        readingQuestionRepository.deleteById(questionId);
    }
    
    @Override
    public List<ReadingQuestion> getQuestionsByArticle(Long articleId) {
        return readingQuestionRepository.findByArticleId(articleId);
    }
    
    @Override
    public List<ReadingQuestion> getQuestionsByType(Long articleId, ReadingQuestion.QuestionType questionType) {
        return readingQuestionRepository.findByArticleIdAndQuestionType(articleId, questionType);
    }
    
    @Override
    public Map<String, Object> submitAnswer(Long userId, Long questionId, String answer) {
        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("questionId", questionId);
        result.put("answer", answer);
        result.put("correct", false); // 简化实现
        return result;
    }
    
    @Override
    public Map<String, Object> submitAnswers(Long userId, Map<Long, String> answers) {
        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("totalQuestions", answers.size());
        result.put("correctAnswers", 0);
        result.put("score", 0.0);
        return result;
    }
    
    @Override
    public Map<String, Object> getUserAnswerRecord(Long userId, Long articleId) {
        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("articleId", articleId);
        result.put("answers", new ArrayList<>());
        return result;
    }
    
    @Override
    public Map<String, Object> getUserAnswerStatistics(Long userId) {
        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("totalAnswered", 0);
        result.put("correctAnswers", 0);
        result.put("accuracy", 0.0);
        return result;
    }
    
    // ==================== 文章收藏和标签 ====================
    
    @Override
    public void favoriteArticle(Long userId, Long articleId) {
        ReadingProgress progress = readingProgressRepository
                .findByUserIdAndArticleId(userId, articleId)
                .orElse(new ReadingProgress());
        
        if (progress.getId() == null) {
            progress.setUserId(userId);
            progress.setArticleId(articleId);
        }
        
        progress.setIsFavorited(true);
        readingProgressRepository.save(progress);
    }
    
    @Override
    public void unfavoriteArticle(Long userId, Long articleId) {
        readingProgressRepository.findByUserIdAndArticleId(userId, articleId)
                .ifPresent(progress -> {
                    progress.setIsFavorited(false);
                    readingProgressRepository.save(progress);
                });
    }
    
    @Override
    public Page<Article> getUserFavoriteArticles(Long userId, Pageable pageable) {
        // 简化实现，返回空页面
        return Page.empty(pageable);
    }
    
    @Override
    public Article addTagsToArticle(Long articleId, List<String> tags) {
        Article article = articleRepository.findById(articleId)
                .orElseThrow(() -> new RuntimeException("Article not found with id: " + articleId));
        
        Set<String> currentTags = new HashSet<>(article.getTags());
        currentTags.addAll(tags);
        article.setTags(new ArrayList<>(currentTags));
        // updatedAt is automatically set by @UpdateTimestamp
        
        return articleRepository.save(article);
    }
    
    @Override
    public Article removeTagsFromArticle(Long articleId, List<String> tags) {
        Article article = articleRepository.findById(articleId)
                .orElseThrow(() -> new RuntimeException("Article not found with id: " + articleId));
        
        List<String> currentTags = new ArrayList<>(article.getTags());
        currentTags.removeAll(tags);
        article.setTags(currentTags);
        // updatedAt is automatically set by @UpdateTimestamp
        
        return articleRepository.save(article);
    }
    
    @Override
    public List<String> getAllArticleTags() {
        return articleRepository.findAll().stream()
                .flatMap(article -> article.getTags().stream())
                .distinct()
                .sorted()
                .toList();
    }
    
    // ==================== 文章导入导出 ====================
    
    @Override
    public Map<String, Object> importArticlesFromFile(MultipartFile file, String category) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", false);
        result.put("message", "Import functionality not implemented yet");
        return result;
    }
    
    @Override
    public byte[] exportArticles(List<Long> articleIds, String format) {
        return new byte[0];
    }
    
    @Override
    public byte[] exportUserReadingData(Long userId, String format) {
        return new byte[0];
    }
    
    // ==================== 文章分析和统计 ====================
    
    @Override
    public Map<String, Object> getArticleStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalArticles", articleRepository.count());
        stats.put("publishedArticles", articleRepository.countByStatus(Article.Status.PUBLISHED));
        return stats;
    }
    
    @Override
    public Map<String, Long> getCategoryStatistics() {
        Map<String, Long> stats = new HashMap<>();
        List<Object[]> categoryStatsData = articleRepository.getCategoryStatistics();
        for (Object[] row : categoryStatsData) {
            stats.put(row[0].toString(), ((Number) row[1]).longValue());
        }
        return stats;
    }
    
    @Override
    public Map<Article.DifficultyLevel, Long> getLevelStatistics() {
        Map<Article.DifficultyLevel, Long> stats = new HashMap<>();
        List<Object[]> difficultyStatsData = articleRepository.getDifficultyLevelStatistics();
        for (Object[] row : difficultyStatsData) {
            Article.DifficultyLevel level = (Article.DifficultyLevel) row[0];
            Long count = ((Number) row[1]).longValue();
            stats.put(level, count);
        }
        return stats;
    }
    
    @Override
    public Map<Article.Category, Long> getTypeStatistics() {
        Map<Article.Category, Long> stats = new HashMap<>();
        List<Object[]> categoryStatsData = articleRepository.getCategoryStatistics();
        for (Object[] row : categoryStatsData) {
            Article.Category category = (Article.Category) row[0];
            Long count = ((Number) row[1]).longValue();
            stats.put(category, count);
        }
        return stats;
    }
    
    @Override
    public List<Map<String, Object>> getUserReadingTrend(Long userId, int days) {
        List<Map<String, Object>> trend = new ArrayList<>();
        // 简化实现
        return trend;
    }
    
    @Override
    public Map<String, Object> getUserReadingStatistics(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("userId", userId);
        stats.put("totalArticlesRead", 0);
        stats.put("totalReadingTime", 0);
        return stats;
    }
    
    @Override
    public List<Map<String, Object>> getArticleReadingRanking(int limit) {
        List<Map<String, Object>> ranking = new ArrayList<>();
        // 简化实现
        return ranking;
    }
    
    @Override
    public Map<String, Object> getUserReadingAbilityAnalysis(Long userId) {
        Map<String, Object> analysis = new HashMap<>();
        analysis.put("userId", userId);
        analysis.put("readingLevel", "BEGINNER");
        analysis.put("averageSpeed", 0.0);
        return analysis;
    }
}