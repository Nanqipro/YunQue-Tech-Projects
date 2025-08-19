package com.nanqipro.entity;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 语音评估记录实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "speech_evaluation_records")
public class SpeechEvaluationRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotNull(message = "用户ID不能为空")
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "content_type", nullable = false)
    private ContentType contentType;
    
    @NotBlank(message = "朗读内容不能为空")
    @Column(name = "content_text", nullable = false, columnDefinition = "TEXT")
    private String contentText;
    
    @NotBlank(message = "录音URL不能为空")
    @Column(name = "audio_url", nullable = false, length = 500)
    private String audioUrl;
    
    @DecimalMin(value = "0.00", message = "发音得分不能小于0.00")
    @DecimalMax(value = "100.00", message = "发音得分不能大于100.00")
    @Column(name = "pronunciation_score", precision = 5, scale = 2)
    private BigDecimal pronunciationScore;
    
    @DecimalMin(value = "0.00", message = "流利度得分不能小于0.00")
    @DecimalMax(value = "100.00", message = "流利度得分不能大于100.00")
    @Column(name = "fluency_score", precision = 5, scale = 2)
    private BigDecimal fluencyScore;
    
    @DecimalMin(value = "0.00", message = "准确度得分不能小于0.00")
    @DecimalMax(value = "100.00", message = "准确度得分不能大于100.00")
    @Column(name = "accuracy_score", precision = 5, scale = 2)
    private BigDecimal accuracyScore;
    
    @DecimalMin(value = "0.00", message = "综合得分不能小于0.00")
    @DecimalMax(value = "100.00", message = "综合得分不能大于100.00")
    @Column(name = "overall_score", precision = 5, scale = 2)
    private BigDecimal overallScore;
    
    @Column(name = "detailed_feedback", columnDefinition = "JSON")
    private String detailedFeedback;
    
    @Column(name = "improvement_suggestions", columnDefinition = "TEXT")
    private String improvementSuggestions;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    // 关联用户实体
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;
    
    /**
     * 内容类型枚举
     */
    public enum ContentType {
        WORD("单词"),
        SENTENCE("句子"),
        PARAGRAPH("段落");
        
        private final String description;
        
        ContentType(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 构造函数
     */
    public SpeechEvaluationRecord() {}
    
    public SpeechEvaluationRecord(Long userId, ContentType contentType, 
                                 String contentText, String audioUrl) {
        this.userId = userId;
        this.contentType = contentType;
        this.contentText = contentText;
        this.audioUrl = audioUrl;
    }
    
    /**
     * 设置评估分数
     */
    public void setScores(BigDecimal pronunciationScore, BigDecimal fluencyScore, 
                         BigDecimal accuracyScore, BigDecimal overallScore) {
        this.pronunciationScore = pronunciationScore;
        this.fluencyScore = fluencyScore;
        this.accuracyScore = accuracyScore;
        this.overallScore = overallScore;
    }
    
    /**
     * 设置反馈信息
     */
    public void setFeedback(String detailedFeedback, String improvementSuggestions) {
        this.detailedFeedback = detailedFeedback;
        this.improvementSuggestions = improvementSuggestions;
    }
    
    /**
     * 检查是否为优秀评估（综合得分>=90）
     */
    public boolean isExcellent() {
        return overallScore != null && overallScore.compareTo(new BigDecimal("90.00")) >= 0;
    }
    
    /**
     * 检查是否为良好评估（综合得分>=80）
     */
    public boolean isGood() {
        return overallScore != null && overallScore.compareTo(new BigDecimal("80.00")) >= 0;
    }
    
    /**
     * 检查是否需要改进（综合得分<60）
     */
    public boolean needsImprovement() {
        return overallScore != null && overallScore.compareTo(new BigDecimal("60.00")) < 0;
    }
    
    /**
     * 获取评估等级
     */
    public String getGradeLevel() {
        if (overallScore == null) {
            return "未评估";
        }
        
        if (overallScore.compareTo(new BigDecimal("90.00")) >= 0) {
            return "优秀";
        } else if (overallScore.compareTo(new BigDecimal("80.00")) >= 0) {
            return "良好";
        } else if (overallScore.compareTo(new BigDecimal("70.00")) >= 0) {
            return "中等";
        } else if (overallScore.compareTo(new BigDecimal("60.00")) >= 0) {
            return "及格";
        } else {
            return "需要改进";
        }
    }
    
    /**
     * 检查是否有详细反馈
     */
    public boolean hasDetailedFeedback() {
        return detailedFeedback != null && !detailedFeedback.trim().isEmpty();
    }
    
    /**
     * 检查是否有改进建议
     */
    public boolean hasImprovementSuggestions() {
        return improvementSuggestions != null && !improvementSuggestions.trim().isEmpty();
    }
}