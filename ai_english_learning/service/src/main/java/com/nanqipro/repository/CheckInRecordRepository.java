package com.nanqipro.repository;

import com.nanqipro.entity.CheckInRecord;
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
 * 打卡记录数据访问接口
 */
@Repository
public interface CheckInRecordRepository extends JpaRepository<CheckInRecord, Long> {
    
    // ==================== 基础查询 ====================
    
    /**
     * 根据打卡活动ID查找记录
     */
    List<CheckInRecord> findByCheckInId(Long checkInId);
    
    /**
     * 根据用户ID查找记录
     */
    List<CheckInRecord> findByUserId(Long userId);
    
    /**
     * 根据打卡活动ID和用户ID查找记录
     */
    List<CheckInRecord> findByCheckInIdAndUserId(Long checkInId, Long userId);
    
    /**
     * 根据状态查找记录
     */
    List<CheckInRecord> findByStatus(CheckInRecord.CheckInRecordStatus status);
    
    /**
     * 根据类型查找记录
     */
    List<CheckInRecord> findByType(CheckInRecord.CheckInRecordType type);
    
    /**
     * 根据验证状态查找记录
     */
    List<CheckInRecord> findByVerificationStatus(CheckInRecord.VerificationStatus verificationStatus);
    
    /**
     * 查找补签记录
     */
    List<CheckInRecord> findByIsMakeupTrue();
    
    /**
     * 查找非补签记录
     */
    List<CheckInRecord> findByIsMakeupFalse();
    
    // ==================== 时间相关查询 ====================
    
    /**
     * 根据打卡日期查找记录
     */
    List<CheckInRecord> findByCheckInDate(LocalDate checkInDate);
    
    /**
     * 根据打卡日期范围查找记录
     */
    List<CheckInRecord> findByCheckInDateBetween(LocalDate startDate, LocalDate endDate);
    
    /**
     * 根据用户ID和打卡日期查找记录
     */
    Optional<CheckInRecord> findByUserIdAndCheckInDate(Long userId, LocalDate checkInDate);
    
    /**
     * 根据打卡活动ID、用户ID和打卡日期查找记录
     */
    Optional<CheckInRecord> findByCheckInIdAndUserIdAndCheckInDate(Long checkInId, Long userId, LocalDate checkInDate);
    
    /**
     * 查找指定时间范围内的记录
     */
    @Query("SELECT r FROM CheckInRecord r WHERE r.checkInTime >= :startTime AND r.checkInTime <= :endTime")
    List<CheckInRecord> findByTimeRange(@Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查找用户在指定时间范围内的记录
     */
    @Query("SELECT r FROM CheckInRecord r WHERE r.userId = :userId AND r.checkInTime >= :startTime AND r.checkInTime <= :endTime")
    List<CheckInRecord> findByUserIdAndTimeRange(@Param("userId") Long userId, @Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);
    
    // ==================== 连续打卡相关 ====================
    
    /**
     * 查找用户最新的打卡记录
     */
    Optional<CheckInRecord> findTopByUserIdOrderByCheckInDateDesc(Long userId);
    
    /**
     * 查找用户在指定打卡活动中的最新记录
     */
    Optional<CheckInRecord> findTopByCheckInIdAndUserIdOrderByCheckInDateDesc(Long checkInId, Long userId);
    
    /**
     * 查找用户连续打卡天数最高的记录
     */
    Optional<CheckInRecord> findTopByUserIdOrderByConsecutiveDaysDesc(Long userId);
    
    /**
     * 查找用户在指定打卡活动中连续打卡天数最高的记录
     */
    Optional<CheckInRecord> findTopByCheckInIdAndUserIdOrderByConsecutiveDaysDesc(Long checkInId, Long userId);
    
    /**
     * 查找连续打卡天数超过指定值的记录
     */
    List<CheckInRecord> findByConsecutiveDaysGreaterThan(Integer days);
    
    /**
     * 查找用户连续打卡天数超过指定值的记录
     */
    List<CheckInRecord> findByUserIdAndConsecutiveDaysGreaterThan(Long userId, Integer days);
    
    // ==================== 统计查询 ====================
    
    /**
     * 统计用户打卡记录总数
     */
    Long countByUserId(Long userId);
    
    /**
     * 统计打卡活动的记录总数
     */
    Long countByCheckInId(Long checkInId);
    
    /**
     * 统计用户在指定打卡活动中的记录数
     */
    Long countByCheckInIdAndUserId(Long checkInId, Long userId);
    
    /**
     * 统计指定状态的记录数
     */
    Long countByStatus(CheckInRecord.CheckInRecordStatus status);
    
    /**
     * 统计用户指定状态的记录数
     */
    Long countByUserIdAndStatus(Long userId, CheckInRecord.CheckInRecordStatus status);
    
    /**
     * 统计补签记录数
     */
    Long countByIsMakeupTrue();
    
    /**
     * 统计用户补签记录数
     */
    Long countByUserIdAndIsMakeupTrue(Long userId);
    
    /**
     * 统计打卡活动的参与用户数
     */
    @Query("SELECT COUNT(DISTINCT r.userId) FROM CheckInRecord r WHERE r.checkIn.id = :checkInId")
    Long countDistinctUsersByCheckInId(@Param("checkInId") Long checkInId);
    
    // ==================== 积分和奖励统计 ====================
    
    /**
     * 计算用户总获得积分
     */
    @Query("SELECT SUM(r.pointsEarned) FROM CheckInRecord r WHERE r.userId = :userId")
    Long calculateTotalPointsByUserId(@Param("userId") Long userId);
    
    /**
     * 计算打卡活动总发放积分
     */
    @Query("SELECT SUM(r.pointsEarned) FROM CheckInRecord r WHERE r.checkIn.id = :checkInId")
    Long calculateTotalPointsByCheckInId(@Param("checkInId") Long checkInId);
    
    /**
     * 计算用户在指定打卡活动中获得的积分
     */
    @Query("SELECT SUM(r.pointsEarned) FROM CheckInRecord r WHERE r.checkIn.id = :checkInId AND r.userId = :userId")
    Long calculatePointsByCheckInIdAndUserId(@Param("checkInId") Long checkInId, @Param("userId") Long userId);
    
    /**
     * 计算用户平均每次打卡获得积分
     */
    @Query("SELECT AVG(r.pointsEarned) FROM CheckInRecord r WHERE r.userId = :userId AND r.pointsEarned > 0")
    Double calculateAveragePointsByUserId(@Param("userId") Long userId);
    
    // ==================== 学习时长统计 ====================
    
    /**
     * 计算用户总学习时长
     */
    @Query("SELECT SUM(r.studyDuration) FROM CheckInRecord r WHERE r.userId = :userId")
    Long calculateTotalStudyDurationByUserId(@Param("userId") Long userId);
    
    /**
     * 计算用户平均学习时长
     */
    @Query("SELECT AVG(r.studyDuration) FROM CheckInRecord r WHERE r.userId = :userId AND r.studyDuration > 0")
    Double calculateAverageStudyDurationByUserId(@Param("userId") Long userId);
    
    /**
     * 计算打卡活动总学习时长
     */
    @Query("SELECT SUM(r.studyDuration) FROM CheckInRecord r WHERE r.checkIn.id = :checkInId")
    Long calculateTotalStudyDurationByCheckInId(@Param("checkInId") Long checkInId);
    
    // ==================== 排行榜查询 ====================
    
    /**
     * 查找打卡活动排行榜（按连续打卡天数）
     */
    @Query("SELECT r FROM CheckInRecord r WHERE r.checkIn.id = :checkInId ORDER BY r.consecutiveDays DESC, r.checkInTime ASC")
    List<CheckInRecord> findLeaderboardByCheckInId(@Param("checkInId") Long checkInId, Pageable pageable);
    
    /**
     * 查找打卡活动排行榜（按总积分）
     */
    @Query("SELECT r.userId, SUM(r.pointsEarned) as totalPoints FROM CheckInRecord r WHERE r.checkIn.id = :checkInId GROUP BY r.userId ORDER BY totalPoints DESC")
    List<Object[]> findPointsLeaderboardByCheckInId(@Param("checkInId") Long checkInId, Pageable pageable);
    
    /**
     * 查找打卡活动排行榜（按学习时长）
     */
    @Query("SELECT r.userId, SUM(r.studyDuration) as totalDuration FROM CheckInRecord r WHERE r.checkIn.id = :checkInId GROUP BY r.userId ORDER BY totalDuration DESC")
    List<Object[]> findStudyDurationLeaderboardByCheckInId(@Param("checkInId") Long checkInId, Pageable pageable);
    
    /**
     * 查找全局排行榜（按连续打卡天数）
     */
    @Query("SELECT r FROM CheckInRecord r ORDER BY r.consecutiveDays DESC, r.checkInTime ASC")
    List<CheckInRecord> findGlobalConsecutiveLeaderboard(Pageable pageable);
    
    // ==================== 完成率和参与度 ====================
    
    /**
     * 计算打卡活动完成率
     */
    @Query("SELECT COUNT(DISTINCT r.userId) * 1.0 / (SELECT COUNT(DISTINCT r2.userId) FROM CheckInRecord r2 WHERE r2.checkIn.id = :checkInId) FROM CheckInRecord r WHERE r.checkIn.id = :checkInId AND r.status = 'COMPLETED'")
    Double getCheckInCompletionRate(@Param("checkInId") Long checkInId);
    
    /**
     * 计算用户完成率
     */
    @Query("SELECT COUNT(r) * 1.0 / (SELECT COUNT(r2) FROM CheckInRecord r2 WHERE r2.userId = :userId) FROM CheckInRecord r WHERE r.userId = :userId AND r.status = 'COMPLETED'")
    Double getUserCompletionRate(@Param("userId") Long userId);
    
    /**
     * 查找高完成度用户（完成率超过指定值）
     */
    @Query("SELECT r.userId, COUNT(r) as totalRecords, SUM(CASE WHEN r.status = 'COMPLETED' THEN 1 ELSE 0 END) as completedRecords FROM CheckInRecord r GROUP BY r.userId HAVING (SUM(CASE WHEN r.status = 'COMPLETED' THEN 1 ELSE 0 END) * 1.0 / COUNT(r)) >= :completionRate")
    List<Object[]> findHighCompletionUsers(@Param("completionRate") Double completionRate);
    
    // ==================== 数据分析 ====================
    
    /**
     * 统计每日打卡记录数量
     */
    @Query("SELECT r.checkInDate, COUNT(r) FROM CheckInRecord r WHERE r.checkInDate >= :startDate GROUP BY r.checkInDate ORDER BY r.checkInDate")
    List<Object[]> countDailyCheckInRecords(@Param("startDate") LocalDate startDate);
    
    /**
     * 统计每月打卡记录数量
     */
    @Query("SELECT YEAR(r.checkInDate), MONTH(r.checkInDate), COUNT(r) FROM CheckInRecord r WHERE r.checkInDate >= :startDate GROUP BY YEAR(r.checkInDate), MONTH(r.checkInDate) ORDER BY YEAR(r.checkInDate), MONTH(r.checkInDate)")
    List<Object[]> countMonthlyCheckInRecords(@Param("startDate") LocalDate startDate);
    
    /**
     * 获取打卡记录状态分布
     */
    @Query("SELECT r.status, COUNT(r) FROM CheckInRecord r GROUP BY r.status")
    List<Object[]> getCheckInRecordStatusDistribution();
    
    /**
     * 获取打卡记录类型分布
     */
    @Query("SELECT r.type, COUNT(r) FROM CheckInRecord r GROUP BY r.type")
    List<Object[]> getCheckInRecordTypeDistribution();
    
    /**
     * 获取用户打卡活动类型分布
     */
    @Query("SELECT c.type, COUNT(DISTINCT r.userId) FROM CheckInRecord r JOIN r.checkIn c GROUP BY c.type")
    List<Object[]> getUserCheckInTypeDistribution();
    
    /**
     * 获取用户月度打卡统计
     */
    @Query("SELECT YEAR(r.checkInDate), MONTH(r.checkInDate), COUNT(DISTINCT r.userId) FROM CheckInRecord r WHERE r.userId = :userId AND r.checkInDate >= :startDate GROUP BY YEAR(r.checkInDate), MONTH(r.checkInDate) ORDER BY YEAR(r.checkInDate), MONTH(r.checkInDate)")
    List<Object[]> getUserMonthlyCheckInStats(@Param("userId") Long userId, @Param("startDate") LocalDate startDate);
    
    // ==================== 验证相关 ====================
    
    /**
     * 查找待验证的记录
     */
    List<CheckInRecord> findByVerificationStatusOrderByCreatedAtAsc(CheckInRecord.VerificationStatus verificationStatus);
    
    /**
     * 查找指定验证者的验证记录
     */
    List<CheckInRecord> findByVerifiedBy(Long verifierId);
    
    /**
     * 统计待验证记录数量
     */
    Long countByVerificationStatus(CheckInRecord.VerificationStatus verificationStatus);
    
    // ==================== 数据清理 ====================
    
    /**
     * 删除过期的记录
     */
    @Query("DELETE FROM CheckInRecord r WHERE r.createdAt < :expireTime")
    void deleteExpiredRecords(@Param("expireTime") LocalDateTime expireTime);
    
    /**
     * 查找长时间未活动的记录
     */
    @Query("SELECT r FROM CheckInRecord r WHERE r.updatedAt < :expireTime AND r.status = 'PENDING'")
    List<CheckInRecord> findStaleRecords(@Param("expireTime") LocalDateTime expireTime);
    
    // ==================== 特殊查询 ====================
    
    /**
     * 查找相似表现的用户（基于连续打卡天数）
     */
    @Query("SELECT r.userId FROM CheckInRecord r WHERE r.consecutiveDays BETWEEN :minDays AND :maxDays AND r.userId != :userId GROUP BY r.userId")
    List<Long> findSimilarPerformanceUsers(@Param("userId") Long userId, @Param("minDays") Integer minDays, @Param("maxDays") Integer maxDays);
    
    /**
     * 查找学习时长最长的记录
     */
    List<CheckInRecord> findTop10ByOrderByStudyDurationDesc();
    
    /**
     * 查找积分最高的记录
     */
    List<CheckInRecord> findTop10ByOrderByPointsEarnedDesc();
    
    /**
     * 查找有证明图片的记录
     */
    @Query("SELECT r FROM CheckInRecord r WHERE r.proofImage IS NOT NULL AND r.proofImage != ''")
    List<CheckInRecord> findRecordsWithProofImage();
    
    /**
     * 查找有打卡内容的记录
     */
    @Query("SELECT r FROM CheckInRecord r WHERE r.checkInContent IS NOT NULL AND r.checkInContent != ''")
    List<CheckInRecord> findRecordsWithContent();
}