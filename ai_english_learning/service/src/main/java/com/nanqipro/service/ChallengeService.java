package com.nanqipro.service;

import com.nanqipro.entity.Challenge;
import com.nanqipro.entity.ChallengeParticipation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 挑战赛服务接口
 */
public interface ChallengeService {
    
    // ==================== 挑战赛管理 ====================
    
    /**
     * 创建挑战赛
     */
    Challenge createChallenge(Challenge challenge);
    
    /**
     * 更新挑战赛
     */
    Challenge updateChallenge(Long challengeId, Challenge challenge);
    
    /**
     * 删除挑战赛
     */
    void deleteChallenge(Long challengeId);
    
    /**
     * 发布挑战赛
     */
    Challenge publishChallenge(Long challengeId);
    
    /**
     * 开始挑战赛
     */
    Challenge startChallenge(Long challengeId);
    
    /**
     * 完成挑战赛
     */
    Challenge completeChallenge(Long challengeId);
    
    /**
     * 取消挑战赛
     */
    Challenge cancelChallenge(Long challengeId);
    
    /**
     * 暂停挑战赛
     */
    Challenge pauseChallenge(Long challengeId);
    
    /**
     * 恢复挑战赛
     */
    Challenge resumeChallenge(Long challengeId);
    
    // ==================== 挑战赛查询 ====================
    
    /**
     * 根据ID获取挑战赛
     */
    Optional<Challenge> getChallengeById(Long challengeId);
    
    /**
     * 获取所有公开挑战赛
     */
    List<Challenge> getAllPublicChallenges();
    
    /**
     * 根据状态获取挑战赛
     */
    List<Challenge> getChallengesByStatus(Challenge.ChallengeStatus status);
    
    /**
     * 根据类型获取挑战赛
     */
    List<Challenge> getChallengesByType(Challenge.ChallengeType type);
    
    /**
     * 根据难度获取挑战赛
     */
    List<Challenge> getChallengesByDifficulty(Challenge.DifficultyLevel difficulty);
    
    /**
     * 获取正在进行的挑战赛
     */
    List<Challenge> getActiveChallenges();
    
    /**
     * 获取即将开始的挑战赛
     */
    List<Challenge> getUpcomingChallenges();
    
    /**
     * 获取已完成的挑战赛
     */
    List<Challenge> getCompletedChallenges();
    
    /**
     * 获取热门挑战赛
     */
    List<Challenge> getPopularChallenges(int limit);
    
    /**
     * 获取最新挑战赛
     */
    List<Challenge> getLatestChallenges(int limit);
    
    /**
     * 搜索挑战赛
     */
    List<Challenge> searchChallenges(String keyword);
    
    /**
     * 多条件查询挑战赛
     */
    Page<Challenge> searchChallenges(Challenge.ChallengeType type, 
                                   Challenge.DifficultyLevel difficulty, 
                                   Challenge.ChallengeStatus status, 
                                   Pageable pageable);
    
    // ==================== 用户相关 ====================
    
    /**
     * 获取用户创建的挑战赛
     */
    List<Challenge> getUserCreatedChallenges(Long userId);
    
    /**
     * 获取用户参与的挑战赛
     */
    List<Challenge> getUserParticipatedChallenges(Long userId);
    
    /**
     * 获取用户正在参与的挑战赛
     */
    List<Challenge> getUserActiveChallenges(Long userId);
    
    /**
     * 获取用户已完成的挑战赛
     */
    List<Challenge> getUserCompletedChallenges(Long userId);
    
    /**
     * 获取推荐给用户的挑战赛
     */
    List<Challenge> getRecommendedChallenges(Long userId, int limit);
    
    /**
     * 获取用户可能感兴趣的挑战赛
     */
    List<Challenge> getSuggestedChallenges(Long userId, int limit);
    
    // ==================== 参与管理 ====================
    
    /**
     * 用户参与挑战赛
     */
    ChallengeParticipation joinChallenge(Long challengeId, Long userId);
    
    /**
     * 用户退出挑战赛
     */
    void leaveChallenge(Long challengeId, Long userId);
    
    /**
     * 更新参与进度
     */
    ChallengeParticipation updateParticipationProgress(Long participationId, 
                                                      Integer score, 
                                                      Integer completedTasks, 
                                                      String participationData);
    
    /**
     * 完成挑战赛参与
     */
    ChallengeParticipation completeParticipation(Long participationId);
    
    /**
     * 放弃挑战赛参与
     */
    ChallengeParticipation abandonParticipation(Long participationId);
    
    // ==================== 排行榜和统计 ====================
    
    /**
     * 获取挑战赛排行榜
     */
    List<ChallengeParticipation> getChallengeLeaderboard(Long challengeId, int limit);
    
    /**
     * 获取挑战赛完成排行榜
     */
    List<ChallengeParticipation> getChallengeCompletedLeaderboard(Long challengeId, int limit);
    
    /**
     * 获取用户在挑战赛中的排名
     */
    Long getUserRankingInChallenge(Long challengeId, Long userId);
    
    /**
     * 获取用户最佳表现
     */
    List<ChallengeParticipation> getUserBestPerformances(Long userId, int limit);
    
    /**
     * 获取挑战赛统计信息
     */
    Map<String, Object> getChallengeStatistics(Long challengeId);
    
    /**
     * 获取用户挑战赛统计
     */
    Map<String, Object> getUserChallengeStatistics(Long userId);
    
    /**
     * 获取系统挑战赛统计
     */
    Map<String, Object> getSystemChallengeStatistics();
    
    // ==================== 奖励和积分 ====================
    
    /**
     * 计算挑战赛奖励
     */
    Integer calculateChallengeReward(Long challengeId, Long userId);
    
    /**
     * 发放挑战赛奖励
     */
    void distributeChallengeRewards(Long challengeId);
    
    /**
     * 获取用户获得的总奖励积分
     */
    Long getUserTotalRewardPoints(Long userId);
    
    // ==================== 数据分析 ====================
    
    /**
     * 分析挑战赛表现
     */
    Map<String, Object> analyzeChallengePerformance(Long challengeId);
    
    /**
     * 分析用户挑战赛表现
     */
    Map<String, Object> analyzeUserChallengePerformance(Long userId);
    
    /**
     * 获取挑战赛趋势分析
     */
    Map<String, Object> getChallengeTrendAnalysis(LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取用户参与趋势
     */
    Map<String, Object> getUserParticipationTrend(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    // ==================== 系统管理 ====================
    
    /**
     * 更新挑战赛状态（定时任务）
     */
    void updateChallengeStatuses();
    
    /**
     * 更新参与者排名
     */
    void updateParticipantRankings(Long challengeId);
    
    /**
     * 清理过期数据
     */
    void cleanupExpiredData();
    
    /**
     * 生成挑战赛报告
     */
    Map<String, Object> generateChallengeReport(Long challengeId);
    
    /**
     * 导出挑战赛数据
     */
    byte[] exportChallengeData(Long challengeId, String format);
    
    /**
     * 批量操作挑战赛
     */
    void batchUpdateChallenges(List<Long> challengeIds, Map<String, Object> updates);
    
    // ==================== 通知和提醒 ====================
    
    /**
     * 发送挑战赛开始通知
     */
    void sendChallengeStartNotification(Long challengeId);
    
    /**
     * 发送挑战赛结束通知
     */
    void sendChallengeEndNotification(Long challengeId);
    
    /**
     * 发送排名变化通知
     */
    void sendRankingChangeNotification(Long challengeId, Long userId, Integer oldRank, Integer newRank);
    
    /**
     * 发送奖励通知
     */
    void sendRewardNotification(Long userId, Integer rewardPoints, String reason);
}