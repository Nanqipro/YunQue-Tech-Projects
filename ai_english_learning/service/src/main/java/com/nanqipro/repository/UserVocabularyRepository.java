package com.nanqipro.repository;

import com.nanqipro.entity.UserVocabulary;
import com.nanqipro.entity.Vocabulary;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 用户词汇学习记录数据访问接口
 */
@Repository
public interface UserVocabularyRepository extends JpaRepository<UserVocabulary, Long> {
    
    /**
     * 根据用户ID和词汇ID查找学习记录
     */
    Optional<UserVocabulary> findByUserIdAndVocabularyId(Long userId, Long vocabularyId);
    
    /**
     * 检查用户是否已学习某个词汇
     */
    boolean existsByUserIdAndVocabularyId(Long userId, Long vocabularyId);
    
    /**
     * 获取用户的学习列表
     */
    Page<UserVocabulary> findByUserId(Long userId, Pageable pageable);
    
    /**
     * 获取用户已掌握的词汇
     */
    Page<UserVocabulary> findByUserIdAndMasteryLevel(Long userId, UserVocabulary.MasteryLevel masteryLevel, Pageable pageable);
    
    /**
     * 获取用户收藏的词汇
     */
    Page<UserVocabulary> findByUserIdAndIsFavoriteTrue(Long userId, Pageable pageable);
    
    /**
     * 获取用户标记为困难的词汇
     */
    Page<UserVocabulary> findByUserIdAndIsDifficultTrue(Long userId, Pageable pageable);
    
    /**
     * 获取用户需要复习的词汇
     */
    @Query("SELECT uv FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND uv.nextReviewAt <= :now " +
           "AND uv.masteryLevel != com.nanqipro.entity.UserVocabulary.MasteryLevel.EXPERT " +
           "ORDER BY uv.nextReviewAt ASC")
    List<UserVocabulary> findVocabulariesForReview(@Param("userId") Long userId, 
                                                   @Param("now") LocalDateTime now, 
                                                   Pageable pageable);
    
    /**
     * 获取用户今日学习的词汇
     */
    @Query("SELECT uv FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND uv.lastReviewedAt >= :startOfDay " +
           "AND uv.lastReviewedAt < :endOfDay " +
           "ORDER BY uv.lastReviewedAt DESC")
    List<UserVocabulary> findTodayLearningVocabularies(@Param("userId") Long userId,
                                                       @Param("startOfDay") LocalDateTime startOfDay,
                                                       @Param("endOfDay") LocalDateTime endOfDay,
                                                       Pageable pageable);
    
    /**
     * 获取用户学习历史
     */
    @Query("SELECT uv FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND uv.lastReviewedAt >= :startDate " +
           "AND uv.lastReviewedAt <= :endDate " +
           "ORDER BY uv.lastReviewedAt DESC")
    Page<UserVocabulary> findUserLearningHistory(@Param("userId") Long userId,
                                                 @Param("startDate") LocalDateTime startDate,
                                                 @Param("endDate") LocalDateTime endDate,
                                                 Pageable pageable);
    
    /**
     * 获取用户学习统计
     */
    @Query("SELECT " +
           "COUNT(uv) as totalWords, " +
           "SUM(uv.studyCount) as totalStudyCount, " +
           "SUM(uv.correctCount) as totalCorrectCount, " +
           "SUM(uv.wrongCount) as totalWrongCount, " +
           "SUM(uv.totalStudyTime) as totalStudyTime, " +
           "AVG(uv.accuracyRate) as avgAccuracyRate " +
           "FROM UserVocabulary uv WHERE uv.user.id = :userId")
    Object[] getUserLearningStatistics(@Param("userId") Long userId);
    
    /**
     * 获取用户各掌握度级别的词汇数量
     */
    @Query("SELECT uv.masteryLevel, COUNT(uv) FROM UserVocabulary uv " +
           "WHERE uv.user.id = :userId " +
           "GROUP BY uv.masteryLevel")
    List<Object[]> getUserMasteryLevelStatistics(@Param("userId") Long userId);
    
    /**
     * 获取用户学习趋势数据
     */
    @Query("SELECT DATE(uv.lastReviewedAt) as studyDate, " +
           "COUNT(DISTINCT uv.vocabulary.id) as wordsStudied, " +
           "SUM(uv.lastStudyTime) as totalTime " +
           "FROM UserVocabulary uv " +
           "WHERE uv.user.id = :userId " +
           "AND uv.lastReviewedAt >= :startDate " +
           "GROUP BY DATE(uv.lastReviewedAt) " +
           "ORDER BY studyDate DESC")
    List<Object[]> getUserLearningTrend(@Param("userId") Long userId, 
                                       @Param("startDate") LocalDateTime startDate);
    
    /**
     * 获取用户连续学习天数
     */
    @Query(value = "SELECT COUNT(*) FROM (" +
           "SELECT DATE(last_reviewed_at) as study_date " +
           "FROM user_vocabularies " +
           "WHERE user_id = :userId " +
           "AND last_reviewed_at >= DATE_SUB(CURDATE(), INTERVAL :days DAY) " +
           "GROUP BY DATE(last_reviewed_at)" +
           ") as daily_studies", nativeQuery = true)
    int getUserStudyStreak(@Param("userId") Long userId, @Param("days") int days);
    
    /**
     * 获取用户最近学习的词汇
     */
    List<UserVocabulary> findByUserIdOrderByLastReviewedAtDesc(Long userId, Pageable pageable);
    
    /**
     * 获取用户学习时间最长的词汇
     */
    List<UserVocabulary> findByUserIdOrderByTotalStudyTimeDesc(Long userId, Pageable pageable);
    
    /**
     * 获取用户准确率最低的词汇
     */
    List<UserVocabulary> findByUserIdOrderByAccuracyRateAsc(Long userId, Pageable pageable);
    
    /**
     * 根据难度级别获取用户词汇
     */
    @Query("SELECT uv FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND uv.vocabulary.difficultyLevel = :difficultyLevel")
    Page<UserVocabulary> findByUserIdAndVocabularyDifficultyLevel(@Param("userId") Long userId,
                                                                 @Param("difficultyLevel") Vocabulary.DifficultyLevel difficultyLevel,
                                                                 Pageable pageable);
    
    /**
     * 根据词汇类型获取用户词汇
     */
    @Query("SELECT uv FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND uv.vocabulary.wordType = :wordType")
    Page<UserVocabulary> findByUserIdAndVocabularyWordType(@Param("userId") Long userId,
                                                          @Param("wordType") Vocabulary.WordType wordType,
                                                          Pageable pageable);
    
    /**
     * 搜索用户词汇
     */
    @Query("SELECT uv FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND (LOWER(uv.vocabulary.word) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(uv.personalNote) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<UserVocabulary> searchUserVocabularies(@Param("userId") Long userId,
                                               @Param("keyword") String keyword,
                                               Pageable pageable);
    
    /**
     * 批量更新收藏状态
     */
    @Modifying
    @Query("UPDATE UserVocabulary uv SET uv.isFavorite = :isFavorite " +
           "WHERE uv.user.id = :userId AND uv.vocabulary.id IN :vocabularyIds")
    int updateFavoriteStatus(@Param("userId") Long userId,
                            @Param("vocabularyIds") List<Long> vocabularyIds,
                            @Param("isFavorite") Boolean isFavorite);
    
    /**
     * 批量更新困难标记
     */
    @Modifying
    @Query("UPDATE UserVocabulary uv SET uv.isDifficult = :isDifficult " +
           "WHERE uv.user.id = :userId AND uv.vocabulary.id IN :vocabularyIds")
    int updateDifficultStatus(@Param("userId") Long userId,
                             @Param("vocabularyIds") List<Long> vocabularyIds,
                             @Param("isDifficult") Boolean isDifficult);
    
    /**
     * 批量重置学习进度
     */
    @Modifying
    @Query("UPDATE UserVocabulary uv SET " +
           "uv.masteryLevel = com.nanqipro.entity.UserVocabulary.MasteryLevel.NEW, " +
           "uv.studyCount = 0, " +
           "uv.correctCount = 0, " +
           "uv.wrongCount = 0, " +
           "uv.accuracyRate = 0.0, " +
           "uv.reviewInterval = 1, " +
           "uv.easeFactor = 2.5, " +
           "uv.repetitionCount = 0, " +
           "uv.nextReviewAt = NULL " +
           "WHERE uv.user.id = :userId AND uv.vocabulary.id IN :vocabularyIds")
    int resetLearningProgress(@Param("userId") Long userId,
                             @Param("vocabularyIds") List<Long> vocabularyIds);
    
    /**
     * 删除用户词汇记录
     */
    void deleteByUserIdAndVocabularyId(Long userId, Long vocabularyId);
    
    /**
     * 批量删除用户词汇记录
     */
    void deleteByUserIdAndVocabularyIdIn(Long userId, List<Long> vocabularyIds);
    
    /**
     * 删除用户所有词汇记录
     */
    void deleteByUserId(Long userId);
    
    /**
     * 获取需要复习的词汇数量
     */
    @Query("SELECT COUNT(uv) FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND uv.nextReviewAt <= :now " +
           "AND uv.masteryLevel != com.nanqipro.entity.UserVocabulary.MasteryLevel.EXPERT")
    long countVocabulariesForReview(@Param("userId") Long userId, @Param("now") LocalDateTime now);
    
    /**
     * 获取用户今日新学词汇数量
     */
    @Query("SELECT COUNT(uv) FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND uv.firstLearnedAt >= :startOfDay " +
           "AND uv.firstLearnedAt < :endOfDay")
    long countTodayNewWords(@Param("userId") Long userId,
                           @Param("startOfDay") LocalDateTime startOfDay,
                           @Param("endOfDay") LocalDateTime endOfDay);
    
    /**
     * 获取用户今日复习词汇数量
     */
    @Query("SELECT COUNT(uv) FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "AND uv.lastReviewedAt >= :startOfDay " +
           "AND uv.lastReviewedAt < :endOfDay " +
           "AND uv.firstLearnedAt < :startOfDay")
    long countTodayReviewedWords(@Param("userId") Long userId,
                                @Param("startOfDay") LocalDateTime startOfDay,
                                @Param("endOfDay") LocalDateTime endOfDay);
    
    /**
     * 获取用户词汇掌握度分布
     */
    @Query("SELECT uv.masteryLevel, COUNT(uv), AVG(uv.accuracyRate) " +
           "FROM UserVocabulary uv WHERE uv.user.id = :userId " +
           "GROUP BY uv.masteryLevel " +
           "ORDER BY uv.masteryLevel")
    List<Object[]> getUserMasteryDistribution(@Param("userId") Long userId);
    
    /**
     * 获取用户学习效率统计
     */
    @Query("SELECT " +
           "AVG(uv.totalStudyTime / NULLIF(uv.studyCount, 0)) as avgTimePerStudy, " +
           "AVG(uv.accuracyRate) as avgAccuracy, " +
           "COUNT(CASE WHEN uv.masteryLevel = com.nanqipro.entity.UserVocabulary.MasteryLevel.EXPERT THEN 1 END) as expertCount, " +
           "COUNT(uv) as totalCount " +
           "FROM UserVocabulary uv WHERE uv.user.id = :userId")
    Object[] getUserLearningEfficiency(@Param("userId") Long userId);
}