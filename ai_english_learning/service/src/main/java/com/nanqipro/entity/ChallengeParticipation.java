package com.nanqipro.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * 挑战赛参与记录实体类
 */
@Entity
@Table(name = "challenge_participations")
public class ChallengeParticipation {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 挑战赛ID
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "challenge_id", nullable = false)
    private Challenge challenge;
    
    /**
     * 参与者用户ID
     */
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    /**
     * 参与状态
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ParticipationStatus status;
    
    /**
     * 当前得分
     */
    @Column(name = "current_score")
    private Integer currentScore = 0;
    
    /**
     * 最高得分
     */
    @Column(name = "best_score")
    private Integer bestScore = 0;
    
    /**
     * 完成进度（百分比）
     */
    @Column(name = "progress_percentage")
    private Double progressPercentage = 0.0;
    
    /**
     * 完成的任务数
     */
    @Column(name = "completed_tasks")
    private Integer completedTasks = 0;
    
    /**
     * 总任务数
     */
    @Column(name = "total_tasks")
    private Integer totalTasks = 0;
    
    /**
     * 排名
     */
    @Column(name = "ranking")
    private Integer ranking;
    
    /**
     * 获得的奖励积分
     */
    @Column(name = "reward_points")
    private Integer rewardPoints = 0;
    
    /**
     * 参与时间
     */
    @Column(name = "joined_at", nullable = false)
    private LocalDateTime joinedAt;
    
    /**
     * 完成时间
     */
    @Column(name = "completed_at")
    private LocalDateTime completedAt;
    
    /**
     * 最后活动时间
     */
    @Column(name = "last_activity_at")
    private LocalDateTime lastActivityAt;
    
    /**
     * 参与数据（JSON格式，存储详细的参与数据）
     */
    @Column(name = "participation_data", columnDefinition = "TEXT")
    private String participationData;
    
    /**
     * 备注
     */
    @Column(columnDefinition = "TEXT")
    private String notes;
    
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
     * 参与状态枚举
     */
    public enum ParticipationStatus {
        REGISTERED,   // 已报名
        ACTIVE,       // 参与中
        COMPLETED,    // 已完成
        ABANDONED,    // 已放弃
        DISQUALIFIED  // 被取消资格
    }
    
    // 构造函数
    public ChallengeParticipation() {
        this.createdAt = LocalDateTime.now();
        this.joinedAt = LocalDateTime.now();
        this.lastActivityAt = LocalDateTime.now();
        this.status = ParticipationStatus.REGISTERED;
        this.currentScore = 0;
        this.bestScore = 0;
        this.progressPercentage = 0.0;
        this.completedTasks = 0;
        this.totalTasks = 0;
        this.rewardPoints = 0;
    }
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
        this.lastActivityAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Challenge getChallenge() {
        return challenge;
    }
    
    public void setChallenge(Challenge challenge) {
        this.challenge = challenge;
    }
    
    public Long getUserId() {
        return userId;
    }
    
    public void setUserId(Long userId) {
        this.userId = userId;
    }
    
    public ParticipationStatus getStatus() {
        return status;
    }
    
    public void setStatus(ParticipationStatus status) {
        this.status = status;
    }
    
    public Integer getCurrentScore() {
        return currentScore;
    }
    
    public void setCurrentScore(Integer currentScore) {
        this.currentScore = currentScore;
        // 更新最高得分
        if (this.bestScore == null || currentScore > this.bestScore) {
            this.bestScore = currentScore;
        }
    }
    
    public Integer getBestScore() {
        return bestScore;
    }
    
    public void setBestScore(Integer bestScore) {
        this.bestScore = bestScore;
    }
    
    public Double getProgressPercentage() {
        return progressPercentage;
    }
    
    public void setProgressPercentage(Double progressPercentage) {
        this.progressPercentage = progressPercentage;
    }
    
    public Integer getCompletedTasks() {
        return completedTasks;
    }
    
    public void setCompletedTasks(Integer completedTasks) {
        this.completedTasks = completedTasks;
        // 自动计算进度百分比
        if (this.totalTasks != null && this.totalTasks > 0) {
            this.progressPercentage = (double) completedTasks / this.totalTasks * 100;
        }
    }
    
    public Integer getTotalTasks() {
        return totalTasks;
    }
    
    public void setTotalTasks(Integer totalTasks) {
        this.totalTasks = totalTasks;
        // 重新计算进度百分比
        if (totalTasks != null && totalTasks > 0 && this.completedTasks != null) {
            this.progressPercentage = (double) this.completedTasks / totalTasks * 100;
        }
    }
    
    public Integer getRanking() {
        return ranking;
    }
    
    public void setRanking(Integer ranking) {
        this.ranking = ranking;
    }
    
    public Integer getRewardPoints() {
        return rewardPoints;
    }
    
    public void setRewardPoints(Integer rewardPoints) {
        this.rewardPoints = rewardPoints;
    }
    
    public LocalDateTime getJoinedAt() {
        return joinedAt;
    }
    
    public void setJoinedAt(LocalDateTime joinedAt) {
        this.joinedAt = joinedAt;
    }
    
    public LocalDateTime getCompletedAt() {
        return completedAt;
    }
    
    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }
    
    public LocalDateTime getLastActivityAt() {
        return lastActivityAt;
    }
    
    public void setLastActivityAt(LocalDateTime lastActivityAt) {
        this.lastActivityAt = lastActivityAt;
    }
    
    public String getParticipationData() {
        return participationData;
    }
    
    public void setParticipationData(String participationData) {
        this.participationData = participationData;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
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
    
    /**
     * 检查是否已完成挑战
     */
    public boolean isCompleted() {
        return this.status == ParticipationStatus.COMPLETED;
    }
    
    /**
     * 检查是否正在参与
     */
    public boolean isActive() {
        return this.status == ParticipationStatus.ACTIVE;
    }
    
    /**
     * 标记为完成
     */
    public void markAsCompleted() {
        this.status = ParticipationStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
        this.progressPercentage = 100.0;
    }
    
    /**
     * 标记为放弃
     */
    public void markAsAbandoned() {
        this.status = ParticipationStatus.ABANDONED;
    }
}