package com.nanqipro.repository;

import com.nanqipro.entity.ChallengeParticipation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 挑战赛参与记录数据访问接口
 */
@Repository
public interface ChallengeParticipationRepository extends JpaRepository<ChallengeParticipation, Long> {
    
    /**
     * 根据挑战赛ID查找参与记录
     */
    List<ChallengeParticipation> findByChallengeId(Long challengeId);
    
    /**
     * 根据用户ID查找参与记录
     */
    List<ChallengeParticipation> findByUserId(Long userId);
    
    /**
     * 根据挑战赛ID和用户ID查找参与记录
     */
    Optional<ChallengeParticipation> findByChallengeIdAndUserId(Long challengeId, Long userId);
    
    /**
     * 根据状态查找参与记录
     */
    List<ChallengeParticipation> findByStatus(ChallengeParticipation.ParticipationStatus status);
    
    /**
     * 根据用户ID和状态查找参与记录
     */
    List<ChallengeParticipation> findByUserIdAndStatus(Long userId, ChallengeParticipation.ParticipationStatus status);
    
    /**
     * 根据挑战赛ID和状态查找参与记录
     */
    List<ChallengeParticipation> findByChallengeIdAndStatus(Long challengeId, ChallengeParticipation.ParticipationStatus status);
    
    /**
     * 查找用户正在参与的挑战赛
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.userId = :userId AND p.status IN ('REGISTERED', 'ACTIVE')")
    List<ChallengeParticipation> findActiveParticipationsByUserId(@Param("userId") Long userId);
    
    /**
     * 查找用户已完成的挑战赛参与记录
     */
    List<ChallengeParticipation> findByUserIdAndStatusOrderByCompletedAtDesc(Long userId, ChallengeParticipation.ParticipationStatus status);
    
    /**
     * 查找挑战赛的排行榜（按得分排序）
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId AND p.status = 'ACTIVE' ORDER BY p.currentScore DESC")
    List<ChallengeParticipation> findLeaderboardByChallengeId(@Param("challengeId") Long challengeId, Pageable pageable);
    
    /**
     * 查找挑战赛的完成排行榜
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId AND p.status = 'COMPLETED' ORDER BY p.bestScore DESC, p.completedAt ASC")
    List<ChallengeParticipation> findCompletedLeaderboardByChallengeId(@Param("challengeId") Long challengeId, Pageable pageable);
    
    /**
     * 查找用户在挑战赛中的排名
     */
    @Query("SELECT COUNT(p) + 1 FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId AND p.currentScore > :userScore")
    Long findUserRankingInChallenge(@Param("challengeId") Long challengeId, @Param("userScore") Integer userScore);
    
    /**
     * 查找用户的最佳表现记录
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.userId = :userId ORDER BY p.bestScore DESC")
    List<ChallengeParticipation> findBestPerformanceByUserId(@Param("userId") Long userId, Pageable pageable);
    
    /**
     * 查找用户最近的参与记录
     */
    List<ChallengeParticipation> findByUserIdOrderByJoinedAtDesc(Long userId, Pageable pageable);
    
    /**
     * 查找用户在指定时间范围内的参与记录
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.userId = :userId AND p.joinedAt >= :startTime AND p.joinedAt <= :endTime")
    List<ChallengeParticipation> findByUserIdAndTimeRange(@Param("userId") Long userId, 
                                                         @Param("startTime") LocalDateTime startTime, 
                                                         @Param("endTime") LocalDateTime endTime);
    
    /**
     * 统计挑战赛的参与人数
     */
    long countByChallengeId(Long challengeId);
    
    /**
     * 统计挑战赛的活跃参与人数
     */
    long countByChallengeIdAndStatusIn(Long challengeId, List<ChallengeParticipation.ParticipationStatus> statuses);
    
    /**
     * 统计用户参与的挑战赛总数
     */
    long countByUserId(Long userId);
    
    /**
     * 统计用户完成的挑战赛数量
     */
    long countByUserIdAndStatus(Long userId, ChallengeParticipation.ParticipationStatus status);
    
    /**
     * 计算用户的平均得分
     */
    @Query("SELECT AVG(p.bestScore) FROM ChallengeParticipation p WHERE p.userId = :userId AND p.status = 'COMPLETED'")
    Double calculateAverageScoreByUserId(@Param("userId") Long userId);
    
    /**
     * 计算挑战赛的平均得分
     */
    @Query("SELECT AVG(p.currentScore) FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId AND p.status = 'ACTIVE'")
    Double calculateAverageScoreByChallengeId(@Param("challengeId") Long challengeId);
    
    /**
     * 查找用户获得的总奖励积分
     */
    @Query("SELECT SUM(p.rewardPoints) FROM ChallengeParticipation p WHERE p.userId = :userId AND p.status = 'COMPLETED'")
    Long calculateTotalRewardPointsByUserId(@Param("userId") Long userId);
    
    /**
     * 查找挑战赛中得分最高的参与记录
     */
    Optional<ChallengeParticipation> findTopByChallengeIdOrderByCurrentScoreDesc(Long challengeId);
    
    /**
     * 查找用户的最高得分记录
     */
    Optional<ChallengeParticipation> findTopByUserIdOrderByBestScoreDesc(Long userId);
    
    /**
     * 查找需要更新排名的参与记录
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId AND p.status = 'ACTIVE' AND p.ranking IS NULL")
    List<ChallengeParticipation> findParticipationsNeedingRankingUpdate(@Param("challengeId") Long challengeId);
    
    /**
     * 查找长时间未活动的参与记录
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.status = 'ACTIVE' AND p.lastActivityAt < :inactiveTime")
    List<ChallengeParticipation> findInactiveParticipations(@Param("inactiveTime") LocalDateTime inactiveTime);
    
    /**
     * 查找进度完成度高的参与记录
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId AND p.progressPercentage >= :minProgress ORDER BY p.progressPercentage DESC")
    List<ChallengeParticipation> findHighProgressParticipations(@Param("challengeId") Long challengeId, 
                                                               @Param("minProgress") Double minProgress);
    
    /**
     * 查找需要改进的参与记录
     */
    @Query("SELECT p FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId AND p.progressPercentage < :maxProgress ORDER BY p.progressPercentage ASC")
    List<ChallengeParticipation> findLowProgressParticipations(@Param("challengeId") Long challengeId, 
                                                              @Param("maxProgress") Double maxProgress);
    
    /**
     * 统计每日新增参与记录数量
     */
    @Query("SELECT COUNT(p) FROM ChallengeParticipation p WHERE DATE(p.joinedAt) = DATE(:date)")
    long countByJoinedDate(@Param("date") LocalDateTime date);
    
    /**
     * 统计每月参与记录数量
     */
    @Query("SELECT COUNT(p) FROM ChallengeParticipation p WHERE YEAR(p.joinedAt) = :year AND MONTH(p.joinedAt) = :month")
    long countByYearAndMonth(@Param("year") int year, @Param("month") int month);
    
    /**
     * 获取参与状态分布统计
     */
    @Query("SELECT p.status, COUNT(p) FROM ChallengeParticipation p GROUP BY p.status")
    List<Object[]> getParticipationStatusDistribution();
    
    /**
     * 获取用户参与挑战赛类型分布
     */
    @Query("SELECT c.type, COUNT(p) FROM ChallengeParticipation p JOIN p.challenge c WHERE p.userId = :userId GROUP BY c.type")
    List<Object[]> getUserChallengeTypeDistribution(@Param("userId") Long userId);
    
    /**
     * 获取用户月度参与统计
     */
    @Query("SELECT YEAR(p.joinedAt), MONTH(p.joinedAt), COUNT(p) FROM ChallengeParticipation p WHERE p.userId = :userId GROUP BY YEAR(p.joinedAt), MONTH(p.joinedAt) ORDER BY YEAR(p.joinedAt), MONTH(p.joinedAt)")
    List<Object[]> getUserMonthlyParticipationStats(@Param("userId") Long userId);
    
    /**
     * 获取挑战赛的完成率
     */
    @Query("SELECT (COUNT(CASE WHEN p.status = 'COMPLETED' THEN 1 END) * 100.0 / COUNT(p)) FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId")
    Double getChallengeCompletionRate(@Param("challengeId") Long challengeId);
    
    /**
     * 获取用户的挑战赛完成率
     */
    @Query("SELECT (COUNT(CASE WHEN p.status = 'COMPLETED' THEN 1 END) * 100.0 / COUNT(p)) FROM ChallengeParticipation p WHERE p.userId = :userId")
    Double getUserCompletionRate(@Param("userId") Long userId);
    
    /**
     * 查找相似表现的用户
     */
    @Query("SELECT p.userId FROM ChallengeParticipation p WHERE p.challenge.id = :challengeId AND p.currentScore BETWEEN :minScore AND :maxScore AND p.userId != :excludeUserId")
    List<Long> findSimilarPerformanceUsers(@Param("challengeId") Long challengeId, 
                                          @Param("minScore") Integer minScore, 
                                          @Param("maxScore") Integer maxScore, 
                                          @Param("excludeUserId") Long excludeUserId);
    
    /**
     * 删除过期的参与记录
     */
    @Query("DELETE FROM ChallengeParticipation p WHERE p.status = 'REGISTERED' AND p.joinedAt < :expireTime")
    void deleteExpiredRegistrations(@Param("expireTime") LocalDateTime expireTime);
}