package com.nanqipro.repository;

import com.nanqipro.entity.Vocabulary;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 词汇数据访问接口
 */
@Repository
public interface VocabularyRepository extends JpaRepository<Vocabulary, Long> {
    
    /**
     * 根据单词查找词汇
     */
    Optional<Vocabulary> findByWord(String word);
    
    /**
     * 根据单词查找词汇（忽略大小写）
     */
    Optional<Vocabulary> findByWordIgnoreCase(String word);
    
    /**
     * 检查单词是否存在
     */
    boolean existsByWord(String word);
    
    /**
     * 检查单词是否存在（忽略大小写）
     */
    boolean existsByWordIgnoreCase(String word);
    
    /**
     * 根据难度级别查找词汇
     */
    Page<Vocabulary> findByDifficultyLevel(Vocabulary.DifficultyLevel difficultyLevel, Pageable pageable);
    
    /**
     * 根据单词类型查找词汇
     */
    Page<Vocabulary> findByWordType(Vocabulary.WordType wordType, Pageable pageable);
    
    /**
     * 根据词汇族查找词汇
     */
    Page<Vocabulary> findByWordFamily(String wordFamily, Pageable pageable);
    
    /**
     * 根据频率排名范围查找词汇
     */
    Page<Vocabulary> findByFrequencyRankBetween(Integer minRank, Integer maxRank, Pageable pageable);
    
    /**
     * 根据是否激活状态查找词汇
     */
    Page<Vocabulary> findByIsActive(Boolean isActive, Pageable pageable);
    
    /**
     * 搜索词汇（单词、音标、词汇族模糊匹配）
     */
    @Query("SELECT v FROM Vocabulary v WHERE " +
           "LOWER(v.word) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(v.phoneticUs) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(v.phoneticUk) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(v.wordFamily) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Vocabulary> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);
    
    /**
     * 高级搜索词汇
     */
    @Query("SELECT v FROM Vocabulary v WHERE " +
           "(:word IS NULL OR LOWER(v.word) LIKE LOWER(CONCAT('%', :word, '%'))) AND " +
           "(:difficultyLevel IS NULL OR v.difficultyLevel = :difficultyLevel) AND " +
           "(:wordType IS NULL OR v.wordType = :wordType) AND " +
           "(:wordFamily IS NULL OR LOWER(v.wordFamily) LIKE LOWER(CONCAT('%', :wordFamily, '%'))) AND " +
           "(:isActive IS NULL OR v.isActive = :isActive)")
    Page<Vocabulary> advancedSearch(@Param("word") String word,
                                   @Param("difficultyLevel") Vocabulary.DifficultyLevel difficultyLevel,
                                   @Param("wordType") Vocabulary.WordType wordType,
                                   @Param("wordFamily") String wordFamily,
                                   @Param("isActive") Boolean isActive,
                                   Pageable pageable);
    
    /**
     * 根据标签搜索词汇
     */
    @Query("SELECT v FROM Vocabulary v JOIN v.tags t WHERE t = :tag")
    Page<Vocabulary> findByTag(@Param("tag") String tag, Pageable pageable);
    
    /**
     * 根据多个标签搜索词汇（包含任一标签）
     */
    @Query("SELECT DISTINCT v FROM Vocabulary v JOIN v.tags t WHERE t IN :tags")
    Page<Vocabulary> findByTagsIn(@Param("tags") List<String> tags, Pageable pageable);
    
    /**
     * 根据多个标签搜索词汇（包含所有标签）
     */
    @Query("SELECT v FROM Vocabulary v WHERE " +
           "(SELECT COUNT(t) FROM Vocabulary v2 JOIN v2.tags t WHERE v2.id = v.id AND t IN :tags) = :tagCount")
    Page<Vocabulary> findByAllTags(@Param("tags") List<String> tags, @Param("tagCount") long tagCount, Pageable pageable);
    
    /**
     * 获取随机词汇
     */
    @Query(value = "SELECT * FROM vocabularies WHERE is_active = true ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Vocabulary> findRandomVocabularies(@Param("limit") int limit);
    
    /**
     * 根据难度级别获取随机词汇
     */
    @Query(value = "SELECT * FROM vocabularies WHERE is_active = true AND difficulty_level = :level ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Vocabulary> findRandomVocabulariesByLevel(@Param("level") String level, @Param("limit") int limit);
    
    /**
     * 获取热门词汇（根据学习次数排序）
     */
    @Query("SELECT v FROM Vocabulary v LEFT JOIN UserVocabulary uv ON v.id = uv.vocabulary.id " +
           "WHERE v.isActive = true " +
           "GROUP BY v.id " +
           "ORDER BY COUNT(uv.id) DESC")
    List<Vocabulary> findPopularVocabularies(Pageable pageable);
    
    /**
     * 获取最新添加的词汇
     */
    List<Vocabulary> findByIsActiveTrueOrderByCreatedAtDesc(Pageable pageable);
    
    /**
     * 根据频率排名获取词汇
     */
    List<Vocabulary> findByFrequencyRankIsNotNullOrderByFrequencyRankAsc(Pageable pageable);
    
    /**
     * 获取指定难度级别的词汇数量
     */
    long countByDifficultyLevel(Vocabulary.DifficultyLevel difficultyLevel);
    
    /**
     * 获取指定单词类型的词汇数量
     */
    long countByWordType(Vocabulary.WordType wordType);
    
    /**
     * 获取激活状态的词汇数量
     */
    long countByIsActive(Boolean isActive);
    
    /**
     * 获取所有标签
     */
    @Query("SELECT DISTINCT t FROM Vocabulary v JOIN v.tags t ORDER BY t")
    List<String> findAllTags();
    
    /**
     * 获取标签使用次数统计
     */
    @Query("SELECT t, COUNT(v) FROM Vocabulary v JOIN v.tags t GROUP BY t ORDER BY COUNT(v) DESC")
    List<Object[]> getTagStatistics();
    
    /**
     * 获取词汇族统计
     */
    @Query("SELECT v.wordFamily, COUNT(v) FROM Vocabulary v WHERE v.wordFamily IS NOT NULL GROUP BY v.wordFamily ORDER BY COUNT(v) DESC")
    List<Object[]> getWordFamilyStatistics();
    
    /**
     * 获取难度级别统计
     */
    @Query("SELECT v.difficultyLevel, COUNT(v) FROM Vocabulary v GROUP BY v.difficultyLevel")
    List<Object[]> getDifficultyLevelStatistics();
    
    /**
     * 获取单词类型统计
     */
    @Query("SELECT v.wordType, COUNT(v) FROM Vocabulary v GROUP BY v.wordType")
    List<Object[]> getWordTypeStatistics();
    
    /**
     * 批量更新词汇激活状态
     */
    @Query("UPDATE Vocabulary v SET v.isActive = :isActive WHERE v.id IN :ids")
    int updateActiveStatusByIds(@Param("ids") List<Long> ids, @Param("isActive") Boolean isActive);
    
    /**
     * 批量删除词汇
     */
    void deleteByIdIn(List<Long> ids);
    
    /**
     * 根据单词列表查找词汇
     */
    List<Vocabulary> findByWordIn(List<String> words);
    
    /**
     * 查找相似单词（基于编辑距离）
     */
    @Query(value = "SELECT * FROM vocabularies v WHERE " +
           "LEVENSHTEIN(LOWER(v.word), LOWER(:word)) <= :maxDistance AND " +
           "v.word != :word AND v.is_active = true " +
           "ORDER BY LEVENSHTEIN(LOWER(v.word), LOWER(:word)) ASC " +
           "LIMIT :limit", nativeQuery = true)
    List<Vocabulary> findSimilarWords(@Param("word") String word, 
                                     @Param("maxDistance") int maxDistance, 
                                     @Param("limit") int limit);
    
    /**
     * 查找包含指定前缀的单词
     */
    List<Vocabulary> findByWordStartingWithIgnoreCaseAndIsActiveTrue(String prefix, Pageable pageable);
    
    /**
     * 查找包含指定后缀的单词
     */
    List<Vocabulary> findByWordEndingWithIgnoreCaseAndIsActiveTrue(String suffix, Pageable pageable);
    
    /**
     * 查找指定长度范围的单词
     */
    @Query("SELECT v FROM Vocabulary v WHERE LENGTH(v.word) BETWEEN :minLength AND :maxLength AND v.isActive = true")
    Page<Vocabulary> findByWordLengthBetween(@Param("minLength") int minLength, 
                                            @Param("maxLength") int maxLength, 
                                            Pageable pageable);
}