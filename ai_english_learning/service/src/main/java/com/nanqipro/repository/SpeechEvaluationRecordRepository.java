package com.nanqipro.repository;

import com.nanqipro.entity.SpeechEvaluationRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 语音评估记录数据访问接口
 */
@Repository
public interface SpeechEvaluationRecordRepository extends JpaRepository<SpeechEvaluationRecord, Long> {
    
    /**
     * 根据用户ID查询语音评估记录
     */
    Page<SpeechEvaluationRecord> findByUserId(Long userId, Pageable pageable);
    
    /**
     * 根据用户ID和内容类型查询评估记录
     */
    List<SpeechEvaluationRecord> findByUserIdAndContentType(
            Long userId, SpeechEvaluationRecord.ContentType contentType);
    
    /**
     * 根据用户ID和词汇ID查询评估记录
     */
    List<SpeechEvaluationRecord> findByUserIdAndVocabularyId(Long userId, Long vocabularyId);
    
    /**
     * 根据用户ID和文章ID查询评估记录
     */
    List<SpeechEvaluationRecord> findByUserIdAndArticleId(Long userId, Long articleId);
    
    /**
     * 查询用户在指定时间段内的评估记录
     */
    List<SpeechEvaluationRecord> findByUserIdAndCreatedAtBetween(
            Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 查询用户最近的评估记录
     */
    List<SpeechEvaluationRecord> findTop10ByUserIdOrderByCreatedAtDesc(Long userId);
    
    /**
     * 查询用户高分评估记录（综合得分大于指定值）
     */
    List<SpeechEvaluationRecord> findByUserIdAndOverallScoreGreaterThan(
            Long userId, Double minScore);
    
    /**
     * 查询用户低分评估记录（综合得分小于指定值）
     */
    List<SpeechEvaluationRecord> findByUserIdAndOverallScoreLessThan(
            Long userId, Double maxScore);
    
    /**
     * 统计用户评估记录总数
     */
    long countByUserId(Long userId);
    
    /**
     * 统计用户指定内容类型的评估数
     */
    long countByUserIdAndContentType(
            Long userId, SpeechEvaluationRecord.ContentType contentType);
    
    /**
     * 统计用户高分评估数（综合得分大于指定值）
     */
    long countByUserIdAndOverallScoreGreaterThan(Long userId, Double minScore);
    
    /**
     * 查询用户平均综合得分
     */
    @Query("SELECT AVG(s.overallScore) FROM SpeechEvaluationRecord s " +
           "WHERE s.userId = :userId AND s.overallScore IS NOT NULL")
    Double getAverageOverallScore(@Param("userId") Long userId);
    
    /**
     * 查询用户平均发音得分
     */
    @Query("SELECT AVG(s.pronunciationScore) FROM SpeechEvaluationRecord s " +
           "WHERE s.userId = :userId AND s.pronunciationScore IS NOT NULL")
    Double getAveragePronunciationScore(@Param("userId") Long userId);
    
    /**
     * 查询用户平均流利度得分
     */
    @Query("SELECT AVG(s.fluencyScore) FROM SpeechEvaluationRecord s " +
           "WHERE s.userId = :userId AND s.fluencyScore IS NOT NULL")
    Double getAverageFluencyScore(@Param("userId") Long userId);
    
    /**
     * 查询用户平均准确度得分
     */
    @Query("SELECT AVG(s.accuracyScore) FROM SpeechEvaluationRecord s " +
           "WHERE s.userId = :userId AND s.accuracyScore IS NOT NULL")
    Double getAverageAccuracyScore(@Param("userId") Long userId);
    
    /**
     * 查询用户各维度得分统计
     */
    @Query("SELECT AVG(s.pronunciationScore), AVG(s.fluencyScore), " +
           "AVG(s.accuracyScore), AVG(s.overallScore) " +
           "FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "AND s.createdAt BETWEEN :startTime AND :endTime")
    Object[] getScoreStats(
            @Param("userId") Long userId, 
            @Param("startTime") LocalDateTime startTime, 
            @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查询用户内容类型分布统计
     */
    @Query("SELECT s.contentType, COUNT(s), AVG(s.overallScore) " +
           "FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "GROUP BY s.contentType")
    List<Object[]> getContentTypeDistribution(@Param("userId") Long userId);
    
    /**
     * 查询每日评估统计
     */
    @Query("SELECT DATE(s.createdAt), COUNT(s), AVG(s.overallScore), " +
           "AVG(s.pronunciationScore), AVG(s.fluencyScore), AVG(s.accuracyScore) " +
           "FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "AND s.createdAt BETWEEN :startTime AND :endTime " +
           "GROUP BY DATE(s.createdAt) " +
           "ORDER BY DATE(s.createdAt)")
    List<Object[]> getDailyEvaluationStats(
            @Param("userId") Long userId, 
            @Param("startTime") LocalDateTime startTime, 
            @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查询用户得分趋势
     */
    @Query("SELECT s.createdAt, s.overallScore, s.pronunciationScore, " +
           "s.fluencyScore, s.accuracyScore " +
           "FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "AND s.createdAt >= :startTime " +
           "ORDER BY s.createdAt")
    List<Object[]> getScoreTrend(
            @Param("userId") Long userId, @Param("startTime") LocalDateTime startTime);
    
    /**
     * 查询用户最佳表现记录
     */
    @Query("SELECT s FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "AND s.overallScore = (SELECT MAX(s2.overallScore) " +
           "FROM SpeechEvaluationRecord s2 WHERE s2.userId = :userId)")
    List<SpeechEvaluationRecord> getBestPerformanceRecords(@Param("userId") Long userId);
    
    /**
     * 查询用户需要改进的记录（得分低于平均值）
     */
    @Query("SELECT s FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "AND s.overallScore < (SELECT AVG(s2.overallScore) " +
           "FROM SpeechEvaluationRecord s2 WHERE s2.userId = :userId) " +
           "ORDER BY s.overallScore ASC")
    List<SpeechEvaluationRecord> getImprovementNeededRecords(
            @Param("userId") Long userId, Pageable pageable);
    
    /**
     * 查询用户进步最大的记录（与前一次相比）
     */
    @Query(value = "SELECT s1.* FROM speech_evaluation_records s1 " +
           "JOIN speech_evaluation_records s2 ON s1.user_id = s2.user_id " +
           "WHERE s1.user_id = :userId " +
           "AND s1.created_at > s2.created_at " +
           "AND s1.overall_score - s2.overall_score = " +
           "(SELECT MAX(s3.overall_score - s4.overall_score) " +
           "FROM speech_evaluation_records s3 " +
           "JOIN speech_evaluation_records s4 ON s3.user_id = s4.user_id " +
           "WHERE s3.user_id = :userId AND s3.created_at > s4.created_at)", 
           nativeQuery = true)
    List<SpeechEvaluationRecord> getBiggestImprovementRecords(@Param("userId") Long userId);
    
    /**
     * 查询用户词汇发音练习统计
     */
    @Query("SELECT s.vocabularyId, COUNT(s), AVG(s.pronunciationScore), " +
           "MAX(s.pronunciationScore), MIN(s.pronunciationScore) " +
           "FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "AND s.contentType = 'VOCABULARY' " +
           "AND s.vocabularyId IS NOT NULL " +
           "GROUP BY s.vocabularyId " +
           "ORDER BY COUNT(s) DESC")
    List<Object[]> getVocabularyPronunciationStats(@Param("userId") Long userId);
    
    /**
     * 查询用户文章朗读练习统计
     */
    @Query("SELECT s.articleId, COUNT(s), AVG(s.fluencyScore), " +
           "AVG(s.accuracyScore), AVG(s.overallScore) " +
           "FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "AND s.contentType = 'ARTICLE' " +
           "AND s.articleId IS NOT NULL " +
           "GROUP BY s.articleId " +
           "ORDER BY AVG(s.overallScore) DESC")
    List<Object[]> getArticleReadingStats(@Param("userId") Long userId);
    
    /**
     * 查询用户评估活跃时段统计
     */
    @Query("SELECT HOUR(s.createdAt), COUNT(s), AVG(s.overallScore) " +
           "FROM SpeechEvaluationRecord s WHERE s.userId = :userId " +
           "AND s.createdAt >= :startTime " +
           "GROUP BY HOUR(s.createdAt) " +
           "ORDER BY HOUR(s.createdAt)")
    List<Object[]> getHourlyEvaluationStats(
            @Param("userId") Long userId, @Param("startTime") LocalDateTime startTime);
    
    /**
     * 查询用户评估等级分布
     */
    @Query("SELECT " +
           "SUM(CASE WHEN s.overallScore >= 90 THEN 1 ELSE 0 END) as excellent, " +
           "SUM(CASE WHEN s.overallScore >= 80 AND s.overallScore < 90 THEN 1 ELSE 0 END) as good, " +
           "SUM(CASE WHEN s.overallScore >= 70 AND s.overallScore < 80 THEN 1 ELSE 0 END) as fair, " +
           "SUM(CASE WHEN s.overallScore >= 60 AND s.overallScore < 70 THEN 1 ELSE 0 END) as poor, " +
           "SUM(CASE WHEN s.overallScore < 60 THEN 1 ELSE 0 END) as fail " +
           "FROM SpeechEvaluationRecord s WHERE s.userId = :userId")
    Object[] getGradeDistribution(@Param("userId") Long userId);
    
    /**
     * 删除用户过期的评估记录
     */
    void deleteByUserIdAndCreatedAtBefore(Long userId, LocalDateTime expireTime);
    
    /**
     * 查询用户最近练习的词汇
     */
    @Query("SELECT DISTINCT s.vocabularyId FROM SpeechEvaluationRecord s " +
           "WHERE s.userId = :userId AND s.contentType = 'VOCABULARY' " +
           "AND s.vocabularyId IS NOT NULL " +
           "ORDER BY s.createdAt DESC")
    List<Long> getRecentPracticedVocabularies(@Param("userId") Long userId, Pageable pageable);
    
    /**
     * 查询用户最近朗读的文章
     */
    @Query("SELECT DISTINCT s.articleId FROM SpeechEvaluationRecord s " +
           "WHERE s.userId = :userId AND s.contentType = 'ARTICLE' " +
           "AND s.articleId IS NOT NULL " +
           "ORDER BY s.createdAt DESC")
    List<Long> getRecentReadArticles(@Param("userId") Long userId, Pageable pageable);
    
    /**
     * 检查用户是否练习过指定词汇
     */
    boolean existsByUserIdAndVocabularyId(Long userId, Long vocabularyId);
    
    /**
     * 检查用户是否朗读过指定文章
     */
    boolean existsByUserIdAndArticleId(Long userId, Long articleId);
}