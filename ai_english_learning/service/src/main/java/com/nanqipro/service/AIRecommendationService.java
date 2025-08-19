package com.nanqipro.service;

import com.nanqipro.entity.AIRecommendation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * AI推荐服务接口
 */
public interface AIRecommendationService {
    
    // ==================== 推荐生成 ====================
    
    /**
     * 为用户生成词汇推荐
     */
    List<AIRecommendation> generateVocabularyRecommendations(Long userId, int count);
    
    /**
     * 为用户生成文章推荐
     */
    List<AIRecommendation> generateArticleRecommendations(Long userId, int count);
    
    /**
     * 为用户生成练习推荐
     */
    List<AIRecommendation> generateExerciseRecommendations(Long userId, int count);
    
    /**
     * 为用户生成学习路径推荐
     */
    List<AIRecommendation> generateLearningPathRecommendations(Long userId, int count);
    
    /**
     * 生成个性化推荐（基于用户学习历史和偏好）
     */
    List<AIRecommendation> generatePersonalizedRecommendations(Long userId, int count);
    
    /**
     * 生成智能复习推荐
     */
    List<AIRecommendation> generateReviewRecommendations(Long userId, int count);
    
    // ==================== 推荐管理 ====================
    
    /**
     * 保存推荐记录
     */
    AIRecommendation saveRecommendation(AIRecommendation recommendation);
    
    /**
     * 批量保存推荐记录
     */
    List<AIRecommendation> saveRecommendations(List<AIRecommendation> recommendations);
    
    /**
     * 更新推荐记录
     */
    AIRecommendation updateRecommendation(AIRecommendation recommendation);
    
    /**
     * 删除推荐记录
     */
    void deleteRecommendation(Long recommendationId);
    
    /**
     * 批量删除推荐记录
     */
    void deleteRecommendations(List<Long> recommendationIds);
    
    // ==================== 用户反馈 ====================
    
    /**
     * 记录用户点击推荐
     */
    void recordClick(Long recommendationId, Long userId);
    
    /**
     * 记录用户反馈
     */
    void recordFeedback(Long recommendationId, Long userId, AIRecommendation.UserFeedback feedback);
    
    /**
     * 批量记录用户反馈
     */
    void batchRecordFeedback(List<Long> recommendationIds, Long userId, AIRecommendation.UserFeedback feedback);
    
    /**
     * 更新推荐置信度
     */
    void updateConfidenceScore(Long recommendationId, Double newScore);
    
    // ==================== 推荐查询 ====================
    
    /**
     * 根据ID获取推荐
     */
    AIRecommendation getRecommendationById(Long recommendationId);
    
    /**
     * 获取用户的推荐记录
     */
    Page<AIRecommendation> getUserRecommendations(Long userId, Pageable pageable);
    
    /**
     * 根据推荐类型获取用户推荐
     */
    List<AIRecommendation> getUserRecommendationsByType(
            Long userId, AIRecommendation.RecommendationType type);
    
    /**
     * 获取用户未点击的推荐
     */
    List<AIRecommendation> getUnclickedRecommendations(Long userId);
    
    /**
     * 获取用户高置信度推荐
     */
    List<AIRecommendation> getHighConfidenceRecommendations(Long userId, Double minConfidence);
    
    /**
     * 获取用户最新推荐
     */
    List<AIRecommendation> getLatestRecommendations(Long userId, int count);
    
    /**
     * 获取用户指定时间段的推荐
     */
    List<AIRecommendation> getRecommendationsByTimeRange(
            Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取推荐项目的推荐记录
     */
    List<AIRecommendation> getRecommendationsByItem(
            AIRecommendation.RecommendationType type, Long itemId);
    
    // ==================== 推荐统计 ====================
    
    /**
     * 获取用户推荐统计
     */
    Map<String, Object> getUserRecommendationStats(Long userId);
    
    /**
     * 获取推荐效果统计
     */
    Map<String, Object> getRecommendationEffectiveness(Long userId);
    
    /**
     * 获取推荐类型分布
     */
    Map<AIRecommendation.RecommendationType, Long> getRecommendationTypeDistribution(Long userId);
    
    /**
     * 获取推荐点击率统计
     */
    Map<String, Double> getClickRateStats(Long userId);
    
    /**
     * 获取推荐接受率统计
     */
    Map<String, Double> getAcceptanceRateStats(Long userId);
    
    /**
     * 获取每日推荐统计
     */
    List<Map<String, Object>> getDailyRecommendationStats(
            Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取推荐置信度分布
     */
    Map<String, Long> getConfidenceDistribution(Long userId);
    
    // ==================== 推荐算法 ====================
    
    /**
     * 基于协同过滤的推荐
     */
    List<AIRecommendation> getCollaborativeFilteringRecommendations(Long userId, int count);
    
    /**
     * 基于内容的推荐
     */
    List<AIRecommendation> getContentBasedRecommendations(Long userId, int count);
    
    /**
     * 混合推荐算法
     */
    List<AIRecommendation> getHybridRecommendations(Long userId, int count);
    
    /**
     * 基于学习进度的推荐
     */
    List<AIRecommendation> getLearningProgressBasedRecommendations(Long userId, int count);
    
    /**
     * 基于遗忘曲线的复习推荐
     */
    List<AIRecommendation> getForgettingCurveBasedRecommendations(Long userId, int count);
    
    /**
     * 基于学习目标的推荐
     */
    List<AIRecommendation> getGoalBasedRecommendations(Long userId, int count);
    
    // ==================== 推荐优化 ====================
    
    /**
     * 优化推荐算法参数
     */
    void optimizeRecommendationParameters(Long userId);
    
    /**
     * 更新用户推荐模型
     */
    void updateUserRecommendationModel(Long userId);
    
    /**
     * 计算推荐多样性
     */
    Double calculateRecommendationDiversity(List<AIRecommendation> recommendations);
    
    /**
     * 过滤重复推荐
     */
    List<AIRecommendation> filterDuplicateRecommendations(
            List<AIRecommendation> recommendations, Long userId);
    
    /**
     * 重新排序推荐列表
     */
    List<AIRecommendation> reorderRecommendations(
            List<AIRecommendation> recommendations, Long userId);
    
    // ==================== 推荐分析 ====================
    
    /**
     * 分析用户推荐偏好
     */
    Map<String, Object> analyzeUserPreferences(Long userId);
    
    /**
     * 分析推荐效果
     */
    Map<String, Object> analyzeRecommendationPerformance(Long userId);
    
    /**
     * 生成推荐报告
     */
    Map<String, Object> generateRecommendationReport(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 预测用户兴趣
     */
    Map<String, Double> predictUserInterests(Long userId);
    
    /**
     * 计算推荐准确率
     */
    Double calculateRecommendationAccuracy(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    // ==================== 系统管理 ====================
    
    /**
     * 清理过期推荐
     */
    void cleanupExpiredRecommendations(LocalDateTime expireTime);
    
    /**
     * 重新计算所有推荐的置信度
     */
    void recalculateAllConfidenceScores();
    
    /**
     * 导出推荐数据
     */
    List<Map<String, Object>> exportRecommendationData(Long userId);
    
    /**
     * 获取推荐系统健康状态
     */
    Map<String, Object> getRecommendationSystemHealth();
}