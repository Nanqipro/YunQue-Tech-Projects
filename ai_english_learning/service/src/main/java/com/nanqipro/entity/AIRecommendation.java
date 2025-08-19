package com.nanqipro.entity;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * AI推荐记录实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "ai_recommendations")
public class AIRecommendation {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotNull(message = "用户ID不能为空")
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "recommendation_type", nullable = false)
    private RecommendationType recommendationType;
    
    @NotNull(message = "推荐项目ID不能为空")
    @Column(name = "recommended_item_id", nullable = false)
    private Long recommendedItemId;
    
    @Column(name = "recommendation_reason", columnDefinition = "TEXT")
    private String recommendationReason;
    
    @DecimalMin(value = "0.00", message = "置信度评分不能小于0.00")
    @DecimalMax(value = "1.00", message = "置信度评分不能大于1.00")
    @Column(name = "confidence_score", precision = 3, scale = 2)
    private BigDecimal confidenceScore;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "user_feedback")
    private UserFeedback userFeedback;
    
    @Column(name = "is_clicked", nullable = false)
    private Boolean isClicked = false;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    // 关联用户实体
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;
    
    /**
     * 推荐类型枚举
     */
    public enum RecommendationType {
        VOCABULARY("词汇推荐"),
        ARTICLE("文章推荐"),
        EXERCISE("练习推荐"),
        STUDY_PLAN("学习计划推荐");
        
        private final String description;
        
        RecommendationType(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 用户反馈枚举
     */
    public enum UserFeedback {
        ACCEPTED("接受"),
        REJECTED("拒绝"),
        IGNORED("忽略");
        
        private final String description;
        
        UserFeedback(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 构造函数
     */
    public AIRecommendation() {}
    
    public AIRecommendation(Long userId, RecommendationType recommendationType, 
                           Long recommendedItemId, String recommendationReason, 
                           BigDecimal confidenceScore) {
        this.userId = userId;
        this.recommendationType = recommendationType;
        this.recommendedItemId = recommendedItemId;
        this.recommendationReason = recommendationReason;
        this.confidenceScore = confidenceScore;
        this.isClicked = false;
    }
    
    /**
     * 设置用户反馈
     */
    public void setUserFeedback(UserFeedback feedback) {
        this.userFeedback = feedback;
    }
    
    /**
     * 标记为已点击
     */
    public void markAsClicked() {
        this.isClicked = true;
    }
    
    /**
     * 检查是否为高置信度推荐
     */
    public boolean isHighConfidence() {
        return confidenceScore != null && confidenceScore.compareTo(new BigDecimal("0.80")) >= 0;
    }
    
    /**
     * 检查是否有用户反馈
     */
    public boolean hasFeedback() {
        return userFeedback != null;
    }
}