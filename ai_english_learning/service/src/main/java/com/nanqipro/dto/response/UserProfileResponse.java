package com.nanqipro.dto.response;

import com.nanqipro.entity.User;
import lombok.Data;
import lombok.Builder;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 用户资料响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
    
    private Long id;
    private String username;
    private String email;
    private String nickname;
    private String avatarUrl;
    private String phone;
    private User.Gender gender;
    private LocalDate birthDate;
    private User.EnglishLevel englishLevel;
    private String learningGoal;
    private Integer dailyGoal;
    private Integer totalPoints;
    private Integer currentStreak;
    private Integer maxStreak;
    private LocalDateTime lastLoginTime;
    private LocalDateTime lastStudyTime;
    private Boolean enabled;
    private Boolean emailVerified;
    private List<User.Role> roles;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    /**
     * 扩展信息
     */
    private String bio;
    private String timezone;
    private String language;
    
    /**
     * 通知设置
     */
    private Boolean emailNotification;
    private Boolean pushNotification;
    private Boolean studyReminder;
    
    /**
     * 隐私设置
     */
    private Boolean profilePublic;
    private Boolean showProgress;
    private Boolean showAchievements;
    
    /**
     * 学习统计
     */
    private Integer totalStudyDays;
    private Integer totalStudyHours;
    private Integer totalWordsLearned;
    private Integer totalArticlesRead;
    private Double averageAccuracy;
    
    /**
     * 成就信息
     */
    private List<Map<String, Object>> achievements;
    
    /**
     * 等级信息
     */
    private Integer level;
    private Integer experiencePoints;
    private Integer nextLevelPoints;
    
    /**
     * 今日学习进度
     */
    private Integer todayWordsLearned;
    private Integer todayStudyTime;
    private Boolean todayGoalAchieved;
    
    /**
     * 排名信息
     */
    private Integer pointsRank;
    private Integer streakRank;
    
    /**
     * 学习偏好
     */
    private Map<String, Object> preferences;
    
    /**
     * 从User实体创建UserProfileResponse
     */
    public static UserProfileResponse fromUser(User user) {
        return UserProfileResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .nickname(user.getNickname())
                .avatarUrl(user.getAvatarUrl())
                .phone(user.getPhoneNumber())
                .gender(user.getGender())
                .birthDate(user.getBirthDate() != null ? user.getBirthDate().toLocalDate() : null)
                .englishLevel(user.getEnglishLevel())
                .learningGoal(user.getLearningGoal())
                .dailyGoal(user.getDailyGoal())
                .totalPoints(user.getTotalPoints())
                .currentStreak(user.getCurrentStreak())
                .maxStreak(user.getMaxStreak())
                .lastLoginTime(user.getLastLoginTime())
                .lastStudyTime(user.getLastStudyTime())
                .enabled(user.getEnabled())
                .emailVerified(user.getEmailVerified())
                .roles(user.getRoles() != null ? List.copyOf(user.getRoles()) : List.of())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
    
    /**
     * 计算年龄
     */
    public Integer getAge() {
        if (birthDate == null) {
            return null;
        }
        return LocalDate.now().getYear() - birthDate.getYear();
    }
    
    /**
     * 获取学习天数
     */
    public Integer getStudyDays() {
        if (createdAt == null) {
            return 0;
        }
        return (int) java.time.Duration.between(createdAt, LocalDateTime.now()).toDays();
    }
    
    /**
     * 检查是否为新用户（注册7天内）
     */
    public Boolean isNewUser() {
        if (createdAt == null) {
            return false;
        }
        return createdAt.isAfter(LocalDateTime.now().minusDays(7));
    }
    
    /**
     * 检查是否为活跃用户（7天内有学习记录）
     */
    public Boolean isActiveUser() {
        if (lastStudyTime == null) {
            return false;
        }
        return lastStudyTime.isAfter(LocalDateTime.now().minusDays(7));
    }
}