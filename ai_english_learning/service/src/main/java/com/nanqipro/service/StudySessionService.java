package com.nanqipro.service;

import com.nanqipro.entity.StudySession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 学习会话服务接口
 */
public interface StudySessionService {
    
    // ==================== 会话管理 ====================
    
    /**
     * 开始学习会话
     * @param userId 用户ID
     * @param sessionType 会话类型
     * @param deviceType 设备类型
     * @param platform 平台
     * @return 学习会话
     */
    StudySession startSession(Long userId, StudySession.SessionType sessionType, 
                             String deviceType, String platform);
    
    /**
     * 结束学习会话
     * @param sessionId 会话ID
     * @param sessionNotes 会话备注
     * @return 更新后的学习会话
     */
    StudySession endSession(Long sessionId, String sessionNotes);
    
    /**
     * 暂停学习会话
     * @param sessionId 会话ID
     * @return 更新后的学习会话
     */
    StudySession pauseSession(Long sessionId);
    
    /**
     * 恢复学习会话
     * @param sessionId 会话ID
     * @return 更新后的学习会话
     */
    StudySession resumeSession(Long sessionId);
    
    /**
     * 放弃学习会话
     * @param sessionId 会话ID
     * @param reason 放弃原因
     * @return 更新后的学习会话
     */
    StudySession abandonSession(Long sessionId, String reason);
    
    /**
     * 更新会话进度
     * @param sessionId 会话ID
     * @param wordsStudied 学习词汇数
     * @param wordsMastered 掌握词汇数
     * @param articlesRead 阅读文章数
     * @param questionsAnswered 回答题目数
     * @param questionsCorrect 正确题目数
     * @param pointsEarned 获得积分
     * @return 更新后的学习会话
     */
    StudySession updateSessionProgress(Long sessionId, Integer wordsStudied, Integer wordsMastered,
                                      Integer articlesRead, Integer questionsAnswered, 
                                      Integer questionsCorrect, Integer pointsEarned);
    
    /**
     * 获取用户当前活跃会话
     * @param userId 用户ID
     * @return 活跃会话
     */
    StudySession getCurrentActiveSession(Long userId);
    
    /**
     * 获取学习会话详情
     * @param sessionId 会话ID
     * @return 学习会话
     */
    StudySession getSessionById(Long sessionId);
    
    // ==================== 会话查询 ====================
    
    /**
     * 获取用户学习会话历史
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 学习会话分页列表
     */
    Page<StudySession> getUserSessionHistory(Long userId, Pageable pageable);
    
    /**
     * 根据会话类型获取用户学习会话
     * @param userId 用户ID
     * @param sessionType 会话类型
     * @param pageable 分页参数
     * @return 学习会话分页列表
     */
    Page<StudySession> getUserSessionsByType(Long userId, StudySession.SessionType sessionType, Pageable pageable);
    
    /**
     * 根据时间范围获取用户学习会话
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param pageable 分页参数
     * @return 学习会话分页列表
     */
    Page<StudySession> getUserSessionsInPeriod(Long userId, LocalDateTime startTime, 
                                              LocalDateTime endTime, Pageable pageable);
    
    // ==================== 学习统计 ====================
    
    /**
     * 获取用户学习统计
     * @param userId 用户ID
     * @return 学习统计信息
     */
    Map<String, Object> getUserLearningStatistics(Long userId);
    
    /**
     * 获取用户指定时间段学习统计
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 学习统计信息
     */
    Map<String, Object> getUserLearningStatisticsInPeriod(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取用户每日学习统计
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 每日学习统计列表
     */
    List<Map<String, Object>> getUserDailyStatistics(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取用户学习类型统计
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 学习类型统计列表
     */
    List<Map<String, Object>> getUserSessionTypeStatistics(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取用户学习成就统计
     * @param userId 用户ID
     * @return 学习成就统计
     */
    Map<String, Object> getUserAchievementStatistics(Long userId);
    
    /**
     * 获取用户连续学习天数
     * @param userId 用户ID
     * @return 连续学习天数
     */
    Integer getUserContinuousStudyDays(Long userId);
    
    /**
     * 获取用户学习排行榜数据
     * @param userId 用户ID
     * @return 排行榜数据
     */
    Map<String, Object> getUserRankingData(Long userId);
    
    // ==================== 学习分析 ====================
    
    /**
     * 分析用户学习模式
     * @param userId 用户ID
     * @return 学习模式分析结果
     */
    Map<String, Object> analyzeUserLearningPattern(Long userId);
    
    /**
     * 获取用户学习建议
     * @param userId 用户ID
     * @return 学习建议
     */
    Map<String, Object> getUserLearningRecommendations(Long userId);
    
    /**
     * 计算用户学习效率
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 学习效率数据
     */
    Map<String, Object> calculateLearningEfficiency(Long userId, LocalDateTime startTime, LocalDateTime endTime);
}