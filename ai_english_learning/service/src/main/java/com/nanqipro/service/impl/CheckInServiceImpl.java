package com.nanqipro.service.impl;

import com.nanqipro.entity.CheckIn;
import com.nanqipro.entity.CheckInRecord;
import com.nanqipro.repository.CheckInRepository;
import com.nanqipro.repository.CheckInRecordRepository;
import com.nanqipro.service.CheckInService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 打卡系统服务实现类
 */
@Service
@Transactional
public class CheckInServiceImpl implements CheckInService {
    
    @Autowired
    private CheckInRepository checkInRepository;
    
    @Autowired
    private CheckInRecordRepository recordRepository;
    
    // ==================== 打卡活动管理 ====================
    
    @Override
    public CheckIn createCheckIn(CheckIn checkIn) {
        checkIn.setCreatedAt(LocalDateTime.now());
        checkIn.setStatus(CheckIn.CheckInStatus.DRAFT);
        return checkInRepository.save(checkIn);
    }
    
    @Override
    public CheckIn updateCheckIn(Long checkInId, CheckIn checkIn) {
        Optional<CheckIn> existingCheckIn = checkInRepository.findById(checkInId);
        if (existingCheckIn.isPresent()) {
            CheckIn existing = existingCheckIn.get();
            existing.setTitle(checkIn.getTitle());
            existing.setDescription(checkIn.getDescription());
            existing.setType(checkIn.getType());
            existing.setFrequency(checkIn.getFrequency());
            existing.setStartDate(checkIn.getStartDate());
            existing.setEndDate(checkIn.getEndDate());
            existing.setTargetDays(checkIn.getTargetDays());
            existing.setRewardPoints(checkIn.getRewardPoints());
            existing.setRules(checkIn.getRules());
            existing.setRequirements(checkIn.getRequirements());
            existing.setCoverImage(checkIn.getCoverImage());
            existing.setIsPublic(checkIn.getIsPublic());
            existing.setAllowMakeup(checkIn.getAllowMakeup());
            existing.setMakeupCost(checkIn.getMakeupCost());
            existing.setMaxMakeupDays(checkIn.getMaxMakeupDays());
            existing.setUpdatedAt(LocalDateTime.now());
            return checkInRepository.save(existing);
        }
        throw new RuntimeException("CheckIn not found with id: " + checkInId);
    }
    
    @Override
    public void deleteCheckIn(Long checkInId) {
        checkInRepository.deleteById(checkInId);
    }
    
    @Override
    public CheckIn publishCheckIn(Long checkInId) {
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (checkIn.isPresent()) {
            CheckIn c = checkIn.get();
            c.setStatus(CheckIn.CheckInStatus.ACTIVE);
            c.setUpdatedAt(LocalDateTime.now());
            return checkInRepository.save(c);
        }
        throw new RuntimeException("CheckIn not found with id: " + checkInId);
    }
    
    @Override
    public CheckIn startCheckIn(Long checkInId) {
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (checkIn.isPresent()) {
            CheckIn c = checkIn.get();
            c.setStatus(CheckIn.CheckInStatus.ACTIVE);
            c.setUpdatedAt(LocalDateTime.now());
            return checkInRepository.save(c);
        }
        throw new RuntimeException("CheckIn not found with id: " + checkInId);
    }
    
    @Override
    public CheckIn completeCheckIn(Long checkInId) {
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (checkIn.isPresent()) {
            CheckIn c = checkIn.get();
            c.setStatus(CheckIn.CheckInStatus.COMPLETED);
            c.setUpdatedAt(LocalDateTime.now());
            
            // 分发最终奖励
            distributeFinalRewards(checkInId);
            
            return checkInRepository.save(c);
        }
        throw new RuntimeException("CheckIn not found with id: " + checkInId);
    }
    
    @Override
    public CheckIn cancelCheckIn(Long checkInId) {
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (checkIn.isPresent()) {
            CheckIn c = checkIn.get();
            c.setStatus(CheckIn.CheckInStatus.CANCELLED);
            c.setUpdatedAt(LocalDateTime.now());
            return checkInRepository.save(c);
        }
        throw new RuntimeException("CheckIn not found with id: " + checkInId);
    }
    
    @Override
    public CheckIn pauseCheckIn(Long checkInId) {
        // 简化实现，实际可能需要新增PAUSED状态
        return cancelCheckIn(checkInId);
    }
    
    @Override
    public CheckIn resumeCheckIn(Long checkInId) {
        return startCheckIn(checkInId);
    }
    
    // ==================== 打卡活动查询 ====================
    
    @Override
    public Optional<CheckIn> getCheckInById(Long checkInId) {
        return checkInRepository.findById(checkInId);
    }
    
    @Override
    public List<CheckIn> getAllPublicCheckIns() {
        return checkInRepository.findByIsPublicTrue();
    }
    
    @Override
    public List<CheckIn> getCheckInsByStatus(CheckIn.CheckInStatus status) {
        return checkInRepository.findByStatus(status);
    }
    
    @Override
    public List<CheckIn> getCheckInsByType(CheckIn.CheckInType type) {
        return checkInRepository.findByType(type);
    }
    
    @Override
    public List<CheckIn> getCheckInsByFrequency(CheckIn.CheckInFrequency frequency) {
        return checkInRepository.findByFrequency(frequency);
    }
    
    @Override
    public List<CheckIn> getActiveCheckIns() {
        return checkInRepository.findActiveChallenges(LocalDate.now());
    }
    
    @Override
    public List<CheckIn> getUpcomingCheckIns() {
        return checkInRepository.findUpcomingChallenges(LocalDate.now());
    }
    
    @Override
    public List<CheckIn> getCompletedCheckIns() {
        return checkInRepository.findCompletedChallenges(LocalDate.now());
    }
    
    @Override
    public List<CheckIn> getPopularCheckIns(int limit) {
        List<Object[]> results = checkInRepository.findPopularCheckIns(PageRequest.of(0, limit));
        return results.stream()
            .map(arr -> (CheckIn) arr[0])
            .collect(Collectors.toList());
    }
    
    @Override
    public List<CheckIn> getLatestCheckIns(int limit) {
        return checkInRepository.findByIsPublicTrueOrderByCreatedAtDesc(PageRequest.of(0, limit));
    }
    
    @Override
    public List<CheckIn> searchCheckIns(String keyword) {
        return checkInRepository.findByTitleOrDescriptionContaining(keyword);
    }
    
    @Override
    public Page<CheckIn> searchCheckIns(CheckIn.CheckInType type, 
                                       CheckIn.CheckInFrequency frequency, 
                                       CheckIn.CheckInStatus status, 
                                       Pageable pageable) {
        return checkInRepository.findByMultipleConditions(type, frequency, status, pageable);
    }
    
    // ==================== 用户相关 ====================
    
    @Override
    public List<CheckIn> getUserCreatedCheckIns(Long userId) {
        return checkInRepository.findByCreatorIdOrderByCreatedAtDesc(userId);
    }
    
    @Override
    public List<CheckIn> getUserParticipatedCheckIns(Long userId) {
        return checkInRepository.findByParticipantUserId(userId);
    }
    
    @Override
    public List<CheckIn> getUserActiveCheckIns(Long userId) {
        return checkInRepository.findActiveParticipationsByUserId(userId, LocalDate.now());
    }
    
    @Override
    public List<CheckIn> getUserCompletedCheckIns(Long userId) {
        return checkInRepository.findCompletedParticipationsByUserId(userId, LocalDate.now());
    }
    
    @Override
    public List<CheckIn> getRecommendedCheckIns(Long userId, int limit) {
        // 简化实现，实际应该基于用户偏好
        return checkInRepository.findRecommendedCheckIns(
            CheckIn.CheckInType.DAILY_LEARNING, 
            CheckIn.CheckInFrequency.DAILY, 
            PageRequest.of(0, limit)
        );
    }
    
    @Override
    public List<CheckIn> getSuggestedCheckIns(Long userId, int limit) {
        return checkInRepository.findSuggestedCheckIns(userId, PageRequest.of(0, limit));
    }
    
    // ==================== 打卡记录管理 ====================
    
    @Override
    public CheckInRecord createCheckInRecord(Long checkInId, Long userId, CheckInRecord record) {
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (!checkIn.isPresent()) {
            throw new RuntimeException("CheckIn not found");
        }
        
        record.setCheckIn(checkIn.get());
        record.setUserId(userId);
        record.setCreatedAt(LocalDateTime.now());
        return recordRepository.save(record);
    }
    
    @Override
    public CheckInRecord checkIn(Long checkInId, Long userId, String content, String proofImage, Integer studyDuration) {
        // 检查今天是否已经打卡
        LocalDate today = LocalDate.now();
        Optional<CheckInRecord> existingRecord = recordRepository.findByCheckInIdAndUserIdAndCheckInDate(checkInId, userId, today);
        if (existingRecord.isPresent()) {
            throw new RuntimeException("Already checked in today");
        }
        
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (!checkIn.isPresent()) {
            throw new RuntimeException("CheckIn not found");
        }
        
        CheckInRecord record = new CheckInRecord();
        record.setCheckIn(checkIn.get());
        record.setUserId(userId);
        record.setCheckInDate(today);
        record.setCheckInTime(LocalDateTime.now());
        record.setStatus(CheckInRecord.CheckInRecordStatus.COMPLETED);
        record.setType(CheckInRecord.CheckInRecordType.NORMAL);
        record.setCheckInContent(content);
        record.setProofImage(proofImage);
        record.setStudyDuration(studyDuration != null ? studyDuration : 0);
        record.setIsMakeup(false);
        record.setVerificationStatus(CheckInRecord.VerificationStatus.PENDING);
        
        // 计算连续打卡天数
        Integer consecutiveDays = calculateConsecutiveDays(checkInId, userId);
        record.setStreakDays(consecutiveDays);
        
        // 计算奖励积分
        Integer rewardPoints = calculateCheckInReward(checkInId, userId, consecutiveDays, studyDuration);
        record.setPointsEarned(rewardPoints);
        
        record.setCreatedAt(LocalDateTime.now());
        CheckInRecord savedRecord = recordRepository.save(record);
        
        // 发放奖励
        distributeCheckInReward(savedRecord.getId());
        
        return savedRecord;
    }
    
    @Override
    public CheckInRecord makeupCheckIn(Long checkInId, Long userId, LocalDate targetDate, String content, String proofImage) {
        if (!canMakeupCheckIn(checkInId, userId, targetDate)) {
            throw new RuntimeException("Cannot makeup check-in for this date");
        }
        
        // 检查是否已经补签过
        Optional<CheckInRecord> existingRecord = recordRepository.findByCheckInIdAndUserIdAndCheckInDate(checkInId, userId, targetDate);
        if (existingRecord.isPresent()) {
            throw new RuntimeException("Already checked in for this date");
        }
        
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (!checkIn.isPresent()) {
            throw new RuntimeException("CheckIn not found");
        }
        
        Integer makeupCost = calculateMakeupCost(checkInId, targetDate);
        
        CheckInRecord record = new CheckInRecord();
        record.setCheckIn(checkIn.get());
        record.setUserId(userId);
        record.setCheckInDate(targetDate);
        record.setCheckInTime(LocalDateTime.now());
        record.setStatus(CheckInRecord.CheckInRecordStatus.COMPLETED);
        record.setType(CheckInRecord.CheckInRecordType.MAKEUP);
        record.setCheckInContent(content);
        record.setProofImage(proofImage);
        record.setIsMakeup(true);
        record.setMakeupCost(makeupCost);
        record.setMakeupTime(LocalDateTime.now());
        record.setVerificationStatus(CheckInRecord.VerificationStatus.PENDING);
        record.setCreatedAt(LocalDateTime.now());
        
        return recordRepository.save(record);
    }
    
    @Override
    public CheckInRecord updateCheckInRecord(Long recordId, CheckInRecord record) {
        Optional<CheckInRecord> existingRecord = recordRepository.findById(recordId);
        if (existingRecord.isPresent()) {
            CheckInRecord existing = existingRecord.get();
            existing.setCheckInContent(record.getCheckInContent());
            existing.setProofImage(record.getProofImage());
            existing.setStudyDuration(record.getStudyDuration());
            existing.setNotes(record.getNotes());
            existing.setUpdatedAt(LocalDateTime.now());
            return recordRepository.save(existing);
        }
        throw new RuntimeException("CheckInRecord not found with id: " + recordId);
    }
    
    @Override
    public void deleteCheckInRecord(Long recordId) {
        recordRepository.deleteById(recordId);
    }
    
    @Override
    public CheckInRecord verifyCheckInRecord(Long recordId, Long verifierId, CheckInRecord.VerificationStatus status, String remarks) {
        Optional<CheckInRecord> record = recordRepository.findById(recordId);
        if (record.isPresent()) {
            CheckInRecord r = record.get();
            r.setVerificationStatus(status);
            r.setVerifierId(verifierId);
            r.setVerifiedAt(LocalDateTime.now());
            if (remarks != null) {
                r.setVerificationNotes(remarks);
            }
            r.setUpdatedAt(LocalDateTime.now());
            return recordRepository.save(r);
        }
        throw new RuntimeException("CheckInRecord not found with id: " + recordId);
    }
    
    // ==================== 打卡记录查询 ====================
    
    @Override
    public Optional<CheckInRecord> getCheckInRecordById(Long recordId) {
        return recordRepository.findById(recordId);
    }
    
    @Override
    public List<CheckInRecord> getUserCheckInRecords(Long userId) {
        return recordRepository.findByUserId(userId);
    }
    
    @Override
    public List<CheckInRecord> getCheckInRecords(Long checkInId) {
        return recordRepository.findByCheckInId(checkInId);
    }
    
    @Override
    public List<CheckInRecord> getUserCheckInRecords(Long checkInId, Long userId) {
        return recordRepository.findByCheckInIdAndUserId(checkInId, userId);
    }
    
    @Override
    public Optional<CheckInRecord> getUserCheckInRecord(Long userId, LocalDate date) {
        return recordRepository.findByUserIdAndCheckInDate(userId, date);
    }
    
    @Override
    public Optional<CheckInRecord> getUserCheckInRecord(Long checkInId, Long userId, LocalDate date) {
        return recordRepository.findByCheckInIdAndUserIdAndCheckInDate(checkInId, userId, date);
    }
    
    @Override
    public Optional<CheckInRecord> getUserLatestCheckInRecord(Long userId) {
        return recordRepository.findTopByUserIdOrderByCheckInDateDesc(userId);
    }
    
    @Override
    public List<CheckInRecord> getUserCheckInRecords(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return recordRepository.findByUserIdAndTimeRange(userId, startTime, endTime);
    }
    
    @Override
    public List<CheckInRecord> getPendingVerificationRecords() {
        return recordRepository.findByVerificationStatusOrderByCreatedAtAsc(CheckInRecord.VerificationStatus.PENDING);
    }
    
    // ==================== 连续打卡和统计 ====================
    
    @Override
    public Integer getUserCurrentConsecutiveDays(Long userId) {
        Optional<CheckInRecord> latestRecord = recordRepository.findTopByUserIdOrderByCheckInDateDesc(userId);
        if (latestRecord.isPresent()) {
            CheckInRecord record = latestRecord.get();
            // 检查最新记录是否是昨天或今天
            LocalDate today = LocalDate.now();
            LocalDate yesterday = today.minusDays(1);
            if (record.getCheckInDate().equals(today) || record.getCheckInDate().equals(yesterday)) {
                return record.getStreakDays();
            }
        }
        return 0;
    }
    
    @Override
    public Integer getUserConsecutiveDays(Long checkInId, Long userId) {
        Optional<CheckInRecord> latestRecord = recordRepository.findTopByCheckInIdAndUserIdOrderByCheckInDateDesc(checkInId, userId);
        return latestRecord.map(CheckInRecord::getStreakDays).orElse(0);
    }
    
    @Override
    public Integer getUserMaxConsecutiveDays(Long userId) {
        Optional<CheckInRecord> maxRecord = recordRepository.findTopByUserIdOrderByConsecutiveDaysDesc(userId);
        return maxRecord.map(CheckInRecord::getStreakDays).orElse(0);
    }
    
    @Override
    public void updateUserConsecutiveDays(Long userId) {
        // 简化实现，实际应该重新计算所有记录的连续天数
        List<CheckInRecord> records = recordRepository.findByUserId(userId);
        // 按日期排序并重新计算连续天数
        records.sort(Comparator.comparing(CheckInRecord::getCheckInDate));
        
        int consecutiveDays = 0;
        LocalDate previousDate = null;
        
        for (CheckInRecord record : records) {
            if (previousDate == null || record.getCheckInDate().equals(previousDate.plusDays(1))) {
                consecutiveDays++;
            } else {
                consecutiveDays = 1;
            }
            record.setStreakDays(consecutiveDays);
            recordRepository.save(record);
            previousDate = record.getCheckInDate();
        }
    }
    
    @Override
    public Map<String, Object> getUserCheckInStatistics(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("userId", userId);
        stats.put("totalCheckIns", recordRepository.countByUserId(userId));
        stats.put("completedCheckIns", recordRepository.countByUserIdAndStatus(userId, CheckInRecord.CheckInRecordStatus.COMPLETED));
        stats.put("currentConsecutiveDays", getUserCurrentConsecutiveDays(userId));
        stats.put("maxConsecutiveDays", getUserMaxConsecutiveDays(userId));
        stats.put("totalPoints", recordRepository.calculateTotalPointsByUserId(userId));
        stats.put("totalStudyDuration", recordRepository.calculateTotalStudyDurationByUserId(userId));
        stats.put("averageStudyDuration", recordRepository.calculateAverageStudyDurationByUserId(userId));
        stats.put("makeupCount", recordRepository.countByUserIdAndIsMakeupTrue(userId));
        
        return stats;
    }
    
    @Override
    public Map<String, Object> getCheckInStatistics(Long checkInId) {
        Map<String, Object> stats = new HashMap<>();
        
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (checkIn.isPresent()) {
            CheckIn c = checkIn.get();
            stats.put("checkInId", checkInId);
            stats.put("title", c.getTitle());
            stats.put("status", c.getStatus());
            stats.put("participantCount", recordRepository.countDistinctUsersByCheckInId(checkInId));
            stats.put("totalRecords", recordRepository.countByCheckInId(checkInId));
            stats.put("totalPoints", recordRepository.calculateTotalPointsByCheckInId(checkInId));
            stats.put("totalStudyDuration", recordRepository.calculateTotalStudyDurationByCheckInId(checkInId));
            
            // 计算完成率
            Double completionRate = recordRepository.getCheckInCompletionRate(checkInId);
            stats.put("completionRate", completionRate != null ? completionRate : 0.0);
        }
        
        return stats;
    }
    
    @Override
    public Map<String, Object> getSystemCheckInStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalCheckIns", checkInRepository.countByIsPublicTrue());
        stats.put("activeCheckIns", checkInRepository.countByStatus(CheckIn.CheckInStatus.ACTIVE));
        stats.put("completedCheckIns", checkInRepository.countByStatus(CheckIn.CheckInStatus.COMPLETED));
        
        // 获取类型分布
        List<Object[]> typeDistribution = checkInRepository.getCheckInTypeDistribution();
        Map<String, Long> typeStats = typeDistribution.stream()
            .collect(Collectors.toMap(
                arr -> arr[0].toString(),
                arr -> (Long) arr[1]
            ));
        stats.put("typeDistribution", typeStats);
        
        // 获取频率分布
        List<Object[]> frequencyDistribution = checkInRepository.getCheckInFrequencyDistribution();
        Map<String, Long> frequencyStats = frequencyDistribution.stream()
            .collect(Collectors.toMap(
                arr -> arr[0].toString(),
                arr -> (Long) arr[1]
            ));
        stats.put("frequencyDistribution", frequencyStats);
        
        return stats;
    }
    
    // ==================== 排行榜 ====================
    
    @Override
    public List<CheckInRecord> getCheckInLeaderboard(Long checkInId, int limit) {
        return recordRepository.findLeaderboardByCheckInId(checkInId, PageRequest.of(0, limit));
    }
    
    @Override
    public List<Map<String, Object>> getCheckInPointsLeaderboard(Long checkInId, int limit) {
        List<Object[]> results = recordRepository.findPointsLeaderboardByCheckInId(checkInId, PageRequest.of(0, limit));
        return results.stream()
            .map(arr -> {
                Map<String, Object> entry = new HashMap<>();
                entry.put("userId", arr[0]);
                entry.put("totalPoints", arr[1]);
                return entry;
            })
            .collect(Collectors.toList());
    }
    
    @Override
    public List<Map<String, Object>> getCheckInStudyDurationLeaderboard(Long checkInId, int limit) {
        List<Object[]> results = recordRepository.findStudyDurationLeaderboardByCheckInId(checkInId, PageRequest.of(0, limit));
        return results.stream()
            .map(arr -> {
                Map<String, Object> entry = new HashMap<>();
                entry.put("userId", arr[0]);
                entry.put("totalDuration", arr[1]);
                return entry;
            })
            .collect(Collectors.toList());
    }
    
    @Override
    public List<CheckInRecord> getGlobalConsecutiveLeaderboard(int limit) {
        return recordRepository.findGlobalConsecutiveLeaderboard(PageRequest.of(0, limit));
    }
    
    @Override
    public Long getUserRankingInCheckIn(Long checkInId, Long userId) {
        List<CheckInRecord> leaderboard = getCheckInLeaderboard(checkInId, Integer.MAX_VALUE);
        for (int i = 0; i < leaderboard.size(); i++) {
            if (leaderboard.get(i).getUserId().equals(userId)) {
                return (long) (i + 1);
            }
        }
        return null;
    }
    
    // ==================== 积分和奖励 ====================
    
    @Override
    public Integer calculateCheckInReward(Long checkInId, Long userId, Integer consecutiveDays, Integer studyDuration) {
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (checkIn.isPresent()) {
            CheckIn c = checkIn.get();
            Integer baseReward = c.getRewardPoints() != null ? c.getRewardPoints() : 10;
            
            // 基础奖励
            int totalReward = baseReward;
            
            // 连续打卡奖励
            if (consecutiveDays != null && consecutiveDays > 1) {
                totalReward += Math.min(consecutiveDays * 2, 50); // 最多额外50分
            }
            
            // 学习时长奖励
            if (studyDuration != null && studyDuration > 0) {
                totalReward += Math.min(studyDuration / 10, 20); // 每10分钟1分，最多20分
            }
            
            return totalReward;
        }
        return 0;
    }
    
    @Override
    public void distributeCheckInReward(Long recordId) {
        Optional<CheckInRecord> record = recordRepository.findById(recordId);
        if (record.isPresent()) {
            CheckInRecord r = record.get();
            // 简化实现，实际应该调用积分系统API
            System.out.println("Distributed " + r.getPointsEarned() + " points to user " + r.getUserId());
        }
    }
    
    @Override
    public Long getUserTotalCheckInPoints(Long userId) {
        Long total = recordRepository.calculateTotalPointsByUserId(userId);
        return total != null ? total : 0L;
    }
    
    @Override
    public Long getUserCheckInPoints(Long checkInId, Long userId) {
        Long total = recordRepository.calculatePointsByCheckInIdAndUserId(checkInId, userId);
        return total != null ? total : 0L;
    }
    
    // ==================== 数据分析 ====================
    
    @Override
    public Map<String, Object> analyzeUserCheckInBehavior(Long userId) {
        Map<String, Object> analysis = new HashMap<>();
        
        analysis.put("userId", userId);
        analysis.put("statistics", getUserCheckInStatistics(userId));
        
        // 分析打卡时间模式
        List<CheckInRecord> records = recordRepository.findByUserId(userId);
        Map<Integer, Long> hourDistribution = records.stream()
            .collect(Collectors.groupingBy(
                r -> r.getCheckInTime().getHour(),
                Collectors.counting()
            ));
        analysis.put("hourDistribution", hourDistribution);
        
        // 分析打卡频率
        Map<String, Long> typeDistribution = records.stream()
            .collect(Collectors.groupingBy(
                r -> r.getCheckIn().getType().toString(),
                Collectors.counting()
            ));
        analysis.put("typeDistribution", typeDistribution);
        
        return analysis;
    }
    
    @Override
    public Map<String, Object> analyzeCheckInPerformance(Long checkInId) {
        return getCheckInStatistics(checkInId);
    }
    
    @Override
    public Map<String, Object> getCheckInTrendAnalysis(LocalDateTime startTime, LocalDateTime endTime) {
        Map<String, Object> analysis = new HashMap<>();
        
        List<CheckInRecord> records = recordRepository.findByTimeRange(startTime, endTime);
        analysis.put("totalRecords", records.size());
        analysis.put("period", Map.of("start", startTime, "end", endTime));
        
        // 按日期分组统计
        Map<LocalDate, Long> dailyCount = records.stream()
            .collect(Collectors.groupingBy(
                CheckInRecord::getCheckInDate,
                Collectors.counting()
            ));
        analysis.put("dailyDistribution", dailyCount);
        
        return analysis;
    }
    
    @Override
    public Map<String, Object> getUserCheckInTrend(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        Map<String, Object> trend = new HashMap<>();
        
        List<CheckInRecord> records = recordRepository.findByUserIdAndTimeRange(userId, startTime, endTime);
        
        trend.put("userId", userId);
        trend.put("totalRecords", records.size());
        trend.put("period", Map.of("start", startTime, "end", endTime));
        
        // 计算平均学习时长
        double avgDuration = records.stream()
            .mapToInt(CheckInRecord::getStudyDuration)
            .average()
            .orElse(0.0);
        trend.put("averageStudyDuration", avgDuration);
        
        return trend;
    }
    
    @Override
    public Map<String, Object> predictUserCheckInBehavior(Long userId) {
        Map<String, Object> prediction = new HashMap<>();
        
        // 简化的预测逻辑
        Integer currentConsecutive = getUserCurrentConsecutiveDays(userId);
        prediction.put("userId", userId);
        prediction.put("currentConsecutiveDays", currentConsecutive);
        
        // 预测明天打卡概率
        double probability = Math.min(0.9, currentConsecutive * 0.1 + 0.3);
        prediction.put("tomorrowCheckInProbability", probability);
        
        return prediction;
    }
    
    // ==================== 系统管理 ====================
    
    @Override
    public void updateCheckInStatuses() {
        LocalDate today = LocalDate.now();
        
        // 开始已发布的打卡活动
        List<CheckIn> toStart = checkInRepository.findCheckInsNeedingStatusUpdate(today);
        for (CheckIn checkIn : toStart) {
            if (checkIn.getStatus() == CheckIn.CheckInStatus.ACTIVE && 
                !checkIn.getStartDate().toLocalDate().isAfter(today)) {
                checkIn.setStatus(CheckIn.CheckInStatus.ACTIVE);
                checkInRepository.save(checkIn);
            } else if (checkIn.getStatus() == CheckIn.CheckInStatus.ACTIVE && 
                       checkIn.getEndDate().toLocalDate().isBefore(today)) {
                completeCheckIn(checkIn.getId());
            }
        }
    }
    
    @Override
    public void updateAllUserConsecutiveDays() {
        // 获取所有有打卡记录的用户
        List<CheckInRecord> allRecords = recordRepository.findAll();
        Set<Long> userIds = allRecords.stream()
            .map(CheckInRecord::getUserId)
            .collect(Collectors.toSet());
        
        for (Long userId : userIds) {
            updateUserConsecutiveDays(userId);
        }
    }
    
    @Override
    public void cleanupExpiredData() {
        LocalDateTime expireTime = LocalDateTime.now().minusDays(90);
        checkInRepository.deleteExpiredDrafts(expireTime);
        recordRepository.deleteExpiredRecords(expireTime);
    }
    
    @Override
    public Map<String, Object> generateCheckInReport(Long checkInId) {
        Map<String, Object> report = new HashMap<>();
        
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (checkIn.isPresent()) {
            CheckIn c = checkIn.get();
            report.put("checkIn", c);
            report.put("statistics", getCheckInStatistics(checkInId));
            report.put("leaderboard", getCheckInLeaderboard(checkInId, 10));
            report.put("generatedAt", LocalDateTime.now());
        }
        
        return report;
    }
    
    @Override
    public byte[] exportCheckInData(Long checkInId, String format) {
        // 简化实现，实际应该根据format生成不同格式的数据
        Map<String, Object> data = generateCheckInReport(checkInId);
        return data.toString().getBytes();
    }
    
    @Override
    public void batchUpdateCheckIns(List<Long> checkInIds, Map<String, Object> updates) {
        for (Long checkInId : checkInIds) {
            Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
            if (checkIn.isPresent()) {
                CheckIn c = checkIn.get();
                // 简化实现，实际应该根据updates中的字段进行更新
                if (updates.containsKey("status")) {
                    c.setStatus(CheckIn.CheckInStatus.valueOf(updates.get("status").toString()));
                }
                c.setUpdatedAt(LocalDateTime.now());
                checkInRepository.save(c);
            }
        }
    }
    
    @Override
    public Map<String, Object> getSystemHealth() {
        Map<String, Object> health = new HashMap<>();
        
        health.put("totalCheckIns", checkInRepository.count());
        health.put("totalRecords", recordRepository.count());
        health.put("pendingVerifications", recordRepository.countByVerificationStatus(CheckInRecord.VerificationStatus.PENDING));
        health.put("systemStatus", "healthy");
        health.put("lastUpdated", LocalDateTime.now());
        
        return health;
    }
    
    @Override
    public void optimizePerformance() {
        // 简化实现，实际应该包含性能优化逻辑
        System.out.println("Optimizing check-in system performance...");
    }
    
    // ==================== 通知和提醒 ====================
    
    @Override
    public void sendCheckInReminder(Long userId) {
        System.out.println("Sending check-in reminder to user " + userId);
    }
    
    @Override
    public void sendConsecutiveRewardNotification(Long userId, Integer consecutiveDays, Integer rewardPoints) {
        System.out.println("User " + userId + " achieved " + consecutiveDays + " consecutive days and earned " + rewardPoints + " points");
    }
    
    @Override
    public void sendCheckInStartNotification(Long checkInId) {
        System.out.println("CheckIn " + checkInId + " has started!");
    }
    
    @Override
    public void sendCheckInEndNotification(Long checkInId) {
        System.out.println("CheckIn " + checkInId + " has ended!");
    }
    
    @Override
    public void sendRankingChangeNotification(Long checkInId, Long userId, Integer oldRank, Integer newRank) {
        System.out.println("User " + userId + " ranking in CheckIn " + checkInId + " changed from " + oldRank + " to " + newRank);
    }
    
    // ==================== 补签管理 ====================
    
    @Override
    public boolean canMakeupCheckIn(Long checkInId, Long userId, LocalDate targetDate) {
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (!checkIn.isPresent() || !checkIn.get().getAllowMakeup()) {
            return false;
        }
        
        CheckIn c = checkIn.get();
        
        // 检查日期是否在活动范围内
        if (targetDate.isBefore(c.getStartDate().toLocalDate()) || targetDate.isAfter(c.getEndDate().toLocalDate())) {
            return false;
        }
        
        // 检查是否超过最大补签天数
        long daysDiff = ChronoUnit.DAYS.between(targetDate, LocalDate.now());
        if (c.getMaxMakeupDays() != null && daysDiff > c.getMaxMakeupDays()) {
            return false;
        }
        
        return true;
    }
    
    @Override
    public Integer calculateMakeupCost(Long checkInId, LocalDate targetDate) {
        Optional<CheckIn> checkIn = checkInRepository.findById(checkInId);
        if (checkIn.isPresent()) {
            CheckIn c = checkIn.get();
            if (c.getMakeupCost() != null) {
                // 简化的费用计算，实际可能根据天数递增
                long daysDiff = ChronoUnit.DAYS.between(targetDate, LocalDate.now());
                return (int) (c.getMakeupCost() * Math.max(1, daysDiff));
            }
        }
        return 0;
    }
    
    @Override
    public List<CheckInRecord> getUserMakeupRecords(Long userId) {
        return recordRepository.findByUserId(userId).stream()
            .filter(CheckInRecord::getIsMakeup)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<CheckInRecord> getCheckInMakeupRecords(Long checkInId) {
        return recordRepository.findByCheckInId(checkInId).stream()
            .filter(CheckInRecord::getIsMakeup)
            .collect(Collectors.toList());
    }
    
    // ==================== 验证管理 ====================
    
    @Override
    public void batchVerifyCheckInRecords(List<Long> recordIds, Long verifierId, CheckInRecord.VerificationStatus status) {
        for (Long recordId : recordIds) {
            verifyCheckInRecord(recordId, verifierId, status, null);
        }
    }
    
    @Override
    public void autoVerifyCheckInRecords() {
        // 简化实现，自动验证一些简单的记录
        List<CheckInRecord> pendingRecords = getPendingVerificationRecords();
        for (CheckInRecord record : pendingRecords) {
            // 简单的自动验证逻辑
            if (record.getStudyDuration() > 0 && record.getCheckInContent() != null) {
                verifyCheckInRecord(record.getId(), null, CheckInRecord.VerificationStatus.APPROVED, "Auto verified");
            }
        }
    }
    
    @Override
    public Map<String, Object> getVerificationStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("pending", recordRepository.countByVerificationStatus(CheckInRecord.VerificationStatus.PENDING));
        stats.put("approved", recordRepository.countByVerificationStatus(CheckInRecord.VerificationStatus.APPROVED));
        stats.put("rejected", recordRepository.countByVerificationStatus(CheckInRecord.VerificationStatus.REJECTED));
        
        return stats;
    }
    
    // ==================== 社交功能 ====================
    
    @Override
    public List<CheckInRecord> getFriendsCheckInActivity(Long userId, int limit) {
        // 简化实现，实际应该基于好友关系
        return recordRepository.findTop10ByOrderByPointsEarnedDesc();
    }
    
    @Override
    public String shareCheckInRecord(Long recordId) {
        // 简化实现，生成分享链接
        return "https://app.example.com/checkin/record/" + recordId;
    }
    
    @Override
    public void likeCheckInRecord(Long recordId, Long userId) {
        // 简化实现，实际应该记录点赞
        System.out.println("User " + userId + " liked record " + recordId);
    }
    
    @Override
    public void commentCheckInRecord(Long recordId, Long userId, String comment) {
        // 简化实现，实际应该保存评论
        System.out.println("User " + userId + " commented on record " + recordId + ": " + comment);
    }
    
    // ==================== 私有辅助方法 ====================
    
    private Integer calculateConsecutiveDays(Long checkInId, Long userId) {
        List<CheckInRecord> records = recordRepository.findByCheckInIdAndUserId(checkInId, userId);
        records.sort(Comparator.comparing(CheckInRecord::getCheckInDate));
        
        if (records.isEmpty()) {
            return 1;
        }
        
        LocalDate today = LocalDate.now();
        LocalDate yesterday = today.minusDays(1);
        
        // 从最新记录开始向前计算连续天数
        int consecutiveDays = 1;
        LocalDate currentDate = today;
        
        for (int i = records.size() - 1; i >= 0; i--) {
            CheckInRecord record = records.get(i);
            if (record.getCheckInDate().equals(currentDate) || record.getCheckInDate().equals(yesterday)) {
                if (i > 0) {
                    CheckInRecord prevRecord = records.get(i - 1);
                    if (record.getCheckInDate().equals(prevRecord.getCheckInDate().plusDays(1))) {
                        consecutiveDays++;
                        currentDate = prevRecord.getCheckInDate();
                    } else {
                        break;
                    }
                }
            } else {
                break;
            }
        }
        
        return consecutiveDays;
    }
    
    private void distributeFinalRewards(Long checkInId) {
        // 为完成打卡活动的用户分发最终奖励
        List<CheckInRecord> completedRecords = recordRepository.findByCheckInId(checkInId).stream()
            .filter(r -> r.getStatus() == CheckInRecord.CheckInRecordStatus.COMPLETED)
            .collect(Collectors.toList());
        
        for (CheckInRecord record : completedRecords) {
            // 简化实现，实际应该根据完成度给予不同奖励
            Integer bonusReward = record.getStreakDays() * 5;
            record.setPointsEarned(record.getPointsEarned() + bonusReward);
            recordRepository.save(record);
        }
    }
}