package com.nanqipro.controller;

import com.nanqipro.common.ApiResponse;
import com.nanqipro.dto.request.UserLoginRequest;
import com.nanqipro.dto.request.UserRegisterRequest;
import com.nanqipro.dto.request.UserUpdateRequest;
import com.nanqipro.dto.response.UserProfileResponse;
import com.nanqipro.dto.response.UserStatsResponse;
import com.nanqipro.entity.User;
import com.nanqipro.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 用户管理控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "用户管理", description = "用户注册、登录、资料管理等功能")
public class UserController {
    
    private final UserService userService;
    
    /**
     * 用户注册
     */
    @PostMapping("/register")
    @Operation(summary = "用户注册", description = "新用户注册账号")
    public ApiResponse<UserProfileResponse> register(@Valid @RequestBody UserRegisterRequest request) {
        log.info("用户注册请求: {}", request.getUsername());
        User user = userService.register(request);
        return ApiResponse.success(UserProfileResponse.fromUser(user));
    }
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    @Operation(summary = "用户登录", description = "用户登录获取访问令牌")
    public ApiResponse<Map<String, Object>> login(@Valid @RequestBody UserLoginRequest request) {
        log.info("用户登录请求: {}", request.getUsernameOrEmail());
        Map<String, Object> result = userService.login(request);
        return ApiResponse.success(result);
    }
    
    /**
     * 刷新令牌
     */
    @PostMapping("/refresh")
    @Operation(summary = "刷新令牌", description = "使用刷新令牌获取新的访问令牌")
    public ApiResponse<Map<String, Object>> refreshToken(
            @Parameter(description = "刷新令牌") @RequestParam String refreshToken) {
        Map<String, Object> result = userService.refreshToken(refreshToken);
        return ApiResponse.success(result);
    }
    
    /**
     * 用户登出
     */
    @PostMapping("/logout")
    @Operation(summary = "用户登出", description = "用户登出，使令牌失效")
    public ApiResponse<Void> logout(@AuthenticationPrincipal UserDetails userDetails) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        userService.logout(userId);
        return ApiResponse.success();
    }
    
    /**
     * 获取当前用户资料
     */
    @GetMapping("/profile")
    @Operation(summary = "获取用户资料", description = "获取当前登录用户的详细资料")
    public ApiResponse<UserProfileResponse> getProfile(@AuthenticationPrincipal UserDetails userDetails) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        UserProfileResponse profile = userService.getUserProfile(userId);
        return ApiResponse.success(profile);
    }
    
    /**
     * 更新用户资料
     */
    @PutMapping("/profile")
    @Operation(summary = "更新用户资料", description = "更新当前登录用户的资料信息")
    public ApiResponse<UserProfileResponse> updateProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UserUpdateRequest request) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        UserProfileResponse profile = userService.updateUserProfile(userId, request);
        return ApiResponse.success(profile);
    }
    
    /**
     * 上传用户头像
     */
    @PostMapping(value = "/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "上传头像", description = "上传用户头像图片")
    public ApiResponse<String> uploadAvatar(
            @AuthenticationPrincipal UserDetails userDetails,
            @Parameter(description = "头像文件") @RequestParam("file") MultipartFile file) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        String avatarUrl = userService.uploadAvatar(userId, file);
        return ApiResponse.success(avatarUrl);
    }
    
    /**
     * 修改密码
     */
    @PostMapping("/change-password")
    @Operation(summary = "修改密码", description = "修改当前用户密码")
    public ApiResponse<Void> changePassword(
            @AuthenticationPrincipal UserDetails userDetails,
            @Parameter(description = "原密码") @RequestParam String oldPassword,
            @Parameter(description = "新密码") @RequestParam String newPassword) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        userService.changePassword(userId, oldPassword, newPassword);
        return ApiResponse.success();
    }
    
    /**
     * 重置密码
     */
    @PostMapping("/reset-password")
    @Operation(summary = "重置密码", description = "通过邮箱重置密码")
    public ApiResponse<Void> resetPassword(
            @Parameter(description = "邮箱地址") @RequestParam String email) {
        userService.resetPassword(email);
        return ApiResponse.success();
    }
    
    /**
     * 验证邮箱
     */
    @PostMapping("/verify-email")
    @Operation(summary = "验证邮箱", description = "通过验证令牌验证邮箱")
    public ApiResponse<Void> verifyEmail(
            @Parameter(description = "验证令牌") @RequestParam String token) {
        userService.verifyEmail(token);
        return ApiResponse.success();
    }
    
    /**
     * 发送邮箱验证
     */
    @PostMapping("/send-verification")
    @Operation(summary = "发送邮箱验证", description = "发送邮箱验证邮件")
    public ApiResponse<Void> sendEmailVerification(@AuthenticationPrincipal UserDetails userDetails) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        userService.sendEmailVerification(userId);
        return ApiResponse.success();
    }
    
    /**
     * 获取用户统计信息
     */
    @GetMapping("/stats")
    @Operation(summary = "获取用户统计", description = "获取当前用户的学习统计信息")
    public ApiResponse<UserStatsResponse> getUserStats(@AuthenticationPrincipal UserDetails userDetails) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        UserStatsResponse stats = userService.getUserStats(userId);
        return ApiResponse.success(stats);
    }
    
    /**
     * 获取用户学习目标进度
     */
    @GetMapping("/goal-progress")
    @Operation(summary = "获取学习目标进度", description = "获取用户学习目标完成情况")
    public ApiResponse<Map<String, Object>> getUserGoalProgress(@AuthenticationPrincipal UserDetails userDetails) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        Map<String, Object> progress = userService.getUserGoalProgress(userId);
        return ApiResponse.success(progress);
    }
    
    /**
     * 更新学习目标
     */
    @PutMapping("/goal")
    @Operation(summary = "更新学习目标", description = "更新用户的学习目标")
    public ApiResponse<Void> updateUserGoal(
            @AuthenticationPrincipal UserDetails userDetails,
            @Parameter(description = "每日目标") @RequestParam int dailyGoal,
            @Parameter(description = "学习目标") @RequestParam String learningGoal) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        userService.updateUserGoal(userId, dailyGoal, learningGoal);
        return ApiResponse.success();
    }
    
    /**
     * 获取用户成就
     */
    @GetMapping("/achievements")
    @Operation(summary = "获取用户成就", description = "获取用户已获得的成就列表")
    public ApiResponse<List<Map<String, Object>>> getUserAchievements(@AuthenticationPrincipal UserDetails userDetails) {
        // TODO: 从UserDetails中获取用户ID
        Long userId = 1L; // 临时实现
        List<Map<String, Object>> achievements = userService.getUserAchievements(userId);
        return ApiResponse.success(achievements);
    }
    
    /**
     * 检查用户名可用性
     */
    @GetMapping("/check-username")
    @Operation(summary = "检查用户名", description = "检查用户名是否可用")
    public ApiResponse<Boolean> checkUsername(
            @Parameter(description = "用户名") @RequestParam String username) {
        boolean available = userService.isUsernameAvailable(username);
        return ApiResponse.success(available);
    }
    
    /**
     * 检查邮箱可用性
     */
    @GetMapping("/check-email")
    @Operation(summary = "检查邮箱", description = "检查邮箱是否可用")
    public ApiResponse<Boolean> checkEmail(
            @Parameter(description = "邮箱地址") @RequestParam String email) {
        boolean available = userService.isEmailAvailable(email);
        return ApiResponse.success(available);
    }
    
    /**
     * 获取积分排行榜
     */
    @GetMapping("/leaderboard/points")
    @Operation(summary = "积分排行榜", description = "获取积分排行榜")
    public ApiResponse<List<UserProfileResponse>> getPointsLeaderboard(
            @Parameter(description = "排行榜数量") @RequestParam(defaultValue = "10") int limit) {
        List<UserProfileResponse> leaderboard = userService.getPointsLeaderboard(limit);
        return ApiResponse.success(leaderboard);
    }
    
    /**
     * 获取连续学习排行榜
     */
    @GetMapping("/leaderboard/streak")
    @Operation(summary = "连续学习排行榜", description = "获取连续学习天数排行榜")
    public ApiResponse<List<UserProfileResponse>> getStreakLeaderboard(
            @Parameter(description = "排行榜数量") @RequestParam(defaultValue = "10") int limit) {
        List<UserProfileResponse> leaderboard = userService.getStreakLeaderboard(limit);
        return ApiResponse.success(leaderboard);
    }
    
    // ==================== 管理员接口 ====================
    
    /**
     * 获取用户列表（管理员）
     */
    @GetMapping("/admin/list")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取用户列表", description = "管理员获取用户列表（分页）")
    public ApiResponse<Page<User>> getUsers(
            @PageableDefault(size = 20) Pageable pageable) {
        Page<User> users = userService.getUsers(pageable);
        return ApiResponse.success(users);
    }
    
    /**
     * 搜索用户（管理员）
     */
    @GetMapping("/admin/search")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "搜索用户", description = "管理员搜索用户")
    public ApiResponse<Page<User>> searchUsers(
            @Parameter(description = "搜索关键词") @RequestParam String keyword,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<User> users = userService.searchUsers(keyword, pageable);
        return ApiResponse.success(users);
    }
    
    /**
     * 获取指定用户信息（管理员）
     */
    @GetMapping("/admin/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取用户信息", description = "管理员获取指定用户详细信息")
    public ApiResponse<UserProfileResponse> getUserById(
            @Parameter(description = "用户ID") @PathVariable Long userId) {
        UserProfileResponse profile = userService.getUserProfile(userId);
        return ApiResponse.success(profile);
    }
    
    /**
     * 启用/禁用用户（管理员）
     */
    @PutMapping("/admin/{userId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "切换用户状态", description = "管理员启用或禁用用户")
    public ApiResponse<Void> toggleUserStatus(
            @Parameter(description = "用户ID") @PathVariable Long userId,
            @Parameter(description = "是否启用") @RequestParam boolean enabled) {
        userService.toggleUserStatus(userId, enabled);
        return ApiResponse.success();
    }
    
    /**
     * 删除用户（管理员）
     */
    @DeleteMapping("/admin/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "删除用户", description = "管理员删除用户")
    public ApiResponse<Void> deleteUser(
            @Parameter(description = "用户ID") @PathVariable Long userId) {
        userService.deleteUser(userId);
        return ApiResponse.success();
    }
    
    /**
     * 更新用户角色（管理员）
     */
    @PutMapping("/admin/{userId}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "更新用户角色", description = "管理员更新用户角色")
    public ApiResponse<Void> updateUserRoles(
            @Parameter(description = "用户ID") @PathVariable Long userId,
            @Parameter(description = "角色列表") @RequestBody List<User.Role> roles) {
        userService.updateUserRoles(userId, roles);
        return ApiResponse.success();
    }
    
    /**
     * 获取活跃用户（管理员）
     */
    @GetMapping("/admin/active")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取活跃用户", description = "管理员获取活跃用户列表")
    public ApiResponse<List<User>> getActiveUsers(
            @Parameter(description = "时间范围（天）") @RequestParam(defaultValue = "7") int days) {
        LocalDateTime since = LocalDateTime.now().minusDays(days);
        List<User> users = userService.getActiveUsers(since);
        return ApiResponse.success(users);
    }
    
    /**
     * 获取新注册用户（管理员）
     */
    @GetMapping("/admin/new")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取新用户", description = "管理员获取新注册用户列表")
    public ApiResponse<List<User>> getNewUsers(
            @Parameter(description = "时间范围（天）") @RequestParam(defaultValue = "7") int days) {
        LocalDateTime since = LocalDateTime.now().minusDays(days);
        List<User> users = userService.getNewUsers(since);
        return ApiResponse.success(users);
    }
    
    /**
     * 批量导入用户（管理员）
     */
    @PostMapping(value = "/admin/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "批量导入用户", description = "管理员批量导入用户")
    public ApiResponse<Void> importUsers(
            @Parameter(description = "用户数据文件") @RequestParam("file") MultipartFile file) {
        userService.importUsers(file);
        return ApiResponse.success();
    }
    
    /**
     * 导出用户数据（管理员）
     */
    @PostMapping("/admin/export")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "导出用户数据", description = "管理员导出用户数据")
    public ApiResponse<byte[]> exportUsers(
            @Parameter(description = "用户ID列表") @RequestBody List<Long> userIds) {
        byte[] data = userService.exportUsers(userIds);
        return ApiResponse.success(data);
    }
}