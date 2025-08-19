package com.nanqipro.repository;

import com.nanqipro.entity.Challenge;
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
 * 挑战赛数据访问接口
 */
@Repository
public interface ChallengeRepository extends JpaRepository<Challenge, Long> {
    
    /**
     * 根据状态查找挑战赛
     */
    List<Challenge> findByStatus(Challenge.ChallengeStatus status);
    
    /**
     * 根据类型查找挑战赛
     */
    List<Challenge> findByType(Challenge.ChallengeType type);
    
    /**
     * 根据难度等级查找挑战赛
     */
    List<Challenge> findByDifficulty(Challenge.DifficultyLevel difficulty);
    
    /**
     * 根据创建者ID查找挑战赛
     */
    List<Challenge> findByCreatorId(Long creatorId);
    
    /**
     * 查找公开的挑战赛
     */
    List<Challenge> findByIsPublicTrue();
    
    /**
     * 根据状态和公开性查找挑战赛
     */
    List<Challenge> findByStatusAndIsPublicTrue(Challenge.ChallengeStatus status);
    
    /**
     * 查找正在进行的挑战赛
     */
    @Query("SELECT c FROM Challenge c WHERE c.status = 'ACTIVE' AND c.startTime <= :now AND (c.endTime IS NULL OR c.endTime >= :now)")
    List<Challenge> findActiveChallenges(@Param("now") LocalDateTime now);
    
    /**
     * 查找即将开始的挑战赛
     */
    @Query("SELECT c FROM Challenge c WHERE c.status = 'PUBLISHED' AND c.startTime > :now")
    List<Challenge> findUpcomingChallenges(@Param("now") LocalDateTime now);
    
    /**
     * 查找已结束的挑战赛
     */
    @Query("SELECT c FROM Challenge c WHERE c.status = 'COMPLETED' OR (c.endTime IS NOT NULL AND c.endTime < :now)")
    List<Challenge> findCompletedChallenges(@Param("now") LocalDateTime now);
    
    /**
     * 根据时间范围查找挑战赛
     */
    @Query("SELECT c FROM Challenge c WHERE c.startTime >= :startTime AND c.startTime <= :endTime")
    List<Challenge> findByTimeRange(@Param("startTime") LocalDateTime startTime, 
                                   @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查找热门挑战赛（按参与人数排序）
     */
    @Query("SELECT c FROM Challenge c WHERE c.isPublic = true ORDER BY c.currentParticipants DESC")
    List<Challenge> findPopularChallenges(Pageable pageable);
    
    /**
     * 查找最新挑战赛
     */
    List<Challenge> findByIsPublicTrueOrderByCreatedAtDesc(Pageable pageable);
    
    /**
     * 根据标题模糊查询
     */
    @Query("SELECT c FROM Challenge c WHERE c.title LIKE %:keyword% AND c.isPublic = true")
    List<Challenge> findByTitleContaining(@Param("keyword") String keyword);
    
    /**
     * 根据标题或描述模糊查询
     */
    @Query("SELECT c FROM Challenge c WHERE (c.title LIKE %:keyword% OR c.description LIKE %:keyword%) AND c.isPublic = true")
    List<Challenge> findByTitleOrDescriptionContaining(@Param("keyword") String keyword);
    
    /**
     * 查找用户参与的挑战赛
     */
    @Query("SELECT DISTINCT c FROM Challenge c JOIN c.participations p WHERE p.userId = :userId")
    List<Challenge> findByParticipantUserId(@Param("userId") Long userId);
    
    /**
     * 查找用户创建的挑战赛
     */
    List<Challenge> findByCreatorIdOrderByCreatedAtDesc(Long creatorId);
    
    /**
     * 查找用户正在参与的挑战赛
     */
    @Query("SELECT DISTINCT c FROM Challenge c JOIN c.participations p WHERE p.userId = :userId AND p.status IN ('REGISTERED', 'ACTIVE')")
    List<Challenge> findActiveParticipationsByUserId(@Param("userId") Long userId);
    
    /**
     * 查找用户已完成的挑战赛
     */
    @Query("SELECT DISTINCT c FROM Challenge c JOIN c.participations p WHERE p.userId = :userId AND p.status = 'COMPLETED'")
    List<Challenge> findCompletedParticipationsByUserId(@Param("userId") Long userId);
    
    /**
     * 统计挑战赛总数
     */
    long countByIsPublicTrue();
    
    /**
     * 统计某状态的挑战赛数量
     */
    long countByStatus(Challenge.ChallengeStatus status);
    
    /**
     * 统计某类型的挑战赛数量
     */
    long countByType(Challenge.ChallengeType type);
    
    /**
     * 统计用户创建的挑战赛数量
     */
    long countByCreatorId(Long creatorId);
    
    /**
     * 统计用户参与的挑战赛数量
     */
    @Query("SELECT COUNT(DISTINCT c) FROM Challenge c JOIN c.participations p WHERE p.userId = :userId")
    long countParticipationsByUserId(@Param("userId") Long userId);
    
    /**
     * 查找参与人数最多的挑战赛
     */
    Optional<Challenge> findTopByIsPublicTrueOrderByCurrentParticipantsDesc();
    
    /**
     * 查找奖励积分最高的挑战赛
     */
    Optional<Challenge> findTopByIsPublicTrueOrderByRewardPointsDesc();
    
    /**
     * 根据多个条件查询挑战赛
     */
    @Query("SELECT c FROM Challenge c WHERE " +
           "(:type IS NULL OR c.type = :type) AND " +
           "(:difficulty IS NULL OR c.difficulty = :difficulty) AND " +
           "(:status IS NULL OR c.status = :status) AND " +
           "c.isPublic = true")
    Page<Challenge> findByMultipleConditions(@Param("type") Challenge.ChallengeType type,
                                           @Param("difficulty") Challenge.DifficultyLevel difficulty,
                                           @Param("status") Challenge.ChallengeStatus status,
                                           Pageable pageable);
    
    /**
     * 查找需要更新状态的挑战赛（已到开始时间但状态仍为PUBLISHED）
     */
    @Query("SELECT c FROM Challenge c WHERE c.status = 'PUBLISHED' AND c.startTime <= :now")
    List<Challenge> findChallengesNeedingStatusUpdate(@Param("now") LocalDateTime now);
    
    /**
     * 查找需要结束的挑战赛（已到结束时间但状态仍为ACTIVE）
     */
    @Query("SELECT c FROM Challenge c WHERE c.status = 'ACTIVE' AND c.endTime IS NOT NULL AND c.endTime <= :now")
    List<Challenge> findChallengesNeedingCompletion(@Param("now") LocalDateTime now);
    
    /**
     * 查找推荐的挑战赛（基于用户偏好）
     */
    @Query("SELECT c FROM Challenge c WHERE c.isPublic = true AND c.status IN ('PUBLISHED', 'ACTIVE') " +
           "AND (:preferredType IS NULL OR c.type = :preferredType) " +
           "AND (:preferredDifficulty IS NULL OR c.difficulty = :preferredDifficulty) " +
           "ORDER BY c.currentParticipants DESC, c.rewardPoints DESC")
    List<Challenge> findRecommendedChallenges(@Param("preferredType") Challenge.ChallengeType preferredType,
                                            @Param("preferredDifficulty") Challenge.DifficultyLevel preferredDifficulty,
                                            Pageable pageable);
    
    /**
     * 查找用户可能感兴趣的挑战赛（排除已参与的）
     */
    @Query("SELECT c FROM Challenge c WHERE c.isPublic = true AND c.status IN ('PUBLISHED', 'ACTIVE') " +
           "AND c.id NOT IN (SELECT p.challenge.id FROM ChallengeParticipation p WHERE p.userId = :userId) " +
           "ORDER BY c.currentParticipants DESC")
    List<Challenge> findSuggestedChallenges(@Param("userId") Long userId, Pageable pageable);
    
    /**
     * 统计每日新增挑战赛数量
     */
    @Query("SELECT COUNT(c) FROM Challenge c WHERE DATE(c.createdAt) = DATE(:date)")
    long countByCreatedDate(@Param("date") LocalDateTime date);
    
    /**
     * 统计每月挑战赛数量
     */
    @Query("SELECT COUNT(c) FROM Challenge c WHERE YEAR(c.createdAt) = :year AND MONTH(c.createdAt) = :month")
    long countByYearAndMonth(@Param("year") int year, @Param("month") int month);
    
    /**
     * 获取挑战赛类型分布统计
     */
    @Query("SELECT c.type, COUNT(c) FROM Challenge c WHERE c.isPublic = true GROUP BY c.type")
    List<Object[]> getChallengeTypeDistribution();
    
    /**
     * 获取挑战赛难度分布统计
     */
    @Query("SELECT c.difficulty, COUNT(c) FROM Challenge c WHERE c.isPublic = true GROUP BY c.difficulty")
    List<Object[]> getChallengeDifficultyDistribution();
    
    /**
     * 删除过期的草稿挑战赛
     */
    @Query("DELETE FROM Challenge c WHERE c.status = 'DRAFT' AND c.createdAt < :expireTime")
    void deleteExpiredDrafts(@Param("expireTime") LocalDateTime expireTime);
}