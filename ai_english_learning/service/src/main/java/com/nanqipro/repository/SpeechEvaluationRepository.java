package com.nanqipro.repository;

import com.nanqipro.entity.SpeechEvaluation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 语音评估记录数据访问接口
 */
@Repository
public interface SpeechEvaluationRepository extends JpaRepository<SpeechEvaluation, Long> {
    
    /**
     * 根据用户ID查找评估记录
     */
    Page<SpeechEvaluation> findByUserId(Long userId, Pageable pageable);
    
    /**
     * 根据用户ID和内容类型查找评估记录
     */
    List<SpeechEvaluation> findByUserIdAndContentType(Long userId, SpeechEvaluation.ContentType contentType);
    
    /**
     * 根据用户ID、内容类型和内容ID查找评估记录
     */
    List<SpeechEvaluation> findByUserIdAndContentTypeAndContentId(Long userId, SpeechEvaluation.ContentType contentType, Long contentId);
    
    /**
     * 获取用户最近的评估记录
     */
    List<SpeechEvaluation> findTop10ByUserIdOrderByCreatedAtDesc(Long userId);
    
    /**
     * 根据时间范围查找评估记录
     */
    List<SpeechEvaluation> findByUserIdAndCreatedAtBetween(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 根据综合分数范围查找评估记录
     */
    List<SpeechEvaluation> findByUserIdAndOverallScoreGreaterThanEqual(Long userId, BigDecimal minScore);
    
    List<SpeechEvaluation> findByUserIdAndOverallScoreLessThanEqual(Long userId, BigDecimal maxScore);
    
    List<SpeechEvaluation> findByUserIdAndOverallScoreLessThan(Long userId, BigDecimal threshold);
    
    /**
     * 获取用户最佳表现记录
     */
    List<SpeechEvaluation> findTop5ByUserIdAndContentTypeOrderByOverallScoreDesc(Long userId, SpeechEvaluation.ContentType contentType);
    
    /**
     * 统计用户评估记录总数
     */
    long countByUserId(Long userId);
    
    /**
     * 获取用户平均分数
     */
    @Query("SELECT AVG(se.overallScore) FROM SpeechEvaluation se WHERE se.userId = :userId")
    BigDecimal getAverageScoreByUserId(@Param("userId") Long userId);
    
    /**
     * 根据内容类型统计评估记录数量
     */
    @Query("SELECT se.contentType, COUNT(se) FROM SpeechEvaluation se WHERE se.userId = :userId GROUP BY se.contentType")
    List<Object[]> getContentTypeDistribution(@Param("userId") Long userId);
    
    /**
     * 获取用户每日评估统计
     */
    @Query("SELECT DATE(se.createdAt), COUNT(se), AVG(se.overallScore) FROM SpeechEvaluation se " +
           "WHERE se.userId = :userId AND se.createdAt BETWEEN :startTime AND :endTime " +
           "GROUP BY DATE(se.createdAt) ORDER BY DATE(se.createdAt)")
    List<Object[]> getDailyEvaluationStats(@Param("userId") Long userId, 
                                          @Param("startTime") LocalDateTime startTime, 
                                          @Param("endTime") LocalDateTime endTime);
    
    /**
     * 获取用户分数趋势
     */
    @Query("SELECT se.createdAt, se.overallScore FROM SpeechEvaluation se " +
           "WHERE se.userId = :userId AND se.createdAt BETWEEN :startTime AND :endTime " +
           "ORDER BY se.createdAt")
    List<Object[]> getScoreTrends(@Param("userId") Long userId, 
                                 @Param("startTime") LocalDateTime startTime, 
                                 @Param("endTime") LocalDateTime endTime);
    
    /**
     * 获取用户词汇发音统计
     */
    @Query("SELECT AVG(se.pronunciationScore), AVG(se.fluencyScore), AVG(se.rhythmScore), AVG(se.intonationScore) " +
           "FROM SpeechEvaluation se WHERE se.userId = :userId AND se.contentType = 'VOCABULARY'")
    Object[] getVocabularyPronunciationStats(@Param("userId") Long userId);
    
    /**
     * 获取用户文章朗读统计
     */
    @Query("SELECT AVG(se.pronunciationScore), AVG(se.fluencyScore), AVG(se.rhythmScore), AVG(se.intonationScore) " +
           "FROM SpeechEvaluation se WHERE se.userId = :userId AND se.contentType = 'ARTICLE'")
    Object[] getArticleReadingStats(@Param("userId") Long userId);
    
    /**
     * 获取用户活跃时段统计
     */
    @Query("SELECT HOUR(se.createdAt), COUNT(se) FROM SpeechEvaluation se " +
           "WHERE se.userId = :userId GROUP BY HOUR(se.createdAt) ORDER BY HOUR(se.createdAt)")
    List<Object[]> getActiveTimeStats(@Param("userId") Long userId);
    
    /**
     * 获取分数等级分布
     */
    @Query("SELECT CASE " +
           "WHEN se.overallScore >= 90 THEN '优秀' " +
           "WHEN se.overallScore >= 80 THEN '良好' " +
           "WHEN se.overallScore >= 70 THEN '中等' " +
           "WHEN se.overallScore >= 60 THEN '及格' " +
           "ELSE '需要改进' END, COUNT(se) " +
           "FROM SpeechEvaluation se WHERE se.userId = :userId GROUP BY " +
           "CASE WHEN se.overallScore >= 90 THEN '优秀' " +
           "WHEN se.overallScore >= 80 THEN '良好' " +
           "WHEN se.overallScore >= 70 THEN '中等' " +
           "WHEN se.overallScore >= 60 THEN '及格' " +
           "ELSE '需要改进' END")
    List<Object[]> getScoreLevelDistribution(@Param("userId") Long userId);
    
    /**
     * 获取用户发音模式分析
     */
    @Query("SELECT se.contentType, AVG(se.pronunciationScore), AVG(se.fluencyScore), " +
           "AVG(se.rhythmScore), AVG(se.intonationScore), COUNT(se) " +
           "FROM SpeechEvaluation se WHERE se.userId = :userId " +
           "GROUP BY se.contentType")
    List<Object[]> getPronunciationPatterns(@Param("userId") Long userId);
    
    /**
     * 获取学习进步分析
     */
    @Query("SELECT DATE(se.createdAt), AVG(se.overallScore), COUNT(se) " +
           "FROM SpeechEvaluation se WHERE se.userId = :userId " +
           "AND se.createdAt BETWEEN :startTime AND :endTime " +
           "GROUP BY DATE(se.createdAt) ORDER BY DATE(se.createdAt)")
    List<Object[]> getLearningProgress(@Param("userId") Long userId, 
                                      @Param("startTime") LocalDateTime startTime, 
                                      @Param("endTime") LocalDateTime endTime);
    
    /**
     * 删除过期记录
     */
    void deleteByCreatedAtBefore(LocalDateTime expireTime);
    
    /**
     * 获取系统总评估数量
     */
    @Query("SELECT COUNT(se) FROM SpeechEvaluation se")
    long getTotalEvaluationCount();
    
    /**
     * 获取今日评估数量
     */
    @Query("SELECT COUNT(se) FROM SpeechEvaluation se WHERE DATE(se.createdAt) = CURRENT_DATE")
    long getTodayEvaluationCount();
    
    /**
     * 获取系统平均分数
     */
    @Query("SELECT AVG(se.overallScore) FROM SpeechEvaluation se")
    BigDecimal getSystemAverageScore();
}