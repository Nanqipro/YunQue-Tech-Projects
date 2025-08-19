package com.nanqipro.repository;

import com.nanqipro.entity.ReadingProgress;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 阅读进度数据访问层
 */
@Repository
public interface ReadingProgressRepository extends JpaRepository<ReadingProgress, Long> {
    
    /**
     * 根据用户ID和文章ID查找阅读进度
     * @param userId 用户ID
     * @param articleId 文章ID
     * @return 阅读进度
     */
    Optional<ReadingProgress> findByUserIdAndArticleId(Long userId, Long articleId);
    
    /**
     * 根据用户ID查找所有阅读进度
     * @param userId 用户ID
     * @return 阅读进度列表
     */
    List<ReadingProgress> findByUserId(Long userId);
    
    /**
     * 根据用户ID和状态查找阅读进度
     * @param userId 用户ID
     * @param status 阅读状态
     * @return 阅读进度列表
     */
    List<ReadingProgress> findByUserIdAndStatus(Long userId, ReadingProgress.Status status);
    
    /**
     * 根据用户ID和状态分页查找阅读进度（按最后阅读时间降序）
     * @param userId 用户ID
     * @param status 阅读状态
     * @param pageable 分页参数
     * @return 阅读进度分页列表
     */
    Page<ReadingProgress> findByUserIdAndStatusOrderByLastReadAtDesc(Long userId, ReadingProgress.Status status, Pageable pageable);
    
    /**
     * 根据用户ID查找收藏的文章
     * @param userId 用户ID
     * @return 收藏的阅读进度列表
     */
    List<ReadingProgress> findByUserIdAndIsFavoriteTrue(Long userId);
    
    /**
     * 根据用户ID查找已书签的文章
     * @param userId 用户ID
     * @return 已书签的阅读进度列表
     */
    List<ReadingProgress> findByUserIdAndIsBookmarkedTrue(Long userId);
    
    /**
     * 根据文章ID查找所有阅读进度
     * @param articleId 文章ID
     * @return 阅读进度列表
     */
    List<ReadingProgress> findByArticleId(Long articleId);
    
    /**
     * 统计用户完成阅读的文章数量
     * @param userId 用户ID
     * @return 完成数量
     */
    @Query("SELECT COUNT(rp) FROM ReadingProgress rp WHERE rp.userId = :userId AND rp.status = 'COMPLETED'")
    long countCompletedByUserId(@Param("userId") Long userId);
    
    /**
     * 统计用户正在阅读的文章数量
     * @param userId 用户ID
     * @return 正在阅读数量
     */
    @Query("SELECT COUNT(rp) FROM ReadingProgress rp WHERE rp.userId = :userId AND rp.status = 'IN_PROGRESS'")
    long countInProgressByUserId(@Param("userId") Long userId);
    
    /**
     * 获取用户总阅读时间
     * @param userId 用户ID
     * @return 总阅读时间（秒）
     */
    @Query("SELECT COALESCE(SUM(rp.totalReadingTime), 0) FROM ReadingProgress rp WHERE rp.userId = :userId")
    long getTotalReadingTimeByUserId(@Param("userId") Long userId);
    
    /**
     * 获取用户平均阅读进度
     * @param userId 用户ID
     * @return 平均进度百分比
     */
    @Query("SELECT COALESCE(AVG(rp.progressPercentage), 0.0) FROM ReadingProgress rp WHERE rp.userId = :userId")
    double getAverageProgressByUserId(@Param("userId") Long userId);
    
    /**
     * 删除用户的所有阅读进度
     * @param userId 用户ID
     */
    void deleteByUserId(Long userId);
    
    /**
     * 删除文章的所有阅读进度
     * @param articleId 文章ID
     */
    void deleteByArticleId(Long articleId);
}