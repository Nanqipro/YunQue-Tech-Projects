package com.nanqipro.controller;

import com.nanqipro.common.ApiResponse;
import com.nanqipro.entity.StudySession;
import com.nanqipro.service.StudySessionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 学习会话控制器
 */
@Tag(name = "学习会话管理", description = "学习会话相关接口")
@RestController
@RequestMapping("/api/learning/sessions")
@RequiredArgsConstructor
public class StudySessionController {
    
    private final StudySessionService studySessionService;
    
    // ==================== 会话管理 ====================
    
    @PostMapping("/start")
    @Operation(summary = "开始学习会话", description = "开始一个新的学习会话")
    public ResponseEntity<ApiResponse<StudySession>> startSession(
            @RequestParam StudySession.SessionType sessionType,
            @RequestParam(required = false) String deviceType,
            @RequestParam(required = false) String platform,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        StudySession session = studySessionService.startSession(userId, sessionType, deviceType, platform);
        return ResponseEntity.ok(ApiResponse.success(session));
    }
    
    @PostMapping("/{sessionId}/end")
    @Operation(summary = "结束学习会话", description = "结束指定的学习会话")
    public ResponseEntity<ApiResponse<StudySession>> endSession(
            @PathVariable Long sessionId,
            @RequestParam(required = false) String sessionNotes,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        StudySession session = studySessionService.endSession(sessionId, sessionNotes);
        return ResponseEntity.ok(ApiResponse.success(session));
    }
    
    @PostMapping("/{sessionId}/pause")
    @Operation(summary = "暂停学习会话", description = "暂停指定的学习会话")
    public ResponseEntity<ApiResponse<StudySession>> pauseSession(
            @PathVariable Long sessionId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        StudySession session = studySessionService.pauseSession(sessionId);
        return ResponseEntity.ok(ApiResponse.success(session));
    }
    
    @PostMapping("/{sessionId}/resume")
    @Operation(summary = "恢复学习会话", description = "恢复暂停的学习会话")
    public ResponseEntity<ApiResponse<StudySession>> resumeSession(
            @PathVariable Long sessionId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        StudySession session = studySessionService.resumeSession(sessionId);
        return ResponseEntity.ok(ApiResponse.success(session));
    }
    
    @PostMapping("/{sessionId}/abandon")
    @Operation(summary = "放弃学习会话", description = "放弃指定的学习会话")
    public ResponseEntity<ApiResponse<StudySession>> abandonSession(
            @PathVariable Long sessionId,
            @RequestParam(required = false) String reason,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        StudySession session = studySessionService.abandonSession(sessionId, reason);
        return ResponseEntity.ok(ApiResponse.success(session));
    }
    
    @PostMapping("/{sessionId}/progress")
    @Operation(summary = "更新会话进度", description = "更新学习会话的进度信息")
    public ResponseEntity<ApiResponse<StudySession>> updateSessionProgress(
            @PathVariable Long sessionId,
            @RequestParam(required = false) Integer wordsStudied,
            @RequestParam(required = false) Integer wordsMastered,
            @RequestParam(required = false) Integer articlesRead,
            @RequestParam(required = false) Integer questionsAnswered,
            @RequestParam(required = false) Integer questionsCorrect,
            @RequestParam(required = false) Integer pointsEarned,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        StudySession session = studySessionService.updateSessionProgress(
            sessionId, wordsStudied, wordsMastered, articlesRead, 
            questionsAnswered, questionsCorrect, pointsEarned);
        return ResponseEntity.ok(ApiResponse.success(session));
    }
    
    @GetMapping("/current")
    @Operation(summary = "获取当前活跃会话", description = "获取用户当前的活跃学习会话")
    public ResponseEntity<ApiResponse<StudySession>> getCurrentActiveSession(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        StudySession session = studySessionService.getCurrentActiveSession(userId);
        return ResponseEntity.ok(ApiResponse.success(session));
    }
    
    @GetMapping("/{sessionId}")
    @Operation(summary = "获取会话详情", description = "获取指定学习会话的详细信息")
    public ResponseEntity<ApiResponse<StudySession>> getSessionById(
            @PathVariable Long sessionId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        StudySession session = studySessionService.getSessionById(sessionId);
        return ResponseEntity.ok(ApiResponse.success(session));
    }
    
    // ==================== 会话查询 ====================
    
    @GetMapping("/history")
    @Operation(summary = "获取学习会话历史", description = "获取用户的学习会话历史记录")
    public ResponseEntity<ApiResponse<Page<StudySession>>> getUserSessionHistory(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "startTime") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Sort sort = Sort.by(Sort.Direction.fromString(sortDir), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<StudySession> sessions = studySessionService.getUserSessionHistory(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(sessions));
    }
    
    @GetMapping("/by-type")
    @Operation(summary = "按类型获取学习会话", description = "根据会话类型获取用户的学习会话")
    public ResponseEntity<ApiResponse<Page<StudySession>>> getUserSessionsByType(
            @RequestParam StudySession.SessionType sessionType,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "startTime"));
        
        Page<StudySession> sessions = studySessionService.getUserSessionsByType(userId, sessionType, pageable);
        return ResponseEntity.ok(ApiResponse.success(sessions));
    }
    
    @GetMapping("/period")
    @Operation(summary = "按时间段获取学习会话", description = "根据时间范围获取用户的学习会话")
    public ResponseEntity<ApiResponse<Page<StudySession>>> getUserSessionsInPeriod(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "startTime"));
        
        Page<StudySession> sessions = studySessionService.getUserSessionsInPeriod(userId, startTime, endTime, pageable);
        return ResponseEntity.ok(ApiResponse.success(sessions));
    }
    
    // ==================== 学习统计 ====================
    
    @GetMapping("/statistics")
    @Operation(summary = "获取学习统计", description = "获取用户的整体学习统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserLearningStatistics(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> statistics = studySessionService.getUserLearningStatistics(userId);
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }
    
    @GetMapping("/statistics/period")
    @Operation(summary = "获取时间段学习统计", description = "获取用户指定时间段的学习统计")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserLearningStatisticsInPeriod(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> statistics = studySessionService.getUserLearningStatisticsInPeriod(userId, startTime, endTime);
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }
    
    @GetMapping("/statistics/daily")
    @Operation(summary = "获取每日学习统计", description = "获取用户的每日学习统计数据")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getUserDailyStatistics(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        List<Map<String, Object>> dailyStats = studySessionService.getUserDailyStatistics(userId, startTime, endTime);
        return ResponseEntity.ok(ApiResponse.success(dailyStats));
    }
    
    @GetMapping("/statistics/session-types")
    @Operation(summary = "获取学习类型统计", description = "获取用户的学习类型统计数据")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getUserSessionTypeStatistics(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        List<Map<String, Object>> typeStats = studySessionService.getUserSessionTypeStatistics(userId, startTime, endTime);
        return ResponseEntity.ok(ApiResponse.success(typeStats));
    }
    
    @GetMapping("/statistics/achievements")
    @Operation(summary = "获取学习成就统计", description = "获取用户的学习成就统计数据")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserAchievementStatistics(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> achievements = studySessionService.getUserAchievementStatistics(userId);
        return ResponseEntity.ok(ApiResponse.success(achievements));
    }
    
    @GetMapping("/statistics/continuous-days")
    @Operation(summary = "获取连续学习天数", description = "获取用户的连续学习天数")
    public ResponseEntity<ApiResponse<Integer>> getUserContinuousStudyDays(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Integer continuousDays = studySessionService.getUserContinuousStudyDays(userId);
        return ResponseEntity.ok(ApiResponse.success(continuousDays));
    }
    
    @GetMapping("/ranking")
    @Operation(summary = "获取排行榜数据", description = "获取用户在排行榜中的数据")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserRankingData(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> ranking = studySessionService.getUserRankingData(userId);
        return ResponseEntity.ok(ApiResponse.success(ranking));
    }
    
    // ==================== 学习分析 ====================
    
    @GetMapping("/analysis/pattern")
    @Operation(summary = "分析学习模式", description = "分析用户的学习模式和习惯")
    public ResponseEntity<ApiResponse<Map<String, Object>>> analyzeUserLearningPattern(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> pattern = studySessionService.analyzeUserLearningPattern(userId);
        return ResponseEntity.ok(ApiResponse.success(pattern));
    }
    
    @GetMapping("/recommendations")
    @Operation(summary = "获取学习建议", description = "基于学习数据获取个性化学习建议")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserLearningRecommendations(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> recommendations = studySessionService.getUserLearningRecommendations(userId);
        return ResponseEntity.ok(ApiResponse.success(recommendations));
    }
    
    @GetMapping("/analysis/efficiency")
    @Operation(summary = "计算学习效率", description = "计算用户在指定时间段的学习效率")
    public ResponseEntity<ApiResponse<Map<String, Object>>> calculateLearningEfficiency(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> efficiency = studySessionService.calculateLearningEfficiency(userId, startTime, endTime);
        return ResponseEntity.ok(ApiResponse.success(efficiency));
    }
    
    // ==================== 便捷接口 ====================
    
    @GetMapping("/statistics/summary")
    @Operation(summary = "获取学习统计摘要", description = "获取用户学习统计的摘要信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getLearningStatisticsSummary(
            @Parameter(description = "统计周期：today, week, month, year") 
            @RequestParam(defaultValue = "week") String period,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        LocalDateTime endTime = LocalDateTime.now();
        LocalDateTime startTime;
        
        switch (period.toLowerCase()) {
            case "today":
                startTime = endTime.toLocalDate().atStartOfDay();
                break;
            case "week":
                startTime = endTime.minusWeeks(1);
                break;
            case "month":
                startTime = endTime.minusMonths(1);
                break;
            case "year":
                startTime = endTime.minusYears(1);
                break;
            default:
                startTime = endTime.minusWeeks(1);
        }
        
        Map<String, Object> summary = studySessionService.getUserLearningStatisticsInPeriod(userId, startTime, endTime);
        
        // 添加额外的摘要信息
        summary.put("period", period);
        summary.put("startTime", startTime);
        summary.put("endTime", endTime);
        
        // 获取连续学习天数
        Integer continuousDays = studySessionService.getUserContinuousStudyDays(userId);
        summary.put("continuousStudyDays", continuousDays);
        
        return ResponseEntity.ok(ApiResponse.success(summary));
    }
    
    @PostMapping("/quick-record")
    @Operation(summary = "快速记录学习", description = "快速记录一次学习活动（无需开始/结束会话）")
    public ResponseEntity<ApiResponse<StudySession>> quickRecordLearning(
            @RequestParam StudySession.SessionType sessionType,
            @RequestParam Integer durationMinutes,
            @RequestParam(required = false, defaultValue = "0") Integer wordsStudied,
            @RequestParam(required = false, defaultValue = "0") Integer wordsMastered,
            @RequestParam(required = false, defaultValue = "0") Integer articlesRead,
            @RequestParam(required = false, defaultValue = "0") Integer questionsAnswered,
            @RequestParam(required = false, defaultValue = "0") Integer questionsCorrect,
            @RequestParam(required = false, defaultValue = "0") Integer pointsEarned,
            @RequestParam(required = false) String notes,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        
        // 创建并立即完成一个会话
        StudySession session = studySessionService.startSession(userId, sessionType, "mobile", "app");
        
        // 更新进度
        session = studySessionService.updateSessionProgress(
            session.getId(), wordsStudied, wordsMastered, articlesRead, 
            questionsAnswered, questionsCorrect, pointsEarned);
        
        // 手动设置持续时间并结束会话
        session.setDuration((long) (durationMinutes * 60));
        session = studySessionService.endSession(session.getId(), notes);
        
        return ResponseEntity.ok(ApiResponse.success(session));
    }
}