package com.nanqipro.controller;

import com.nanqipro.common.ApiResponse;
import com.nanqipro.entity.Challenge;
import com.nanqipro.entity.ChallengeParticipation;
import com.nanqipro.service.ChallengeService;
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

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 挑战赛控制器
 * 提供挑战赛相关的REST API接口
 */
@RestController
@RequestMapping("/api/challenges")
@RequiredArgsConstructor
@Tag(name = "挑战赛管理", description = "挑战赛相关API")
public class ChallengeController {

    private final ChallengeService challengeService;

    // ==================== 挑战赛管理 ====================

    @PostMapping
    @Operation(summary = "创建挑战赛", description = "创建新的挑战赛")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Challenge>> createChallenge(
            @Valid @RequestBody Challenge challenge) {
        Challenge created = challengeService.createChallenge(challenge);
        return ResponseEntity.ok(ApiResponse.success(created));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新挑战赛", description = "更新挑战赛信息")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Challenge>> updateChallenge(
            @PathVariable Long id,
            @Valid @RequestBody Challenge challenge) {
        Challenge updated = challengeService.updateChallenge(id, challenge);
        return ResponseEntity.ok(ApiResponse.success(updated));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除挑战赛", description = "删除指定的挑战赛")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteChallenge(@PathVariable Long id) {
        challengeService.deleteChallenge(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/{id}/publish")
    @Operation(summary = "发布挑战赛", description = "发布挑战赛，使其可见")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Challenge>> publishChallenge(@PathVariable Long id) {
        Challenge published = challengeService.publishChallenge(id);
        return ResponseEntity.ok(ApiResponse.success(published));
    }

    @PostMapping("/{id}/start")
    @Operation(summary = "开始挑战赛", description = "开始挑战赛")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Challenge>> startChallenge(@PathVariable Long id) {
        Challenge started = challengeService.startChallenge(id);
        return ResponseEntity.ok(ApiResponse.success(started));
    }

    @PostMapping("/{id}/complete")
    @Operation(summary = "完成挑战赛", description = "完成挑战赛")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Challenge>> completeChallenge(@PathVariable Long id) {
        Challenge completed = challengeService.completeChallenge(id);
        return ResponseEntity.ok(ApiResponse.success(completed));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "取消挑战赛", description = "取消挑战赛")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Challenge>> cancelChallenge(@PathVariable Long id) {
        Challenge cancelled = challengeService.cancelChallenge(id);
        return ResponseEntity.ok(ApiResponse.success(cancelled));
    }

    @PostMapping("/{id}/pause")
    @Operation(summary = "暂停挑战赛", description = "暂停挑战赛")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Challenge>> pauseChallenge(@PathVariable Long id) {
        Challenge paused = challengeService.pauseChallenge(id);
        return ResponseEntity.ok(ApiResponse.success(paused));
    }

    @PostMapping("/{id}/resume")
    @Operation(summary = "恢复挑战赛", description = "恢复暂停的挑战赛")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Challenge>> resumeChallenge(@PathVariable Long id) {
        Challenge resumed = challengeService.resumeChallenge(id);
        return ResponseEntity.ok(ApiResponse.success(resumed));
    }

    // ==================== 挑战赛查询 ====================

    @GetMapping("/{id}")
    @Operation(summary = "获取挑战赛详情", description = "根据ID获取挑战赛详情")
    public ResponseEntity<ApiResponse<Challenge>> getChallengeById(@PathVariable Long id) {
        Challenge challenge = challengeService.getChallengeById(id).orElse(null);
        return ResponseEntity.ok(ApiResponse.success(challenge));
    }

    @GetMapping
    @Operation(summary = "分页查询挑战赛", description = "分页查询挑战赛列表")
    public ResponseEntity<ApiResponse<Page<Challenge>>> getChallenges(
            @Parameter(description = "状态") @RequestParam(required = false) Challenge.ChallengeStatus status,
            @Parameter(description = "类型") @RequestParam(required = false) Challenge.ChallengeType type,
            @Parameter(description = "难度") @RequestParam(required = false) String difficulty,
            @Parameter(description = "关键词") @RequestParam(required = false) String keyword,
            Pageable pageable) {
        Page<Challenge> challenges = challengeService.searchChallenges(
                type, Challenge.DifficultyLevel.valueOf(difficulty != null ? difficulty : "BEGINNER"), status, pageable);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "按状态查询挑战赛", description = "根据状态查询挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getChallengesByStatus(
            @PathVariable Challenge.ChallengeStatus status) {
        List<Challenge> challenges = challengeService.getChallengesByStatus(status);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/type/{type}")
    @Operation(summary = "按类型查询挑战赛", description = "根据类型查询挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getChallengesByType(
            @PathVariable Challenge.ChallengeType type) {
        List<Challenge> challenges = challengeService.getChallengesByType(type);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/difficulty/{difficulty}")
    @Operation(summary = "按难度查询挑战赛", description = "根据难度查询挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getChallengesByDifficulty(
            @PathVariable String difficulty) {
        List<Challenge> challenges = challengeService.getChallengesByDifficulty(
                Challenge.DifficultyLevel.valueOf(difficulty));
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/active")
    @Operation(summary = "获取活跃挑战赛", description = "获取当前活跃的挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getActiveChallenges() {
        List<Challenge> challenges = challengeService.getActiveChallenges();
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/popular")
    @Operation(summary = "获取热门挑战赛", description = "获取热门挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getPopularChallenges(
            @Parameter(description = "数量限制") @RequestParam(defaultValue = "10") int limit) {
        List<Challenge> challenges = challengeService.getPopularChallenges(limit);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/latest")
    @Operation(summary = "获取最新挑战赛", description = "获取最新的挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getLatestChallenges(
            @Parameter(description = "数量限制") @RequestParam(defaultValue = "10") int limit) {
        List<Challenge> challenges = challengeService.getLatestChallenges(limit);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/search")
    @Operation(summary = "搜索挑战赛", description = "根据关键词搜索挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> searchChallenges(
            @Parameter(description = "搜索关键词") @RequestParam String keyword) {
        List<Challenge> challenges = challengeService.searchChallenges(keyword);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    // ==================== 用户相关 ====================

    @GetMapping("/user/{userId}/created")
    @Operation(summary = "获取用户创建的挑战赛", description = "获取指定用户创建的挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getUserCreatedChallenges(
            @PathVariable Long userId) {
        List<Challenge> challenges = challengeService.getUserCreatedChallenges(userId);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/user/{userId}/participated")
    @Operation(summary = "获取用户参与的挑战赛", description = "获取指定用户参与的挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getUserParticipatedChallenges(
            @PathVariable Long userId) {
        List<Challenge> challenges = challengeService.getUserParticipatedChallenges(userId);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/user/{userId}/active")
    @Operation(summary = "获取用户活跃挑战赛", description = "获取用户当前活跃参与的挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getUserActiveChallenges(
            @PathVariable Long userId) {
        List<Challenge> challenges = challengeService.getUserActiveChallenges(userId);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/user/{userId}/completed")
    @Operation(summary = "获取用户完成的挑战赛", description = "获取用户已完成的挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getUserCompletedChallenges(
            @PathVariable Long userId) {
        List<Challenge> challenges = challengeService.getUserCompletedChallenges(userId);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/user/{userId}/recommendations")
    @Operation(summary = "获取用户推荐挑战赛", description = "为用户推荐合适的挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getRecommendedChallenges(
            @PathVariable Long userId,
            @Parameter(description = "推荐数量") @RequestParam(defaultValue = "5") int limit) {
        List<Challenge> challenges = challengeService.getRecommendedChallenges(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    @GetMapping("/user/{userId}/suggestions")
    @Operation(summary = "获取用户建议挑战赛", description = "为用户建议挑战赛")
    public ResponseEntity<ApiResponse<List<Challenge>>> getSuggestedChallenges(
            @PathVariable Long userId,
            @Parameter(description = "建议数量") @RequestParam(defaultValue = "5") int limit) {
        List<Challenge> challenges = challengeService.getSuggestedChallenges(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(challenges));
    }

    // ==================== 参与管理 ====================

    @PostMapping("/{challengeId}/join")
    @Operation(summary = "加入挑战赛", description = "用户加入挑战赛")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<ChallengeParticipation>> joinChallenge(
            @PathVariable Long challengeId,
            @Parameter(description = "用户ID") @RequestParam Long userId) {
        ChallengeParticipation participation = challengeService.joinChallenge(challengeId, userId);
        return ResponseEntity.ok(ApiResponse.success(participation));
    }

    @PostMapping("/{challengeId}/leave")
    @Operation(summary = "退出挑战赛", description = "用户退出挑战赛")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Void>> leaveChallenge(
            @PathVariable Long challengeId,
            @Parameter(description = "用户ID") @RequestParam Long userId) {
        challengeService.leaveChallenge(challengeId, userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PutMapping("/{challengeId}/progress")
    @Operation(summary = "更新参与进度", description = "更新用户在挑战赛中的进度")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<ChallengeParticipation>> updateParticipationProgress(
            @PathVariable Long challengeId,
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Parameter(description = "进度") @RequestParam Integer progress) {
        // Note: This requires getting participation ID first
        // For now, using a placeholder implementation
        ChallengeParticipation participation = null; // TODO: Implement proper participation update
        return ResponseEntity.ok(ApiResponse.success(participation));
    }

    @PostMapping("/{challengeId}/complete")
    @Operation(summary = "完成挑战赛参与", description = "标记用户完成挑战赛")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<ChallengeParticipation>> completeParticipation(
            @PathVariable Long challengeId,
            @Parameter(description = "用户ID") @RequestParam Long userId) {
        ChallengeParticipation participation = challengeService.completeParticipation(challengeId);
        return ResponseEntity.ok(ApiResponse.success(participation));
    }

    @PostMapping("/{challengeId}/abandon")
    @Operation(summary = "放弃挑战赛", description = "用户放弃挑战赛")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Void>> abandonParticipation(
            @PathVariable Long challengeId,
            @Parameter(description = "用户ID") @RequestParam Long userId) {
        challengeService.abandonParticipation(challengeId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ==================== 排行榜和统计 ====================

    @GetMapping("/{challengeId}/leaderboard")
    @Operation(summary = "获取挑战赛排行榜", description = "获取挑战赛的排行榜")
    public ResponseEntity<ApiResponse<List<ChallengeParticipation>>> getChallengeLeaderboard(
            @PathVariable Long challengeId,
            @Parameter(description = "排行榜数量") @RequestParam(defaultValue = "10") int limit) {
        List<ChallengeParticipation> leaderboard = challengeService.getChallengeLeaderboard(
                challengeId, limit);
        return ResponseEntity.ok(ApiResponse.success(leaderboard));
    }

    @GetMapping("/user/{userId}/ranking")
    @Operation(summary = "获取用户排名", description = "获取用户在挑战赛中的排名")
    public ResponseEntity<ApiResponse<Long>> getUserRanking(
            @PathVariable Long userId,
            @Parameter(description = "挑战赛ID") @RequestParam Long challengeId) {
        Long ranking = challengeService.getUserRankingInChallenge(challengeId, userId);
        return ResponseEntity.ok(ApiResponse.success(ranking));
    }

    @GetMapping("/user/{userId}/best-performance")
    @Operation(summary = "获取用户最佳表现", description = "获取用户的最佳挑战赛表现")
    public ResponseEntity<ApiResponse<ChallengeParticipation>> getUserBestPerformance(
            @PathVariable Long userId) {
        List<ChallengeParticipation> bestPerformances = challengeService.getUserBestPerformances(userId, 1);
        ChallengeParticipation bestPerformance = bestPerformances.isEmpty() ? null : bestPerformances.get(0);
        return ResponseEntity.ok(ApiResponse.success(bestPerformance));
    }

    @GetMapping("/{challengeId}/statistics")
    @Operation(summary = "获取挑战赛统计", description = "获取挑战赛的统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getChallengeStatistics(
            @PathVariable Long challengeId) {
        Map<String, Object> statistics = challengeService.getChallengeStatistics(challengeId);
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    @GetMapping("/user/{userId}/statistics")
    @Operation(summary = "获取用户统计", description = "获取用户的挑战赛统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserStatistics(
            @PathVariable Long userId) {
        Map<String, Object> statistics = challengeService.getUserChallengeStatistics(userId);
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    @GetMapping("/statistics/system")
    @Operation(summary = "获取系统统计", description = "获取整个挑战赛系统的统计信息")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSystemStatistics() {
        Map<String, Object> statistics = challengeService.getSystemChallengeStatistics();
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }

    // ==================== 奖励和积分 ====================

    @PostMapping("/{challengeId}/calculate-rewards")
    @Operation(summary = "计算奖励", description = "计算挑战赛的奖励")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<Long, Integer>>> calculateRewards(
            @PathVariable Long challengeId) {
        // Note: This method calculates for single user, need to implement batch calculation
        Map<Long, Integer> rewards = Map.of(); // TODO: Implement batch reward calculation
        return ResponseEntity.ok(ApiResponse.success(rewards));
    }

    @PostMapping("/{challengeId}/distribute-rewards")
    @Operation(summary = "发放奖励", description = "发放挑战赛奖励")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> distributeRewards(
            @PathVariable Long challengeId) {
        challengeService.distributeChallengeRewards(challengeId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/user/{userId}/total-points")
    @Operation(summary = "获取用户总积分", description = "获取用户在所有挑战赛中的总积分")
    public ResponseEntity<ApiResponse<Long>> getUserTotalPoints(
            @PathVariable Long userId) {
        Long totalPoints = challengeService.getUserTotalRewardPoints(userId);
        return ResponseEntity.ok(ApiResponse.success(totalPoints));
    }

    // ==================== 数据分析 ====================

    @GetMapping("/{challengeId}/performance-analysis")
    @Operation(summary = "挑战赛表现分析", description = "分析挑战赛的表现数据")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> analyzeChallengePerformance(
            @PathVariable Long challengeId) {
        Map<String, Object> analysis = challengeService.analyzeChallengePerformance(challengeId);
        return ResponseEntity.ok(ApiResponse.success(analysis));
    }

    @GetMapping("/user/{userId}/performance-analysis")
    @Operation(summary = "用户表现分析", description = "分析用户的挑战赛表现")
    public ResponseEntity<ApiResponse<Map<String, Object>>> analyzeUserPerformance(
            @PathVariable Long userId) {
        Map<String, Object> analysis = challengeService.analyzeUserChallengePerformance(userId);
        return ResponseEntity.ok(ApiResponse.success(analysis));
    }

    @GetMapping("/trends")
    @Operation(summary = "挑战赛趋势分析", description = "分析挑战赛的趋势")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> analyzeChallengesTrend(
            @Parameter(description = "开始时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        Map<String, Object> trend = challengeService.getChallengeTrendAnalysis(startTime, endTime);
        return ResponseEntity.ok(ApiResponse.success(trend));
    }

    @GetMapping("/user-participation-trends")
    @Operation(summary = "用户参与趋势分析", description = "分析用户参与挑战赛的趋势")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> analyzeUserParticipationTrend(
            @Parameter(description = "开始时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        Map<String, Object> trend = challengeService.getUserParticipationTrend(null, startTime, endTime); // TODO: Add userId parameter
        return ResponseEntity.ok(ApiResponse.success(trend));
    }

    // ==================== 系统管理 ====================

    @PostMapping("/update-statuses")
    @Operation(summary = "更新挑战赛状态", description = "批量更新挑战赛状态")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> updateChallengeStatuses() {
        challengeService.updateChallengeStatuses();
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/update-rankings")
    @Operation(summary = "更新排名", description = "更新所有挑战赛的排名")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> updateRankings() {
        // Note: This would need to update all challenges
        // challengeService.updateParticipantRankings(challengeId); // TODO: Implement for all challenges
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/cleanup")
    @Operation(summary = "清理数据", description = "清理过期的挑战赛数据")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> cleanupExpiredData() {
        challengeService.cleanupExpiredData();
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/generate-report")
    @Operation(summary = "生成报告", description = "生成挑战赛报告")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<String>> generateReport(
            @Parameter(description = "报告类型") @RequestParam String reportType,
            @Parameter(description = "开始时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        // Note: Service method generates different format
        Map<String, Object> reportData = challengeService.generateChallengeReport(null); // TODO: Implement proper report generation
        String report = reportData.toString();
        return ResponseEntity.ok(ApiResponse.success(report));
    }

    @PostMapping("/export")
    @Operation(summary = "导出数据", description = "导出挑战赛数据")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<String>> exportData(
            @Parameter(description = "导出格式") @RequestParam String format,
            @Parameter(description = "挑战赛ID列表") @RequestParam List<Long> challengeIds) {
        // Note: Service method exports single challenge
        String exportResult = "Export completed"; // TODO: Implement batch export
        return ResponseEntity.ok(ApiResponse.success(exportResult));
    }

    @PostMapping("/batch-update")
    @Operation(summary = "批量更新", description = "批量更新挑战赛")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> batchUpdateChallenges(
            @Parameter(description = "挑战赛ID列表") @RequestParam List<Long> challengeIds,
            @Parameter(description = "更新操作") @RequestParam String operation) {
        challengeService.batchUpdateChallenges(challengeIds, Map.of("operation", operation));
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ==================== 通知和提醒 ====================

    @PostMapping("/{challengeId}/notify-start")
    @Operation(summary = "发送开始通知", description = "通知用户挑战赛开始")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifyChallengeStart(
            @PathVariable Long challengeId) {
        challengeService.sendChallengeStartNotification(challengeId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/{challengeId}/notify-end")
    @Operation(summary = "发送结束通知", description = "通知用户挑战赛结束")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifyChallengeEnd(
            @PathVariable Long challengeId) {
        challengeService.sendChallengeEndNotification(challengeId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/{challengeId}/notify-ranking-change")
    @Operation(summary = "发送排名变化通知", description = "通知用户排名变化")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifyRankingChange(
            @PathVariable Long challengeId,
            @Parameter(description = "用户ID") @RequestParam Long userId) {
        challengeService.sendRankingChangeNotification(challengeId, userId, null, null); // TODO: Add old/new rank parameters
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/{challengeId}/notify-reward")
    @Operation(summary = "发送奖励通知", description = "通知用户获得奖励")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifyReward(
            @PathVariable Long challengeId,
            @Parameter(description = "用户ID") @RequestParam Long userId,
            @Parameter(description = "奖励积分") @RequestParam Integer points) {
        challengeService.sendRewardNotification(userId, points, "Challenge completion reward");
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}