package com.nanqipro.entity;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Type;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

/**
 * AI问答记录实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "ai_qa_records")
public class AIQARecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotNull(message = "用户ID不能为空")
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Column(name = "article_id")
    private Long articleId;
    
    @NotBlank(message = "用户问题不能为空")
    @Column(name = "question_text", nullable = false, columnDefinition = "TEXT")
    private String questionText;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "question_language", nullable = false)
    private Language questionLanguage;
    
    @NotBlank(message = "AI回答不能为空")
    @Column(name = "answer_text", nullable = false, columnDefinition = "TEXT")
    private String answerText;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "answer_language", nullable = false)
    private Language answerLanguage;
    
    @Column(name = "context_info", columnDefinition = "JSON")
    private String contextInfo;
    
    @Column(name = "response_time_ms")
    private Integer responseTimeMs;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    // 关联用户实体
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;
    
    // 关联文章实体
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", insertable = false, updatable = false)
    private Article article;
    
    /**
     * 语言枚举
     */
    public enum Language {
        EN("英语"),
        ZH("中文");
        
        private final String description;
        
        Language(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 构造函数
     */
    public AIQARecord() {}
    
    public AIQARecord(Long userId, Long articleId, String questionText, 
                     Language questionLanguage, String answerText, 
                     Language answerLanguage) {
        this.userId = userId;
        this.articleId = articleId;
        this.questionText = questionText;
        this.questionLanguage = questionLanguage;
        this.answerText = answerText;
        this.answerLanguage = answerLanguage;
    }
    
    /**
     * 设置上下文信息
     */
    public void setContextInfo(String contextInfo) {
        this.contextInfo = contextInfo;
    }
    
    /**
     * 设置响应时间
     */
    public void setResponseTime(Integer responseTimeMs) {
        this.responseTimeMs = responseTimeMs;
    }
    
    /**
     * 检查是否为快速响应（小于2秒）
     */
    public boolean isFastResponse() {
        return responseTimeMs != null && responseTimeMs < 2000;
    }
    
    /**
     * 检查是否有关联文章
     */
    public boolean hasRelatedArticle() {
        return articleId != null;
    }
    
    /**
     * 检查是否为跨语言问答（问题和回答语言不同）
     */
    public boolean isCrossLanguage() {
        return questionLanguage != answerLanguage;
    }
}