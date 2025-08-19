package com.nanqipro.service;

import com.nanqipro.entity.CheckIn;
import com.nanqipro.entity.CheckInRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 打卡系统服务接口
 */
public interface CheckInService {
    
    // ==================== 打卡活动管理 ====================
    
    /**
     * 创建打卡活动
     */
    CheckIn createCheckIn(CheckIn checkIn);
    
    /**
     * 更新打卡活动
     */
    CheckIn updateCheckIn(Long checkInId, CheckIn checkIn);
    
    /**
     * 删除打卡活动
     */
    void deleteCheckIn(Long checkInId);
    
    /**
     * 发布打卡活动
     */
    CheckIn publishCheckIn(Long checkInId);
    
    /**
     * 开始打卡活动
     */
    CheckIn startCheckIn(Long checkInId);
    
    /**
     * 完成打卡活动
     */
    CheckIn completeCheckIn(Long checkInId);
    
    /**
     * 取消打卡活动
     */
    CheckIn cancelCheckIn(Long checkInId);
    
    /**
     * 暂停打卡活动
     */
    CheckIn pauseCheckIn(Long checkInId);
    
    /**
     * 恢复打卡活动
     */
    CheckIn resumeCheckIn(Long checkInId);
    
    // ==================== 打卡活动查询 ====================
    
    /**
     * 根据ID获取打卡活动
     */
    Optional<CheckIn> getCheckInById(Long checkInId);
    
    /**
     * 获取所有公开的打卡活动
     */
    List<CheckIn> getAllPublicCheckIns();
    
    /**
     * 根据状态获取打卡活动
     */
    List<CheckIn> getCheckInsByStatus(CheckIn.CheckInStatus status);
    
    /**
     * 根据类型获取打卡活动
     */
    List<CheckIn> getCheckInsByType(CheckIn.CheckInType type);
    
    /**
     * 根据频率获取打卡活动
     */
    List<CheckIn> getCheckInsByFrequency(CheckIn.CheckInFrequency frequency);
    
    /**
     * 获取正在进行的打卡活动
     */
    List<CheckIn> getActiveCheckIns();
    
    /**
     * 获取即将开始的打卡活动
     */
    List<CheckIn> getUpcomingCheckIns();
    
    /**
     * 获取已完成的打卡活动
     */
    List<CheckIn> getCompletedCheckIns();
    
    /**
     * 获取热门打卡活动
     */
    List<CheckIn> getPopularCheckIns(int limit);
    
    /**
     * 获取最新打卡活动
     */
    List<CheckIn> getLatestCheckIns(int limit);
    
    /**
     * 搜索打卡活动
     */
    List<CheckIn> searchCheckIns(String keyword);
    
    /**
     * 多条件搜索打卡活动
     */
    Page<CheckIn> searchCheckIns(CheckIn.CheckInType type, 
                                CheckIn.CheckInFrequency frequency, 
                                CheckIn.CheckInStatus status, 
                                Pageable pageable);
    
    // ==================== 用户相关 ====================
    
    /**
     * 获取用户创建的打卡活动
     */
    List<CheckIn> getUserCreatedCheckIns(Long userId);
    
    /**
     * 获取用户参与的打卡活动
     */
    List<CheckIn> getUserParticipatedCheckIns(Long userId);
    
    /**
     * 获取用户正在参与的打卡活动
     */
    List<CheckIn> getUserActiveCheckIns(Long userId);
    
    /**
     * 获取用户已完成的打卡活动
     */
    List<CheckIn> getUserCompletedCheckIns(Long userId);
    
    /**
     * 获取推荐的打卡活动
     */
    List<CheckIn> getRecommendedCheckIns(Long userId, int limit);
    
    /**
     * 获取建议的打卡活动
     */
    List<CheckIn> getSuggestedCheckIns(Long userId, int limit);
    
    // ==================== 打卡记录管理 ====================
    
    /**
     * 创建打卡记录
     */
    CheckInRecord createCheckInRecord(Long checkInId, Long userId, CheckInRecord record);
    
    /**
     * 用户打卡
     */
    CheckInRecord checkIn(Long checkInId, Long userId, String content, String proofImage, Integer studyDuration);
    
    /**
     * 补签打卡
     */
    CheckInRecord makeupCheckIn(Long checkInId, Long userId, LocalDate targetDate, String content, String proofImage);
    
    /**
     * 更新打卡记录
     */
    CheckInRecord updateCheckInRecord(Long recordId, CheckInRecord record);
    
    /**
     * 删除打卡记录
     */
    void deleteCheckInRecord(Long recordId);
    
    /**
     * 验证打卡记录
     */
    CheckInRecord verifyCheckInRecord(Long recordId, Long verifierId, CheckInRecord.VerificationStatus status, String remarks);
    
    // ==================== 打卡记录查询 ====================
    
    /**
     * 根据ID获取打卡记录
     */
    Optional<CheckInRecord> getCheckInRecordById(Long recordId);
    
    /**
     * 获取用户的打卡记录
     */
    List<CheckInRecord> getUserCheckInRecords(Long userId);
    
    /**
     * 获取打卡活动的记录
     */
    List<CheckInRecord> getCheckInRecords(Long checkInId);
    
    /**
     * 获取用户在指定打卡活动中的记录
     */
    List<CheckInRecord> getUserCheckInRecords(Long checkInId, Long userId);
    
    /**
     * 获取用户指定日期的打卡记录
     */
    Optional<CheckInRecord> getUserCheckInRecord(Long userId, LocalDate date);
    
    /**
     * 获取用户在指定打卡活动和日期的记录
     */
    Optional<CheckInRecord> getUserCheckInRecord(Long checkInId, Long userId, LocalDate date);
    
    /**
     * 获取用户最新的打卡记录
     */
    Optional<CheckInRecord> getUserLatestCheckInRecord(Long userId);
    
    /**
     * 获取用户在指定时间范围内的打卡记录
     */
    List<CheckInRecord> getUserCheckInRecords(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取待验证的打卡记录
     */
    List<CheckInRecord> getPendingVerificationRecords();
    
    // ==================== 连续打卡和统计 ====================
    
    /**
     * 获取用户当前连续打卡天数
     */
    Integer getUserCurrentConsecutiveDays(Long userId);
    
    /**
     * 获取用户在指定打卡活动中的连续打卡天数
     */
    Integer getUserConsecutiveDays(Long checkInId, Long userId);
    
    /**
     * 获取用户最高连续打卡天数
     */
    Integer getUserMaxConsecutiveDays(Long userId);
    
    /**
     * 更新用户连续打卡天数
     */
    void updateUserConsecutiveDays(Long userId);
    
    /**
     * 获取用户打卡统计
     */
    Map<String, Object> getUserCheckInStatistics(Long userId);
    
    /**
     * 获取打卡活动统计
     */
    Map<String, Object> getCheckInStatistics(Long checkInId);
    
    /**
     * 获取系统打卡统计
     */
    Map<String, Object> getSystemCheckInStatistics();
    
    // ==================== 排行榜 ====================
    
    /**
     * 获取打卡活动排行榜（按连续天数）
     */
    List<CheckInRecord> getCheckInLeaderboard(Long checkInId, int limit);
    
    /**
     * 获取打卡活动积分排行榜
     */
    List<Map<String, Object>> getCheckInPointsLeaderboard(Long checkInId, int limit);
    
    /**
     * 获取打卡活动学习时长排行榜
     */
    List<Map<String, Object>> getCheckInStudyDurationLeaderboard(Long checkInId, int limit);
    
    /**
     * 获取全局连续打卡排行榜
     */
    List<CheckInRecord> getGlobalConsecutiveLeaderboard(int limit);
    
    /**
     * 获取用户在打卡活动中的排名
     */
    Long getUserRankingInCheckIn(Long checkInId, Long userId);
    
    // ==================== 积分和奖励 ====================
    
    /**
     * 计算打卡奖励积分
     */
    Integer calculateCheckInReward(Long checkInId, Long userId, Integer consecutiveDays, Integer studyDuration);
    
    /**
     * 发放打卡奖励
     */
    void distributeCheckInReward(Long recordId);
    
    /**
     * 获取用户总打卡积分
     */
    Long getUserTotalCheckInPoints(Long userId);
    
    /**
     * 获取用户在指定打卡活动中的积分
     */
    Long getUserCheckInPoints(Long checkInId, Long userId);
    
    // ==================== 数据分析 ====================
    
    /**
     * 分析用户打卡行为
     */
    Map<String, Object> analyzeUserCheckInBehavior(Long userId);
    
    /**
     * 分析打卡活动表现
     */
    Map<String, Object> analyzeCheckInPerformance(Long checkInId);
    
    /**
     * 获取打卡趋势分析
     */
    Map<String, Object> getCheckInTrendAnalysis(LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取用户打卡趋势
     */
    Map<String, Object> getUserCheckInTrend(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 预测用户打卡行为
     */
    Map<String, Object> predictUserCheckInBehavior(Long userId);
    
    // ==================== 系统管理 ====================
    
    /**
     * 更新打卡活动状态
     */
    void updateCheckInStatuses();
    
    /**
     * 更新所有用户连续打卡天数
     */
    void updateAllUserConsecutiveDays();
    
    /**
     * 清理过期数据
     */
    void cleanupExpiredData();
    
    /**
     * 生成打卡活动报告
     */
    Map<String, Object> generateCheckInReport(Long checkInId);
    
    /**
     * 导出打卡数据
     */
    byte[] exportCheckInData(Long checkInId, String format);
    
    /**
     * 批量更新打卡活动
     */
    void batchUpdateCheckIns(List<Long> checkInIds, Map<String, Object> updates);
    
    /**
     * 获取系统健康状态
     */
    Map<String, Object> getSystemHealth();
    
    /**
     * 优化系统性能
     */
    void optimizePerformance();
    
    // ==================== 通知和提醒 ====================
    
    /**
     * 发送打卡提醒
     */
    void sendCheckInReminder(Long userId);
    
    /**
     * 发送连续打卡奖励通知
     */
    void sendConsecutiveRewardNotification(Long userId, Integer consecutiveDays, Integer rewardPoints);
    
    /**
     * 发送打卡活动开始通知
     */
    void sendCheckInStartNotification(Long checkInId);
    
    /**
     * 发送打卡活动结束通知
     */
    void sendCheckInEndNotification(Long checkInId);
    
    /**
     * 发送排名变化通知
     */
    void sendRankingChangeNotification(Long checkInId, Long userId, Integer oldRank, Integer newRank);
    
    // ==================== 补签管理 ====================
    
    /**
     * 检查是否可以补签
     */
    boolean canMakeupCheckIn(Long checkInId, Long userId, LocalDate targetDate);
    
    /**
     * 计算补签费用
     */
    Integer calculateMakeupCost(Long checkInId, LocalDate targetDate);
    
    /**
     * 获取用户补签记录
     */
    List<CheckInRecord> getUserMakeupRecords(Long userId);
    
    /**
     * 获取打卡活动补签记录
     */
    List<CheckInRecord> getCheckInMakeupRecords(Long checkInId);
    
    // ==================== 验证管理 ====================
    
    /**
     * 批量验证打卡记录
     */
    void batchVerifyCheckInRecords(List<Long> recordIds, Long verifierId, CheckInRecord.VerificationStatus status);
    
    /**
     * 自动验证打卡记录
     */
    void autoVerifyCheckInRecords();
    
    /**
     * 获取验证统计
     */
    Map<String, Object> getVerificationStatistics();
    
    // ==================== 社交功能 ====================
    
    /**
     * 获取好友打卡动态
     */
    List<CheckInRecord> getFriendsCheckInActivity(Long userId, int limit);
    
    /**
     * 分享打卡记录
     */
    String shareCheckInRecord(Long recordId);
    
    /**
     * 点赞打卡记录
     */
    void likeCheckInRecord(Long recordId, Long userId);
    
    /**
     * 评论打卡记录
     */
    void commentCheckInRecord(Long recordId, Long userId, String comment);
}