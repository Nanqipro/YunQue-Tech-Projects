package com.nanqipro.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 阅读进度实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "reading_progress", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "article_id"}))
public class ReadingProgress {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Column(name = "article_id", nullable = false)
    private Long articleId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", insertable = false, updatable = false)
    private Article article;
    
    @Column(name = "progress_percentage", nullable = false)
    private Integer progressPercentage = 0; // 阅读进度百分比 (0-100)
    
    @Column(name = "current_position", nullable = false)
    private Integer currentPosition = 0; // 当前阅读位置（字符位置或段落位置）
    
    @Column(name = "total_reading_time", nullable = false)
    private Integer totalReadingTime = 0; // 总阅读时间（秒）
    
    @Column(name = "session_count", nullable = false)
    private Integer sessionCount = 0; // 阅读会话次数
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.IN_PROGRESS;
    
    @Column(name = "is_bookmarked", nullable = false)
    private Boolean isBookmarked = false;
    
    @Column(name = "is_favorited", nullable = false)
    private Boolean isFavorited = false;
    
    @Column(name = "last_read_at")
    private LocalDateTime lastReadAt;
    
    @Column(name = "completed_at")
    private LocalDateTime completedAt;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 阅读状态枚举
     */
    public enum Status {
        NOT_STARTED("未开始"),
        IN_PROGRESS("进行中"),
        COMPLETED("已完成"),
        PAUSED("已暂停");
        
        private final String description;
        
        Status(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 更新阅读进度
     * @param progressPercentage 进度百分比
     * @param currentPosition 当前位置
     */
    public void updateProgress(int progressPercentage, int currentPosition) {
        this.progressPercentage = Math.max(0, Math.min(100, progressPercentage));
        this.currentPosition = Math.max(0, currentPosition);
        this.lastReadAt = LocalDateTime.now();
        
        if (this.progressPercentage >= 100) {
            this.status = Status.COMPLETED;
            this.completedAt = LocalDateTime.now();
        } else if (this.progressPercentage > 0) {
            this.status = Status.IN_PROGRESS;
        }
    }
    
    /**
     * 增加阅读时间
     * @param additionalTime 额外阅读时间（秒）
     */
    public void addReadingTime(int additionalTime) {
        this.totalReadingTime += Math.max(0, additionalTime);
    }
    
    /**
     * 增加会话次数
     */
    public void incrementSessionCount() {
        this.sessionCount++;
    }
    
    /**
     * 标记为已完成
     */
    public void markAsCompleted() {
        this.progressPercentage = 100;
        this.status = Status.COMPLETED;
        this.completedAt = LocalDateTime.now();
        this.lastReadAt = LocalDateTime.now();
    }
    
    /**
     * 检查是否已完成
     * @return 是否已完成
     */
    public boolean isCompleted() {
        return status == Status.COMPLETED || progressPercentage >= 100;
    }
    
    /**
     * 获取平均阅读速度（字符/分钟）
     * @return 平均阅读速度
     */
    public double getAverageReadingSpeed() {
        if (totalReadingTime <= 0 || currentPosition <= 0) {
            return 0.0;
        }
        return (double) currentPosition / (totalReadingTime / 60.0);
    }
}