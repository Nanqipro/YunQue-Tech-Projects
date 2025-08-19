package com.nanqipro.entity;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 语音评估记录实体类
 */
@Data
@Entity
@Table(name = "speech_evaluations")
@EqualsAndHashCode(callSuper = false)
public class SpeechEvaluation {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 用户ID
     */
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    /**
     * 内容类型
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "content_type", nullable = false)
    private ContentType contentType;
    
    /**
     * 内容ID（词汇ID、文章ID等）
     */
    @Column(name = "content_id")
    private Long contentId;
    
    /**
     * 音频文件路径
     */
    @Column(name = "audio_file_path", nullable = false)
    private String audioFilePath;
    
    /**
     * 发音准确度分数
     */
    @Column(name = "pronunciation_score", precision = 5, scale = 2)
    private BigDecimal pronunciationScore;
    
    /**
     * 流利度分数
     */
    @Column(name = "fluency_score", precision = 5, scale = 2)
    private BigDecimal fluencyScore;
    
    /**
     * 节奏分数
     */
    @Column(name = "rhythm_score", precision = 5, scale = 2)
    private BigDecimal rhythmScore;
    
    /**
     * 语调分数
     */
    @Column(name = "intonation_score", precision = 5, scale = 2)
    private BigDecimal intonationScore;
    
    /**
     * 综合分数
     */
    @Column(name = "overall_score", precision = 5, scale = 2)
    private BigDecimal overallScore;
    
    /**
     * 评估反馈
     */
    @Column(name = "feedback", columnDefinition = "TEXT")
    private String feedback;
    
    /**
     * 详细分析结果（JSON格式）
     */
    @Column(name = "analysis_result", columnDefinition = "TEXT")
    private String analysisResult;
    
    /**
     * 音频时长（秒）
     */
    @Column(name = "audio_duration")
    private Double audioDuration;
    
    /**
     * 评估状态
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "evaluation_status")
    private EvaluationStatus evaluationStatus = EvaluationStatus.COMPLETED;
    
    /**
     * 创建时间
     */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    /**
     * 内容类型枚举
     */
    public enum ContentType {
        VOCABULARY("词汇发音"),
        ARTICLE("文章朗读"),
        SENTENCE("句子朗读"),
        FREE_SPEECH("自由发言"),
        CONVERSATION("对话练习");
        
        private final String description;
        
        ContentType(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 评估状态枚举
     */
    public enum EvaluationStatus {
        PENDING("待评估"),
        PROCESSING("评估中"),
        COMPLETED("已完成"),
        FAILED("评估失败");
        
        private final String description;
        
        EvaluationStatus(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
}