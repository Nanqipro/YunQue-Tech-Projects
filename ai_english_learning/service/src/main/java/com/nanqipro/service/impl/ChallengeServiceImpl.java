package com.nanqipro.service.impl;

import com.nanqipro.entity.Challenge;
import com.nanqipro.entity.ChallengeParticipation;
import com.nanqipro.repository.ChallengeRepository;
import com.nanqipro.repository.ChallengeParticipationRepository;
import com.nanqipro.service.ChallengeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 挑战赛服务实现类
 */
@Service
@Transactional
public class ChallengeServiceImpl implements ChallengeService {
    
    @Autowired
    private ChallengeRepository challengeRepository;
    
    @Autowired
    private ChallengeParticipationRepository participationRepository;
    
    // ==================== 挑战赛管理 ====================
    
    @Override
    public Challenge createChallenge(Challenge challenge) {
        challenge.setCreatedAt(LocalDateTime.now());
        challenge.setStatus(Challenge.ChallengeStatus.DRAFT);
        challenge.setCurrentParticipants(0);
        return challengeRepository.save(challenge);
    }
    
    @Override
    public Challenge updateChallenge(Long challengeId, Challenge challenge) {
        Optional<Challenge> existingChallenge = challengeRepository.findById(challengeId);
        if (existingChallenge.isPresent()) {
            Challenge existing = existingChallenge.get();
            existing.setTitle(challenge.getTitle());
            existing.setDescription(challenge.getDescription());
            existing.setType(challenge.getType());
            existing.setDifficulty(challenge.getDifficulty());
            existing.setStartTime(challenge.getStartTime());
            existing.setEndTime(challenge.getEndTime());
            existing.setMaxParticipants(challenge.getMaxParticipants());
            existing.setRewardPoints(challenge.getRewardPoints());
            existing.setRules(challenge.getRules());
            existing.setTargets(challenge.getTargets());
            existing.setCoverImage(challenge.getCoverImage());
            existing.setIsPublic(challenge.getIsPublic());
            existing.setUpdatedAt(LocalDateTime.now());
            return challengeRepository.save(existing);
        }
        throw new RuntimeException("Challenge not found with id: " + challengeId);
    }
    
    @Override
    public void deleteChallenge(Long challengeId) {
        challengeRepository.deleteById(challengeId);
    }
    
    @Override
    public Challenge publishChallenge(Long challengeId) {
        Optional<Challenge> challenge = challengeRepository.findById(challengeId);
        if (challenge.isPresent()) {
            Challenge c = challenge.get();
            c.setStatus(Challenge.ChallengeStatus.PUBLISHED);
            c.setUpdatedAt(LocalDateTime.now());
            return challengeRepository.save(c);
        }
        throw new RuntimeException("Challenge not found with id: " + challengeId);
    }
    
    @Override
    public Challenge startChallenge(Long challengeId) {
        Optional<Challenge> challenge = challengeRepository.findById(challengeId);
        if (challenge.isPresent()) {
            Challenge c = challenge.get();
            c.setStatus(Challenge.ChallengeStatus.ACTIVE);
            c.setUpdatedAt(LocalDateTime.now());
            return challengeRepository.save(c);
        }
        throw new RuntimeException("Challenge not found with id: " + challengeId);
    }
    
    @Override
    public Challenge completeChallenge(Long challengeId) {
        Optional<Challenge> challenge = challengeRepository.findById(challengeId);
        if (challenge.isPresent()) {
            Challenge c = challenge.get();
            c.setStatus(Challenge.ChallengeStatus.COMPLETED);
            c.setUpdatedAt(LocalDateTime.now());
            
            // 分发奖励
            distributeChallengeRewards(challengeId);
            
            return challengeRepository.save(c);
        }
        throw new RuntimeException("Challenge not found with id: " + challengeId);
    }
    
    @Override
    public Challenge cancelChallenge(Long challengeId) {
        Optional<Challenge> challenge = challengeRepository.findById(challengeId);
        if (challenge.isPresent()) {
            Challenge c = challenge.get();
            c.setStatus(Challenge.ChallengeStatus.CANCELLED);
            c.setUpdatedAt(LocalDateTime.now());
            return challengeRepository.save(c);
        }
        throw new RuntimeException("Challenge not found with id: " + challengeId);
    }
    
    @Override
    public Challenge pauseChallenge(Long challengeId) {
        // 简化实现，实际可能需要新增PAUSED状态
        return cancelChallenge(challengeId);
    }
    
    @Override
    public Challenge resumeChallenge(Long challengeId) {
        return startChallenge(challengeId);
    }
    
    // ==================== 挑战赛查询 ====================
    
    @Override
    public Optional<Challenge> getChallengeById(Long challengeId) {
        return challengeRepository.findById(challengeId);
    }
    
    @Override
    public List<Challenge> getAllPublicChallenges() {
        return challengeRepository.findByIsPublicTrue();
    }
    
    @Override
    public List<Challenge> getChallengesByStatus(Challenge.ChallengeStatus status) {
        return challengeRepository.findByStatus(status);
    }
    
    @Override
    public List<Challenge> getChallengesByType(Challenge.ChallengeType type) {
        return challengeRepository.findByType(type);
    }
    
    @Override
    public List<Challenge> getChallengesByDifficulty(Challenge.DifficultyLevel difficulty) {
        return challengeRepository.findByDifficulty(difficulty);
    }
    
    @Override
    public List<Challenge> getActiveChallenges() {
        return challengeRepository.findActiveChallenges(LocalDateTime.now());
    }
    
    @Override
    public List<Challenge> getUpcomingChallenges() {
        return challengeRepository.findUpcomingChallenges(LocalDateTime.now());
    }
    
    @Override
    public List<Challenge> getCompletedChallenges() {
        return challengeRepository.findCompletedChallenges(LocalDateTime.now());
    }
    
    @Override
    public List<Challenge> getPopularChallenges(int limit) {
        return challengeRepository.findPopularChallenges(PageRequest.of(0, limit));
    }
    
    @Override
    public List<Challenge> getLatestChallenges(int limit) {
        return challengeRepository.findByIsPublicTrueOrderByCreatedAtDesc(PageRequest.of(0, limit));
    }
    
    @Override
    public List<Challenge> searchChallenges(String keyword) {
        return challengeRepository.findByTitleOrDescriptionContaining(keyword);
    }
    
    @Override
    public Page<Challenge> searchChallenges(Challenge.ChallengeType type, 
                                          Challenge.DifficultyLevel difficulty, 
                                          Challenge.ChallengeStatus status, 
                                          Pageable pageable) {
        return challengeRepository.findByMultipleConditions(type, difficulty, status, pageable);
    }
    
    // ==================== 用户相关 ====================
    
    @Override
    public List<Challenge> getUserCreatedChallenges(Long userId) {
        return challengeRepository.findByCreatorIdOrderByCreatedAtDesc(userId);
    }
    
    @Override
    public List<Challenge> getUserParticipatedChallenges(Long userId) {
        return challengeRepository.findByParticipantUserId(userId);
    }
    
    @Override
    public List<Challenge> getUserActiveChallenges(Long userId) {
        return challengeRepository.findActiveParticipationsByUserId(userId);
    }
    
    @Override
    public List<Challenge> getUserCompletedChallenges(Long userId) {
        return challengeRepository.findCompletedParticipationsByUserId(userId);
    }
    
    @Override
    public List<Challenge> getRecommendedChallenges(Long userId, int limit) {
        // 简化实现，实际应该基于用户偏好
        return challengeRepository.findRecommendedChallenges(
            Challenge.ChallengeType.VOCABULARY_LEARNING, 
            Challenge.DifficultyLevel.INTERMEDIATE, 
            PageRequest.of(0, limit)
        );
    }
    
    @Override
    public List<Challenge> getSuggestedChallenges(Long userId, int limit) {
        return challengeRepository.findSuggestedChallenges(userId, PageRequest.of(0, limit));
    }
    
    // ==================== 参与管理 ====================
    
    @Override
    public ChallengeParticipation joinChallenge(Long challengeId, Long userId) {
        // 检查是否已经参与
        Optional<ChallengeParticipation> existing = participationRepository.findByChallengeIdAndUserId(challengeId, userId);
        if (existing.isPresent()) {
            throw new RuntimeException("User already joined this challenge");
        }
        
        Optional<Challenge> challenge = challengeRepository.findById(challengeId);
        if (!challenge.isPresent()) {
            throw new RuntimeException("Challenge not found");
        }
        
        Challenge c = challenge.get();
        
        // 检查参与人数限制
        if (c.getMaxParticipants() != null && c.getCurrentParticipants() >= c.getMaxParticipants()) {
            throw new RuntimeException("Challenge is full");
        }
        
        ChallengeParticipation participation = new ChallengeParticipation();
        participation.setChallenge(c);
        participation.setUserId(userId);
        participation.setStatus(ChallengeParticipation.ParticipationStatus.REGISTERED);
        participation.setJoinedAt(LocalDateTime.now());
        
        // 更新挑战赛参与人数
        c.setCurrentParticipants(c.getCurrentParticipants() + 1);
        challengeRepository.save(c);
        
        return participationRepository.save(participation);
    }
    
    @Override
    public void leaveChallenge(Long challengeId, Long userId) {
        Optional<ChallengeParticipation> participation = participationRepository.findByChallengeIdAndUserId(challengeId, userId);
        if (participation.isPresent()) {
            participationRepository.delete(participation.get());
            
            // 更新挑战赛参与人数
            Optional<Challenge> challenge = challengeRepository.findById(challengeId);
            if (challenge.isPresent()) {
                Challenge c = challenge.get();
                c.setCurrentParticipants(Math.max(0, c.getCurrentParticipants() - 1));
                challengeRepository.save(c);
            }
        }
    }
    
    @Override
    public ChallengeParticipation updateParticipationProgress(Long participationId, 
                                                            Integer score, 
                                                            Integer completedTasks, 
                                                            String participationData) {
        Optional<ChallengeParticipation> participation = participationRepository.findById(participationId);
        if (participation.isPresent()) {
            ChallengeParticipation p = participation.get();
            if (score != null) {
                p.setCurrentScore(score);
            }
            if (completedTasks != null) {
                p.setCompletedTasks(completedTasks);
            }
            if (participationData != null) {
                p.setParticipationData(participationData);
            }
            p.setLastActivityAt(LocalDateTime.now());
            p.setStatus(ChallengeParticipation.ParticipationStatus.ACTIVE);
            return participationRepository.save(p);
        }
        throw new RuntimeException("Participation not found with id: " + participationId);
    }
    
    @Override
    public ChallengeParticipation completeParticipation(Long participationId) {
        Optional<ChallengeParticipation> participation = participationRepository.findById(participationId);
        if (participation.isPresent()) {
            ChallengeParticipation p = participation.get();
            p.markAsCompleted();
            return participationRepository.save(p);
        }
        throw new RuntimeException("Participation not found with id: " + participationId);
    }
    
    @Override
    public ChallengeParticipation abandonParticipation(Long participationId) {
        Optional<ChallengeParticipation> participation = participationRepository.findById(participationId);
        if (participation.isPresent()) {
            ChallengeParticipation p = participation.get();
            p.markAsAbandoned();
            return participationRepository.save(p);
        }
        throw new RuntimeException("Participation not found with id: " + participationId);
    }
    
    // ==================== 排行榜和统计 ====================
    
    @Override
    public List<ChallengeParticipation> getChallengeLeaderboard(Long challengeId, int limit) {
        return participationRepository.findLeaderboardByChallengeId(challengeId, PageRequest.of(0, limit));
    }
    
    @Override
    public List<ChallengeParticipation> getChallengeCompletedLeaderboard(Long challengeId, int limit) {
        return participationRepository.findCompletedLeaderboardByChallengeId(challengeId, PageRequest.of(0, limit));
    }
    
    @Override
    public Long getUserRankingInChallenge(Long challengeId, Long userId) {
        Optional<ChallengeParticipation> participation = participationRepository.findByChallengeIdAndUserId(challengeId, userId);
        if (participation.isPresent()) {
            return participationRepository.findUserRankingInChallenge(challengeId, participation.get().getCurrentScore());
        }
        return null;
    }
    
    @Override
    public List<ChallengeParticipation> getUserBestPerformances(Long userId, int limit) {
        return participationRepository.findBestPerformanceByUserId(userId, PageRequest.of(0, limit));
    }
    
    @Override
    public Map<String, Object> getChallengeStatistics(Long challengeId) {
        Map<String, Object> stats = new HashMap<>();
        
        Optional<Challenge> challenge = challengeRepository.findById(challengeId);
        if (challenge.isPresent()) {
            Challenge c = challenge.get();
            stats.put("challengeId", challengeId);
            stats.put("title", c.getTitle());
            stats.put("status", c.getStatus());
            stats.put("participantCount", c.getCurrentParticipants());
            stats.put("maxParticipants", c.getMaxParticipants());
            
            // 计算完成率
            Double completionRate = participationRepository.getChallengeCompletionRate(challengeId);
            stats.put("completionRate", completionRate != null ? completionRate : 0.0);
            
            // 计算平均得分
            Double averageScore = participationRepository.calculateAverageScoreByChallengeId(challengeId);
            stats.put("averageScore", averageScore != null ? averageScore : 0.0);
            
            // 获取最高得分
            Optional<ChallengeParticipation> topParticipation = participationRepository.findTopByChallengeIdOrderByCurrentScoreDesc(challengeId);
            stats.put("highestScore", topParticipation.map(ChallengeParticipation::getCurrentScore).orElse(0));
        }
        
        return stats;
    }
    
    @Override
    public Map<String, Object> getUserChallengeStatistics(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("userId", userId);
        stats.put("totalParticipations", participationRepository.countByUserId(userId));
        stats.put("completedChallenges", participationRepository.countByUserIdAndStatus(userId, ChallengeParticipation.ParticipationStatus.COMPLETED));
        
        Double completionRate = participationRepository.getUserCompletionRate(userId);
        stats.put("completionRate", completionRate != null ? completionRate : 0.0);
        
        Double averageScore = participationRepository.calculateAverageScoreByUserId(userId);
        stats.put("averageScore", averageScore != null ? averageScore : 0.0);
        
        Long totalRewards = participationRepository.calculateTotalRewardPointsByUserId(userId);
        stats.put("totalRewardPoints", totalRewards != null ? totalRewards : 0L);
        
        Optional<ChallengeParticipation> bestPerformance = participationRepository.findTopByUserIdOrderByBestScoreDesc(userId);
        stats.put("bestScore", bestPerformance.map(ChallengeParticipation::getBestScore).orElse(0));
        
        return stats;
    }
    
    @Override
    public Map<String, Object> getSystemChallengeStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalChallenges", challengeRepository.countByIsPublicTrue());
        stats.put("activeChallenges", challengeRepository.countByStatus(Challenge.ChallengeStatus.ACTIVE));
        stats.put("completedChallenges", challengeRepository.countByStatus(Challenge.ChallengeStatus.COMPLETED));
        
        // 获取类型分布
        List<Object[]> typeDistribution = challengeRepository.getChallengeTypeDistribution();
        Map<String, Long> typeStats = typeDistribution.stream()
            .collect(Collectors.toMap(
                arr -> arr[0].toString(),
                arr -> (Long) arr[1]
            ));
        stats.put("typeDistribution", typeStats);
        
        // 获取难度分布
        List<Object[]> difficultyDistribution = challengeRepository.getChallengeDifficultyDistribution();
        Map<String, Long> difficultyStats = difficultyDistribution.stream()
            .collect(Collectors.toMap(
                arr -> arr[0].toString(),
                arr -> (Long) arr[1]
            ));
        stats.put("difficultyDistribution", difficultyStats);
        
        return stats;
    }
    
    // ==================== 奖励和积分 ====================
    
    @Override
    public Integer calculateChallengeReward(Long challengeId, Long userId) {
        Optional<ChallengeParticipation> participation = participationRepository.findByChallengeIdAndUserId(challengeId, userId);
        if (participation.isPresent() && participation.get().isCompleted()) {
            Optional<Challenge> challenge = challengeRepository.findById(challengeId);
            if (challenge.isPresent()) {
                // 简化的奖励计算逻辑
                Integer baseReward = challenge.get().getRewardPoints();
                if (baseReward != null) {
                    // 根据排名给予额外奖励
                    Long ranking = getUserRankingInChallenge(challengeId, userId);
                    if (ranking != null && ranking <= 3) {
                        return (int) (baseReward * (1.5 - ranking * 0.1));
                    }
                    return baseReward;
                }
            }
        }
        return 0;
    }
    
    @Override
    public void distributeChallengeRewards(Long challengeId) {
        List<ChallengeParticipation> completedParticipations = participationRepository
            .findByChallengeIdAndStatus(challengeId, ChallengeParticipation.ParticipationStatus.COMPLETED);
        
        for (ChallengeParticipation participation : completedParticipations) {
            Integer reward = calculateChallengeReward(challengeId, participation.getUserId());
            participation.setRewardPoints(reward);
            participationRepository.save(participation);
        }
    }
    
    @Override
    public Long getUserTotalRewardPoints(Long userId) {
        Long total = participationRepository.calculateTotalRewardPointsByUserId(userId);
        return total != null ? total : 0L;
    }
    
    // ==================== 数据分析 ====================
    
    @Override
    public Map<String, Object> analyzeChallengePerformance(Long challengeId) {
        return getChallengeStatistics(challengeId);
    }
    
    @Override
    public Map<String, Object> analyzeUserChallengePerformance(Long userId) {
        return getUserChallengeStatistics(userId);
    }
    
    @Override
    public Map<String, Object> getChallengeTrendAnalysis(LocalDateTime startTime, LocalDateTime endTime) {
        Map<String, Object> analysis = new HashMap<>();
        
        List<Challenge> challenges = challengeRepository.findByTimeRange(startTime, endTime);
        analysis.put("totalChallenges", challenges.size());
        analysis.put("period", Map.of("start", startTime, "end", endTime));
        
        // 按类型分组统计
        Map<Challenge.ChallengeType, Long> typeCount = challenges.stream()
            .collect(Collectors.groupingBy(Challenge::getType, Collectors.counting()));
        analysis.put("typeDistribution", typeCount);
        
        return analysis;
    }
    
    @Override
    public Map<String, Object> getUserParticipationTrend(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        Map<String, Object> trend = new HashMap<>();
        
        List<ChallengeParticipation> participations = participationRepository
            .findByUserIdAndTimeRange(userId, startTime, endTime);
        
        trend.put("userId", userId);
        trend.put("totalParticipations", participations.size());
        trend.put("period", Map.of("start", startTime, "end", endTime));
        
        long completedCount = participations.stream()
            .filter(ChallengeParticipation::isCompleted)
            .count();
        trend.put("completedCount", completedCount);
        
        return trend;
    }
    
    // ==================== 系统管理 ====================
    
    @Override
    public void updateChallengeStatuses() {
        LocalDateTime now = LocalDateTime.now();
        
        // 开始已发布的挑战赛
        List<Challenge> toStart = challengeRepository.findChallengesNeedingStatusUpdate(now);
        for (Challenge challenge : toStart) {
            challenge.setStatus(Challenge.ChallengeStatus.ACTIVE);
            challengeRepository.save(challenge);
        }
        
        // 完成已到期的挑战赛
        List<Challenge> toComplete = challengeRepository.findChallengesNeedingCompletion(now);
        for (Challenge challenge : toComplete) {
            completeChallenge(challenge.getId());
        }
    }
    
    @Override
    public void updateParticipantRankings(Long challengeId) {
        List<ChallengeParticipation> participations = participationRepository
            .findLeaderboardByChallengeId(challengeId, Pageable.unpaged());
        
        for (int i = 0; i < participations.size(); i++) {
            ChallengeParticipation participation = participations.get(i);
            participation.setRanking(i + 1);
            participationRepository.save(participation);
        }
    }
    
    @Override
    public void cleanupExpiredData() {
        LocalDateTime expireTime = LocalDateTime.now().minusDays(30);
        challengeRepository.deleteExpiredDrafts(expireTime);
        participationRepository.deleteExpiredRegistrations(expireTime);
    }
    
    @Override
    public Map<String, Object> generateChallengeReport(Long challengeId) {
        Map<String, Object> report = new HashMap<>();
        
        Optional<Challenge> challenge = challengeRepository.findById(challengeId);
        if (challenge.isPresent()) {
            Challenge c = challenge.get();
            report.put("challenge", c);
            report.put("statistics", getChallengeStatistics(challengeId));
            report.put("leaderboard", getChallengeLeaderboard(challengeId, 10));
            report.put("generatedAt", LocalDateTime.now());
        }
        
        return report;
    }
    
    @Override
    public byte[] exportChallengeData(Long challengeId, String format) {
        // 简化实现，实际应该根据format生成不同格式的数据
        Map<String, Object> data = generateChallengeReport(challengeId);
        return data.toString().getBytes();
    }
    
    @Override
    public void batchUpdateChallenges(List<Long> challengeIds, Map<String, Object> updates) {
        for (Long challengeId : challengeIds) {
            Optional<Challenge> challenge = challengeRepository.findById(challengeId);
            if (challenge.isPresent()) {
                Challenge c = challenge.get();
                // 简化实现，实际应该根据updates中的字段进行更新
                if (updates.containsKey("status")) {
                    c.setStatus(Challenge.ChallengeStatus.valueOf(updates.get("status").toString()));
                }
                c.setUpdatedAt(LocalDateTime.now());
                challengeRepository.save(c);
            }
        }
    }
    
    // ==================== 通知和提醒 ====================
    
    @Override
    public void sendChallengeStartNotification(Long challengeId) {
        // 简化实现，实际应该发送通知
        System.out.println("Challenge " + challengeId + " has started!");
    }
    
    @Override
    public void sendChallengeEndNotification(Long challengeId) {
        System.out.println("Challenge " + challengeId + " has ended!");
    }
    
    @Override
    public void sendRankingChangeNotification(Long challengeId, Long userId, Integer oldRank, Integer newRank) {
        System.out.println("User " + userId + " ranking changed from " + oldRank + " to " + newRank);
    }
    
    @Override
    public void sendRewardNotification(Long userId, Integer rewardPoints, String reason) {
        System.out.println("User " + userId + " received " + rewardPoints + " points for " + reason);
    }
}