package com.nanqipro.service;

import com.nanqipro.dto.request.UserLoginRequest;
import com.nanqipro.dto.request.UserRegisterRequest;
import com.nanqipro.dto.request.UserUpdateRequest;
import com.nanqipro.dto.response.UserProfileResponse;
import com.nanqipro.dto.response.UserStatsResponse;
import com.nanqipro.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 用户服务接口
 */
public interface UserService {
    
    /**
     * 用户注册
     */
    User register(UserRegisterRequest request);
    
    /**
     * 用户登录
     */
    Map<String, Object> login(UserLoginRequest request);
    
    /**
     * 刷新令牌
     */
    Map<String, Object> refreshToken(String refreshToken);
    
    /**
     * 用户登出
     */
    void logout(Long userId);
    
    /**
     * 根据ID获取用户
     */
    User getUserById(Long id);
    
    /**
     * 根据用户名获取用户
     */
    User getUserByUsername(String username);
    
    /**
     * 根据邮箱获取用户
     */
    User getUserByEmail(String email);
    
    /**
     * 获取用户资料
     */
    UserProfileResponse getUserProfile(Long userId);
    
    /**
     * 更新用户资料
     */
    UserProfileResponse updateUserProfile(Long userId, UserUpdateRequest request);
    
    /**
     * 上传用户头像
     */
    String uploadAvatar(Long userId, MultipartFile file);
    
    /**
     * 修改密码
     */
    void changePassword(Long userId, String oldPassword, String newPassword);
    
    /**
     * 重置密码
     */
    void resetPassword(String email);
    
    /**
     * 验证邮箱
     */
    void verifyEmail(String token);
    
    /**
     * 发送邮箱验证码
     */
    void sendEmailVerification(Long userId);
    
    /**
     * 启用/禁用用户
     */
    void toggleUserStatus(Long userId, boolean enabled);
    
    /**
     * 删除用户
     */
    void deleteUser(Long userId);
    
    /**
     * 获取用户列表（分页）
     */
    Page<User> getUsers(Pageable pageable);
    
    /**
     * 搜索用户
     */
    Page<User> searchUsers(String keyword, Pageable pageable);
    
    /**
     * 获取用户统计信息
     */
    UserStatsResponse getUserStats(Long userId);
    
    /**
     * 更新用户学习统计
     */
    void updateUserStudyStats(Long userId, int pointsEarned, boolean maintainStreak);
    
    /**
     * 更新用户最后登录时间
     */
    void updateLastLoginTime(Long userId);
    
    /**
     * 更新用户最后学习时间
     */
    void updateLastStudyTime(Long userId);
    
    /**
     * 获取活跃用户列表
     */
    List<User> getActiveUsers(LocalDateTime since);
    
    /**
     * 获取新注册用户列表
     */
    List<User> getNewUsers(LocalDateTime since);
    
    /**
     * 获取积分排行榜
     */
    List<UserProfileResponse> getPointsLeaderboard(int limit);
    
    /**
     * 获取连续学习排行榜
     */
    List<UserProfileResponse> getStreakLeaderboard(int limit);
    
    /**
     * 检查用户名是否可用
     */
    boolean isUsernameAvailable(String username);
    
    /**
     * 检查邮箱是否可用
     */
    boolean isEmailAvailable(String email);
    
    /**
     * 获取用户角色
     */
    List<User.Role> getUserRoles(Long userId);
    
    /**
     * 更新用户角色
     */
    void updateUserRoles(Long userId, List<User.Role> roles);
    
    /**
     * 获取用户学习偏好
     */
    Map<String, Object> getUserPreferences(Long userId);
    
    /**
     * 更新用户学习偏好
     */
    void updateUserPreferences(Long userId, Map<String, Object> preferences);
    
    /**
     * 获取用户学习目标完成情况
     */
    Map<String, Object> getUserGoalProgress(Long userId);
    
    /**
     * 更新用户学习目标
     */
    void updateUserGoal(Long userId, int dailyGoal, String learningGoal);
    
    /**
     * 检查用户是否达成今日目标
     */
    boolean checkDailyGoalAchievement(Long userId);
    
    /**
     * 计算用户连续学习天数
     */
    void calculateUserStreak(Long userId);
    
    /**
     * 获取用户成就列表
     */
    List<Map<String, Object>> getUserAchievements(Long userId);
    
    /**
     * 批量导入用户
     */
    void importUsers(MultipartFile file);
    
    /**
     * 导出用户数据
     */
    byte[] exportUsers(List<Long> userIds);
}