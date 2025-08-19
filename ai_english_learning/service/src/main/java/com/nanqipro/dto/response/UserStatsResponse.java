package com.nanqipro.dto.response;

import lombok.Data;
import lombok.Builder;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 用户统计响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserStatsResponse {
    
    /**
     * 基础统计
     */
    private Long userId;
    private String username;
    private String nickname;
    private String avatarUrl;
    private Integer totalPoints;
    private Integer currentStreak;
    private Integer maxStreak;
    private Integer level;
    private Integer experiencePoints;
    
    /**
     * 学习统计
     */
    private Integer totalStudyDays;
    private Integer totalStudyHours;
    private Integer totalStudyMinutes;
    private Integer totalWordsLearned;
    private Integer totalWordsReviewed;
    private Integer totalArticlesRead;
    private Integer totalQuestionsAnswered;
    private Integer totalCorrectAnswers;
    private Double overallAccuracy;
    
    /**
     * 词汇统计
     */
    private Integer vocabularyMastered;
    private Integer vocabularyLearning;
    private Integer vocabularyReview;
    private Integer vocabularyDifficult;
    private Integer vocabularyFavorite;
    private Double vocabularyAccuracy;
    
    /**
     * 阅读统计
     */
    private Integer articlesCompleted;
    private Integer articlesInProgress;
    private Integer totalReadingTime;
    private Double averageReadingSpeed;
    private Double readingComprehension;
    
    /**
     * 今日统计
     */
    private Integer todayWordsLearned;
    private Integer todayStudyTime;
    private Integer todayPointsEarned;
    private Integer todayArticlesRead;
    private Boolean todayGoalAchieved;
    
    /**
     * 本周统计
     */
    private Integer weekWordsLearned;
    private Integer weekStudyTime;
    private Integer weekPointsEarned;
    private Integer weekArticlesRead;
    private List<Integer> weeklyProgress; // 7天的学习进度
    
    /**
     * 本月统计
     */
    private Integer monthWordsLearned;
    private Integer monthStudyTime;
    private Integer monthPointsEarned;
    private Integer monthArticlesRead;
    private List<Integer> monthlyProgress; // 30天的学习进度
    
    /**
     * 排名信息
     */
    private Integer pointsRank;
    private Integer streakRank;
    private Integer weeklyRank;
    private Integer monthlyRank;
    
    /**
     * 成就统计
     */
    private Integer totalAchievements;
    private Integer unlockedAchievements;
    private List<Map<String, Object>> recentAchievements;
    
    /**
     * 学习趋势
     */
    private List<Map<String, Object>> studyTrend; // 学习趋势数据
    private List<Map<String, Object>> accuracyTrend; // 准确率趋势
    private List<Map<String, Object>> vocabularyTrend; // 词汇量趋势
    
    /**
     * 学习分析
     */
    private String strongestSkill; // 最强技能
    private String weakestSkill; // 最弱技能
    private List<String> recommendedActions; // 推荐行动
    private Double learningEfficiency; // 学习效率
    
    /**
     * 时间分析
     */
    private String mostActiveTime; // 最活跃时间段
    private String preferredStudyDuration; // 偏好学习时长
    private Integer averageSessionTime; // 平均会话时间
    
    /**
     * 目标完成情况
     */
    private Integer dailyGoal;
    private Double dailyGoalCompletion;
    private Integer weeklyGoal;
    private Double weeklyGoalCompletion;
    private Integer monthlyGoal;
    private Double monthlyGoalCompletion;
    
    /**
     * 学习质量指标
     */
    private Double retentionRate; // 记忆保持率
    private Double improvementRate; // 进步率
    private Double consistencyScore; // 一致性分数
    private Double engagementScore; // 参与度分数
    
    /**
     * 最后更新时间
     */
    private LocalDateTime lastUpdated;
    
    /**
     * 计算学习效率
     */
    public Double calculateLearningEfficiency() {
        if (totalStudyHours == null || totalStudyHours == 0 || totalWordsLearned == null) {
            return 0.0;
        }
        return (double) totalWordsLearned / totalStudyHours;
    }
    
    /**
     * 计算总体进度
     */
    public Double calculateOverallProgress() {
        if (dailyGoal == null || dailyGoal == 0) {
            return 0.0;
        }
        return Math.min(100.0, (double) (todayWordsLearned != null ? todayWordsLearned : 0) / dailyGoal * 100);
    }
    
    /**
     * 获取学习等级
     */
    public String getLearningLevel() {
        if (totalPoints == null) {
            return "初学者";
        }
        if (totalPoints < 1000) {
            return "初学者";
        } else if (totalPoints < 5000) {
            return "进阶者";
        } else if (totalPoints < 15000) {
            return "熟练者";
        } else if (totalPoints < 50000) {
            return "专家";
        } else {
            return "大师";
        }
    }
    
    /**
     * 检查是否为活跃用户
     */
    public Boolean isActiveUser() {
        return currentStreak != null && currentStreak >= 3;
    }
    
    /**
     * 获取学习建议
     */
    public String getStudyRecommendation() {
        if (overallAccuracy != null && overallAccuracy < 0.7) {
            return "建议加强基础练习，提高准确率";
        }
        if (currentStreak != null && currentStreak == 0) {
            return "建议保持每日学习，建立学习习惯";
        }
        if (vocabularyAccuracy != null && vocabularyAccuracy < 0.8) {
            return "建议多复习已学词汇，巩固记忆";
        }
        return "继续保持良好的学习状态";
    }
}