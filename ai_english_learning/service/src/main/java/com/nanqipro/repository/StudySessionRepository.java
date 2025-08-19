package com.nanqipro.repository;

import com.nanqipro.entity.StudySession;
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
 * 学习会话数据访问层
 */
@Repository
public interface StudySessionRepository extends JpaRepository<StudySession, Long> {
    
    /**
     * 根据用户ID查找学习会话（按开始时间降序）
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 学习会话分页列表
     */
    Page<StudySession> findByUserIdOrderByStartTimeDesc(Long userId, Pageable pageable);
    
    /**
     * 根据用户ID和状态查找学习会话
     * @param userId 用户ID
     * @param status 会话状态
     * @return 学习会话列表
     */
    List<StudySession> findByUserIdAndStatus(Long userId, StudySession.Status status);
    
    /**
     * 根据用户ID和会话类型查找学习会话
     * @param userId 用户ID
     * @param sessionType 会话类型
     * @param pageable 分页参数
     * @return 学习会话分页列表
     */
    Page<StudySession> findByUserIdAndSessionType(Long userId, StudySession.SessionType sessionType, Pageable pageable);
    
    /**
     * 根据用户ID查找最新的活跃会话
     * @param userId 用户ID
     * @return 最新的活跃会话
     */
    Optional<StudySession> findTopByUserIdAndStatusOrderByStartTimeDesc(Long userId, StudySession.Status status);
    
    /**
     * 根据用户ID和时间范围查找学习会话
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param pageable 分页参数
     * @return 学习会话分页列表
     */
    Page<StudySession> findByUserIdAndStartTimeBetween(Long userId, LocalDateTime startTime, 
                                                      LocalDateTime endTime, Pageable pageable);
    
    /**
     * 统计用户总学习时长
     * @param userId 用户ID
     * @return 总学习时长（秒）
     */
    @Query("SELECT COALESCE(SUM(s.duration), 0) FROM StudySession s WHERE s.user.id = :userId AND s.status = 'COMPLETED'")
    Long getTotalStudyDuration(@Param("userId") Long userId);
    
    /**
     * 统计用户指定时间段的学习时长
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 学习时长（秒）
     */
    @Query("SELECT COALESCE(SUM(s.duration), 0) FROM StudySession s WHERE s.user.id = :userId " +
           "AND s.startTime >= :startTime AND s.startTime <= :endTime AND s.status = 'COMPLETED'")
    Long getStudyDurationInPeriod(@Param("userId") Long userId, 
                                  @Param("startTime") LocalDateTime startTime, 
                                  @Param("endTime") LocalDateTime endTime);
    
    /**
     * 统计用户学习天数
     * @param userId 用户ID
     * @return 学习天数
     */
    @Query("SELECT COUNT(DISTINCT DATE(s.startTime)) FROM StudySession s WHERE s.user.id = :userId AND s.status = 'COMPLETED'")
    Long getStudyDaysCount(@Param("userId") Long userId);
    
    /**
     * 统计用户指定时间段的学习天数
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 学习天数
     */
    @Query("SELECT COUNT(DISTINCT DATE(s.startTime)) FROM StudySession s WHERE s.user.id = :userId " +
           "AND s.startTime >= :startTime AND s.startTime <= :endTime AND s.status = 'COMPLETED'")
    Long getStudyDaysInPeriod(@Param("userId") Long userId, 
                             @Param("startTime") LocalDateTime startTime, 
                             @Param("endTime") LocalDateTime endTime);
    
    /**
     * 获取用户每日学习统计
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 每日学习统计 [日期, 学习时长, 学习词汇数, 阅读文章数]
     */
    @Query("SELECT DATE(s.startTime) as date, " +
           "SUM(s.duration) as totalDuration, " +
           "SUM(s.wordsStudied) as totalWords, " +
           "SUM(s.articlesRead) as totalArticles " +
           "FROM StudySession s WHERE s.user.id = :userId " +
           "AND s.startTime >= :startTime AND s.startTime <= :endTime " +
           "AND s.status = 'COMPLETED' " +
           "GROUP BY DATE(s.startTime) " +
           "ORDER BY DATE(s.startTime)")
    List<Object[]> getDailyStudyStatistics(@Param("userId") Long userId, 
                                          @Param("startTime") LocalDateTime startTime, 
                                          @Param("endTime") LocalDateTime endTime);
    
    /**
     * 获取用户学习类型统计
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 学习类型统计 [会话类型, 次数, 总时长]
     */
    @Query("SELECT s.sessionType, COUNT(s), SUM(s.duration) " +
           "FROM StudySession s WHERE s.user.id = :userId " +
           "AND s.startTime >= :startTime AND s.startTime <= :endTime " +
           "AND s.status = 'COMPLETED' " +
           "GROUP BY s.sessionType")
    List<Object[]> getSessionTypeStatistics(@Param("userId") Long userId, 
                                           @Param("startTime") LocalDateTime startTime, 
                                           @Param("endTime") LocalDateTime endTime);
    
    /**
     * 获取用户学习成就统计
     * @param userId 用户ID
     * @return 学习成就统计 [总词汇数, 掌握词汇数, 总文章数, 总题目数, 正确题目数, 总积分]
     */
    @Query("SELECT SUM(s.wordsStudied), SUM(s.wordsMastered), SUM(s.articlesRead), " +
           "SUM(s.questionsAnswered), SUM(s.questionsCorrect), SUM(s.pointsEarned) " +
           "FROM StudySession s WHERE s.user.id = :userId AND s.status = 'COMPLETED'")
    Object[] getUserAchievementStatistics(@Param("userId") Long userId);
    
    /**
     * 获取用户连续学习天数
     * @param userId 用户ID
     * @return 连续学习天数
     */
    @Query(value = "SELECT COUNT(*) FROM (" +
           "SELECT DATE(start_time) as study_date " +
           "FROM study_sessions " +
           "WHERE user_id = :userId AND status = 'COMPLETED' " +
           "AND DATE(start_time) >= (" +
           "  SELECT MAX(DATE(start_time)) - INTERVAL (" +
           "    SELECT COUNT(*) - 1 FROM (" +
           "      SELECT DATE(start_time), " +
           "      ROW_NUMBER() OVER (ORDER BY DATE(start_time) DESC) - " +
           "      DATEDIFF(CURDATE(), DATE(start_time)) as diff " +
           "      FROM study_sessions " +
           "      WHERE user_id = :userId AND status = 'COMPLETED' " +
           "      GROUP BY DATE(start_time) " +
           "      ORDER BY DATE(start_time) DESC" +
           "    ) t WHERE diff = 0" +
           "  ) DAY FROM study_sessions WHERE user_id = :userId AND status = 'COMPLETED'" +
           ") " +
           "GROUP BY study_date" +
           ") continuous_days", nativeQuery = true)
    Integer getContinuousStudyDays(@Param("userId") Long userId);
}