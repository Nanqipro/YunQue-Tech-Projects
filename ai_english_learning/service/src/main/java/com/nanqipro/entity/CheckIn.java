package com.nanqipro.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 打卡活动实体类
 */
@Entity
@Table(name = "check_ins")
public class CheckIn {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 打卡活动标题
     */
    @Column(nullable = false, length = 200)
    private String title;
    
    /**
     * 打卡活动描述
     */
    @Column(columnDefinition = "TEXT")
    private String description;
    
    /**
     * 打卡类型
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CheckInType type;
    
    /**
     * 打卡状态
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CheckInStatus status;
    
    /**
     * 打卡频率
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CheckInFrequency frequency;
    
    /**
     * 创建者ID
     */
    @Column(name = "creator_id", nullable = false)
    private Long creatorId;
    
    /**
     * 开始日期
     */
    @Column(name = "start_date", nullable = false)
    private LocalDateTime startDate;
    
    /**
     * 结束日期
     */
    @Column(name = "end_date")
    private LocalDateTime endDate;
    
    /**
     * 目标天数
     */
    @Column(name = "target_days")
    private Integer targetDays;
    
    /**
     * 每日目标积分
     */
    @Column(name = "daily_target_points")
    private Integer dailyTargetPoints;
    
    /**
     * 奖励积分
     */
    @Column(name = "reward_points")
    private Integer rewardPoints;
    
    /**
     * 连续打卡奖励倍数
     */
    @Column(name = "streak_multiplier")
    private Double streakMultiplier = 1.0;
    
    /**
     * 打卡规则（JSON格式）
     */
    @Column(columnDefinition = "TEXT")
    private String rules;
    
    /**
     * 打卡要求（JSON格式）
     */
    @Column(columnDefinition = "TEXT")
    private String requirements;
    
    /**
     * 封面图片URL
     */
    @Column(name = "cover_image")
    private String coverImage;
    
    /**
     * 是否公开
     */
    @Column(name = "is_public", nullable = false)
    private Boolean isPublic = true;
    
    /**
     * 是否允许补签
     */
    @Column(name = "allow_makeup", nullable = false)
    private Boolean allowMakeup = false;
    
    /**
     * 补签费用（积分）
     */
    @Column(name = "makeup_cost")
    private Integer makeupCost;
    
    /**
     * 最大补签天数
     */
    @Column(name = "max_makeup_days")
    private Integer maxMakeupDays;
    
    /**
     * 当前参与人数
     */
    @Column(name = "participant_count", nullable = false)
    private Integer participantCount = 0;
    
    /**
     * 创建时间
     */
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    /**
     * 打卡记录
     */
    @OneToMany(mappedBy = "checkIn", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<CheckInRecord> checkInRecords;
    
    /**
     * 打卡类型枚举
     */
    public enum CheckInType {
        DAILY_LEARNING,        // 每日学习
        VOCABULARY_PRACTICE,   // 词汇练习
        READING_PRACTICE,      // 阅读练习
        PRONUNCIATION_PRACTICE, // 发音练习
        STUDY_TIME,           // 学习时长
        EXERCISE_COMPLETION,   // 练习完成
        CUSTOM_TASK           // 自定义任务
    }
    
    /**
     * 打卡状态枚举
     */
    public enum CheckInStatus {
        DRAFT,      // 草稿
        ACTIVE,     // 进行中
        COMPLETED,  // 已完成
        PAUSED,     // 已暂停
        CANCELLED   // 已取消
    }
    
    /**
     * 打卡频率枚举
     */
    public enum CheckInFrequency {
        DAILY,      // 每日
        WEEKLY,     // 每周
        MONTHLY,    // 每月
        CUSTOM      // 自定义
    }
    
    // 构造函数
    public CheckIn() {
        this.createdAt = LocalDateTime.now();
        this.status = CheckInStatus.DRAFT;
        this.participantCount = 0;
        this.isPublic = true;
        this.allowMakeup = false;
        this.streakMultiplier = 1.0;
    }
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public CheckInType getType() {
        return type;
    }
    
    public void setType(CheckInType type) {
        this.type = type;
    }
    
    public CheckInStatus getStatus() {
        return status;
    }
    
    public void setStatus(CheckInStatus status) {
        this.status = status;
    }
    
    public CheckInFrequency getFrequency() {
        return frequency;
    }
    
    public void setFrequency(CheckInFrequency frequency) {
        this.frequency = frequency;
    }
    
    public Long getCreatorId() {
        return creatorId;
    }
    
    public void setCreatorId(Long creatorId) {
        this.creatorId = creatorId;
    }
    
    public LocalDateTime getStartDate() {
        return startDate;
    }
    
    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }
    
    public LocalDateTime getEndDate() {
        return endDate;
    }
    
    public void setEndDate(LocalDateTime endDate) {
        this.endDate = endDate;
    }
    
    public Integer getTargetDays() {
        return targetDays;
    }
    
    public void setTargetDays(Integer targetDays) {
        this.targetDays = targetDays;
    }
    
    public Integer getDailyTargetPoints() {
        return dailyTargetPoints;
    }
    
    public void setDailyTargetPoints(Integer dailyTargetPoints) {
        this.dailyTargetPoints = dailyTargetPoints;
    }
    
    public Integer getRewardPoints() {
        return rewardPoints;
    }
    
    public void setRewardPoints(Integer rewardPoints) {
        this.rewardPoints = rewardPoints;
    }
    
    public Double getStreakMultiplier() {
        return streakMultiplier;
    }
    
    public void setStreakMultiplier(Double streakMultiplier) {
        this.streakMultiplier = streakMultiplier;
    }
    
    public String getRules() {
        return rules;
    }
    
    public void setRules(String rules) {
        this.rules = rules;
    }
    
    public String getRequirements() {
        return requirements;
    }
    
    public void setRequirements(String requirements) {
        this.requirements = requirements;
    }
    
    public String getCoverImage() {
        return coverImage;
    }
    
    public void setCoverImage(String coverImage) {
        this.coverImage = coverImage;
    }
    
    public Boolean getIsPublic() {
        return isPublic;
    }
    
    public void setIsPublic(Boolean isPublic) {
        this.isPublic = isPublic;
    }
    
    public Boolean getAllowMakeup() {
        return allowMakeup;
    }
    
    public void setAllowMakeup(Boolean allowMakeup) {
        this.allowMakeup = allowMakeup;
    }
    
    public Integer getMakeupCost() {
        return makeupCost;
    }
    
    public void setMakeupCost(Integer makeupCost) {
        this.makeupCost = makeupCost;
    }
    
    public Integer getMaxMakeupDays() {
        return maxMakeupDays;
    }
    
    public void setMaxMakeupDays(Integer maxMakeupDays) {
        this.maxMakeupDays = maxMakeupDays;
    }
    
    public Integer getParticipantCount() {
        return participantCount;
    }
    
    public void setParticipantCount(Integer participantCount) {
        this.participantCount = participantCount;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public List<CheckInRecord> getCheckInRecords() {
        return checkInRecords;
    }
    
    public void setCheckInRecords(List<CheckInRecord> checkInRecords) {
        this.checkInRecords = checkInRecords;
    }
    
    /**
     * 检查是否正在进行中
     */
    public boolean isActive() {
        return this.status == CheckInStatus.ACTIVE;
    }
    
    /**
     * 检查是否已完成
     */
    public boolean isCompleted() {
        return this.status == CheckInStatus.COMPLETED;
    }
    
    /**
     * 检查是否在有效期内
     */
    public boolean isInValidPeriod() {
        LocalDateTime now = LocalDateTime.now();
        return now.isAfter(this.startDate) && 
               (this.endDate == null || now.isBefore(this.endDate));
    }
}