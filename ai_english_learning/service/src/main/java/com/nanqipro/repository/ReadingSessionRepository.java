package com.nanqipro.repository;

import com.nanqipro.entity.ReadingSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 阅读会话数据访问层
 */
@Repository
public interface ReadingSessionRepository extends JpaRepository<ReadingSession, Long> {
    
    /**
     * 根据用户ID和文章ID查找最新的阅读会话
     * @param userId 用户ID
     * @param articleId 文章ID
     * @return 最新的阅读会话
     */
    Optional<ReadingSession> findTopByUserIdAndArticleIdOrderByStartTimeDesc(Long userId, Long articleId);
    
    /**
     * 根据用户ID和状态查找阅读会话
     * @param userId 用户ID
     * @param status 会话状态
     * @return 阅读会话列表
     */
    List<ReadingSession> findByUserIdAndStatus(Long userId, ReadingSession.Status status);
    
    /**
     * 根据用户ID查找所有阅读会话（按开始时间降序）
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 阅读会话分页列表
     */
    Page<ReadingSession> findByUserIdOrderByStartTimeDesc(Long userId, Pageable pageable);
    
    /**
     * 根据用户ID和文章ID查找所有阅读会话
     * @param userId 用户ID
     * @param articleId 文章ID
     * @return 阅读会话列表
     */
    List<ReadingSession> findByUserIdAndArticleId(Long userId, Long articleId);
    
    /**
     * 根据用户ID和会话类型查找阅读会话
     * @param userId 用户ID
     * @param sessionType 会话类型
     * @return 阅读会话列表
     */
    List<ReadingSession> findByUserIdAndSessionType(Long userId, ReadingSession.SessionType sessionType);
    
    /**
     * 根据文章ID查找所有阅读会话
     * @param articleId 文章ID
     * @return 阅读会话列表
     */
    List<ReadingSession> findByArticleId(Long articleId);
    
    /**
     * 根据时间范围查找用户的阅读会话
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 阅读会话列表
     */
    List<ReadingSession> findByUserIdAndStartTimeBetween(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 统计用户的总阅读会话数
     * @param userId 用户ID
     * @return 会话总数
     */
    long countByUserId(Long userId);
    
    /**
     * 统计用户已完成的阅读会话数
     * @param userId 用户ID
     * @return 已完成会话数
     */
    @Query("SELECT COUNT(rs) FROM ReadingSession rs WHERE rs.userId = :userId AND rs.status = 'COMPLETED'")
    long countCompletedByUserId(@Param("userId") Long userId);
    
    /**
     * 获取用户总阅读时长
     * @param userId 用户ID
     * @return 总阅读时长（秒）
     */
    @Query("SELECT COALESCE(SUM(rs.readingDuration), 0) FROM ReadingSession rs WHERE rs.userId = :userId")
    long getTotalReadingDurationByUserId(@Param("userId") Long userId);
    
    /**
     * 获取用户平均阅读速度
     * @param userId 用户ID
     * @return 平均阅读速度（词/分钟）
     */
    @Query("SELECT COALESCE(AVG(rs.readingSpeed), 0.0) FROM ReadingSession rs WHERE rs.userId = :userId AND rs.readingSpeed > 0")
    double getAverageReadingSpeedByUserId(@Param("userId") Long userId);
    
    /**
     * 获取用户平均理解度得分
     * @param userId 用户ID
     * @return 平均理解度得分
     */
    @Query("SELECT COALESCE(AVG(rs.comprehensionScore), 0.0) FROM ReadingSession rs WHERE rs.userId = :userId AND rs.comprehensionScore > 0")
    double getAverageComprehensionScoreByUserId(@Param("userId") Long userId);
    
    /**
     * 获取文章的平均阅读时长
     * @param articleId 文章ID
     * @return 平均阅读时长（秒）
     */
    @Query("SELECT COALESCE(AVG(rs.readingDuration), 0.0) FROM ReadingSession rs WHERE rs.articleId = :articleId AND rs.status = 'COMPLETED'")
    double getAverageReadingDurationByArticleId(@Param("articleId") Long articleId);
    
    /**
     * 获取文章的平均理解度得分
     * @param articleId 文章ID
     * @return 平均理解度得分
     */
    @Query("SELECT COALESCE(AVG(rs.comprehensionScore), 0.0) FROM ReadingSession rs WHERE rs.articleId = :articleId AND rs.comprehensionScore > 0")
    double getAverageComprehensionScoreByArticleId(@Param("articleId") Long articleId);
    
    /**
     * 删除用户的所有阅读会话
     * @param userId 用户ID
     */
    void deleteByUserId(Long userId);
    
    /**
     * 删除文章的所有阅读会话
     * @param articleId 文章ID
     */
    void deleteByArticleId(Long articleId);
    
    /**
     * 删除指定时间之前的阅读会话
     * @param beforeTime 时间点
     */
    void deleteByStartTimeBefore(LocalDateTime beforeTime);
}