package com.nanqipro.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 阅读会话实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "reading_sessions")
public class ReadingSession {
    
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
    
    @Column(name = "session_start_time", nullable = false)
    private LocalDateTime sessionStartTime;
    
    @Column(name = "session_end_time")
    private LocalDateTime sessionEndTime;
    
    @Column(name = "reading_duration", nullable = false)
    private Integer readingDuration = 0; // 阅读时长（秒）
    
    @Column(name = "start_position", nullable = false)
    private Integer startPosition = 0; // 开始阅读位置
    
    @Column(name = "end_position", nullable = false)
    private Integer endPosition = 0; // 结束阅读位置
    
    @Column(name = "progress_gained", nullable = false)
    private Integer progressGained = 0; // 本次会话获得的进度（百分比）
    
    @Column(name = "words_read", nullable = false)
    private Integer wordsRead = 0; // 本次会话阅读的单词数
    
    @Column(name = "reading_speed") // 阅读速度（单词/分钟）
    private Double readingSpeed;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SessionType sessionType = SessionType.NORMAL;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.ACTIVE;
    
    @Column(name = "device_type", length = 50)
    private String deviceType; // 设备类型（mobile, tablet, desktop）
    
    @Column(name = "reading_mode", length = 50)
    private String readingMode; // 阅读模式（normal, speed, focus）
    
    @ElementCollection
    @CollectionTable(name = "session_bookmarks", joinColumns = @JoinColumn(name = "session_id"))
    @Column(name = "bookmark_position")
    private List<Integer> bookmarks; // 书签位置列表
    
    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes; // 阅读笔记
    
    @Column(name = "difficulty_rating")
    private Integer difficultyRating; // 用户对文章难度的评分（1-5）
    
    @Column(name = "enjoyment_rating")
    private Integer enjoymentRating; // 用户对文章的喜爱程度评分（1-5）
    
    @Column(name = "comprehension_score")
    private Double comprehensionScore; // 理解度得分（基于答题情况）
    
    @Column(name = "is_completed", nullable = false)
    private Boolean isCompleted = false;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 会话类型枚举
     */
    public enum SessionType {
        NORMAL("普通阅读"),
        SPEED_READING("快速阅读"),
        INTENSIVE_READING("精读"),
        REVIEW("复习阅读"),
        PRACTICE("练习阅读");
        
        private final String description;
        
        SessionType(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 会话状态枚举
     */
    public enum Status {
        ACTIVE("进行中"),
        COMPLETED("已完成"),
        PAUSED("已暂停"),
        ABANDONED("已放弃");
        
        private final String description;
        
        Status(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 开始阅读会话
     */
    public void startSession() {
        this.sessionStartTime = LocalDateTime.now();
        this.status = Status.ACTIVE;
    }
    
    /**
     * 结束阅读会话
     * @param endPosition 结束位置
     */
    public void endSession(int endPosition) {
        this.sessionEndTime = LocalDateTime.now();
        this.endPosition = endPosition;
        this.status = Status.COMPLETED;
        this.isCompleted = true;
        
        // 计算阅读时长
        if (sessionStartTime != null && sessionEndTime != null) {
            this.readingDuration = (int) java.time.Duration.between(sessionStartTime, sessionEndTime).getSeconds();
        }
        
        // 计算阅读的单词数
        this.wordsRead = Math.max(0, endPosition - startPosition);
        
        // 计算阅读速度（单词/分钟）
        if (readingDuration > 0) {
            this.readingSpeed = (double) wordsRead / (readingDuration / 60.0);
        }
    }
    
    /**
     * 暂停阅读会话
     * @param currentPosition 当前位置
     */
    public void pauseSession(int currentPosition) {
        this.endPosition = currentPosition;
        this.status = Status.PAUSED;
        
        // 更新已读单词数
        this.wordsRead = Math.max(0, currentPosition - startPosition);
        
        // 计算当前阅读时长
        if (sessionStartTime != null) {
            this.readingDuration = (int) java.time.Duration.between(sessionStartTime, LocalDateTime.now()).getSeconds();
        }
    }
    
    /**
     * 恢复阅读会话
     */
    public void resumeSession() {
        this.status = Status.ACTIVE;
        // 重新设置开始时间，但保留之前的阅读时长
        this.sessionStartTime = LocalDateTime.now();
    }
    
    /**
     * 添加书签
     * @param position 书签位置
     */
    public void addBookmark(int position) {
        if (bookmarks == null) {
            bookmarks = new java.util.ArrayList<>();
        }
        if (!bookmarks.contains(position)) {
            bookmarks.add(position);
        }
    }
    
    /**
     * 移除书签
     * @param position 书签位置
     */
    public void removeBookmark(int position) {
        if (bookmarks != null) {
            bookmarks.remove(Integer.valueOf(position));
        }
    }
    
    /**
     * 计算阅读效率（单词/分钟）
     * @return 阅读效率
     */
    public double getReadingEfficiency() {
        if (readingDuration <= 0 || wordsRead <= 0) {
            return 0.0;
        }
        return (double) wordsRead / (readingDuration / 60.0);
    }
    
    /**
     * 获取阅读进度增长
     * @return 进度增长百分比
     */
    public int getProgressGrowth() {
        return progressGained;
    }
    
    /**
     * 设置理解度得分
     * @param score 得分
     */
    public void setComprehensionScore(double score) {
        this.comprehensionScore = Math.max(0.0, Math.min(100.0, score));
    }
    
    /**
     * 设置难度评分
     * @param rating 评分（1-5）
     */
    public void setDifficultyRating(int rating) {
        this.difficultyRating = Math.max(1, Math.min(5, rating));
    }
    
    /**
     * 设置喜爱程度评分
     * @param rating 评分（1-5）
     */
    public void setEnjoymentRating(int rating) {
        this.enjoymentRating = Math.max(1, Math.min(5, rating));
    }
}