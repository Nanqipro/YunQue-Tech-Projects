package com.nanqipro.repository;

import com.nanqipro.entity.AIRecommendation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * AI推荐记录数据访问接口
 */
@Repository
public interface AIRecommendationRepository extends JpaRepository<AIRecommendation, Long> {
    
    /**
     * 根据用户ID查询推荐记录
     */
    Page<AIRecommendation> findByUserId(Long userId, Pageable pageable);
    
    /**
     * 根据用户ID和推荐类型查询推荐记录
     */
    Page<AIRecommendation> findByUserIdAndRecommendationType(
            Long userId, AIRecommendation.RecommendationType recommendationType, Pageable pageable);
    
    /**
     * 根据用户ID和推荐项目ID查询推荐记录
     */
    Optional<AIRecommendation> findByUserIdAndRecommendedItemId(Long userId, Long recommendedItemId);
    
    /**
     * 查询用户未反馈的推荐记录
     */
    List<AIRecommendation> findByUserIdAndUserFeedbackIsNull(Long userId);
    
    /**
     * 查询用户高置信度的推荐记录
     */
    @Query("SELECT r FROM AIRecommendation r WHERE r.userId = :userId AND r.confidenceScore >= :minScore")
    List<AIRecommendation> findHighConfidenceRecommendations(
            @Param("userId") Long userId, @Param("minScore") BigDecimal minScore);
    
    /**
     * 查询用户在指定时间段内的推荐记录
     */
    List<AIRecommendation> findByUserIdAndCreatedAtBetween(
            Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 查询用户已点击的推荐记录
     */
    List<AIRecommendation> findByUserIdAndIsClickedTrue(Long userId);
    
    /**
     * 查询用户未点击的推荐记录
     */
    List<AIRecommendation> findByUserIdAndIsClickedFalse(Long userId);
    
    /**
     * 根据用户反馈查询推荐记录
     */
    List<AIRecommendation> findByUserIdAndUserFeedback(
            Long userId, AIRecommendation.UserFeedback userFeedback);
    
    /**
     * 统计用户推荐记录总数
     */
    long countByUserId(Long userId);
    
    /**
     * 统计用户指定类型的推荐记录数
     */
    long countByUserIdAndRecommendationType(
            Long userId, AIRecommendation.RecommendationType recommendationType);
    
    /**
     * 统计用户已点击的推荐记录数
     */
    long countByUserIdAndIsClickedTrue(Long userId);
    
    /**
     * 统计用户接受的推荐记录数
     */
    long countByUserIdAndUserFeedback(
            Long userId, AIRecommendation.UserFeedback userFeedback);
    
    /**
     * 查询推荐效果统计
     */
    @Query("SELECT r.recommendationType, COUNT(r), " +
           "SUM(CASE WHEN r.isClicked = true THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN r.userFeedback = 'ACCEPTED' THEN 1 ELSE 0 END), " +
           "AVG(r.confidenceScore) " +
           "FROM AIRecommendation r WHERE r.userId = :userId " +
           "GROUP BY r.recommendationType")
    List<Object[]> getRecommendationEffectivenessStats(@Param("userId") Long userId);
    
    /**
     * 查询用户推荐点击率
     */
    @Query("SELECT CAST(SUM(CASE WHEN r.isClicked = true THEN 1 ELSE 0 END) AS double) / COUNT(r) " +
           "FROM AIRecommendation r WHERE r.userId = :userId")
    Double getClickThroughRate(@Param("userId") Long userId);
    
    /**
     * 查询用户推荐接受率
     */
    @Query("SELECT CAST(SUM(CASE WHEN r.userFeedback = 'ACCEPTED' THEN 1 ELSE 0 END) AS double) / COUNT(r) " +
           "FROM AIRecommendation r WHERE r.userId = :userId AND r.userFeedback IS NOT NULL")
    Double getAcceptanceRate(@Param("userId") Long userId);
    
    /**
     * 查询最近的推荐记录
     */
    List<AIRecommendation> findTop10ByUserIdOrderByCreatedAtDesc(Long userId);
    
    /**
     * 查询用户最近未反馈的推荐记录
     */
    @Query("SELECT r FROM AIRecommendation r WHERE r.userId = :userId " +
           "AND r.userFeedback IS NULL " +
           "ORDER BY r.createdAt DESC")
    List<AIRecommendation> findRecentPendingRecommendations(@Param("userId") Long userId, Pageable pageable);
    
    /**
     * 删除用户过期的推荐记录
     */
    void deleteByUserIdAndCreatedAtBefore(Long userId, LocalDateTime expireTime);
    
    /**
     * 查询推荐类型分布统计
     */
    @Query("SELECT r.recommendationType, COUNT(r) " +
           "FROM AIRecommendation r WHERE r.userId = :userId " +
           "AND r.createdAt >= :startTime " +
           "GROUP BY r.recommendationType")
    List<Object[]> getRecommendationTypeDistribution(
            @Param("userId") Long userId, @Param("startTime") LocalDateTime startTime);
    
    /**
     * 查询每日推荐统计
     */
    @Query("SELECT DATE(r.createdAt), COUNT(r), " +
           "SUM(CASE WHEN r.isClicked = true THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN r.userFeedback = 'ACCEPTED' THEN 1 ELSE 0 END) " +
           "FROM AIRecommendation r WHERE r.userId = :userId " +
           "AND r.createdAt BETWEEN :startTime AND :endTime " +
           "GROUP BY DATE(r.createdAt) " +
           "ORDER BY DATE(r.createdAt)")
    List<Object[]> getDailyRecommendationStats(
            @Param("userId") Long userId, 
            @Param("startTime") LocalDateTime startTime, 
            @Param("endTime") LocalDateTime endTime);
    
    /**
     * 检查用户是否已有相同项目的推荐
     */
    boolean existsByUserIdAndRecommendedItemIdAndRecommendationType(
            Long userId, Long recommendedItemId, AIRecommendation.RecommendationType recommendationType);
}