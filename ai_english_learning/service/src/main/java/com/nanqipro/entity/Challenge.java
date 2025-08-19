package com.nanqipro.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 挑战赛实体类
 */
@Entity
@Table(name = "challenges")
public class Challenge {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 挑战赛标题
     */
    @Column(nullable = false, length = 200)
    private String title;
    
    /**
     * 挑战赛描述
     */
    @Column(columnDefinition = "TEXT")
    private String description;
    
    /**
     * 挑战赛类型
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ChallengeType type;
    
    /**
     * 挑战赛状态
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ChallengeStatus status;
    
    /**
     * 难度等级
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DifficultyLevel difficulty;
    
    /**
     * 创建者ID
     */
    @Column(name = "creator_id", nullable = false)
    private Long creatorId;
    
    /**
     * 开始时间
     */
    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;
    
    /**
     * 结束时间
     */
    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;
    
    /**
     * 最大参与人数
     */
    @Column(name = "max_participants")
    private Integer maxParticipants;
    
    /**
     * 当前参与人数
     */
    @Column(name = "current_participants", nullable = false)
    private Integer currentParticipants = 0;
    
    /**
     * 奖励积分
     */
    @Column(name = "reward_points")
    private Integer rewardPoints;
    
    /**
     * 挑战规则（JSON格式）
     */
    @Column(columnDefinition = "TEXT")
    private String rules;
    
    /**
     * 挑战目标（JSON格式）
     */
    @Column(columnDefinition = "TEXT")
    private String targets;
    
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
     * 挑战赛参与记录
     */
    @OneToMany(mappedBy = "challenge", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<ChallengeParticipation> participations;
    
    /**
     * 挑战赛类型枚举
     */
    public enum ChallengeType {
        VOCABULARY_LEARNING,    // 词汇学习
        READING_COMPREHENSION,  // 阅读理解
        PRONUNCIATION_PRACTICE, // 发音练习
        DAILY_CHECK_IN,        // 每日打卡
        SPEED_CHALLENGE,       // 速度挑战
        ACCURACY_CHALLENGE,    // 准确度挑战
        ENDURANCE_CHALLENGE,   // 耐力挑战
        MIXED_CHALLENGE        // 综合挑战
    }
    
    /**
     * 挑战赛状态枚举
     */
    public enum ChallengeStatus {
        DRAFT,      // 草稿
        PUBLISHED,  // 已发布
        ACTIVE,     // 进行中
        COMPLETED,  // 已完成
        CANCELLED   // 已取消
    }
    
    /**
     * 难度等级枚举
     */
    public enum DifficultyLevel {
        BEGINNER,     // 初级
        INTERMEDIATE, // 中级
        ADVANCED,     // 高级
        EXPERT        // 专家级
    }
    
    // 构造函数
    public Challenge() {
        this.createdAt = LocalDateTime.now();
        this.status = ChallengeStatus.DRAFT;
        this.currentParticipants = 0;
        this.isPublic = true;
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
    
    public ChallengeType getType() {
        return type;
    }
    
    public void setType(ChallengeType type) {
        this.type = type;
    }
    
    public ChallengeStatus getStatus() {
        return status;
    }
    
    public void setStatus(ChallengeStatus status) {
        this.status = status;
    }
    
    public DifficultyLevel getDifficulty() {
        return difficulty;
    }
    
    public void setDifficulty(DifficultyLevel difficulty) {
        this.difficulty = difficulty;
    }
    
    public Long getCreatorId() {
        return creatorId;
    }
    
    public void setCreatorId(Long creatorId) {
        this.creatorId = creatorId;
    }
    
    public LocalDateTime getStartTime() {
        return startTime;
    }
    
    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }
    
    public LocalDateTime getEndTime() {
        return endTime;
    }
    
    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }
    
    public Integer getMaxParticipants() {
        return maxParticipants;
    }
    
    public void setMaxParticipants(Integer maxParticipants) {
        this.maxParticipants = maxParticipants;
    }
    
    public Integer getCurrentParticipants() {
        return currentParticipants;
    }
    
    public void setCurrentParticipants(Integer currentParticipants) {
        this.currentParticipants = currentParticipants;
    }
    
    public Integer getRewardPoints() {
        return rewardPoints;
    }
    
    public void setRewardPoints(Integer rewardPoints) {
        this.rewardPoints = rewardPoints;
    }
    
    public String getRules() {
        return rules;
    }
    
    public void setRules(String rules) {
        this.rules = rules;
    }
    
    public String getTargets() {
        return targets;
    }
    
    public void setTargets(String targets) {
        this.targets = targets;
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
    
    public List<ChallengeParticipation> getParticipations() {
        return participations;
    }
    
    public void setParticipations(List<ChallengeParticipation> participations) {
        this.participations = participations;
    }
}