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
 * 词汇定义实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "vocabulary_definitions")
public class VocabularyDefinition {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vocabulary_id", nullable = false)
    private Vocabulary vocabulary;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "part_of_speech", nullable = false)
    private PartOfSpeech partOfSpeech;
    
    @NotBlank(message = "定义不能为空")
    @Column(nullable = false, columnDefinition = "TEXT")
    private String definition;
    
    @Column(name = "chinese_definition", columnDefinition = "TEXT")
    private String chineseDefinition;
    
    @ElementCollection
    @CollectionTable(name = "vocabulary_examples", joinColumns = @JoinColumn(name = "definition_id"))
    @Column(name = "example", columnDefinition = "TEXT")
    private List<String> examples;
    
    @ElementCollection
    @CollectionTable(name = "vocabulary_synonyms", joinColumns = @JoinColumn(name = "definition_id"))
    @Column(name = "synonym")
    private List<String> synonyms;
    
    @ElementCollection
    @CollectionTable(name = "vocabulary_antonyms", joinColumns = @JoinColumn(name = "definition_id"))
    @Column(name = "antonym")
    private List<String> antonyms;
    
    @Column(name = "definition_order", nullable = false)
    private Integer definitionOrder = 1;
    
    @Column(name = "is_primary", nullable = false)
    private Boolean isPrimary = false;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 词性枚举
     */
    public enum PartOfSpeech {
        NOUN("n."),           // 名词
        VERB("v."),           // 动词
        ADJECTIVE("adj."),    // 形容词
        ADVERB("adv."),       // 副词
        PRONOUN("pron."),     // 代词
        PREPOSITION("prep."), // 介词
        CONJUNCTION("conj."), // 连词
        INTERJECTION("int."), // 感叹词
        ARTICLE("art."),      // 冠词
        NUMERAL("num."),      // 数词
        PHRASE("phrase"),     // 短语
        IDIOM("idiom");       // 习语
        
        private final String abbreviation;
        
        PartOfSpeech(String abbreviation) {
            this.abbreviation = abbreviation;
        }
        
        public String getAbbreviation() {
            return abbreviation;
        }
    }
}