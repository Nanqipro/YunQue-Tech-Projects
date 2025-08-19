package com.nanqipro.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 用户词汇学习记录实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "user_vocabularies", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "vocabulary_id"}))
public class UserVocabulary {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vocabulary_id", nullable = false)
    private Vocabulary vocabulary;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "mastery_level", nullable = false)
    private MasteryLevel masteryLevel = MasteryLevel.NEW;
    
    @Column(name = "study_count", nullable = false)
    private Integer studyCount = 0;
    
    @Column(name = "correct_count", nullable = false)
    private Integer correctCount = 0;
    
    @Column(name = "wrong_count", nullable = false)
    private Integer wrongCount = 0;
    
    @Column(name = "accuracy_rate", nullable = false)
    private Double accuracyRate = 0.0;
    
    @Column(name = "first_learned_at")
    private LocalDateTime firstLearnedAt;
    
    @Column(name = "last_reviewed_at")
    private LocalDateTime lastReviewedAt;
    
    @Column(name = "next_review_at")
    private LocalDateTime nextReviewAt;
    
    @Column(name = "review_interval", nullable = false)
    private Integer reviewInterval = 1; // 复习间隔（天）
    
    @Column(name = "ease_factor", nullable = false)
    private Double easeFactor = 2.5; // 艾宾浩斯遗忘曲线参数
    
    @Column(name = "repetition_count", nullable = false)
    private Integer repetitionCount = 0;
    
    @Column(name = "is_favorite", nullable = false)
    private Boolean isFavorite = false;
    
    @Column(name = "is_difficult", nullable = false)
    private Boolean isDifficult = false;
    
    @Column(name = "personal_note", columnDefinition = "TEXT")
    private String personalNote;
    
    @Column(name = "total_study_time", nullable = false)
    private Long totalStudyTime = 0L; // 总学习时间（秒）
    
    @Column(name = "last_study_time", nullable = false)
    private Long lastStudyTime = 0L; // 最后一次学习时间（秒）
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 掌握程度枚举
     */
    public enum MasteryLevel {
        NEW(0, "新学"),
        LEARNING(1, "学习中"),
        FAMILIAR(2, "熟悉"),
        MASTERED(3, "掌握"),
        EXPERT(4, "精通");
        
        private final int level;
        private final String description;
        
        MasteryLevel(int level, String description) {
            this.level = level;
            this.description = description;
        }
        
        public int getLevel() {
            return level;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 计算准确率
     */
    public void calculateAccuracyRate() {
        if (studyCount > 0) {
            this.accuracyRate = (double) correctCount / studyCount * 100;
        } else {
            this.accuracyRate = 0.0;
        }
    }
    
    /**
     * 更新学习统计
     */
    public void updateStudyStats(boolean isCorrect, long studyTime) {
        this.studyCount++;
        if (isCorrect) {
            this.correctCount++;
        } else {
            this.wrongCount++;
        }
        this.lastStudyTime = studyTime;
        this.totalStudyTime += studyTime;
        this.lastReviewedAt = LocalDateTime.now();
        calculateAccuracyRate();
    }
}