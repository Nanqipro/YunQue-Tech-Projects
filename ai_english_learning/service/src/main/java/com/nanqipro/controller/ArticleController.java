package com.nanqipro.controller;

import com.nanqipro.common.ApiResponse;
import com.nanqipro.entity.Article;
import com.nanqipro.entity.ReadingProgress;
import com.nanqipro.entity.ReadingQuestion;
import com.nanqipro.entity.ReadingSession;
import com.nanqipro.service.ArticleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

/**
 * 文章管理控制器
 */
@RestController
@RequestMapping("/api/articles")
@Tag(name = "文章管理", description = "文章相关的API接口")
public class ArticleController {

    @Autowired
    private ArticleService articleService;

    // ==================== 文章基础管理 ====================

    /**
     * 添加文章
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "添加文章", description = "创建新的文章")
    public ResponseEntity<ApiResponse<Article>> addArticle(@RequestBody Article article) {
        Article savedArticle = articleService.addArticle(article);
        return ResponseEntity.ok(ApiResponse.success(savedArticle));
    }

    /**
     * 批量添加文章
     */
    @PostMapping("/batch")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "批量添加文章", description = "批量创建文章")
    public ResponseEntity<ApiResponse<List<Article>>> addArticles(@RequestBody List<Article> articles) {
        List<Article> savedArticles = articleService.addArticles(articles);
        return ResponseEntity.ok(ApiResponse.success(savedArticles));
    }

    /**
     * 更新文章
     */
    @PutMapping("/{articleId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "更新文章", description = "更新指定文章的信息")
    public ResponseEntity<ApiResponse<Article>> updateArticle(
            @PathVariable Long articleId,
            @RequestBody Article article) {
        Article updatedArticle = articleService.updateArticle(articleId, article);
        return ResponseEntity.ok(ApiResponse.success(updatedArticle));
    }

    /**
     * 删除文章
     */
    @DeleteMapping("/{articleId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "删除文章", description = "删除指定的文章")
    public ResponseEntity<ApiResponse<Void>> deleteArticle(@PathVariable Long articleId) {
        articleService.deleteArticle(articleId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 批量删除文章
     */
    @DeleteMapping("/batch")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "批量删除文章", description = "批量删除文章")
    public ResponseEntity<ApiResponse<Void>> deleteArticles(@RequestBody List<Long> articleIds) {
        articleService.deleteArticles(articleIds);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 根据ID获取文章
     */
    @GetMapping("/{articleId}")
    @Operation(summary = "获取文章详情", description = "根据ID获取文章详细信息")
    public ResponseEntity<ApiResponse<Article>> getArticleById(@PathVariable Long articleId) {
        Article article = articleService.getArticleById(articleId);
        return ResponseEntity.ok(ApiResponse.success(article));
    }

    /**
     * 根据标题获取文章
     */
    @GetMapping("/title/{title}")
    @Operation(summary = "根据标题获取文章", description = "根据标题获取文章信息")
    public ResponseEntity<ApiResponse<Article>> getArticleByTitle(@PathVariable String title) {
        Article article = articleService.getArticleByTitle(title);
        return ResponseEntity.ok(ApiResponse.success(article));
    }

    /**
     * 检查标题是否存在
     */
    @GetMapping("/exists/{title}")
    @Operation(summary = "检查标题是否存在", description = "检查指定标题的文章是否存在")
    public ResponseEntity<ApiResponse<Boolean>> existsByTitle(@PathVariable String title) {
        boolean exists = articleService.existsByTitle(title);
        return ResponseEntity.ok(ApiResponse.success(exists));
    }

    // ==================== 文章查询和搜索 ====================

    /**
     * 获取文章列表
     */
    @GetMapping
    @Operation(summary = "获取文章列表", description = "分页获取文章列表")
    public ResponseEntity<ApiResponse<Page<Article>>> getArticles(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Article> articles = articleService.getArticles(pageable);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 根据难度级别获取文章
     */
    @GetMapping("/level/{level}")
    @Operation(summary = "根据难度获取文章", description = "根据难度级别获取文章列表")
    public ResponseEntity<ApiResponse<Page<Article>>> getArticlesByLevel(
            @PathVariable Article.DifficultyLevel level,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Article> articles = articleService.getArticlesByLevel(level, pageable);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 根据分类获取文章
     */
    @GetMapping("/category/{category}")
    @Operation(summary = "根据分类获取文章", description = "根据分类获取文章列表")
    public ResponseEntity<ApiResponse<Page<Article>>> getArticlesByCategory(
            @PathVariable String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Article> articles = articleService.getArticlesByCategory(category, pageable);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 根据类型获取文章
     */
    @GetMapping("/type/{type}")
    @Operation(summary = "根据类型获取文章", description = "根据类型获取文章列表")
    public ResponseEntity<ApiResponse<Page<Article>>> getArticlesByType(
            @PathVariable Article.Category type,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Article> articles = articleService.getArticlesByType(type, pageable);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 搜索文章
     */
    @GetMapping("/search")
    @Operation(summary = "搜索文章", description = "根据关键词搜索文章")
    public ResponseEntity<ApiResponse<Page<Article>>> searchArticles(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Article> articles = articleService.searchArticles(keyword, pageable);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 高级搜索文章
     */
    @GetMapping("/advanced-search")
    @Operation(summary = "高级搜索文章", description = "根据多个条件搜索文章")
    public ResponseEntity<ApiResponse<Page<Article>>> advancedSearchArticles(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String author,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Article.DifficultyLevel level,
            @RequestParam(required = false) Article.Category type,
            @RequestParam(required = false) List<String> tags,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Article> articles = articleService.advancedSearchArticles(title, author, category, level, type, tags, pageable);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 获取推荐文章
     */
    @GetMapping("/recommended")
    @Operation(summary = "获取推荐文章", description = "获取用户推荐文章")
    public ResponseEntity<ApiResponse<List<Article>>> getRecommendedArticles(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "10") int limit) {
        List<Article> articles = articleService.getRecommendedArticles(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 获取热门文章
     */
    @GetMapping("/popular")
    @Operation(summary = "获取热门文章", description = "获取热门文章列表")
    public ResponseEntity<ApiResponse<List<Article>>> getPopularArticles(
            @RequestParam(defaultValue = "10") int limit) {
        List<Article> articles = articleService.getPopularArticles(limit);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 获取最新文章
     */
    @GetMapping("/latest")
    @Operation(summary = "获取最新文章", description = "获取最新发布的文章")
    public ResponseEntity<ApiResponse<List<Article>>> getLatestArticles(
            @RequestParam(defaultValue = "10") int limit) {
        List<Article> articles = articleService.getLatestArticles(limit);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    /**
     * 根据标签获取文章
     */
    @GetMapping("/tag/{tag}")
    @Operation(summary = "根据标签获取文章", description = "根据标签获取文章列表")
    public ResponseEntity<ApiResponse<Page<Article>>> getArticlesByTag(
            @PathVariable String tag,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Article> articles = articleService.getArticlesByTag(tag, pageable);
        return ResponseEntity.ok(ApiResponse.success(articles));
    }

    // ==================== 阅读进度管理 ====================

    /**
     * 开始阅读文章
     */
    @PostMapping("/{articleId}/reading/start")
    @Operation(summary = "开始阅读", description = "开始阅读指定文章")
    public ResponseEntity<ApiResponse<ReadingSession>> startReading(
            @PathVariable Long articleId,
            @RequestParam Long userId) {
        ReadingSession session = articleService.startReading(userId, articleId);
        return ResponseEntity.ok(ApiResponse.success(session));
    }

    /**
     * 更新阅读进度
     */
    @PutMapping("/{articleId}/reading/progress")
    @Operation(summary = "更新阅读进度", description = "更新用户的阅读进度")
    public ResponseEntity<ApiResponse<ReadingProgress>> updateReadingProgress(
            @PathVariable Long articleId,
            @RequestParam Long userId,
            @RequestParam int progress,
            @RequestParam int currentPosition) {
        ReadingProgress readingProgress = articleService.updateReadingProgress(userId, articleId, progress, currentPosition);
        return ResponseEntity.ok(ApiResponse.success(readingProgress));
    }

    /**
     * 完成阅读
     */
    @PostMapping("/{articleId}/reading/complete")
    @Operation(summary = "完成阅读", description = "标记文章阅读完成")
    public ResponseEntity<ApiResponse<ReadingSession>> completeReading(
            @PathVariable Long articleId,
            @RequestParam Long userId,
            @RequestParam int readingTime) {
        ReadingSession session = articleService.completeReading(userId, articleId, readingTime);
        return ResponseEntity.ok(ApiResponse.success(session));
    }

    /**
     * 获取用户阅读进度
     */
    @GetMapping("/{articleId}/reading/progress")
    @Operation(summary = "获取阅读进度", description = "获取用户对指定文章的阅读进度")
    public ResponseEntity<ApiResponse<ReadingProgress>> getUserReadingProgress(
            @PathVariable Long articleId,
            @RequestParam Long userId) {
        ReadingProgress progress = articleService.getUserReadingProgress(userId, articleId);
        return ResponseEntity.ok(ApiResponse.success(progress));
    }

    /**
     * 获取用户阅读历史
     */
    @GetMapping("/reading/history")
    @Operation(summary = "获取阅读历史", description = "获取用户的阅读历史记录")
    public ResponseEntity<ApiResponse<Page<ReadingSession>>> getUserReadingHistory(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<ReadingSession> history = articleService.getUserReadingHistory(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(history));
    }

    /**
     * 获取用户当前阅读
     */
    @GetMapping("/reading/current")
    @Operation(summary = "获取当前阅读", description = "获取用户当前正在阅读的文章")
    public ResponseEntity<ApiResponse<Page<ReadingProgress>>> getUserCurrentReading(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<ReadingProgress> current = articleService.getUserCurrentReading(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(current));
    }

    /**
     * 获取用户已完成阅读
     */
    @GetMapping("/reading/completed")
    @Operation(summary = "获取已完成阅读", description = "获取用户已完成阅读的文章")
    public ResponseEntity<ApiResponse<Page<ReadingSession>>> getUserCompletedReading(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<ReadingSession> completed = articleService.getUserCompletedReading(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(completed));
    }

    // ==================== 题目系统 ====================

    /**
     * 为文章添加题目
     */
    @PostMapping("/{articleId}/questions")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "添加题目", description = "为文章添加阅读理解题目")
    public ResponseEntity<ApiResponse<ReadingQuestion>> addQuestionToArticle(
            @PathVariable Long articleId,
            @RequestBody ReadingQuestion question) {
        ReadingQuestion savedQuestion = articleService.addQuestionToArticle(articleId, question);
        return ResponseEntity.ok(ApiResponse.success(savedQuestion));
    }

    /**
     * 批量添加题目
     */
    @PostMapping("/{articleId}/questions/batch")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "批量添加题目", description = "为文章批量添加题目")
    public ResponseEntity<ApiResponse<List<ReadingQuestion>>> addQuestionsToArticle(
            @PathVariable Long articleId,
            @RequestBody List<ReadingQuestion> questions) {
        List<ReadingQuestion> savedQuestions = articleService.addQuestionsToArticle(articleId, questions);
        return ResponseEntity.ok(ApiResponse.success(savedQuestions));
    }

    /**
     * 更新题目
     */
    @PutMapping("/questions/{questionId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "更新题目", description = "更新指定的题目")
    public ResponseEntity<ApiResponse<ReadingQuestion>> updateQuestion(
            @PathVariable Long questionId,
            @RequestBody ReadingQuestion question) {
        ReadingQuestion updatedQuestion = articleService.updateQuestion(questionId, question);
        return ResponseEntity.ok(ApiResponse.success(updatedQuestion));
    }

    /**
     * 删除题目
     */
    @DeleteMapping("/questions/{questionId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "删除题目", description = "删除指定的题目")
    public ResponseEntity<ApiResponse<Void>> deleteQuestion(@PathVariable Long questionId) {
        articleService.deleteQuestion(questionId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 获取文章的所有题目
     */
    @GetMapping("/{articleId}/questions")
    @Operation(summary = "获取文章题目", description = "获取指定文章的所有题目")
    public ResponseEntity<ApiResponse<List<ReadingQuestion>>> getQuestionsByArticle(@PathVariable Long articleId) {
        List<ReadingQuestion> questions = articleService.getQuestionsByArticle(articleId);
        return ResponseEntity.ok(ApiResponse.success(questions));
    }

    /**
     * 根据类型获取题目
     */
    @GetMapping("/{articleId}/questions/type/{questionType}")
    @Operation(summary = "根据类型获取题目", description = "根据题目类型获取文章的题目")
    public ResponseEntity<ApiResponse<List<ReadingQuestion>>> getQuestionsByType(
            @PathVariable Long articleId,
            @PathVariable ReadingQuestion.QuestionType questionType) {
        List<ReadingQuestion> questions = articleService.getQuestionsByType(articleId, questionType);
        return ResponseEntity.ok(ApiResponse.success(questions));
    }

    /**
     * 提交答案
     */
    @PostMapping("/questions/{questionId}/answer")
    @Operation(summary = "提交答案", description = "提交题目答案")
    public ResponseEntity<ApiResponse<Map<String, Object>>> submitAnswer(
            @PathVariable Long questionId,
            @RequestParam Long userId,
            @RequestParam String answer) {
        Map<String, Object> result = articleService.submitAnswer(userId, questionId, answer);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /**
     * 批量提交答案
     */
    @PostMapping("/questions/answers")
    @Operation(summary = "批量提交答案", description = "批量提交题目答案")
    public ResponseEntity<ApiResponse<Map<String, Object>>> submitAnswers(
            @RequestParam Long userId,
            @RequestBody Map<Long, String> answers) {
        Map<String, Object> result = articleService.submitAnswers(userId, answers);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /**
     * 获取用户答题记录
     */
    @GetMapping("/{articleId}/answers")
    @Operation(summary = "获取答题记录", description = "获取用户对指定文章的答题记录")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserAnswerRecord(
            @PathVariable Long articleId,
            @RequestParam Long userId) {
        Map<String, Object> record = articleService.getUserAnswerRecord(userId, articleId);
        return ResponseEntity.ok(ApiResponse.success(record));
    }

    /**
     * 获取用户答题统计
     */
    @GetMapping("/answers/statistics")
    @Operation(summary = "获取答题统计", description = "获取用户的答题统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserAnswerStatistics(@RequestParam Long userId) {
        Map<String, Object> statistics = articleService.getUserAnswerStatistics(userId);
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    // ==================== 文章收藏和标签 ====================

    /**
     * 收藏文章
     */
    @PostMapping("/{articleId}/favorite")
    @Operation(summary = "收藏文章", description = "收藏指定文章")
    public ResponseEntity<ApiResponse<Void>> favoriteArticle(
            @PathVariable Long articleId,
            @RequestParam Long userId) {
        articleService.favoriteArticle(userId, articleId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 取消收藏文章
     */
    @DeleteMapping("/{articleId}/favorite")
    @Operation(summary = "取消收藏", description = "取消收藏指定文章")
    public ResponseEntity<ApiResponse<Void>> unfavoriteArticle(
            @PathVariable Long articleId,
            @RequestParam Long userId) {
        articleService.unfavoriteArticle(userId, articleId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 获取用户收藏的文章
     */
    @GetMapping("/favorites")
    @Operation(summary = "获取收藏文章", description = "获取用户收藏的文章列表")
    public ResponseEntity<ApiResponse<Page<Article>>> getUserFavoriteArticles(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Article> favorites = articleService.getUserFavoriteArticles(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(favorites));
    }

    /**
     * 为文章添加标签
     */
    @PostMapping("/{articleId}/tags")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "添加标签", description = "为文章添加标签")
    public ResponseEntity<ApiResponse<Article>> addTagsToArticle(
            @PathVariable Long articleId,
            @RequestBody List<String> tags) {
        Article article = articleService.addTagsToArticle(articleId, tags);
        return ResponseEntity.ok(ApiResponse.success(article));
    }

    /**
     * 移除文章标签
     */
    @DeleteMapping("/{articleId}/tags")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "移除标签", description = "移除文章的指定标签")
    public ResponseEntity<ApiResponse<Article>> removeTagsFromArticle(
            @PathVariable Long articleId,
            @RequestBody List<String> tags) {
        Article article = articleService.removeTagsFromArticle(articleId, tags);
        return ResponseEntity.ok(ApiResponse.success(article));
    }

    /**
     * 获取所有文章标签
     */
    @GetMapping("/tags")
    @Operation(summary = "获取所有标签", description = "获取系统中所有的文章标签")
    public ResponseEntity<ApiResponse<List<String>>> getAllArticleTags() {
        List<String> tags = articleService.getAllArticleTags();
        return ResponseEntity.ok(ApiResponse.success(tags));
    }

    // ==================== 文章导入导出和统计 ====================

    /**
     * 从文件导入文章
     */
    @PostMapping("/import")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "导入文章", description = "从文件导入文章")
    public ResponseEntity<ApiResponse<Map<String, Object>>> importArticlesFromFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam String category) {
        Map<String, Object> result = articleService.importArticlesFromFile(file, category);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /**
     * 导出文章
     */
    @PostMapping("/export")
    @PreAuthorize("hasRole('ADMIN') or hasRole('TEACHER')")
    @Operation(summary = "导出文章", description = "导出指定文章")
    public ResponseEntity<byte[]> exportArticles(
            @RequestBody List<Long> articleIds,
            @RequestParam String format) {
        byte[] data = articleService.exportArticles(articleIds, format);
        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=articles." + format)
                .body(data);
    }

    /**
     * 导出用户阅读数据
     */
    @PostMapping("/export/reading-data")
    @Operation(summary = "导出阅读数据", description = "导出用户的阅读数据")
    public ResponseEntity<byte[]> exportUserReadingData(
            @RequestParam Long userId,
            @RequestParam String format) {
        byte[] data = articleService.exportUserReadingData(userId, format);
        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=reading-data." + format)
                .body(data);
    }

    /**
     * 获取文章统计信息
     */
    @GetMapping("/statistics")
    @Operation(summary = "获取文章统计", description = "获取文章的统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getArticleStatistics() {
        Map<String, Object> statistics = articleService.getArticleStatistics();
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    /**
     * 获取分类统计
     */
    @GetMapping("/statistics/category")
    @Operation(summary = "获取分类统计", description = "获取文章分类统计")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getCategoryStatistics() {
        Map<String, Long> statistics = articleService.getCategoryStatistics();
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    /**
     * 获取难度级别统计
     */
    @GetMapping("/statistics/level")
    @Operation(summary = "获取难度统计", description = "获取文章难度级别统计")
    public ResponseEntity<ApiResponse<Map<Article.DifficultyLevel, Long>>> getLevelStatistics() {
        Map<Article.DifficultyLevel, Long> statistics = articleService.getLevelStatistics();
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    /**
     * 获取类型统计
     */
    @GetMapping("/statistics/type")
    @Operation(summary = "获取类型统计", description = "获取文章类型统计")
    public ResponseEntity<ApiResponse<Map<Article.Category, Long>>> getTypeStatistics() {
        Map<Article.Category, Long> statistics = articleService.getTypeStatistics();
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    /**
     * 获取用户阅读趋势
     */
    @GetMapping("/statistics/reading-trend")
    @Operation(summary = "获取阅读趋势", description = "获取用户的阅读趋势")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getUserReadingTrend(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "30") int days) {
        List<Map<String, Object>> trend = articleService.getUserReadingTrend(userId, days);
        return ResponseEntity.ok(ApiResponse.success(trend));
    }

    /**
     * 获取用户阅读统计
     */
    @GetMapping("/statistics/user-reading")
    @Operation(summary = "获取用户阅读统计", description = "获取用户的阅读统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserReadingStatistics(@RequestParam Long userId) {
        Map<String, Object> statistics = articleService.getUserReadingStatistics(userId);
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    /**
     * 获取文章阅读排行
     */
    @GetMapping("/statistics/reading-ranking")
    @Operation(summary = "获取阅读排行", description = "获取文章阅读排行榜")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getArticleReadingRanking(
            @RequestParam(defaultValue = "10") int limit) {
        List<Map<String, Object>> ranking = articleService.getArticleReadingRanking(limit);
        return ResponseEntity.ok(ApiResponse.success(ranking));
    }

    /**
     * 获取用户阅读能力分析
     */
    @GetMapping("/statistics/ability-analysis")
    @Operation(summary = "获取能力分析", description = "获取用户的阅读能力分析")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserReadingAbilityAnalysis(@RequestParam Long userId) {
        Map<String, Object> analysis = articleService.getUserReadingAbilityAnalysis(userId);
        return ResponseEntity.ok(ApiResponse.success(analysis));
    }
}