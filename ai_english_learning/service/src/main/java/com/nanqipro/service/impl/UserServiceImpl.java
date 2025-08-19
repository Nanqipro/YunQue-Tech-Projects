package com.nanqipro.service.impl;

import com.nanqipro.dto.request.UserLoginRequest;
import com.nanqipro.dto.request.UserRegisterRequest;
import com.nanqipro.dto.request.UserUpdateRequest;
import com.nanqipro.dto.response.UserProfileResponse;
import com.nanqipro.dto.response.UserStatsResponse;
import com.nanqipro.entity.User;
import com.nanqipro.exception.BusinessException;
import com.nanqipro.repository.UserRepository;
import com.nanqipro.service.UserService;
import com.nanqipro.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 用户服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final UserDetailsService userDetailsService;
    
    @Override
    @Transactional
    public User register(UserRegisterRequest request) {
        log.info("用户注册: {}", request.getUsername());
        
        // 验证密码确认
        if (!request.isPasswordConfirmed()) {
            throw new BusinessException("密码确认不匹配");
        }
        
        // 检查用户名是否已存在
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BusinessException("用户名已存在");
        }
        
        // 检查邮箱是否已存在
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("邮箱已存在");
        }
        
        // 检查手机号是否已存在（如果提供）
        if (request.getPhone() != null && userRepository.existsByPhoneNumber(request.getPhone())) {
            throw new BusinessException("手机号已存在");
        }
        
        // 创建用户
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setNickname(request.getNickname() != null ? request.getNickname() : request.getUsername());
        user.setPhoneNumber(request.getPhone());
        user.setGender(request.getGender());
        user.setBirthDate(request.getBirthDate() != null ? request.getBirthDate().atStartOfDay() : null);
        user.setEnglishLevel(request.getEnglishLevel() != null ? request.getEnglishLevel() : User.EnglishLevel.BEGINNER);
        user.setLearningGoal(request.getLearningGoal());
        user.setDailyGoal(request.getDailyGoal());
        user.setTotalPoints(0);
        user.setCurrentStreak(0);
        user.setMaxStreak(0);
        user.setEnabled(true);
        user.setEmailVerified(false);
        user.setRoles(Set.of(User.Role.USER));
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        
        User savedUser = userRepository.save(user);
        log.info("用户注册成功: {}", savedUser.getId());
        
        // TODO: 发送邮箱验证邮件
        
        return savedUser;
    }
    
    @Override
    public Map<String, Object> login(UserLoginRequest request) {
        log.info("用户登录: {}", request.getUsernameOrEmail());
        
        // 查找用户
        User user = userRepository.findByUsernameOrEmail(request.getUsernameOrEmail(), request.getUsernameOrEmail())
                .orElseThrow(() -> new BusinessException("用户名或密码错误"));
        
        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 检查用户状态
        if (!user.getEnabled()) {
            throw new BusinessException("账户已被禁用");
        }
        
        // 生成JWT令牌
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());
        String accessToken = jwtUtil.generateToken(userDetails);
        String refreshToken = jwtUtil.generateRefreshToken(userDetails);
        
        // 更新最后登录时间
        updateLastLoginTime(user.getId());
        
        Map<String, Object> result = new HashMap<>();
        result.put("accessToken", accessToken);
        result.put("refreshToken", refreshToken);
        result.put("tokenType", "Bearer");
        result.put("expiresIn", 3600000); // 1小时
        result.put("user", UserProfileResponse.fromUser(user));
        
        log.info("用户登录成功: {}", user.getId());
        return result;
    }
    
    @Override
    public Map<String, Object> refreshToken(String refreshToken) {
        log.info("刷新令牌");
        
        if (!jwtUtil.validateTokenFormat(refreshToken) || jwtUtil.isTokenExpired(refreshToken)) {
            throw new BusinessException("刷新令牌无效");
        }
        
        String username = jwtUtil.getUsernameFromToken(refreshToken);
        User user = getUserByUsername(username);
        
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);
        String newAccessToken = jwtUtil.generateToken(userDetails);
        String newRefreshToken = jwtUtil.generateRefreshToken(userDetails);
        
        Map<String, Object> result = new HashMap<>();
        result.put("accessToken", newAccessToken);
        result.put("refreshToken", newRefreshToken);
        result.put("tokenType", "Bearer");
        result.put("expiresIn", 3600000); // 1小时
        
        return result;
    }
    
    @Override
    public void logout(Long userId) {
        log.info("用户登出: {}", userId);
        // TODO: 实现令牌黑名单机制
    }
    
    @Override
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new BusinessException("用户不存在"));
    }
    
    @Override
    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException("用户不存在"));
    }
    
    @Override
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessException("用户不存在"));
    }
    
    @Override
    public UserProfileResponse getUserProfile(Long userId) {
        User user = getUserById(userId);
        return UserProfileResponse.fromUser(user);
    }
    
    @Override
    @Transactional
    public UserProfileResponse updateUserProfile(Long userId, UserUpdateRequest request) {
        log.info("更新用户资料: {}", userId);
        
        User user = getUserById(userId);
        
        // 更新基本信息
        if (request.getNickname() != null) {
            user.setNickname(request.getNickname());
        }
        if (request.getPhone() != null) {
            // 检查手机号是否已被其他用户使用
            userRepository.findByPhoneNumber(request.getPhone())
                    .ifPresent(existingUser -> {
                        if (!existingUser.getId().equals(userId)) {
                            throw new BusinessException("手机号已被使用");
                        }
                    });
            user.setPhoneNumber(request.getPhone());
        }
        if (request.getGender() != null) {
            user.setGender(request.getGender());
        }
        if (request.getBirthDate() != null) {
            user.setBirthDate(request.getBirthDate().atStartOfDay());
        }
        if (request.getEnglishLevel() != null) {
            user.setEnglishLevel(request.getEnglishLevel());
        }
        if (request.getLearningGoal() != null) {
            user.setLearningGoal(request.getLearningGoal());
        }
        if (request.getDailyGoal() != null) {
            user.setDailyGoal(request.getDailyGoal());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }
        
        user.setUpdatedAt(LocalDateTime.now());
        User savedUser = userRepository.save(user);
        
        log.info("用户资料更新成功: {}", userId);
        return UserProfileResponse.fromUser(savedUser);
    }
    
    @Override
    public String uploadAvatar(Long userId, MultipartFile file) {
        log.info("上传用户头像: {}", userId);
        
        // TODO: 实现文件上传逻辑
        // 1. 验证文件类型和大小
        // 2. 生成唯一文件名
        // 3. 上传到文件存储服务
        // 4. 更新用户头像URL
        
        throw new BusinessException("文件上传功能暂未实现");
    }
    
    @Override
    @Transactional
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        log.info("修改密码: {}", userId);
        
        User user = getUserById(userId);
        
        // 验证旧密码
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new BusinessException("原密码错误");
        }
        
        // 更新密码
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
        
        log.info("密码修改成功: {}", userId);
    }
    
    @Override
    public void resetPassword(String email) {
        log.info("重置密码: {}", email);
        
        User user = getUserByEmail(email);
        
        // TODO: 实现密码重置逻辑
        // 1. 生成重置令牌
        // 2. 发送重置邮件
        
        throw new BusinessException("密码重置功能暂未实现");
    }
    
    @Override
    @Transactional
    public void verifyEmail(String token) {
        log.info("验证邮箱: {}", token);
        
        // TODO: 实现邮箱验证逻辑
        // 1. 验证令牌
        // 2. 更新用户邮箱验证状态
        
        throw new BusinessException("邮箱验证功能暂未实现");
    }
    
    @Override
    public void sendEmailVerification(Long userId) {
        log.info("发送邮箱验证: {}", userId);
        
        User user = getUserById(userId);
        
        // TODO: 实现发送邮箱验证逻辑
        // 1. 生成验证令牌
        // 2. 发送验证邮件
        
        throw new BusinessException("邮箱验证功能暂未实现");
    }
    
    @Override
    @Transactional
    public void toggleUserStatus(Long userId, boolean enabled) {
        log.info("切换用户状态: {} -> {}", userId, enabled);
        
        User user = getUserById(userId);
        user.setEnabled(enabled);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
        
        log.info("用户状态更新成功: {}", userId);
    }
    
    @Override
    @Transactional
    public void deleteUser(Long userId) {
        log.info("删除用户: {}", userId);
        
        User user = getUserById(userId);
        
        // TODO: 实现软删除或数据清理逻辑
        userRepository.delete(user);
        
        log.info("用户删除成功: {}", userId);
    }
    
    @Override
    public Page<User> getUsers(Pageable pageable) {
        return userRepository.findAll(pageable);
    }
    
    @Override
    public Page<User> searchUsers(String keyword, Pageable pageable) {
        return userRepository.findByUsernameContainingOrNicknameContainingOrEmailContaining(
                keyword, keyword, keyword, pageable);
    }
    
    @Override
    public UserStatsResponse getUserStats(Long userId) {
        log.info("获取用户统计: {}", userId);
        
        User user = getUserById(userId);
        
        // TODO: 实现详细的统计计算逻辑
        return UserStatsResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .nickname(user.getNickname())
                .avatarUrl(user.getAvatarUrl())
                .totalPoints(user.getTotalPoints())
                .currentStreak(user.getCurrentStreak())
                .maxStreak(user.getMaxStreak())
                .lastUpdated(LocalDateTime.now())
                .build();
    }
    
    @Override
    @Transactional
    public void updateUserStudyStats(Long userId, int pointsEarned, boolean maintainStreak) {
        log.info("更新用户学习统计: {} +{} points", userId, pointsEarned);
        
        User user = getUserById(userId);
        
        // 更新积分
        user.setTotalPoints(user.getTotalPoints() + pointsEarned);
        
        // 更新连续学习天数
        if (maintainStreak) {
            user.setCurrentStreak(user.getCurrentStreak() + 1);
            if (user.getCurrentStreak() > user.getMaxStreak()) {
                user.setMaxStreak(user.getCurrentStreak());
            }
        } else {
            user.setCurrentStreak(0);
        }
        
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }
    
    @Override
    @Transactional
    public void updateLastLoginTime(Long userId) {
        userRepository.updateLastLoginTime(userId, LocalDateTime.now());
    }
    
    @Override
    @Transactional
    public void updateLastStudyTime(Long userId) {
        userRepository.updateLastStudyTime(userId, LocalDateTime.now());
    }
    
    @Override
    public List<User> getActiveUsers(LocalDateTime since) {
        return userRepository.findByLastStudyTimeAfter(since);
    }
    
    @Override
    public List<User> getNewUsers(LocalDateTime since) {
        return userRepository.findByCreatedAtAfter(since);
    }
    
    @Override
    public List<UserProfileResponse> getPointsLeaderboard(int limit) {
        return userRepository.findTopByOrderByTotalPointsDesc(Pageable.ofSize(limit))
                .stream()
                .map(UserProfileResponse::fromUser)
                .collect(Collectors.toList());
    }
    
    @Override
    public List<UserProfileResponse> getStreakLeaderboard(int limit) {
        return userRepository.findTopByOrderByCurrentStreakDesc(Pageable.ofSize(limit))
                .stream()
                .map(UserProfileResponse::fromUser)
                .collect(Collectors.toList());
    }
    
    @Override
    public boolean isUsernameAvailable(String username) {
        return !userRepository.existsByUsername(username);
    }
    
    @Override
    public boolean isEmailAvailable(String email) {
        return !userRepository.existsByEmail(email);
    }
    
    @Override
    public List<User.Role> getUserRoles(Long userId) {
        User user = getUserById(userId);
        return new ArrayList<>(user.getRoles());
    }
    
    @Override
    @Transactional
    public void updateUserRoles(Long userId, List<User.Role> roles) {
        log.info("更新用户角色: {} -> {}", userId, roles);
        
        User user = getUserById(userId);
        user.setRoles(new HashSet<>(roles));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }
    
    @Override
    public Map<String, Object> getUserPreferences(Long userId) {
        // TODO: 实现用户偏好设置获取
        return new HashMap<>();
    }
    
    @Override
    @Transactional
    public void updateUserPreferences(Long userId, Map<String, Object> preferences) {
        log.info("更新用户偏好: {}", userId);
        // TODO: 实现用户偏好设置更新
    }
    
    @Override
    public Map<String, Object> getUserGoalProgress(Long userId) {
        User user = getUserById(userId);
        
        Map<String, Object> progress = new HashMap<>();
        progress.put("dailyGoal", user.getDailyGoal());
        progress.put("currentProgress", 0); // TODO: 计算今日进度
        progress.put("completed", false); // TODO: 检查是否完成
        
        return progress;
    }
    
    @Override
    @Transactional
    public void updateUserGoal(Long userId, int dailyGoal, String learningGoal) {
        log.info("更新用户目标: {}", userId);
        
        User user = getUserById(userId);
        user.setDailyGoal(dailyGoal);
        user.setLearningGoal(learningGoal);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }
    
    @Override
    public boolean checkDailyGoalAchievement(Long userId) {
        // TODO: 实现每日目标检查逻辑
        return false;
    }
    
    @Override
    @Transactional
    public void calculateUserStreak(Long userId) {
        log.info("计算用户连续学习天数: {}", userId);
        // TODO: 实现连续学习天数计算逻辑
    }
    
    @Override
    public List<Map<String, Object>> getUserAchievements(Long userId) {
        // TODO: 实现用户成就获取逻辑
        return new ArrayList<>();
    }
    
    @Override
    @Transactional
    public void importUsers(MultipartFile file) {
        log.info("批量导入用户");
        // TODO: 实现用户批量导入逻辑
        throw new BusinessException("用户导入功能暂未实现");
    }
    
    @Override
    public byte[] exportUsers(List<Long> userIds) {
        log.info("导出用户数据: {}", userIds.size());
        // TODO: 实现用户数据导出逻辑
        throw new BusinessException("用户导出功能暂未实现");
    }
}