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
 * 阅读理解题目实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "reading_questions")
public class ReadingQuestion {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "article_id", nullable = false)
    private Long articleId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", insertable = false, updatable = false)
    private Article article;
    
    @NotBlank(message = "题目内容不能为空")
    @Column(nullable = false, columnDefinition = "TEXT")
    private String question;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "question_type", nullable = false)
    private QuestionType questionType;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty_level", nullable = false)
    private DifficultyLevel difficultyLevel;
    
    @ElementCollection
    @CollectionTable(name = "question_options", joinColumns = @JoinColumn(name = "question_id"))
    @OrderColumn(name = "option_order")
    @Column(name = "option_text")
    private List<String> options; // 选择题选项
    
    @Column(name = "correct_answer", nullable = false, columnDefinition = "TEXT")
    private String correctAnswer; // 正确答案
    
    @ElementCollection
    @CollectionTable(name = "question_alternative_answers", joinColumns = @JoinColumn(name = "question_id"))
    @Column(name = "alternative_answer")
    private List<String> alternativeAnswers; // 可接受的其他答案
    
    @Column(columnDefinition = "TEXT")
    private String explanation; // 答案解释
    
    @Column(name = "reference_text", columnDefinition = "TEXT")
    private String referenceText; // 参考文本段落
    
    @Column(name = "reference_position")
    private Integer referencePosition; // 参考文本在文章中的位置
    
    @Column(name = "points", nullable = false)
    private Integer points = 1; // 题目分值
    
    @Column(name = "time_limit")
    private Integer timeLimit; // 答题时间限制（秒）
    
    @Column(name = "order_index", nullable = false)
    private Integer orderIndex = 0; // 题目顺序
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
    
    @Column(name = "answer_count", nullable = false)
    private Long answerCount = 0L; // 答题次数
    
    @Column(name = "correct_count", nullable = false)
    private Long correctCount = 0L; // 正确次数
    
    @Column(name = "accuracy_rate")
    private Double accuracyRate = 0.0; // 正确率
    
    @ElementCollection
    @CollectionTable(name = "question_tags", joinColumns = @JoinColumn(name = "question_id"))
    @Column(name = "tag")
    private List<String> tags; // 题目标签
    
    @Column(columnDefinition = "TEXT")
    private String hints; // 提示信息
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 题目类型枚举
     */
    public enum QuestionType {
        MULTIPLE_CHOICE("单选题"),
        MULTIPLE_SELECT("多选题"),
        TRUE_FALSE("判断题"),
        FILL_BLANK("填空题"),
        SHORT_ANSWER("简答题"),
        ESSAY("论述题"),
        MATCHING("匹配题"),
        ORDERING("排序题"),
        COMPREHENSION("理解题"),
        VOCABULARY("词汇题"),
        GRAMMAR("语法题"),
        INFERENCE("推理题"),
        MAIN_IDEA("主旨题"),
        DETAIL("细节题"),
        ATTITUDE("态度题");
        
        private final String description;
        
        QuestionType(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 题目难度级别枚举
     */
    public enum DifficultyLevel {
        EASY("简单"),
        MEDIUM("中等"),
        HARD("困难"),
        EXPERT("专家级");
        
        private final String description;
        
        DifficultyLevel(String description) {
            this.description = description;
        }
        
        public String getDescription() {
            return description;
        }
    }
    
    /**
     * 检查答案是否正确
     * @param userAnswer 用户答案
     * @return 是否正确
     */
    public boolean isAnswerCorrect(String userAnswer) {
        if (userAnswer == null || userAnswer.trim().isEmpty()) {
            return false;
        }
        
        String trimmedAnswer = userAnswer.trim();
        
        // 检查主要正确答案
        if (correctAnswer != null && correctAnswer.trim().equalsIgnoreCase(trimmedAnswer)) {
            return true;
        }
        
        // 检查可接受的其他答案
        if (alternativeAnswers != null) {
            return alternativeAnswers.stream()
                .anyMatch(alt -> alt != null && alt.trim().equalsIgnoreCase(trimmedAnswer));
        }
        
        return false;
    }
    
    /**
     * 更新答题统计
     * @param isCorrect 是否正确
     */
    public void updateStatistics(boolean isCorrect) {
        this.answerCount++;
        if (isCorrect) {
            this.correctCount++;
        }
        
        // 更新正确率
        if (answerCount > 0) {
            this.accuracyRate = (double) correctCount / answerCount * 100.0;
        }
    }
    
    /**
     * 获取题目难度系数
     * @return 难度系数（1.0-4.0）
     */
    public double getDifficultyFactor() {
        switch (difficultyLevel) {
            case EASY:
                return 1.0;
            case MEDIUM:
                return 2.0;
            case HARD:
                return 3.0;
            case EXPERT:
                return 4.0;
            default:
                return 1.0;
        }
    }
    
    /**
     * 检查是否为选择题
     * @return 是否为选择题
     */
    public boolean isMultipleChoice() {
        return questionType == QuestionType.MULTIPLE_CHOICE || 
               questionType == QuestionType.MULTIPLE_SELECT;
    }
    
    /**
     * 检查是否为主观题
     * @return 是否为主观题
     */
    public boolean isSubjectiveQuestion() {
        return questionType == QuestionType.SHORT_ANSWER || 
               questionType == QuestionType.ESSAY ||
               questionType == QuestionType.FILL_BLANK;
    }
    
    /**
     * 获取题目权重（基于分值和难度）
     * @return 题目权重
     */
    public double getQuestionWeight() {
        return points * getDifficultyFactor();
    }
    
    /**
     * 添加标签
     * @param tag 标签
     */
    public void addTag(String tag) {
        if (tags == null) {
            tags = new java.util.ArrayList<>();
        }
        if (!tags.contains(tag)) {
            tags.add(tag);
        }
    }
    
    /**
     * 移除标签
     * @param tag 标签
     */
    public void removeTag(String tag) {
        if (tags != null) {
            tags.remove(tag);
        }
    }
    
    /**
     * 设置选择题选项
     * @param options 选项列表
     */
    public void setMultipleChoiceOptions(List<String> options) {
        if (isMultipleChoice()) {
            this.options = options;
        }
    }
    
    /**
     * 获取格式化的题目内容
     * @return 格式化的题目
     */
    public String getFormattedQuestion() {
        StringBuilder formatted = new StringBuilder();
        formatted.append(question);
        
        if (isMultipleChoice() && options != null && !options.isEmpty()) {
            formatted.append("\n\n选项：\n");
            char optionLabel = 'A';
            for (String option : options) {
                formatted.append(optionLabel).append(". ").append(option).append("\n");
                optionLabel++;
            }
        }
        
        return formatted.toString();
    }
}