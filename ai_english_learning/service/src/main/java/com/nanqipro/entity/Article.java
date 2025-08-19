package com.nanqipro.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 文章实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "articles")
public class Article {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "标题不能为空")
    @Column(nullable = false, length = 200)
    private String title;
    
    @Column(name = "subtitle", length = 300)
    private String subtitle;
    
    @NotBlank(message = "内容不能为空")
    @Column(nullable = false, columnDefinition = "LONGTEXT")
    private String content;
    
    @Column(name = "content_html", columnDefinition = "LONGTEXT")
    private String contentHtml;
    
    @Column(columnDefinition = "TEXT")
    private String summary;
    
    @Column(length = 100)
    private String author;
    
    @Column(name = "source_url")
    private String sourceUrl;
    
    @Column(name = "cover_image_url")
    private String coverImageUrl;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category category;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty_level", nullable = false)
    private DifficultyLevel difficultyLevel;
    
    @Column(name = "estimated_reading_time", nullable = false)
    private Integer estimatedReadingTime; // 预估阅读时间（分钟）
    
    @Column(name = "word_count", nullable = false)
    private Integer wordCount = 0;
    
    @ElementCollection
    @CollectionTable(name = "article_tags", joinColumns = @JoinColumn(name = "article_id"))
    @Column(name = "tag")
    private List<String> tags;
    
    @ElementCollection
    @CollectionTable(name = "article_keywords", joinColumns = @JoinColumn(name = "article_id"))
    @Column(name = "keyword")
    private List<String> keywords;
    
    @Column(name = "view_count", nullable = false)
    private Long viewCount = 0L;
    
    @Column(name = "like_count", nullable = false)
    private Long likeCount = 0L;
    
    @Column(name = "favorite_count", nullable = false)
    private Long favoriteCount = 0L;
    
    @Column(name = "comment_count", nullable = false)
    private Long commentCount = 0L;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.DRAFT;
    
    @Column(name = "is_featured", nullable = false)
    private Boolean isFeatured = false;
    
    @Column(name = "is_premium", nullable = false)
    private Boolean isPremium = false;
    
    @Column(name = "published_at")
    private LocalDateTime publishedAt;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 文章分类枚举
     */
    public enum Category {
        NEWS("新闻"),
        TECHNOLOGY("科技"),
        BUSINESS("商业"),
        SCIENCE("科学"),
        CULTURE("文化"),
        SPORTS("体育"),
        ENTERTAINMENT("娱乐"),
        HEALTH("健康"),
        TRAVEL("旅行"),
        EDUCATION("教育"),
        LIFESTYLE("生活方式"),
        OPINION("观点"),
        FICTION("小说"),
        BIOGRAPHY("传记"),
        HISTORY("历史");
        
        private final String description;
        
        Category(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 难度级别枚举
     */
    public enum DifficultyLevel {
        BEGINNER("初级"),
        ELEMENTARY("基础"),
        INTERMEDIATE("中级"),
        ADVANCED("高级"),
        EXPERT("专家");
        
        private final String description;
        
        DifficultyLevel(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 文章状态枚举
     */
    public enum Status {
        DRAFT("草稿"),
        PUBLISHED("已发布"),
        ARCHIVED("已归档"),
        DELETED("已删除");
        
        private final String description;
        
        Status(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 获取文章来源
     * @return 文章来源URL
     */
    public String getSource() {
        return this.sourceUrl;
    }
    
    /**
     * 增加浏览量
     */
    public void incrementViewCount() {
        this.viewCount++;
    }
    
    /**
     * 增加点赞数
     */
    public void incrementLikeCount() {
        this.likeCount++;
    }
    
    /**
     * 减少点赞数
     */
    public void decrementLikeCount() {
        if (this.likeCount > 0) {
            this.likeCount--;
        }
    }
    
    /**
     * 增加收藏数
     */
    public void incrementFavoriteCount() {
        this.favoriteCount++;
    }
    
    /**
     * 减少收藏数
     */
    public void decrementFavoriteCount() {
        if (this.favoriteCount > 0) {
            this.favoriteCount--;
        }
    }
    
    /**
     * 增加评论数
     */
    public void incrementCommentCount() {
        this.commentCount++;
    }
    
    /**
     * 减少评论数
     */
    public void decrementCommentCount() {
        if (this.commentCount > 0) {
            this.commentCount--;
        }
    }
    
    /**
     * 发布文章
     */
    public void publish() {
        this.status = Status.PUBLISHED;
        this.publishedAt = LocalDateTime.now();
    }
    
    /**
     * 取消发布
     */
    public void unpublish() {
        this.status = Status.DRAFT;
        this.publishedAt = null;
    }
    
    /**
     * 归档文章
     */
    public void archive() {
        this.status = Status.ARCHIVED;
    }
    
    /**
     * 检查是否已发布
     * @return 是否已发布
     */
    public boolean isPublished() {
        return this.status == Status.PUBLISHED;
    }
    
    /**
     * 检查是否为草稿
     * @return 是否为草稿
     */
    public boolean isDraft() {
        return this.status == Status.DRAFT;
    }
}