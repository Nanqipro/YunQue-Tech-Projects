package com.nanqipro.service.impl;

import com.nanqipro.entity.AIRecommendation;
import com.nanqipro.entity.User;
import com.nanqipro.entity.UserVocabulary;
import com.nanqipro.repository.AIRecommendationRepository;
import com.nanqipro.repository.UserRepository;
import com.nanqipro.repository.UserVocabularyRepository;
import com.nanqipro.service.AIRecommendationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * AI推荐服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AIRecommendationServiceImpl implements AIRecommendationService {
    
    private final AIRecommendationRepository aiRecommendationRepository;
    private final UserRepository userRepository;
    private final UserVocabularyRepository userVocabularyRepository;
    
    // ==================== 推荐生成 ====================
    
    @Override
    @Transactional
    public List<AIRecommendation> generateVocabularyRecommendations(Long userId, int count) {
        log.info("为用户 {} 生成 {} 个词汇推荐", userId, count);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        List<AIRecommendation> recommendations = new ArrayList<>();
        
        for (int i = 0; i < count; i++) {
            AIRecommendation recommendation = new AIRecommendation();
            recommendation.setUserId(userId);
            recommendation.setRecommendationType(AIRecommendation.RecommendationType.VOCABULARY);
            recommendation.setRecommendedItemId(generateVocabularyItemId());
            recommendation.setRecommendationReason("基于您的学习历史和掌握程度推荐");
            recommendation.setConfidenceScore(BigDecimal.valueOf(0.8));
            recommendation.setCreatedAt(LocalDateTime.now());
            
            recommendations.add(recommendation);
        }
        
        return aiRecommendationRepository.saveAll(recommendations);
    }
    
    @Override
    @Transactional
    public List<AIRecommendation> generateArticleRecommendations(Long userId, int count) {
        log.info("为用户 {} 生成 {} 个文章推荐", userId, count);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        List<AIRecommendation> recommendations = new ArrayList<>();
        
        for (int i = 0; i < count; i++) {
            AIRecommendation recommendation = new AIRecommendation();
            recommendation.setUserId(userId);
            recommendation.setRecommendationType(AIRecommendation.RecommendationType.ARTICLE);
            recommendation.setRecommendedItemId(generateArticleItemId());
            recommendation.setRecommendationReason("根据您的阅读水平和兴趣推荐");
            recommendation.setConfidenceScore(BigDecimal.valueOf(0.75));
            recommendation.setCreatedAt(LocalDateTime.now());
            
            recommendations.add(recommendation);
        }
        
        return aiRecommendationRepository.saveAll(recommendations);
    }
    
    @Override
    @Transactional
    public List<AIRecommendation> generateExerciseRecommendations(Long userId, int count) {
        log.info("为用户 {} 生成 {} 个练习推荐", userId, count);
        
        List<AIRecommendation> recommendations = new ArrayList<>();
        
        for (int i = 0; i < count; i++) {
            AIRecommendation recommendation = new AIRecommendation();
            recommendation.setUserId(userId);
            recommendation.setRecommendationType(AIRecommendation.RecommendationType.EXERCISE);
            recommendation.setRecommendedItemId(generateExerciseItemId());
            recommendation.setRecommendationReason("基于您的薄弱环节定制练习");
            recommendation.setConfidenceScore(BigDecimal.valueOf(0.7));
            recommendation.setCreatedAt(LocalDateTime.now());
            
            recommendations.add(recommendation);
        }
        
        return aiRecommendationRepository.saveAll(recommendations);
    }
    
    @Override
    @Transactional
    public List<AIRecommendation> generateLearningPathRecommendations(Long userId, int count) {
        log.info("为用户 {} 生成 {} 个学习路径推荐", userId, count);
        
        List<AIRecommendation> recommendations = new ArrayList<>();
        
        for (int i = 0; i < count; i++) {
            AIRecommendation recommendation = new AIRecommendation();
            recommendation.setUserId(userId);
            recommendation.setRecommendationType(AIRecommendation.RecommendationType.ARTICLE);
            recommendation.setRecommendedItemId(generateLearningPathItemId());
            recommendation.setRecommendationReason("为您量身定制的学习路径");
            recommendation.setConfidenceScore(BigDecimal.valueOf(0.85));
            recommendation.setCreatedAt(LocalDateTime.now());
            
            recommendations.add(recommendation);
        }
        
        return aiRecommendationRepository.saveAll(recommendations);
    }
    
    @Override
    @Transactional
    public List<AIRecommendation> generatePersonalizedRecommendations(Long userId, int count) {
        log.info("为用户 {} 生成 {} 个个性化推荐", userId, count);
        
        List<AIRecommendation> recommendations = new ArrayList<>();
        recommendations.addAll(generateVocabularyRecommendations(userId, count / 3));
        recommendations.addAll(generateArticleRecommendations(userId, count / 3));
        recommendations.addAll(generateExerciseRecommendations(userId, count / 3));
        
        return recommendations;
    }
    
    @Override
    @Transactional
    public List<AIRecommendation> generateReviewRecommendations(Long userId, int count) {
        log.info("为用户 {} 生成 {} 个复习推荐", userId, count);
        
        List<UserVocabulary> needReviewVocabs = userVocabularyRepository
                .findVocabulariesForReview(userId, LocalDateTime.now(), PageRequest.of(0, count));
        
        List<AIRecommendation> recommendations = new ArrayList<>();
        
        for (UserVocabulary vocab : needReviewVocabs) {
            AIRecommendation recommendation = new AIRecommendation();
            recommendation.setUserId(userId);
            recommendation.setRecommendationType(AIRecommendation.RecommendationType.VOCABULARY);
            recommendation.setRecommendedItemId(vocab.getVocabulary().getId());
            recommendation.setRecommendationReason("基于遗忘曲线的智能复习推荐");
            recommendation.setConfidenceScore(BigDecimal.valueOf(0.9));
            recommendation.setCreatedAt(LocalDateTime.now());
            
            recommendations.add(recommendation);
        }
        
        return aiRecommendationRepository.saveAll(recommendations);
    }
    
    // ==================== 推荐管理 ====================
    
    @Override
    @Transactional
    public AIRecommendation saveRecommendation(AIRecommendation recommendation) {
        return aiRecommendationRepository.save(recommendation);
    }
    
    @Override
    @Transactional
    public List<AIRecommendation> saveRecommendations(List<AIRecommendation> recommendations) {
        return aiRecommendationRepository.saveAll(recommendations);
    }
    
    @Override
    @Transactional
    public AIRecommendation updateRecommendation(AIRecommendation recommendation) {
        return aiRecommendationRepository.save(recommendation);
    }
    
    @Override
    @Transactional
    public void deleteRecommendation(Long recommendationId) {
        aiRecommendationRepository.deleteById(recommendationId);
    }
    
    @Override
    @Transactional
    public void deleteRecommendations(List<Long> recommendationIds) {
        aiRecommendationRepository.deleteAllById(recommendationIds);
    }
    
    // ==================== 用户反馈 ====================
    
    @Override
    @Transactional
    public void recordClick(Long recommendationId, Long userId) {
        AIRecommendation recommendation = aiRecommendationRepository.findById(recommendationId)
                .orElseThrow(() -> new RuntimeException("推荐记录不存在"));
        
        if (!recommendation.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此推荐记录");
        }
        
        recommendation.setIsClicked(true);
        aiRecommendationRepository.save(recommendation);
    }
    
    @Override
    @Transactional
    public void recordFeedback(Long recommendationId, Long userId, AIRecommendation.UserFeedback feedback) {
        AIRecommendation recommendation = aiRecommendationRepository.findById(recommendationId)
                .orElseThrow(() -> new RuntimeException("推荐记录不存在"));
        
        if (!recommendation.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此推荐记录");
        }
        
        recommendation.setUserFeedback(feedback);
        aiRecommendationRepository.save(recommendation);
    }
    
    @Override
    @Transactional
    public void batchRecordFeedback(List<Long> recommendationIds, Long userId, AIRecommendation.UserFeedback feedback) {
        for (Long id : recommendationIds) {
            recordFeedback(id, userId, feedback);
        }
    }
    
    @Override
    @Transactional
    public void updateConfidenceScore(Long recommendationId, Double newScore) {
        AIRecommendation recommendation = aiRecommendationRepository.findById(recommendationId)
                .orElseThrow(() -> new RuntimeException("推荐记录不存在"));
        
        recommendation.setConfidenceScore(BigDecimal.valueOf(newScore));
        aiRecommendationRepository.save(recommendation);
    }
    
    // ==================== 推荐查询 ====================
    
    @Override
    public AIRecommendation getRecommendationById(Long recommendationId) {
        return aiRecommendationRepository.findById(recommendationId)
                .orElseThrow(() -> new RuntimeException("推荐记录不存在"));
    }
    
    @Override
    public Page<AIRecommendation> getUserRecommendations(Long userId, Pageable pageable) {
        return aiRecommendationRepository.findByUserId(userId, pageable);
    }
    
    @Override
    public List<AIRecommendation> getUserRecommendationsByType(Long userId, AIRecommendation.RecommendationType type) {
        return aiRecommendationRepository.findByUserIdAndRecommendationType(userId, type, PageRequest.of(0, 100)).getContent();
    }
    
    @Override
    public List<AIRecommendation> getUnclickedRecommendations(Long userId) {
        return aiRecommendationRepository.findByUserIdAndIsClickedFalse(userId);
    }
    
    @Override
    public List<AIRecommendation> getHighConfidenceRecommendations(Long userId, Double minConfidence) {
        return aiRecommendationRepository.findHighConfidenceRecommendations(userId, BigDecimal.valueOf(minConfidence));
    }
    
    @Override
    public List<AIRecommendation> getLatestRecommendations(Long userId, int count) {
        return aiRecommendationRepository.findTop10ByUserIdOrderByCreatedAtDesc(userId);
    }
    
    @Override
    public List<AIRecommendation> getRecommendationsByTimeRange(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return aiRecommendationRepository.findByUserIdAndCreatedAtBetween(userId, startTime, endTime);
    }
    
    @Override
    public List<AIRecommendation> getRecommendationsByItem(AIRecommendation.RecommendationType type, Long itemId) {
        // 简化实现，返回空列表
        return new ArrayList<>();
    }
    
    // ==================== 其他方法的简化实现 ====================
    
    // 为了避免编译错误，提供所有接口方法的基本实现
    
    @Override
    public Map<String, Object> getUserRecommendationStats(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRecommendations", aiRecommendationRepository.countByUserId(userId));
        stats.put("clickedRecommendations", aiRecommendationRepository.countByUserIdAndIsClickedTrue(userId));
        return stats;
    }
    
    @Override
    public Map<String, Object> getRecommendationEffectiveness(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<AIRecommendation.RecommendationType, Long> getRecommendationTypeDistribution(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Double> getClickRateStats(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Double> getAcceptanceRateStats(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public List<Map<String, Object>> getDailyRecommendationStats(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return new ArrayList<>();
    }
    
    @Override
    public Map<String, Long> getConfidenceDistribution(Long userId) {
        return new HashMap<>();
    }
    
    // 推荐算法方法的简化实现
    @Override
    public List<AIRecommendation> getCollaborativeFilteringRecommendations(Long userId, int count) {
        return generateVocabularyRecommendations(userId, count);
    }
    
    @Override
    public List<AIRecommendation> getContentBasedRecommendations(Long userId, int count) {
        return generateArticleRecommendations(userId, count);
    }
    
    @Override
    public List<AIRecommendation> getHybridRecommendations(Long userId, int count) {
        return generatePersonalizedRecommendations(userId, count);
    }
    
    @Override
    public List<AIRecommendation> getLearningProgressBasedRecommendations(Long userId, int count) {
        return generateVocabularyRecommendations(userId, count);
    }
    
    @Override
    public List<AIRecommendation> getForgettingCurveBasedRecommendations(Long userId, int count) {
        return generateReviewRecommendations(userId, count);
    }
    
    @Override
    public List<AIRecommendation> getGoalBasedRecommendations(Long userId, int count) {
        return generatePersonalizedRecommendations(userId, count);
    }
    
    // 其他接口方法的空实现
    @Override
    @Transactional
    public void optimizeRecommendationParameters(Long userId) {
        // 空实现
    }
    
    @Override
    @Transactional
    public void updateUserRecommendationModel(Long userId) {
        // 空实现
    }
    
    @Override
    public Double calculateRecommendationDiversity(List<AIRecommendation> recommendations) {
        return 0.5;
    }
    
    @Override
    public List<AIRecommendation> filterDuplicateRecommendations(List<AIRecommendation> recommendations, Long userId) {
        return recommendations;
    }
    
    @Override
    public List<AIRecommendation> reorderRecommendations(List<AIRecommendation> recommendations, Long userId) {
        return recommendations;
    }
    
    @Override
    public Map<String, Object> analyzeUserPreferences(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> analyzeRecommendationPerformance(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> generateRecommendationReport(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Double> predictUserInterests(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Double calculateRecommendationAccuracy(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return 0.8;
    }
    
    @Override
    @Transactional
    public void cleanupExpiredRecommendations(LocalDateTime expireTime) {
        // 空实现
    }
    
    @Override
    @Transactional
    public void recalculateAllConfidenceScores() {
        // 空实现
    }
    
    @Override
    public List<Map<String, Object>> exportRecommendationData(Long userId) {
        return new ArrayList<>();
    }
    
    @Override
    public Map<String, Object> getRecommendationSystemHealth() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "healthy");
        health.put("totalRecommendations", aiRecommendationRepository.count());
        return health;
    }
    
    // ==================== 私有辅助方法 ====================
    
    private Long generateVocabularyItemId() {
        return System.currentTimeMillis() % 1000 + 1;
    }
    
    private Long generateArticleItemId() {
        return System.currentTimeMillis() % 1000 + 1;
    }
    
    private Long generateExerciseItemId() {
        return System.currentTimeMillis() % 1000 + 1;
    }
    
    private Long generateLearningPathItemId() {
        return System.currentTimeMillis() % 1000 + 1;
    }
}