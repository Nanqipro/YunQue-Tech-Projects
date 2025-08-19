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
 * 词汇实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "vocabularies")
public class Vocabulary {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "单词不能为空")
    @Column(nullable = false, unique = true, length = 100)
    private String word;
    
    @Column(name = "phonetic_us", length = 100)
    private String phoneticUs;
    
    @Column(name = "phonetic_uk", length = 100)
    private String phoneticUk;
    
    @Column(name = "audio_us_url")
    private String audioUsUrl;
    
    @Column(name = "audio_uk_url")
    private String audioUkUrl;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "word_type", nullable = false)
    private WordType wordType = WordType.WORD;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty_level", nullable = false)
    private DifficultyLevel difficultyLevel = DifficultyLevel.BEGINNER;
    
    @Column(name = "frequency_rank")
    private Integer frequencyRank;
    
    @Column(name = "word_family", length = 50)
    private String wordFamily;
    
    @ElementCollection
    @CollectionTable(name = "vocabulary_tags", joinColumns = @JoinColumn(name = "vocabulary_id"))
    @Column(name = "tag")
    private List<String> tags;
    
    @Column(name = "image_url")
    private String imageUrl;
    
    @Column(name = "memory_tip", columnDefinition = "TEXT")
    private String memoryTip;
    
    @Column(name = "etymology", columnDefinition = "TEXT")
    private String etymology;
    
    @Column(name = "usage_note", columnDefinition = "TEXT")
    private String usageNote;
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 单词类型枚举
     */
    public enum WordType {
        WORD,        // 单词
        PHRASE,      // 短语
        IDIOM,       // 习语
        COLLOCATION  // 搭配
    }
    
    /**
     * 难度级别枚举
     */
    public enum DifficultyLevel {
        BEGINNER,    // 初级
        ELEMENTARY,  // 基础
        INTERMEDIATE,// 中级
        ADVANCED,    // 高级
        EXPERT       // 专家
    }
}