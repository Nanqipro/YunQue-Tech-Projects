package com.nanqipro.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 学习会话实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "study_sessions")
public class StudySession {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "session_type", nullable = false)
    private SessionType sessionType;
    
    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;
    
    @Column(name = "end_time")
    private LocalDateTime endTime;
    
    @Column(name = "duration", nullable = false)
    private Long duration = 0L; // 持续时间（秒）
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.ACTIVE;
    
    @Column(name = "words_studied", nullable = false)
    private Integer wordsStudied = 0;
    
    @Column(name = "words_mastered", nullable = false)
    private Integer wordsMastered = 0;
    
    @Column(name = "articles_read", nullable = false)
    private Integer articlesRead = 0;
    
    @Column(name = "questions_answered", nullable = false)
    private Integer questionsAnswered = 0;
    
    @Column(name = "questions_correct", nullable = false)
    private Integer questionsCorrect = 0;
    
    @Column(name = "points_earned", nullable = false)
    private Integer pointsEarned = 0;
    
    @Column(name = "streak_maintained", nullable = false)
    private Boolean streakMaintained = false;
    
    @Column(name = "daily_goal_achieved", nullable = false)
    private Boolean dailyGoalAchieved = false;
    
    @Column(name = "session_notes", columnDefinition = "TEXT")
    private String sessionNotes;
    
    @Column(name = "performance_score")
    private Double performanceScore; // 表现分数
    
    @Column(name = "focus_score")
    private Double focusScore; // 专注度分数
    
    @Column(name = "device_type", length = 50)
    private String deviceType; // 设备类型
    
    @Column(name = "platform", length = 50)
    private String platform; // 平台
    
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
        VOCABULARY_LEARNING("词汇学习"),
        VOCABULARY_REVIEW("词汇复习"),
        READING_PRACTICE("阅读练习"),
        LISTENING_PRACTICE("听力练习"),
        SPEAKING_PRACTICE("口语练习"),
        WRITING_PRACTICE("写作练习"),
        GRAMMAR_PRACTICE("语法练习"),
        MIXED_PRACTICE("综合练习"),
        AI_CONVERSATION("AI对话"),
        CHALLENGE("挑战赛");
        
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
        ABANDONED("已放弃"),
        INTERRUPTED("被中断");
        
        private final String description;
        
        Status(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 结束会话
     */
    public void endSession() {
        this.endTime = LocalDateTime.now();
        this.status = Status.COMPLETED;
        if (startTime != null) {
            this.duration = java.time.Duration.between(startTime, endTime).getSeconds();
        }
    }
    
    /**
     * 计算正确率
     */
    public double getAccuracyRate() {
        if (questionsAnswered > 0) {
            return (double) questionsCorrect / questionsAnswered * 100;
        }
        return 0.0;
    }
    
    /**
     * 计算掌握率
     */
    public double getMasteryRate() {
        if (wordsStudied > 0) {
            return (double) wordsMastered / wordsStudied * 100;
        }
        return 0.0;
    }
    
    /**
     * 更新学习统计
     */
    public void updateStats(int wordsStudied, int wordsMastered, int questionsAnswered, int questionsCorrect, int pointsEarned) {
        this.wordsStudied += wordsStudied;
        this.wordsMastered += wordsMastered;
        this.questionsAnswered += questionsAnswered;
        this.questionsCorrect += questionsCorrect;
        this.pointsEarned += pointsEarned;
    }
}