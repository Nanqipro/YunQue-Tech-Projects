package com.nanqipro.repository;

import com.nanqipro.entity.Article;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 文章数据访问层接口
 */
@Repository
public interface ArticleRepository extends JpaRepository<Article, Long> {
    
    // ==================== 基础查询 ====================
    
    /**
     * 根据标题查找文章
     * @param title 标题
     * @return 文章
     */
    Optional<Article> findByTitle(String title);
    
    /**
     * 检查标题是否存在
     * @param title 标题
     * @return 是否存在
     */
    boolean existsByTitle(String title);
    
    /**
     * 根据作者查找文章
     * @param author 作者
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByAuthor(String author, Pageable pageable);
    
    /**
     * 根据状态查找文章
     * @param status 状态
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByStatus(Article.Status status, Pageable pageable);
    
    /**
     * 查找已发布的文章
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByStatusOrderByPublishedAtDesc(Article.Status status, Pageable pageable);
    
    // ==================== 分类和难度查询 ====================
    
    /**
     * 根据分类查找文章
     * @param category 分类
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByCategory(Article.Category category, Pageable pageable);
    
    /**
     * 根据难度级别查找文章
     * @param difficultyLevel 难度级别
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByDifficultyLevel(Article.DifficultyLevel difficultyLevel, Pageable pageable);
    
    /**
     * 根据分类和难度级别查找文章
     * @param category 分类
     * @param difficultyLevel 难度级别
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByCategoryAndDifficultyLevel(Article.Category category, 
                                                  Article.DifficultyLevel difficultyLevel, 
                                                  Pageable pageable);
    
    // ==================== 搜索查询 ====================
    
    /**
     * 根据标题关键词搜索文章
     * @param keyword 关键词
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByTitleContainingIgnoreCase(String keyword, Pageable pageable);
    
    /**
     * 根据内容关键词搜索文章
     * @param keyword 关键词
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByContentContainingIgnoreCase(String keyword, Pageable pageable);
    
    /**
     * 全文搜索文章
     * @param keyword 关键词
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    @Query("SELECT a FROM Article a WHERE " +
           "LOWER(a.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.content) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.summary) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.author) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Article> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);
    
    /**
     * 高级搜索文章
     * @param title 标题
     * @param author 作者
     * @param category 分类
     * @param difficultyLevel 难度级别
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    @Query("SELECT a FROM Article a WHERE " +
           "(:title IS NULL OR LOWER(a.title) LIKE LOWER(CONCAT('%', :title, '%'))) AND " +
           "(:author IS NULL OR LOWER(a.author) LIKE LOWER(CONCAT('%', :author, '%'))) AND " +
           "(:category IS NULL OR a.category = :category) AND " +
           "(:difficultyLevel IS NULL OR a.difficultyLevel = :difficultyLevel) AND " +
           "a.status = 'PUBLISHED'")
    Page<Article> advancedSearch(@Param("title") String title,
                               @Param("author") String author,
                               @Param("category") Article.Category category,
                               @Param("difficultyLevel") Article.DifficultyLevel difficultyLevel,
                               Pageable pageable);
    
    // ==================== 标签查询 ====================
    
    /**
     * 根据标签查找文章
     * @param tag 标签
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    @Query("SELECT a FROM Article a JOIN a.tags t WHERE t = :tag AND a.status = 'PUBLISHED'")
    Page<Article> findByTag(@Param("tag") String tag, Pageable pageable);
    
    /**
     * 根据多个标签查找文章
     * @param tags 标签列表
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    @Query("SELECT DISTINCT a FROM Article a JOIN a.tags t WHERE t IN :tags AND a.status = 'PUBLISHED'")
    Page<Article> findByTagsIn(@Param("tags") List<String> tags, Pageable pageable);
    
    /**
     * 获取所有标签
     * @return 标签列表
     */
    @Query("SELECT DISTINCT t FROM Article a JOIN a.tags t ORDER BY t")
    List<String> findAllTags();
    
    // ==================== 排序和推荐查询 ====================
    
    /**
     * 获取热门文章（按浏览量排序）
     * @param limit 数量限制
     * @return 文章列表
     */
    @Query("SELECT a FROM Article a WHERE a.status = 'PUBLISHED' ORDER BY a.viewCount DESC")
    List<Article> findPopularArticles(Pageable pageable);
    
    /**
     * 获取最新文章
     * @param limit 数量限制
     * @return 文章列表
     */
    @Query("SELECT a FROM Article a WHERE a.status = 'PUBLISHED' ORDER BY a.publishedAt DESC")
    List<Article> findLatestArticles(Pageable pageable);
    
    /**
     * 获取推荐文章（按点赞数和浏览量综合排序）
     * @param limit 数量限制
     * @return 文章列表
     */
    @Query("SELECT a FROM Article a WHERE a.status = 'PUBLISHED' " +
           "ORDER BY (a.likeCount * 2 + a.viewCount * 0.1) DESC")
    List<Article> findRecommendedArticles(Pageable pageable);
    
    /**
     * 获取精选文章
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByIsFeaturedTrueAndStatusOrderByPublishedAtDesc(Article.Status status, Pageable pageable);
    
    /**
     * 获取付费文章
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByIsPremiumTrueAndStatusOrderByPublishedAtDesc(Article.Status status, Pageable pageable);
    
    // ==================== 时间范围查询 ====================
    
    /**
     * 根据发布时间范围查找文章
     * @param startDate 开始时间
     * @param endDate 结束时间
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByPublishedAtBetween(LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    
    /**
     * 根据创建时间范围查找文章
     * @param startDate 开始时间
     * @param endDate 结束时间
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByCreatedAtBetween(LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    
    // ==================== 统计查询 ====================
    
    /**
     * 统计已发布文章总数
     * @return 文章总数
     */
    long countByStatus(Article.Status status);
    
    /**
     * 统计各分类文章数量
     * @return 分类统计
     */
    @Query("SELECT a.category, COUNT(a) FROM Article a WHERE a.status = 'PUBLISHED' GROUP BY a.category")
    List<Object[]> getCategoryStatistics();
    
    /**
     * 统计各难度级别文章数量
     * @return 难度级别统计
     */
    @Query("SELECT a.difficultyLevel, COUNT(a) FROM Article a WHERE a.status = 'PUBLISHED' GROUP BY a.difficultyLevel")
    List<Object[]> getDifficultyLevelStatistics();
    
    /**
     * 获取文章阅读排行
     * @param limit 数量限制
     * @return 阅读排行
     */
    @Query("SELECT a.id, a.title, a.viewCount FROM Article a WHERE a.status = 'PUBLISHED' " +
           "ORDER BY a.viewCount DESC")
    List<Object[]> getArticleReadingRanking(Pageable pageable);
    
    /**
     * 获取作者文章统计
     * @return 作者统计
     */
    @Query("SELECT a.author, COUNT(a), SUM(a.viewCount), AVG(a.viewCount) FROM Article a " +
           "WHERE a.status = 'PUBLISHED' GROUP BY a.author ORDER BY COUNT(a) DESC")
    List<Object[]> getAuthorStatistics();
    
    // ==================== 更新操作 ====================
    
    /**
     * 增加文章浏览量
     * @param articleId 文章ID
     */
    @Modifying
    @Query("UPDATE Article a SET a.viewCount = a.viewCount + 1 WHERE a.id = :articleId")
    void incrementViewCount(@Param("articleId") Long articleId);
    
    /**
     * 增加文章点赞数
     * @param articleId 文章ID
     */
    @Modifying
    @Query("UPDATE Article a SET a.likeCount = a.likeCount + 1 WHERE a.id = :articleId")
    void incrementLikeCount(@Param("articleId") Long articleId);
    
    /**
     * 减少文章点赞数
     * @param articleId 文章ID
     */
    @Modifying
    @Query("UPDATE Article a SET a.likeCount = a.likeCount - 1 WHERE a.id = :articleId AND a.likeCount > 0")
    void decrementLikeCount(@Param("articleId") Long articleId);
    
    /**
     * 增加文章收藏数
     * @param articleId 文章ID
     */
    @Modifying
    @Query("UPDATE Article a SET a.favoriteCount = a.favoriteCount + 1 WHERE a.id = :articleId")
    void incrementFavoriteCount(@Param("articleId") Long articleId);
    
    /**
     * 减少文章收藏数
     * @param articleId 文章ID
     */
    @Modifying
    @Query("UPDATE Article a SET a.favoriteCount = a.favoriteCount - 1 WHERE a.id = :articleId AND a.favoriteCount > 0")
    void decrementFavoriteCount(@Param("articleId") Long articleId);
    
    /**
     * 批量更新文章状态
     * @param articleIds 文章ID列表
     * @param status 新状态
     */
    @Modifying
    @Query("UPDATE Article a SET a.status = :status WHERE a.id IN :articleIds")
    void batchUpdateStatus(@Param("articleIds") List<Long> articleIds, @Param("status") Article.Status status);
    
    /**
     * 批量设置精选状态
     * @param articleIds 文章ID列表
     * @param featured 是否精选
     */
    @Modifying
    @Query("UPDATE Article a SET a.isFeatured = :featured WHERE a.id IN :articleIds")
    void batchUpdateFeatured(@Param("articleIds") List<Long> articleIds, @Param("featured") boolean featured);
    
    // ==================== 复杂查询 ====================
    
    /**
     * 根据阅读时长范围查找文章
     * @param minTime 最小阅读时间
     * @param maxTime 最大阅读时间
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByEstimatedReadingTimeBetween(Integer minTime, Integer maxTime, Pageable pageable);
    
    /**
     * 根据单词数范围查找文章
     * @param minWords 最小单词数
     * @param maxWords 最大单词数
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    Page<Article> findByWordCountBetween(Integer minWords, Integer maxWords, Pageable pageable);
    
    /**
     * 查找相似文章（基于标签和分类）
     * @param category 分类
     * @param tags 标签列表
     * @param excludeId 排除的文章ID
     * @param pageable 分页参数
     * @return 文章分页列表
     */
    @Query("SELECT DISTINCT a FROM Article a LEFT JOIN a.tags t WHERE " +
           "(a.category = :category OR t IN :tags) AND " +
           "a.id != :excludeId AND a.status = 'PUBLISHED' " +
           "ORDER BY (CASE WHEN a.category = :category THEN 2 ELSE 0 END + " +
           "(SELECT COUNT(t2) FROM Article a2 JOIN a2.tags t2 WHERE a2.id = a.id AND t2 IN :tags)) DESC")
    Page<Article> findSimilarArticles(@Param("category") Article.Category category,
                                    @Param("tags") List<String> tags,
                                    @Param("excludeId") Long excludeId,
                                    Pageable pageable);
    
    /**
     * 高级搜索文章（增强版）
     * @param keyword 关键词
     * @param category 分类
     * @param difficultyLevel 难度级别
     * @param author 作者
     * @param tags 标签列表
     * @param pageable 分页参数
     * @return 搜索结果分页列表
     */
    @Query("SELECT DISTINCT a FROM Article a LEFT JOIN a.tags t WHERE a.status = 'PUBLISHED' " +
           "AND (:keyword IS NULL OR LOWER(a.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(a.content) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(a.summary) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "AND (:category IS NULL OR a.category = :category) " +
           "AND (:difficultyLevel IS NULL OR a.difficultyLevel = :difficultyLevel) " +
           "AND (:author IS NULL OR LOWER(a.author) LIKE LOWER(CONCAT('%', :author, '%'))) " +
           "AND (:tags IS NULL OR t IN :tags)")
    Page<Article> advancedSearchEnhanced(@Param("keyword") String keyword,
                                        @Param("category") Article.Category category,
                                        @Param("difficultyLevel") Article.DifficultyLevel difficultyLevel,
                                        @Param("author") String author,
                                        @Param("tags") List<String> tags,
                                        Pageable pageable);
    
    /**
     * 随机获取指定数量的已发布文章
     * @param limit 数量限制
     * @return 随机文章列表
     */
    @Query(value = "SELECT * FROM articles WHERE status = 'PUBLISHED' ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Article> findRandomArticles(@Param("limit") int limit);
    
    /**
     * 根据分类随机获取指定数量的已发布文章
     * @param category 分类
     * @param limit 数量限制
     * @return 随机文章列表
     */
    @Query(value = "SELECT * FROM articles WHERE category = :category AND status = 'PUBLISHED' ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Article> findRandomArticlesByCategory(@Param("category") String category, @Param("limit") int limit);
    
    /**
     * 根据难度级别随机获取指定数量的已发布文章
     * @param difficultyLevel 难度级别
     * @param limit 数量限制
     * @return 随机文章列表
     */
    @Query(value = "SELECT * FROM articles WHERE difficulty_level = :difficultyLevel AND status = 'PUBLISHED' ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Article> findRandomArticlesByDifficultyLevel(@Param("difficultyLevel") String difficultyLevel, @Param("limit") int limit);
}