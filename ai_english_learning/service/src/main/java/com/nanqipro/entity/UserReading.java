package com.nanqipro.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 用户阅读记录实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "user_readings", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "article_id"}))
public class UserReading {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "reading_status", nullable = false)
    private ReadingStatus readingStatus = ReadingStatus.NOT_STARTED;
    
    @Column(name = "progress_percentage", nullable = false)
    private Double progressPercentage = 0.0;
    
    @Column(name = "current_position", nullable = false)
    private Integer currentPosition = 0; // 当前阅读位置（字符位置）
    
    @Column(name = "reading_time", nullable = false)
    private Long readingTime = 0L; // 阅读时间（秒）
    
    @Column(name = "start_time")
    private LocalDateTime startTime;
    
    @Column(name = "finish_time")
    private LocalDateTime finishTime;
    
    @Column(name = "last_read_time")
    private LocalDateTime lastReadTime;
    
    @Column(name = "reading_speed", nullable = false)
    private Double readingSpeed = 0.0; // 阅读速度（词/分钟）
    
    @Column(name = "comprehension_score")
    private Double comprehensionScore; // 理解分数
    
    @Column(name = "difficulty_rating")
    private Integer difficultyRating; // 用户评价的难度（1-5）
    
    @Column(name = "enjoyment_rating")
    private Integer enjoymentRating; // 用户评价的喜好度（1-5）
    
    @Column(name = "is_liked", nullable = false)
    private Boolean isLiked = false;
    
    @Column(name = "is_favorited", nullable = false)
    private Boolean isFavorited = false;
    
    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes; // 用户笔记
    
    @Column(name = "highlighted_text", columnDefinition = "TEXT")
    private String highlightedText; // 高亮文本
    
    @Column(name = "bookmark_positions", columnDefinition = "TEXT")
    private String bookmarkPositions; // 书签位置（JSON格式）
    
    @Column(name = "vocabulary_learned_count", nullable = false)
    private Integer vocabularyLearnedCount = 0; // 学习的词汇数量
    
    @Column(name = "questions_answered", nullable = false)
    private Integer questionsAnswered = 0; // 回答的问题数量
    
    @Column(name = "questions_correct", nullable = false)
    private Integer questionsCorrect = 0; // 回答正确的问题数量
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 阅读状态枚举
     */
    public enum ReadingStatus {
        NOT_STARTED("未开始"),
        IN_PROGRESS("阅读中"),
        COMPLETED("已完成"),
        PAUSED("已暂停"),
        ABANDONED("已放弃");
        
        private final String description;
        
        ReadingStatus(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 计算阅读速度
     */
    public void calculateReadingSpeed() {
        if (readingTime > 0 && article != null && article.getWordCount() > 0) {
            double minutes = readingTime / 60.0;
            this.readingSpeed = article.getWordCount() / minutes;
        }
    }
    
    /**
     * 更新阅读进度
     */
    public void updateProgress(int position, long sessionTime) {
        this.currentPosition = position;
        this.readingTime += sessionTime;
        this.lastReadTime = LocalDateTime.now();
        
        if (article != null && article.getContent() != null) {
            this.progressPercentage = (double) position / article.getContent().length() * 100;
            
            // 如果进度达到95%以上，标记为完成
            if (progressPercentage >= 95.0 && readingStatus != ReadingStatus.COMPLETED) {
                this.readingStatus = ReadingStatus.COMPLETED;
                this.finishTime = LocalDateTime.now();
            } else if (readingStatus == ReadingStatus.NOT_STARTED) {
                this.readingStatus = ReadingStatus.IN_PROGRESS;
                this.startTime = LocalDateTime.now();
            }
        }
        
        calculateReadingSpeed();
    }
    
    /**
     * 计算问题正确率
     */
    public double getQuestionAccuracy() {
        if (questionsAnswered > 0) {
            return (double) questionsCorrect / questionsAnswered * 100;
        }
        return 0.0;
    }
}