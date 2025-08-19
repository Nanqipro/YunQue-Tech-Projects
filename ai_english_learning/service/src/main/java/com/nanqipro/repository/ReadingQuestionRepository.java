package com.nanqipro.repository;

import com.nanqipro.entity.ReadingQuestion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 阅读题目数据访问层
 */
@Repository
public interface ReadingQuestionRepository extends JpaRepository<ReadingQuestion, Long> {
    
    /**
     * 根据文章ID查找所有题目
     * @param articleId 文章ID
     * @return 题目列表
     */
    List<ReadingQuestion> findByArticleId(Long articleId);
    
    /**
     * 根据文章ID和激活状态查找题目（按顺序排序）
     * @param articleId 文章ID
     * @param isActive 是否激活
     * @return 题目列表
     */
    List<ReadingQuestion> findByArticleIdAndIsActiveOrderByOrderIndex(Long articleId, Boolean isActive);
    
    /**
     * 根据文章ID和题目类型查找题目
     * @param articleId 文章ID
     * @param questionType 题目类型
     * @return 题目列表
     */
    List<ReadingQuestion> findByArticleIdAndQuestionType(Long articleId, ReadingQuestion.QuestionType questionType);
    
    /**
     * 根据文章ID、题目类型和激活状态查找题目
     * @param articleId 文章ID
     * @param questionType 题目类型
     * @param isActive 是否激活
     * @return 题目列表
     */
    List<ReadingQuestion> findByArticleIdAndQuestionTypeAndIsActive(Long articleId, ReadingQuestion.QuestionType questionType, Boolean isActive);
    
    /**
     * 根据文章ID和难度级别查找题目
     * @param articleId 文章ID
     * @param difficultyLevel 难度级别
     * @return 题目列表
     */
    List<ReadingQuestion> findByArticleIdAndDifficultyLevel(Long articleId, ReadingQuestion.DifficultyLevel difficultyLevel);
    
    /**
     * 根据题目类型查找所有题目
     * @param questionType 题目类型
     * @return 题目列表
     */
    List<ReadingQuestion> findByQuestionType(ReadingQuestion.QuestionType questionType);
    
    /**
     * 根据难度级别查找所有题目
     * @param difficultyLevel 难度级别
     * @return 题目列表
     */
    List<ReadingQuestion> findByDifficultyLevel(ReadingQuestion.DifficultyLevel difficultyLevel);
    
    /**
     * 根据激活状态查找题目
     * @param isActive 是否激活
     * @param pageable 分页参数
     * @return 题目分页列表
     */
    Page<ReadingQuestion> findByIsActive(Boolean isActive, Pageable pageable);
    
    /**
     * 根据标签查找题目
     * @param tag 标签
     * @return 题目列表
     */
    @Query("SELECT rq FROM ReadingQuestion rq WHERE :tag MEMBER OF rq.tags")
    List<ReadingQuestion> findByTag(@Param("tag") String tag);
    
    /**
     * 根据文章ID随机获取指定数量的激活题目
     * @param articleId 文章ID
     * @param limit 数量限制
     * @return 随机题目列表
     */
    @Query(value = "SELECT * FROM reading_question WHERE article_id = :articleId AND is_active = true ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<ReadingQuestion> findRandomActiveQuestionsByArticleId(@Param("articleId") Long articleId, @Param("limit") int limit);
    
    /**
     * 根据题目类型随机获取指定数量的激活题目
     * @param questionType 题目类型
     * @param limit 数量限制
     * @return 随机题目列表
     */
    @Query(value = "SELECT * FROM reading_question WHERE question_type = :questionType AND is_active = true ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<ReadingQuestion> findRandomActiveQuestionsByType(@Param("questionType") String questionType, @Param("limit") int limit);
    
    /**
     * 根据难度级别随机获取指定数量的激活题目
     * @param difficultyLevel 难度级别
     * @param limit 数量限制
     * @return 随机题目列表
     */
    @Query(value = "SELECT * FROM reading_question WHERE difficulty_level = :difficultyLevel AND is_active = true ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<ReadingQuestion> findRandomActiveQuestionsByDifficulty(@Param("difficultyLevel") String difficultyLevel, @Param("limit") int limit);
    
    /**
     * 统计文章的题目总数
     * @param articleId 文章ID
     * @return 题目总数
     */
    long countByArticleId(Long articleId);
    
    /**
     * 统计文章的激活题目数
     * @param articleId 文章ID
     * @return 激活题目数
     */
    long countByArticleIdAndIsActive(Long articleId, Boolean isActive);
    
    /**
     * 统计指定类型的题目数
     * @param questionType 题目类型
     * @return 题目数
     */
    long countByQuestionType(ReadingQuestion.QuestionType questionType);
    
    /**
     * 统计指定难度的题目数
     * @param difficultyLevel 难度级别
     * @return 题目数
     */
    long countByDifficultyLevel(ReadingQuestion.DifficultyLevel difficultyLevel);
    
    /**
     * 获取文章题目的平均分值
     * @param articleId 文章ID
     * @return 平均分值
     */
    @Query("SELECT COALESCE(AVG(rq.points), 0.0) FROM ReadingQuestion rq WHERE rq.articleId = :articleId AND rq.isActive = true")
    double getAveragePointsByArticleId(@Param("articleId") Long articleId);
    
    /**
     * 获取文章题目的总分值
     * @param articleId 文章ID
     * @return 总分值
     */
    @Query("SELECT COALESCE(SUM(rq.points), 0) FROM ReadingQuestion rq WHERE rq.articleId = :articleId AND rq.isActive = true")
    int getTotalPointsByArticleId(@Param("articleId") Long articleId);
    
    /**
     * 删除文章的所有题目
     * @param articleId 文章ID
     */
    void deleteByArticleId(Long articleId);
    
    /**
     * 检查文章是否存在指定内容的题目
     * @param articleId 文章ID
     * @param content 题目内容
     * @return 是否存在
     */
    boolean existsByArticleIdAndContent(Long articleId, String content);
}