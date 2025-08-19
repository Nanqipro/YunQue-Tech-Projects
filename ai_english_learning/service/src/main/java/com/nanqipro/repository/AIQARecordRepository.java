package com.nanqipro.repository;

import com.nanqipro.entity.AIQARecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * AI问答记录数据访问接口
 */
@Repository
public interface AIQARecordRepository extends JpaRepository<AIQARecord, Long> {
    
    /**
     * 根据用户ID查询问答记录
     */
    Page<AIQARecord> findByUserId(Long userId, Pageable pageable);
    
    /**
     * 根据用户ID和文章ID查询问答记录
     */
    List<AIQARecord> findByUserIdAndArticleId(Long userId, Long articleId);
    
    /**
     * 根据文章ID查询问答记录
     */
    List<AIQARecord> findByArticleId(Long articleId);
    
    /**
     * 根据用户ID和问题语言查询问答记录
     */
    List<AIQARecord> findByUserIdAndQuestionLanguage(
            Long userId, AIQARecord.Language questionLanguage);
    
    /**
     * 根据用户ID和回答语言查询问答记录
     */
    List<AIQARecord> findByUserIdAndAnswerLanguage(
            Long userId, AIQARecord.Language answerLanguage);
    
    /**
     * 查询用户在指定时间段内的问答记录
     */
    List<AIQARecord> findByUserIdAndCreatedAtBetween(
            Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 查询用户最近的问答记录
     */
    List<AIQARecord> findTop10ByUserIdOrderByCreatedAtDesc(Long userId);
    
    /**
     * 统计用户问答记录总数
     */
    long countByUserId(Long userId);
    
    /**
     * 统计用户指定语言的问题数
     */
    long countByUserIdAndQuestionLanguage(
            Long userId, AIQARecord.Language questionLanguage);
    
    /**
     * 统计用户指定语言的回答数
     */
    long countByUserIdAndAnswerLanguage(
            Long userId, AIQARecord.Language answerLanguage);
    
    /**
     * 统计文章相关的问答数
     */
    long countByArticleId(Long articleId);
    
    /**
     * 查询用户快速响应的问答记录（响应时间小于指定值）
     */
    @Query("SELECT q FROM AIQARecord q WHERE q.userId = :userId " +
           "AND q.responseTimeMs < :maxResponseTime")
    List<AIQARecord> findFastResponseRecords(
            @Param("userId") Long userId, @Param("maxResponseTime") Integer maxResponseTime);
    
    /**
     * 查询用户跨语言问答记录
     */
    @Query("SELECT q FROM AIQARecord q WHERE q.userId = :userId " +
           "AND q.questionLanguage != q.answerLanguage")
    List<AIQARecord> findCrossLanguageRecords(@Param("userId") Long userId);
    
    /**
     * 查询用户平均响应时间
     */
    @Query("SELECT AVG(q.responseTimeMs) FROM AIQARecord q WHERE q.userId = :userId " +
           "AND q.responseTimeMs IS NOT NULL")
    Double getAverageResponseTime(@Param("userId") Long userId);
    
    /**
     * 查询用户问答语言分布统计
     */
    @Query("SELECT q.questionLanguage, q.answerLanguage, COUNT(q) " +
           "FROM AIQARecord q WHERE q.userId = :userId " +
           "GROUP BY q.questionLanguage, q.answerLanguage")
    List<Object[]> getLanguageDistribution(@Param("userId") Long userId);
    
    /**
     * 查询每日问答统计
     */
    @Query("SELECT DATE(q.createdAt), COUNT(q), AVG(q.responseTimeMs) " +
           "FROM AIQARecord q WHERE q.userId = :userId " +
           "AND q.createdAt BETWEEN :startTime AND :endTime " +
           "GROUP BY DATE(q.createdAt) " +
           "ORDER BY DATE(q.createdAt)")
    List<Object[]> getDailyQAStats(
            @Param("userId") Long userId, 
            @Param("startTime") LocalDateTime startTime, 
            @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查询用户最活跃的问答文章
     */
    @Query("SELECT q.articleId, COUNT(q) " +
           "FROM AIQARecord q WHERE q.userId = :userId " +
           "AND q.articleId IS NOT NULL " +
           "GROUP BY q.articleId " +
           "ORDER BY COUNT(q) DESC")
    List<Object[]> getMostActiveArticles(@Param("userId") Long userId, Pageable pageable);
    
    /**
     * 查询用户问答活跃时段统计
     */
    @Query("SELECT HOUR(q.createdAt), COUNT(q) " +
           "FROM AIQARecord q WHERE q.userId = :userId " +
           "AND q.createdAt >= :startTime " +
           "GROUP BY HOUR(q.createdAt) " +
           "ORDER BY HOUR(q.createdAt)")
    List<Object[]> getHourlyActivityStats(
            @Param("userId") Long userId, @Param("startTime") LocalDateTime startTime);
    
    /**
     * 查询包含特定关键词的问答记录
     */
    @Query("SELECT q FROM AIQARecord q WHERE q.userId = :userId " +
           "AND (q.questionText LIKE %:keyword% OR q.answerText LIKE %:keyword%)")
    List<AIQARecord> findByKeyword(@Param("userId") Long userId, @Param("keyword") String keyword);
    
    /**
     * 删除用户过期的问答记录
     */
    void deleteByUserIdAndCreatedAtBefore(Long userId, LocalDateTime expireTime);
    
    /**
     * 查询用户问答效率统计
     */
    @Query("SELECT COUNT(q), " +
           "AVG(q.responseTimeMs), " +
           "MIN(q.responseTimeMs), " +
           "MAX(q.responseTimeMs), " +
           "SUM(CASE WHEN q.responseTimeMs < 2000 THEN 1 ELSE 0 END) " +
           "FROM AIQARecord q WHERE q.userId = :userId " +
           "AND q.responseTimeMs IS NOT NULL " +
           "AND q.createdAt BETWEEN :startTime AND :endTime")
    Object[] getQAEfficiencyStats(
            @Param("userId") Long userId, 
            @Param("startTime") LocalDateTime startTime, 
            @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查询用户最近的文章问答记录
     */
    @Query("SELECT q FROM AIQARecord q WHERE q.userId = :userId " +
           "AND q.articleId = :articleId " +
           "ORDER BY q.createdAt DESC")
    List<AIQARecord> findRecentArticleQA(
            @Param("userId") Long userId, 
            @Param("articleId") Long articleId, 
            Pageable pageable);
    
    /**
     * 检查用户是否对文章提过问题
     */
    boolean existsByUserIdAndArticleId(Long userId, Long articleId);
}