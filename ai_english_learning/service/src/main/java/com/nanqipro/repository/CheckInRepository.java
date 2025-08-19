package com.nanqipro.repository;

import com.nanqipro.entity.CheckIn;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 打卡活动数据访问接口
 */
@Repository
public interface CheckInRepository extends JpaRepository<CheckIn, Long> {
    
    // ==================== 基础查询 ====================
    
    /**
     * 根据状态查找打卡活动
     */
    List<CheckIn> findByStatus(CheckIn.CheckInStatus status);
    
    /**
     * 根据类型查找打卡活动
     */
    List<CheckIn> findByType(CheckIn.CheckInType type);
    
    /**
     * 根据频率查找打卡活动
     */
    List<CheckIn> findByFrequency(CheckIn.CheckInFrequency frequency);
    
    /**
     * 根据创建者ID查找打卡活动
     */
    List<CheckIn> findByCreatorIdOrderByCreatedAtDesc(Long creatorId);
    
    /**
     * 查找公开的打卡活动
     */
    List<CheckIn> findByIsPublicTrue();
    
    /**
     * 查找私有的打卡活动
     */
    List<CheckIn> findByIsPublicFalse();
    
    /**
     * 根据标题或描述模糊查询
     */
    @Query("SELECT c FROM CheckIn c WHERE c.title LIKE %:keyword% OR c.description LIKE %:keyword%")
    List<CheckIn> findByTitleOrDescriptionContaining(@Param("keyword") String keyword);
    
    // ==================== 时间相关查询 ====================
    
    /**
     * 查找指定时间范围内的打卡活动
     */
    @Query("SELECT c FROM CheckIn c WHERE c.startDate <= :endDate AND c.endDate >= :startDate")
    List<CheckIn> findByTimeRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    /**
     * 查找正在进行的打卡活动
     */
    @Query("SELECT c FROM CheckIn c WHERE c.status = 'ACTIVE' AND c.startDate <= :currentDate AND c.endDate >= :currentDate")
    List<CheckIn> findActiveChallenges(@Param("currentDate") LocalDate currentDate);
    
    /**
     * 查找即将开始的打卡活动
     */
    @Query("SELECT c FROM CheckIn c WHERE c.status = 'PUBLISHED' AND c.startDate > :currentDate")
    List<CheckIn> findUpcomingChallenges(@Param("currentDate") LocalDate currentDate);
    
    /**
     * 查找已结束的打卡活动
     */
    @Query("SELECT c FROM CheckIn c WHERE c.status = 'COMPLETED' OR c.endDate < :currentDate")
    List<CheckIn> findCompletedChallenges(@Param("currentDate") LocalDate currentDate);
    
    /**
     * 查找需要更新状态的打卡活动
     */
    @Query("SELECT c FROM CheckIn c WHERE (c.status = 'PUBLISHED' AND c.startDate <= :currentDate) OR (c.status = 'ACTIVE' AND c.endDate < :currentDate)")
    List<CheckIn> findCheckInsNeedingStatusUpdate(@Param("currentDate") LocalDate currentDate);
    
    // ==================== 用户相关查询 ====================
    
    /**
     * 查找用户参与的打卡活动
     */
    @Query("SELECT DISTINCT c FROM CheckIn c JOIN CheckInRecord r ON c.id = r.checkIn.id WHERE r.userId = :userId")
    List<CheckIn> findByParticipantUserId(@Param("userId") Long userId);
    
    /**
     * 查找用户正在参与的打卡活动
     */
    @Query("SELECT DISTINCT c FROM CheckIn c JOIN CheckInRecord r ON c.id = r.checkIn.id WHERE r.userId = :userId AND c.status = 'ACTIVE' AND c.endDate >= :currentDate")
    List<CheckIn> findActiveParticipationsByUserId(@Param("userId") Long userId, @Param("currentDate") LocalDate currentDate);
    
    /**
     * 查找用户已完成的打卡活动
     */
    @Query("SELECT DISTINCT c FROM CheckIn c JOIN CheckInRecord r ON c.id = r.checkIn.id WHERE r.userId = :userId AND (c.status = 'COMPLETED' OR c.endDate < :currentDate)")
    List<CheckIn> findCompletedParticipationsByUserId(@Param("userId") Long userId, @Param("currentDate") LocalDate currentDate);
    
    // ==================== 统计查询 ====================
    
    /**
     * 统计打卡活动总数
     */
    Long countByIsPublicTrue();
    
    /**
     * 统计指定状态的打卡活动数量
     */
    Long countByStatus(CheckIn.CheckInStatus status);
    
    /**
     * 统计指定类型的打卡活动数量
     */
    Long countByType(CheckIn.CheckInType type);
    
    /**
     * 统计指定创建者的打卡活动数量
     */
    Long countByCreatorId(Long creatorId);
    
    /**
     * 统计指定用户参与的打卡活动数量
     */
    @Query("SELECT COUNT(DISTINCT c.id) FROM CheckIn c JOIN CheckInRecord r ON c.id = r.checkIn.id WHERE r.userId = :userId")
    Long countByParticipantUserId(@Param("userId") Long userId);
    
    // ==================== 排序和分页查询 ====================
    
    /**
     * 查找最新的打卡活动
     */
    List<CheckIn> findByIsPublicTrueOrderByCreatedAtDesc(Pageable pageable);
    
    /**
     * 查找最热门的打卡活动（按参与人数排序）
     */
    @Query("SELECT c, COUNT(r.id) as participantCount FROM CheckIn c LEFT JOIN CheckInRecord r ON c.id = r.checkIn.id WHERE c.isPublic = true GROUP BY c.id ORDER BY participantCount DESC")
    List<Object[]> findPopularCheckIns(Pageable pageable);
    
    /**
     * 多条件分页查询
     */
    @Query("SELECT c FROM CheckIn c WHERE " +
           "(:type IS NULL OR c.type = :type) AND " +
           "(:frequency IS NULL OR c.frequency = :frequency) AND " +
           "(:status IS NULL OR c.status = :status) AND " +
           "c.isPublic = true")
    Page<CheckIn> findByMultipleConditions(@Param("type") CheckIn.CheckInType type,
                                          @Param("frequency") CheckIn.CheckInFrequency frequency,
                                          @Param("status") CheckIn.CheckInStatus status,
                                          Pageable pageable);
    
    // ==================== 推荐和建议 ====================
    
    /**
     * 查找推荐的打卡活动
     */
    @Query("SELECT c FROM CheckIn c WHERE c.type = :type AND c.frequency = :frequency AND c.isPublic = true AND c.status = 'ACTIVE' ORDER BY c.createdAt DESC")
    List<CheckIn> findRecommendedCheckIns(@Param("type") CheckIn.CheckInType type,
                                         @Param("frequency") CheckIn.CheckInFrequency frequency,
                                         Pageable pageable);
    
    /**
     * 查找建议的打卡活动（基于用户历史）
     */
    @Query("SELECT c FROM CheckIn c WHERE c.id NOT IN " +
           "(SELECT DISTINCT r.checkIn.id FROM CheckInRecord r WHERE r.userId = :userId) " +
           "AND c.isPublic = true AND c.status IN ('PUBLISHED', 'ACTIVE') " +
           "ORDER BY c.createdAt DESC")
    List<CheckIn> findSuggestedCheckIns(@Param("userId") Long userId, Pageable pageable);
    
    // ==================== 数据分析 ====================
    
    /**
     * 统计每日新增打卡活动数量
     */
    @Query("SELECT DATE(c.createdAt) as date, COUNT(c.id) as count FROM CheckIn c WHERE c.createdAt >= :startDate GROUP BY DATE(c.createdAt) ORDER BY date")
    List<Object[]> countDailyNewCheckIns(@Param("startDate") LocalDateTime startDate);
    
    /**
     * 统计每月新增打卡活动数量
     */
    @Query("SELECT YEAR(c.createdAt) as year, MONTH(c.createdAt) as month, COUNT(c.id) as count FROM CheckIn c WHERE c.createdAt >= :startDate GROUP BY YEAR(c.createdAt), MONTH(c.createdAt) ORDER BY year, month")
    List<Object[]> countMonthlyNewCheckIns(@Param("startDate") LocalDateTime startDate);
    
    /**
     * 获取打卡活动类型分布统计
     */
    @Query("SELECT c.type, COUNT(c.id) FROM CheckIn c WHERE c.isPublic = true GROUP BY c.type")
    List<Object[]> getCheckInTypeDistribution();
    
    /**
     * 获取打卡活动频率分布统计
     */
    @Query("SELECT c.frequency, COUNT(c.id) FROM CheckIn c WHERE c.isPublic = true GROUP BY c.frequency")
    List<Object[]> getCheckInFrequencyDistribution();
    
    /**
     * 获取打卡活动状态分布统计
     */
    @Query("SELECT c.status, COUNT(c.id) FROM CheckIn c GROUP BY c.status")
    List<Object[]> getCheckInStatusDistribution();
    
    // ==================== 数据清理 ====================
    
    /**
     * 删除过期的草稿打卡活动
     */
    @Query("DELETE FROM CheckIn c WHERE c.status = 'DRAFT' AND c.createdAt < :expireTime")
    void deleteExpiredDrafts(@Param("expireTime") LocalDateTime expireTime);
    
    /**
     * 查找长时间未更新的打卡活动
     */
    @Query("SELECT c FROM CheckIn c WHERE c.updatedAt < :expireTime AND c.status = 'ACTIVE'")
    List<CheckIn> findStaleCheckIns(@Param("expireTime") LocalDateTime expireTime);
    
    // ==================== 特殊查询 ====================
    
    /**
     * 查找积分奖励最高的打卡活动
     */
    List<CheckIn> findTop10ByIsPublicTrueOrderByPointsRewardDesc();
    
    /**
     * 查找目标天数最长的打卡活动
     */
    List<CheckIn> findTop10ByIsPublicTrueOrderByTargetDaysDesc();
    
    /**
     * 查找允许补签的打卡活动
     */
    List<CheckIn> findByAllowMakeupTrue();
    
    /**
     * 查找不允许补签的打卡活动
     */
    List<CheckIn> findByAllowMakeupFalse();
    
    /**
     * 根据补签费用范围查找打卡活动
     */
    @Query("SELECT c FROM CheckIn c WHERE c.allowMakeup = true AND c.makeupCost BETWEEN :minCost AND :maxCost")
    List<CheckIn> findByMakeupCostRange(@Param("minCost") Integer minCost, @Param("maxCost") Integer maxCost);
}