package com.nanqipro.service.impl;

import com.nanqipro.entity.StudySession;
import com.nanqipro.entity.User;
import com.nanqipro.repository.StudySessionRepository;
import com.nanqipro.repository.UserRepository;
import com.nanqipro.service.StudySessionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学习会话服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class StudySessionServiceImpl implements StudySessionService {
    
    private final StudySessionRepository studySessionRepository;
    private final UserRepository userRepository;
    
    // ==================== 会话管理 ====================
    
    @Override
    @Transactional
    public StudySession startSession(Long userId, StudySession.SessionType sessionType, 
                                    String deviceType, String platform) {
        log.info("Starting session for user {} with type {}", userId, sessionType);
        
        // 检查是否有活跃会话，如果有则先结束
        StudySession activeSession = getCurrentActiveSession(userId);
        if (activeSession != null) {
            log.warn("User {} has active session {}, ending it first", userId, activeSession.getId());
            endSession(activeSession.getId(), "Auto-ended due to new session start");
        }
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found: " + userId));
        
        StudySession session = new StudySession();
        session.setUser(user);
        session.setSessionType(sessionType);
        session.setStartTime(LocalDateTime.now());
        session.setStatus(StudySession.Status.ACTIVE);
        session.setDeviceType(deviceType);
        session.setPlatform(platform);
        
        return studySessionRepository.save(session);
    }
    
    @Override
    @Transactional
    public StudySession endSession(Long sessionId, String sessionNotes) {
        log.info("Ending session {}", sessionId);
        
        StudySession session = getSessionById(sessionId);
        if (session.getStatus() != StudySession.Status.ACTIVE && 
            session.getStatus() != StudySession.Status.PAUSED) {
            throw new RuntimeException("Session is not active or paused: " + sessionId);
        }
        
        LocalDateTime endTime = LocalDateTime.now();
        session.setEndTime(endTime);
        session.setStatus(StudySession.Status.COMPLETED);
        session.setSessionNotes(sessionNotes);
        
        // 计算总持续时间
        long duration = ChronoUnit.SECONDS.between(session.getStartTime(), endTime);
        session.setDuration(duration);
        
        // 计算表现分数和专注度分数
        calculatePerformanceScores(session);
        
        // 更新用户学习统计
        updateUserStudyStatistics(session);
        
        return studySessionRepository.save(session);
    }
    
    @Override
    @Transactional
    public StudySession pauseSession(Long sessionId) {
        log.info("Pausing session {}", sessionId);
        
        StudySession session = getSessionById(sessionId);
        if (session.getStatus() != StudySession.Status.ACTIVE) {
            throw new RuntimeException("Session is not active: " + sessionId);
        }
        
        session.setStatus(StudySession.Status.PAUSED);
        return studySessionRepository.save(session);
    }
    
    @Override
    @Transactional
    public StudySession resumeSession(Long sessionId) {
        log.info("Resuming session {}", sessionId);
        
        StudySession session = getSessionById(sessionId);
        if (session.getStatus() != StudySession.Status.PAUSED) {
            throw new RuntimeException("Session is not paused: " + sessionId);
        }
        
        session.setStatus(StudySession.Status.ACTIVE);
        return studySessionRepository.save(session);
    }
    
    @Override
    @Transactional
    public StudySession abandonSession(Long sessionId, String reason) {
        log.info("Abandoning session {} with reason: {}", sessionId, reason);
        
        StudySession session = getSessionById(sessionId);
        if (session.getStatus() == StudySession.Status.COMPLETED || 
            session.getStatus() == StudySession.Status.ABANDONED) {
            throw new RuntimeException("Session is already completed or abandoned: " + sessionId);
        }
        
        session.setEndTime(LocalDateTime.now());
        session.setStatus(StudySession.Status.ABANDONED);
        session.setSessionNotes(reason);
        
        return studySessionRepository.save(session);
    }
    
    @Override
    @Transactional
    public StudySession updateSessionProgress(Long sessionId, Integer wordsStudied, Integer wordsMastered,
                                             Integer articlesRead, Integer questionsAnswered, 
                                             Integer questionsCorrect, Integer pointsEarned) {
        log.debug("Updating session {} progress", sessionId);
        
        StudySession session = getSessionById(sessionId);
        if (session.getStatus() != StudySession.Status.ACTIVE) {
            throw new RuntimeException("Session is not active: " + sessionId);
        }
        
        if (wordsStudied != null) session.setWordsStudied(session.getWordsStudied() + wordsStudied);
        if (wordsMastered != null) session.setWordsMastered(session.getWordsMastered() + wordsMastered);
        if (articlesRead != null) session.setArticlesRead(session.getArticlesRead() + articlesRead);
        if (questionsAnswered != null) session.setQuestionsAnswered(session.getQuestionsAnswered() + questionsAnswered);
        if (questionsCorrect != null) session.setQuestionsCorrect(session.getQuestionsCorrect() + questionsCorrect);
        if (pointsEarned != null) session.setPointsEarned(session.getPointsEarned() + pointsEarned);
        
        return studySessionRepository.save(session);
    }
    
    @Override
    @Transactional(readOnly = true)
    public StudySession getCurrentActiveSession(Long userId) {
        return studySessionRepository.findTopByUserIdAndStatusOrderByStartTimeDesc(userId, StudySession.Status.ACTIVE)
            .orElse(null);
    }
    
    @Override
    @Transactional(readOnly = true)
    public StudySession getSessionById(Long sessionId) {
        return studySessionRepository.findById(sessionId)
            .orElseThrow(() -> new RuntimeException("Session not found: " + sessionId));
    }
    
    // ==================== 会话查询 ====================
    
    @Override
    @Transactional(readOnly = true)
    public Page<StudySession> getUserSessionHistory(Long userId, Pageable pageable) {
        return studySessionRepository.findByUserIdOrderByStartTimeDesc(userId, pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<StudySession> getUserSessionsByType(Long userId, StudySession.SessionType sessionType, Pageable pageable) {
        return studySessionRepository.findByUserIdAndSessionType(userId, sessionType, pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<StudySession> getUserSessionsInPeriod(Long userId, LocalDateTime startTime, 
                                                     LocalDateTime endTime, Pageable pageable) {
        return studySessionRepository.findByUserIdAndStartTimeBetween(userId, startTime, endTime, pageable);
    }
    
    // ==================== 学习统计 ====================
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserLearningStatistics(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        
        // 基础统计
        Long totalDuration = studySessionRepository.getTotalStudyDuration(userId);
        Long studyDays = studySessionRepository.getStudyDaysCount(userId);
        Integer continuousDays = studySessionRepository.getContinuousStudyDays(userId);
        
        // 成就统计
        Object[] achievements = studySessionRepository.getUserAchievementStatistics(userId);
        
        stats.put("totalStudyTime", totalDuration != null ? totalDuration : 0L);
        stats.put("totalStudyDays", studyDays != null ? studyDays : 0L);
        stats.put("continuousStudyDays", continuousDays != null ? continuousDays : 0);
        
        if (achievements != null) {
            stats.put("totalWordsStudied", achievements[0] != null ? achievements[0] : 0);
            stats.put("totalWordsMastered", achievements[1] != null ? achievements[1] : 0);
            stats.put("totalArticlesRead", achievements[2] != null ? achievements[2] : 0);
            stats.put("totalQuestionsAnswered", achievements[3] != null ? achievements[3] : 0);
            stats.put("totalQuestionsCorrect", achievements[4] != null ? achievements[4] : 0);
            stats.put("totalPointsEarned", achievements[5] != null ? achievements[5] : 0);
            
            // 计算正确率
            Long totalQuestions = (Long) achievements[3];
            Long correctQuestions = (Long) achievements[4];
            if (totalQuestions != null && totalQuestions > 0 && correctQuestions != null) {
                double accuracy = (double) correctQuestions / totalQuestions * 100;
                stats.put("overallAccuracy", Math.round(accuracy * 100.0) / 100.0);
            } else {
                stats.put("overallAccuracy", 0.0);
            }
        }
        
        return stats;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserLearningStatisticsInPeriod(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        Map<String, Object> stats = new HashMap<>();
        
        Long duration = studySessionRepository.getStudyDurationInPeriod(userId, startTime, endTime);
        Long studyDays = studySessionRepository.getStudyDaysInPeriod(userId, startTime, endTime);
        
        stats.put("studyTime", duration != null ? duration : 0L);
        stats.put("studyDays", studyDays != null ? studyDays : 0L);
        
        // 平均每日学习时长
        if (studyDays != null && studyDays > 0) {
            stats.put("averageDailyStudyTime", duration / studyDays);
        } else {
            stats.put("averageDailyStudyTime", 0L);
        }
        
        return stats;
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getUserDailyStatistics(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        List<Object[]> dailyStats = studySessionRepository.getDailyStudyStatistics(userId, startTime, endTime);
        
        return dailyStats.stream().map(row -> {
            Map<String, Object> dayStats = new HashMap<>();
            dayStats.put("date", row[0]);
            dayStats.put("studyTime", row[1] != null ? row[1] : 0L);
            dayStats.put("wordsLearned", row[2] != null ? row[2] : 0);
            dayStats.put("articlesRead", row[3] != null ? row[3] : 0);
            return dayStats;
        }).collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getUserSessionTypeStatistics(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        List<Object[]> typeStats = studySessionRepository.getSessionTypeStatistics(userId, startTime, endTime);
        
        return typeStats.stream().map(row -> {
            Map<String, Object> typeData = new HashMap<>();
            typeData.put("sessionType", row[0]);
            typeData.put("sessionCount", row[1] != null ? row[1] : 0L);
            typeData.put("totalDuration", row[2] != null ? row[2] : 0L);
            return typeData;
        }).collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserAchievementStatistics(Long userId) {
        Object[] achievements = studySessionRepository.getUserAchievementStatistics(userId);
        Map<String, Object> stats = new HashMap<>();
        
        if (achievements != null) {
            stats.put("totalWordsStudied", achievements[0] != null ? achievements[0] : 0);
            stats.put("totalWordsMastered", achievements[1] != null ? achievements[1] : 0);
            stats.put("totalArticlesRead", achievements[2] != null ? achievements[2] : 0);
            stats.put("totalQuestionsAnswered", achievements[3] != null ? achievements[3] : 0);
            stats.put("totalQuestionsCorrect", achievements[4] != null ? achievements[4] : 0);
            stats.put("totalPointsEarned", achievements[5] != null ? achievements[5] : 0);
        }
        
        return stats;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Integer getUserContinuousStudyDays(Long userId) {
        Integer days = studySessionRepository.getContinuousStudyDays(userId);
        return days != null ? days : 0;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserRankingData(Long userId) {
        Map<String, Object> ranking = new HashMap<>();
        
        // 获取用户统计数据
        Map<String, Object> userStats = getUserLearningStatistics(userId);
        
        // TODO: 实现排行榜逻辑，需要与其他用户比较
        ranking.put("userStats", userStats);
        ranking.put("studyTimeRank", 0);
        ranking.put("streakRank", 0);
        ranking.put("pointsRank", 0);
        
        return ranking;
    }
    
    // ==================== 学习分析 ====================
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> analyzeUserLearningPattern(Long userId) {
        Map<String, Object> analysis = new HashMap<>();
        
        // 获取最近30天的学习数据
        LocalDateTime endTime = LocalDateTime.now();
        LocalDateTime startTime = endTime.minusDays(30);
        
        List<Map<String, Object>> dailyStats = getUserDailyStatistics(userId, startTime, endTime);
        List<Map<String, Object>> typeStats = getUserSessionTypeStatistics(userId, startTime, endTime);
        
        // 分析学习频率
        analysis.put("learningFrequency", analyzeLearningFrequency(dailyStats));
        
        // 分析偏好的学习类型
        analysis.put("preferredSessionTypes", analyzePreferredSessionTypes(typeStats));
        
        // 分析学习效率趋势
        analysis.put("efficiencyTrend", analyzeEfficiencyTrend(dailyStats));
        
        return analysis;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserLearningRecommendations(Long userId) {
        Map<String, Object> recommendations = new HashMap<>();
        
        // 基于学习模式分析给出建议
        Map<String, Object> pattern = analyzeUserLearningPattern(userId);
        
        List<String> suggestions = new ArrayList<>();
        
        // 根据学习频率给建议
        String frequency = (String) pattern.get("learningFrequency");
        if ("low".equals(frequency)) {
            suggestions.add("建议增加学习频率，每天至少学习15分钟");
        } else if ("high".equals(frequency)) {
            suggestions.add("学习频率很好，继续保持");
        }
        
        // 根据学习类型给建议
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> preferredTypes = (List<Map<String, Object>>) pattern.get("preferredSessionTypes");
        if (preferredTypes != null && !preferredTypes.isEmpty()) {
            suggestions.add("尝试多样化学习内容，平衡词汇和阅读练习");
        }
        
        recommendations.put("suggestions", suggestions);
        recommendations.put("recommendedDailyGoal", calculateRecommendedDailyGoal(userId));
        
        return recommendations;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> calculateLearningEfficiency(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        Map<String, Object> efficiency = new HashMap<>();
        
        Map<String, Object> stats = getUserLearningStatisticsInPeriod(userId, startTime, endTime);
        Long totalTime = (Long) stats.get("studyTime");
        
        if (totalTime != null && totalTime > 0) {
            // 计算每分钟学习的词汇数、文章数等
            Map<String, Object> achievements = getUserAchievementStatistics(userId);
            
            Long wordsStudied = (Long) achievements.get("totalWordsStudied");
            Long articlesRead = (Long) achievements.get("totalArticlesRead");
            
            if (wordsStudied != null) {
                efficiency.put("wordsPerMinute", (double) wordsStudied / (totalTime / 60.0));
            }
            
            if (articlesRead != null) {
                efficiency.put("articlesPerHour", (double) articlesRead / (totalTime / 3600.0));
            }
        }
        
        return efficiency;
    }
    
    // ==================== 私有辅助方法 ====================
    
    private void calculatePerformanceScores(StudySession session) {
        // 计算表现分数（基于正确率和完成度）
        double performanceScore = 0.0;
        if (session.getQuestionsAnswered() > 0) {
            double accuracy = (double) session.getQuestionsCorrect() / session.getQuestionsAnswered();
            performanceScore = accuracy * 100;
        }
        session.setPerformanceScore(performanceScore);
        
        // 计算专注度分数（基于学习时长和效率）
        double focusScore = Math.min(100.0, session.getDuration() / 60.0 * 10); // 简化计算
        session.setFocusScore(focusScore);
    }
    
    private void updateUserStudyStatistics(StudySession session) {
        // 更新用户的学习统计信息
        User user = session.getUser();
        
        // 更新最后学习时间
        user.setLastStudyTime(LocalDateTime.now());
        
        // 更新总积分
        user.setTotalPoints(user.getTotalPoints() + session.getPointsEarned());
        
        userRepository.save(user);
    }
    
    private String analyzeLearningFrequency(List<Map<String, Object>> dailyStats) {
        if (dailyStats.size() < 7) return "low";
        if (dailyStats.size() > 20) return "high";
        return "medium";
    }
    
    private List<Map<String, Object>> analyzePreferredSessionTypes(List<Map<String, Object>> typeStats) {
        return typeStats.stream()
            .sorted((a, b) -> Long.compare((Long) b.get("totalDuration"), (Long) a.get("totalDuration")))
            .limit(3)
            .collect(Collectors.toList());
    }
    
    private String analyzeEfficiencyTrend(List<Map<String, Object>> dailyStats) {
        // 简化的趋势分析
        if (dailyStats.size() < 7) return "insufficient_data";
        
        // 比较前半段和后半段的平均学习时长
        int mid = dailyStats.size() / 2;
        double firstHalfAvg = dailyStats.subList(0, mid).stream()
            .mapToLong(stat -> (Long) stat.get("studyTime"))
            .average().orElse(0.0);
        
        double secondHalfAvg = dailyStats.subList(mid, dailyStats.size()).stream()
            .mapToLong(stat -> (Long) stat.get("studyTime"))
            .average().orElse(0.0);
        
        if (secondHalfAvg > firstHalfAvg * 1.1) return "improving";
        if (secondHalfAvg < firstHalfAvg * 0.9) return "declining";
        return "stable";
    }
    
    private Integer calculateRecommendedDailyGoal(Long userId) {
        // 基于用户历史数据计算推荐的每日学习目标（分钟）
        Map<String, Object> stats = getUserLearningStatistics(userId);
        Long totalTime = (Long) stats.get("totalStudyTime");
        Long totalDays = (Long) stats.get("totalStudyDays");
        
        if (totalDays != null && totalDays > 0 && totalTime != null) {
            long avgDailyTime = totalTime / totalDays / 60; // 转换为分钟
            return Math.max(15, (int) (avgDailyTime * 1.1)); // 建议比平均值高10%，最少15分钟
        }
        
        return 30; // 默认30分钟
    }
}