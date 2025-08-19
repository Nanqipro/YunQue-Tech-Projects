package com.nanqipro.controller;

import com.nanqipro.common.ApiResponse;
import com.nanqipro.entity.CheckIn;
import com.nanqipro.entity.CheckInRecord;
import com.nanqipro.service.CheckInService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 打卡系统控制器
 * 提供打卡相关的REST API接口
 */
@RestController
@RequestMapping("/api/checkins")
@RequiredArgsConstructor
@Tag(name = "打卡系统管理", description = "打卡系统相关API")
public class CheckInController {

    private final CheckInService checkInService;

    // ==================== 打卡活动管理 ====================

    @PostMapping
    @Operation(summary = "创建打卡活动", description = "创建新的打卡活动")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<CheckIn>> createCheckIn(
            @Valid @RequestBody CheckIn checkIn) {
        CheckIn created = checkInService.createCheckIn(checkIn);
        return ResponseEntity.ok(ApiResponse.success(created));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新打卡活动", description = "更新打卡活动信息")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<CheckIn>> updateCheckIn(
            @PathVariable Long id,
            @Valid @RequestBody CheckIn checkIn) {
        CheckIn updated = checkInService.updateCheckIn(id, checkIn);
        return ResponseEntity.ok(ApiResponse.success(updated));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除打卡活动", description = "删除指定的打卡活动")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteCheckIn(@PathVariable Long id) {
        checkInService.deleteCheckIn(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/{id}/publish")
    @Operation(summary = "发布打卡活动", description = "发布打卡活动，使其可见")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<CheckIn>> publishCheckIn(@PathVariable Long id) {
        CheckIn published = checkInService.publishCheckIn(id);
        return ResponseEntity.ok(ApiResponse.success(published));
    }

    @PostMapping("/{id}/start")
    @Operation(summary = "开始打卡活动", description = "开始打卡活动")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<CheckIn>> startCheckIn(@PathVariable Long id) {
        CheckIn started = checkInService.startCheckIn(id);
        return ResponseEntity.ok(ApiResponse.success(started));
    }

    @PostMapping("/{id}/complete")
    @Operation(summary = "完成打卡活动", description = "完成打卡活动")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<CheckIn>> completeCheckIn(@PathVariable Long id) {
        CheckIn completed = checkInService.completeCheckIn(id);
        return ResponseEntity.ok(ApiResponse.success(completed));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "取消打卡活动", description = "取消打卡活动")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<CheckIn>> cancelCheckIn(@PathVariable Long id) {
        CheckIn cancelled = checkInService.cancelCheckIn(id);
        return ResponseEntity.ok(ApiResponse.success(cancelled));
    }

    @PostMapping("/{id}/pause")
    @Operation(summary = "暂停打卡活动", description = "暂停打卡活动")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<CheckIn>> pauseCheckIn(@PathVariable Long id) {
        CheckIn paused = checkInService.pauseCheckIn(id);
        return ResponseEntity.ok(ApiResponse.success(paused));
    }

    @PostMapping("/{id}/resume")
    @Operation(summary = "恢复打卡活动", description = "恢复暂停的打卡活动")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<CheckIn>> resumeCheckIn(@PathVariable Long id) {
        CheckIn resumed = checkInService.resumeCheckIn(id);
        return ResponseEntity.ok(ApiResponse.success(resumed));
    }

    // ==================== 打卡活动查询 ====================

    @GetMapping("/{id}")
    @Operation(summary = "获取打卡活动详情", description = "根据ID获取打卡活动详情")
    public ResponseEntity<ApiResponse<CheckIn>> getCheckInById(@PathVariable Long id) {
        CheckIn checkIn = checkInService.getCheckInById(id).orElse(null);
        return ResponseEntity.ok(ApiResponse.success(checkIn));
    }

    @GetMapping
    @Operation(summary = "分页查询打卡活动", description = "分页查询打卡活动列表")
    public ResponseEntity<ApiResponse<Page<CheckIn>>> getCheckIns(
            @Parameter(description = "状态") @RequestParam(required = false) CheckIn.CheckInStatus status,
            @Parameter(description = "类型") @RequestParam(required = false) CheckIn.CheckInType type,
            @Parameter(description = "频率") @RequestParam(required = false) CheckIn.CheckInFrequency frequency,
            @Parameter(description = "关键词") @RequestParam(required = false) String keyword,
            Pageable pageable) {
        Page<CheckIn> checkIns = checkInService.searchCheckIns(type, frequency, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "按状态查询打卡活动", description = "根据状态查询打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getCheckInsByStatus(
            @PathVariable CheckIn.CheckInStatus status) {
        List<CheckIn> checkIns = checkInService.getCheckInsByStatus(status);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/type/{type}")
    @Operation(summary = "按类型查询打卡活动", description = "根据类型查询打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getCheckInsByType(
            @PathVariable CheckIn.CheckInType type) {
        List<CheckIn> checkIns = checkInService.getCheckInsByType(type);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/frequency/{frequency}")
    @Operation(summary = "按频率查询打卡活动", description = "根据频率查询打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getCheckInsByFrequency(
            @PathVariable CheckIn.CheckInFrequency frequency) {
        List<CheckIn> checkIns = checkInService.getCheckInsByFrequency(frequency);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/active")
    @Operation(summary = "获取活跃打卡活动", description = "获取当前活跃的打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getActiveCheckIns() {
        List<CheckIn> checkIns = checkInService.getActiveCheckIns();
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/popular")
    @Operation(summary = "获取热门打卡活动", description = "获取热门打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getPopularCheckIns(
            @Parameter(description = "数量限制") @RequestParam(defaultValue = "10") int limit) {
        List<CheckIn> checkIns = checkInService.getPopularCheckIns(limit);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/latest")
    @Operation(summary = "获取最新打卡活动", description = "获取最新的打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getLatestCheckIns(
            @Parameter(description = "数量限制") @RequestParam(defaultValue = "10") int limit) {
        List<CheckIn> checkIns = checkInService.getLatestCheckIns(limit);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/search")
    @Operation(summary = "搜索打卡活动", description = "根据关键词搜索打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> searchCheckIns(
            @Parameter(description = "搜索关键词") @RequestParam String keyword) {
        List<CheckIn> checkIns = checkInService.searchCheckIns(keyword);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    // ==================== 用户相关 ====================

    @GetMapping("/user/{userId}/created")
    @Operation(summary = "获取用户创建的打卡活动", description = "获取指定用户创建的打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getUserCreatedCheckIns(
            @PathVariable Long userId) {
        List<CheckIn> checkIns = checkInService.getUserCreatedCheckIns(userId);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/user/{userId}/participated")
    @Operation(summary = "获取用户参与的打卡活动", description = "获取指定用户参与的打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getUserParticipatedCheckIns(
            @PathVariable Long userId) {
        List<CheckIn> checkIns = checkInService.getUserParticipatedCheckIns(userId);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/user/{userId}/active")
    @Operation(summary = "获取用户活跃打卡活动", description = "获取用户当前活跃参与的打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getUserActiveCheckIns(
            @PathVariable Long userId) {
        List<CheckIn> checkIns = checkInService.getUserActiveCheckIns(userId);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/user/{userId}/completed")
    @Operation(summary = "获取用户完成的打卡活动", description = "获取用户已完成的打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getUserCompletedCheckIns(
            @PathVariable Long userId) {
        List<CheckIn> checkIns = checkInService.getUserCompletedCheckIns(userId);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/user/{userId}/recommendations")
    @Operation(summary = "获取用户推荐打卡活动", description = "为用户推荐合适的打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getRecommendedCheckIns(
            @PathVariable Long userId,
            @Parameter(description = "推荐数量") @RequestParam(defaultValue = "5") int limit) {
        List<CheckIn> checkIns = checkInService.getRecommendedCheckIns(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    @GetMapping("/user/{userId}/suggestions")
    @Operation(summary = "获取用户建议打卡活动", description = "为用户建议打卡活动")
    public ResponseEntity<ApiResponse<List<CheckIn>>> getSuggestedCheckIns(
            @PathVariable Long userId,
            @Parameter(description = "建议数量") @RequestParam(defaultValue = "5") int limit) {
        List<CheckIn> checkIns = checkInService.getSuggestedCheckIns(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(checkIns));
    }

    // ==================== 打卡记录管理 ====================

    @PostMapping("/records")
    @Operation(summary = "创建打卡记录", description = "创建新的打卡记录")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<CheckInRecord>> createCheckInRecord(
            @Parameter(description = "打卡活动ID") @RequestParam Long checkInId,
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Valid @RequestBody CheckInRecord record) {
        CheckInRecord created = checkInService.createCheckInRecord(checkInId, userId, record);
        return ResponseEntity.ok(ApiResponse.success(created));
    }

    @PostMapping("/{checkInId}/checkin")
    @Operation(summary = "用户打卡", description = "用户进行打卡")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<CheckInRecord>> userCheckIn(
            @PathVariable Long checkInId,
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Parameter(description = "学习时长（分钟）") @RequestParam(required = false) Integer studyDuration,
            @Parameter(description = "打卡内容") @RequestParam(required = false) String content,
            @Parameter(description = "证明图片") @RequestParam(required = false) MultipartFile proofImage) {
        String proofImagePath = proofImage != null ? proofImage.getOriginalFilename() : null;
        CheckInRecord record = checkInService.checkIn(checkInId, userId, content, proofImagePath, studyDuration);
        return ResponseEntity.ok(ApiResponse.success(record));
    }

    @PostMapping("/{checkInId}/makeup")
    @Operation(summary = "补签打卡", description = "用户补签打卡")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<CheckInRecord>> makeupCheckIn(
            @PathVariable Long checkInId,
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Parameter(description = "补签日期") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate makeupDate,
            @Parameter(description = "打卡内容") @RequestParam(required = false) String content,
            @Parameter(description = "证明图片") @RequestParam(required = false) String proofImage) {
        CheckInRecord record = checkInService.makeupCheckIn(checkInId, userId, makeupDate, content, proofImage);
        return ResponseEntity.ok(ApiResponse.success(record));
    }

    @PutMapping("/records/{id}")
    @Operation(summary = "更新打卡记录", description = "更新打卡记录信息")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<CheckInRecord>> updateCheckInRecord(
            @PathVariable Long id,
            @Valid @RequestBody CheckInRecord record) {
        CheckInRecord updated = checkInService.updateCheckInRecord(id, record);
        return ResponseEntity.ok(ApiResponse.success(updated));
    }

    @DeleteMapping("/records/{id}")
    @Operation(summary = "删除打卡记录", description = "删除指定的打卡记录")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteCheckInRecord(@PathVariable Long id) {
        checkInService.deleteCheckInRecord(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/records/{id}/verify")
    @Operation(summary = "验证打卡记录", description = "验证打卡记录的真实性")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<CheckInRecord>> verifyCheckInRecord(
            @PathVariable Long id,
            @Parameter(description = "验证者ID") @RequestParam Long verifierId,
            @Parameter(description = "验证状态") @RequestParam CheckInRecord.VerificationStatus status,
            @Parameter(description = "验证备注") @RequestParam(required = false) String verificationNotes) {
        CheckInRecord verified = checkInService.verifyCheckInRecord(id, verifierId, status, verificationNotes);
        return ResponseEntity.ok(ApiResponse.success(verified));
    }

    // ==================== 打卡记录查询 ====================

    @GetMapping("/records/{id}")
    @Operation(summary = "获取打卡记录详情", description = "根据ID获取打卡记录详情")
    public ResponseEntity<ApiResponse<CheckInRecord>> getCheckInRecordById(@PathVariable Long id) {
        CheckInRecord record = checkInService.getCheckInRecordById(id).orElse(null);
        return ResponseEntity.ok(ApiResponse.success(record));
    }

    @GetMapping("/records/user/{userId}")
    @Operation(summary = "获取用户打卡记录", description = "获取指定用户的打卡记录")
    public ResponseEntity<ApiResponse<List<CheckInRecord>>> getUserCheckInRecords(
            @PathVariable Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam(required = false) Long checkInId,
            @Parameter(description = "开始日期") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "结束日期") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        if (checkInId != null) {
            List<CheckInRecord> records = checkInService.getUserCheckInRecords(checkInId, userId);
            return ResponseEntity.ok(ApiResponse.success(records));
        } else {
            List<CheckInRecord> records = checkInService.getUserCheckInRecords(userId);
            return ResponseEntity.ok(ApiResponse.success(records));
        }
    }

    @GetMapping("/{checkInId}/records")
    @Operation(summary = "获取打卡活动记录", description = "获取指定打卡活动的所有记录")
    public ResponseEntity<ApiResponse<List<CheckInRecord>>> getCheckInRecords(
            @PathVariable Long checkInId,
            @Parameter(description = "状态") @RequestParam(required = false) String status,
            @Parameter(description = "开始日期") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "结束日期") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<CheckInRecord> records = checkInService.getCheckInRecords(checkInId);
        return ResponseEntity.ok(ApiResponse.success(records));
    }

    @GetMapping("/records/date/{date}")
    @Operation(summary = "按日期获取打卡记录", description = "获取指定日期的打卡记录")
    public ResponseEntity<ApiResponse<CheckInRecord>> getCheckInRecordsByDate(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @Parameter(description = "用户ID") @RequestParam Long userId) {
        CheckInRecord record = checkInService.getUserCheckInRecord(userId, date).orElse(null);
        return ResponseEntity.ok(ApiResponse.success(record));
    }

    @GetMapping("/records/date-range")
    @Operation(summary = "按日期范围获取打卡记录", description = "获取指定日期范围的打卡记录")
    public ResponseEntity<ApiResponse<List<CheckInRecord>>> getCheckInRecordsByDateRange(
            @Parameter(description = "开始日期") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "结束日期") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam(required = false) Long checkInId) {
        LocalDateTime startTime = startDate.atStartOfDay();
        LocalDateTime endTime = endDate.atTime(23, 59, 59);
        List<CheckInRecord> records = checkInService.getUserCheckInRecords(userId, startTime, endTime);
        return ResponseEntity.ok(ApiResponse.success(records));
    }

    @GetMapping("/records/pending-verification")
    @Operation(summary = "获取待验证记录", description = "获取待验证的打卡记录")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<CheckInRecord>>> getPendingVerificationRecords() {
        List<CheckInRecord> records = checkInService.getPendingVerificationRecords();
        return ResponseEntity.ok(ApiResponse.success(records));
    }

    // ==================== 连续打卡和统计 ====================

    @GetMapping("/user/{userId}/streak")
    @Operation(summary = "获取用户连续打卡天数", description = "获取用户当前连续打卡天数")
    public ResponseEntity<ApiResponse<Integer>> getUserCurrentStreak(
            @PathVariable Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam(required = false) Long checkInId) {
        Integer streak;
        if (checkInId != null) {
            streak = checkInService.getUserConsecutiveDays(checkInId, userId);
        } else {
            streak = checkInService.getUserCurrentConsecutiveDays(userId);
        }
        return ResponseEntity.ok(ApiResponse.success(streak));
    }

    @GetMapping("/user/{userId}/max-streak")
    @Operation(summary = "获取用户最高连续打卡天数", description = "获取用户历史最高连续打卡天数")
    public ResponseEntity<ApiResponse<Integer>> getUserMaxStreak(
            @PathVariable Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam(required = false) Long checkInId) {
        Integer maxStreak = checkInService.getUserMaxConsecutiveDays(userId);
        return ResponseEntity.ok(ApiResponse.success(maxStreak));
    }

    @GetMapping("/user/{userId}/statistics")
    @Operation(summary = "获取用户打卡统计", description = "获取用户的打卡统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserCheckInStatistics(
            @PathVariable Long userId) {
        Map<String, Object> statistics = checkInService.getUserCheckInStatistics(userId);
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    @GetMapping("/{checkInId}/statistics")
    @Operation(summary = "获取打卡活动统计", description = "获取打卡活动的统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getCheckInStatistics(
            @PathVariable Long checkInId) {
        Map<String, Object> statistics = checkInService.getCheckInStatistics(checkInId);
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    @GetMapping("/statistics/system")
    @Operation(summary = "获取系统统计", description = "获取整个打卡系统的统计信息")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSystemStatistics() {
        Map<String, Object> statistics = checkInService.getSystemCheckInStatistics();
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    // ==================== 排行榜 ====================

    @GetMapping("/{checkInId}/leaderboard")
    @Operation(summary = "获取打卡活动排行榜", description = "获取打卡活动的排行榜")
    public ResponseEntity<ApiResponse<List<CheckInRecord>>> getCheckInLeaderboard(
            @PathVariable Long checkInId,
            @Parameter(description = "排行榜类型") @RequestParam(defaultValue = "streak") String type,
            @Parameter(description = "排行榜数量") @RequestParam(defaultValue = "10") int limit) {
        List<CheckInRecord> leaderboard = checkInService.getCheckInLeaderboard(checkInId, limit);
        return ResponseEntity.ok(ApiResponse.success(leaderboard));
    }

    @GetMapping("/leaderboard/points")
    @Operation(summary = "获取积分排行榜", description = "获取全局积分排行榜")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getPointsLeaderboard(
            @Parameter(description = "打卡活动ID") @RequestParam Long checkInId,
            @Parameter(description = "排行榜数量") @RequestParam(defaultValue = "10") int limit) {
        List<Map<String, Object>> leaderboard = checkInService.getCheckInPointsLeaderboard(checkInId, limit);
        return ResponseEntity.ok(ApiResponse.success(leaderboard));
    }

    @GetMapping("/leaderboard/study-time")
    @Operation(summary = "获取学习时长排行榜", description = "获取学习时长排行榜")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getStudyTimeLeaderboard(
            @Parameter(description = "打卡活动ID") @RequestParam Long checkInId,
            @Parameter(description = "排行榜数量") @RequestParam(defaultValue = "10") int limit) {
        List<Map<String, Object>> leaderboard = checkInService.getCheckInStudyDurationLeaderboard(checkInId, limit);
        return ResponseEntity.ok(ApiResponse.success(leaderboard));
    }

    @GetMapping("/leaderboard/streak")
    @Operation(summary = "获取连续打卡排行榜", description = "获取全局连续打卡排行榜")
    public ResponseEntity<ApiResponse<List<CheckInRecord>>> getGlobalStreakLeaderboard(
            @Parameter(description = "排行榜数量") @RequestParam(defaultValue = "10") int limit) {
        List<CheckInRecord> leaderboard = checkInService.getGlobalConsecutiveLeaderboard(limit);
        return ResponseEntity.ok(ApiResponse.success(leaderboard));
    }

    @GetMapping("/user/{userId}/ranking")
    @Operation(summary = "获取用户排名", description = "获取用户在各种排行榜中的排名")
    public ResponseEntity<ApiResponse<Long>> getUserRanking(
            @PathVariable Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam Long checkInId) {
        Long ranking = checkInService.getUserRankingInCheckIn(checkInId, userId);
        return ResponseEntity.ok(ApiResponse.success(ranking));
    }

    // ==================== 积分和奖励 ====================

    @PostMapping("/{checkInId}/calculate-points")
    @Operation(summary = "计算积分", description = "计算打卡活动的积分")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<String>> calculatePoints(
            @PathVariable Long checkInId,
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Parameter(description = "连续天数") @RequestParam Integer consecutiveDays,
            @Parameter(description = "学习时长") @RequestParam Integer studyDuration) {
        Integer points = checkInService.calculateCheckInReward(checkInId, userId, consecutiveDays, studyDuration);
        return ResponseEntity.ok(ApiResponse.success("计算完成，积分: " + points));
    }

    @PostMapping("/records/{recordId}/distribute-rewards")
    @Operation(summary = "发放奖励", description = "发放打卡记录奖励")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> distributeRewards(
            @PathVariable Long recordId) {
        checkInService.distributeCheckInReward(recordId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/user/{userId}/total-points")
    @Operation(summary = "获取用户总积分", description = "获取用户在所有打卡活动中的总积分")
    public ResponseEntity<ApiResponse<Long>> getUserTotalPoints(
            @PathVariable Long userId) {
        Long totalPoints = checkInService.getUserTotalCheckInPoints(userId);
        return ResponseEntity.ok(ApiResponse.success(totalPoints));
    }

    // ==================== 数据分析 ====================

    @GetMapping("/user/{userId}/behavior-analysis")
    @Operation(summary = "用户行为分析", description = "分析用户的打卡行为")
    public ResponseEntity<ApiResponse<Map<String, Object>>> analyzeUserBehavior(
            @PathVariable Long userId) {
        // TODO: 实现用户行为分析功能
        Map<String, Object> analysis = Map.of();
        return ResponseEntity.ok(ApiResponse.success(analysis));
    }

    @GetMapping("/{checkInId}/performance-analysis")
    @Operation(summary = "打卡活动表现分析", description = "分析打卡活动的表现数据")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> analyzeCheckInPerformance(
            @PathVariable Long checkInId) {
        // TODO: 实现打卡活动表现分析功能
        Map<String, Object> analysis = Map.of();
        return ResponseEntity.ok(ApiResponse.success(analysis));
    }

    @GetMapping("/trends/checkin")
    @Operation(summary = "打卡趋势分析", description = "分析打卡的趋势")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> analyzeCheckInTrend(
            @Parameter(description = "开始时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        // TODO: 实现打卡趋势分析功能
        Map<String, Object> trend = Map.of();
        return ResponseEntity.ok(ApiResponse.success(trend));
    }

    @GetMapping("/predictions")
    @Operation(summary = "打卡预测", description = "预测用户的打卡行为")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> predictCheckInBehavior(
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Parameter(description = "预测天数") @RequestParam(defaultValue = "7") int days) {
        // TODO: 实现用户行为预测功能
        Map<String, Object> prediction = Map.of();
        return ResponseEntity.ok(ApiResponse.success(prediction));
    }

    // ==================== 系统管理 ====================

    @PostMapping("/update-statuses")
    @Operation(summary = "更新打卡活动状态", description = "批量更新打卡活动状态")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> updateCheckInStatuses() {
        checkInService.updateCheckInStatuses();
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/cleanup")
    @Operation(summary = "清理数据", description = "清理过期的打卡数据")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> cleanupExpiredData() {
        checkInService.cleanupExpiredData();
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/generate-report")
    @Operation(summary = "生成报告", description = "生成打卡报告")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<String>> generateReport(
            @Parameter(description = "报告类型") @RequestParam String reportType,
            @Parameter(description = "开始时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        // TODO: 实现报告生成功能
        String report = "";
        return ResponseEntity.ok(ApiResponse.success(report));
    }

    @PostMapping("/export")
    @Operation(summary = "导出数据", description = "导出打卡数据")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<String>> exportData(
            @Parameter(description = "导出格式") @RequestParam String format,
            @Parameter(description = "打卡活动ID列表") @RequestParam List<Long> checkInIds) {
        // TODO: 实现数据导出功能
        String exportResult = "";
        return ResponseEntity.ok(ApiResponse.success(exportResult));
    }

    @PostMapping("/batch-update")
    @Operation(summary = "批量更新", description = "批量更新打卡活动")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> batchUpdateCheckIns(
            @Parameter(description = "打卡活动ID列表") @RequestParam List<Long> checkInIds,
            @Parameter(description = "更新数据") @RequestBody Map<String, Object> updates) {
        checkInService.batchUpdateCheckIns(checkInIds, updates);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/health")
    @Operation(summary = "系统健康状态", description = "获取打卡系统的健康状态")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSystemHealth() {
        Map<String, Object> health = checkInService.getSystemHealth();
        return ResponseEntity.ok(ApiResponse.success(health));
    }

    @PostMapping("/optimize-performance")
    @Operation(summary = "性能优化", description = "执行系统性能优化")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> optimizePerformance() {
        checkInService.optimizePerformance();
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ==================== 通知和提醒 ====================

    @PostMapping("/user/{userId}/remind")
    @Operation(summary = "发送打卡提醒", description = "向用户发送打卡提醒")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> sendCheckInReminder(
            @PathVariable Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam(required = false) Long checkInId) {
        // TODO: 实现发送打卡提醒功能
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/user/{userId}/notify-reward")
    @Operation(summary = "发送奖励通知", description = "通知用户获得奖励")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifyReward(
            @PathVariable Long userId,
            @Parameter(description = "奖励积分") @RequestParam Integer points,
            @Parameter(description = "奖励原因") @RequestParam String reason) {
        // TODO: 实现奖励通知功能
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/{checkInId}/notify-start")
    @Operation(summary = "发送活动开始通知", description = "通知用户打卡活动开始")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifyCheckInStart(
            @PathVariable Long checkInId) {
        // TODO: 实现活动开始通知功能
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/{checkInId}/notify-end")
    @Operation(summary = "发送活动结束通知", description = "通知用户打卡活动结束")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifyCheckInEnd(
            @PathVariable Long checkInId) {
        // TODO: 实现活动结束通知功能
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/user/{userId}/notify-ranking-change")
    @Operation(summary = "发送排名变化通知", description = "通知用户排名变化")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifyRankingChange(
            @PathVariable Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam Long checkInId,
            @Parameter(description = "新排名") @RequestParam Integer newRank) {
        // TODO: 实现排名变化通知功能
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ==================== 补签管理 ====================

    @GetMapping("/user/{userId}/can-makeup")
    @Operation(summary = "检查是否可以补签", description = "检查用户是否可以进行补签")
    public ResponseEntity<ApiResponse<Boolean>> canMakeupCheckIn(
            @PathVariable Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam Long checkInId,
            @Parameter(description = "补签日期") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Boolean canMakeup = checkInService.canMakeupCheckIn(userId, checkInId, date);
        return ResponseEntity.ok(ApiResponse.success(canMakeup));
    }

    @GetMapping("/makeup-cost")
    @Operation(summary = "计算补签费用", description = "计算补签所需的费用")
    public ResponseEntity<ApiResponse<Integer>> calculateMakeupCost(
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Parameter(description = "打卡活动ID") @RequestParam Long checkInId,
            @Parameter(description = "补签日期") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        // TODO: 实现计算补签费用功能
        Integer cost = 0;
        return ResponseEntity.ok(ApiResponse.success(cost));
    }

    @GetMapping("/user/{userId}/makeup-records")
    @Operation(summary = "获取用户补签记录", description = "获取用户的补签记录")
    public ResponseEntity<ApiResponse<List<CheckInRecord>>> getUserMakeupRecords(
            @PathVariable Long userId) {
        List<CheckInRecord> records = checkInService.getUserMakeupRecords(userId);
        return ResponseEntity.ok(ApiResponse.success(records));
    }

    @GetMapping("/{checkInId}/makeup-records")
    @Operation(summary = "获取打卡活动补签记录", description = "获取打卡活动的补签记录")
    public ResponseEntity<ApiResponse<List<CheckInRecord>>> getCheckInMakeupRecords(
            @PathVariable Long checkInId) {
        List<CheckInRecord> records = checkInService.getCheckInMakeupRecords(checkInId);
        return ResponseEntity.ok(ApiResponse.success(records));
    }

    // ==================== 验证管理 ====================

    @PostMapping("/records/batch-verify")
    @Operation(summary = "批量验证记录", description = "批量验证打卡记录")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> batchVerifyRecords(
            @Parameter(description = "记录ID列表") @RequestParam List<Long> recordIds,
            @Parameter(description = "验证状态") @RequestParam CheckInRecord.VerificationStatus status) {
        // TODO: 实现批量验证记录功能
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/auto-verify")
    @Operation(summary = "自动验证", description = "自动验证符合条件的打卡记录")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Integer>> autoVerifyRecords() {
        // TODO: 实现自动验证记录功能
        Integer verifiedCount = 0;
        return ResponseEntity.ok(ApiResponse.success(verifiedCount));
    }

    @GetMapping("/verification-statistics")
    @Operation(summary = "验证统计", description = "获取验证相关的统计信息")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getVerificationStatistics() {
        // TODO: 实现验证统计功能
        Map<String, Object> statistics = Map.of();
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }
}