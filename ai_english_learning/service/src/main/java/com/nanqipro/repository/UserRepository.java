package com.nanqipro.repository;

import com.nanqipro.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 用户数据访问层
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * 根据用户名查找用户
     */
    Optional<User> findByUsername(String username);
    
    /**
     * 根据邮箱查找用户
     */
    Optional<User> findByEmail(String email);
    
    /**
     * 根据用户名或邮箱查找用户
     */
    Optional<User> findByUsernameOrEmail(String username, String email);
    
    /**
     * 检查用户名是否存在
     */
    boolean existsByUsername(String username);
    
    /**
     * 检查邮箱是否存在
     */
    boolean existsByEmail(String email);
    
    /**
     * 检查手机号是否存在
     */
    boolean existsByPhoneNumber(String phoneNumber);
    
    /**
     * 根据手机号查找用户
     */
    Optional<User> findByPhoneNumber(String phoneNumber);
    
    /**
     * 搜索用户（用户名、昵称、邮箱模糊匹配）
     */
    Page<User> findByUsernameContainingOrNicknameContainingOrEmailContaining(
            String username, String nickname, String email, Pageable pageable);
    
    /**
     * 查找最后学习时间在指定时间之后的用户
     */
    List<User> findByLastStudyTimeAfter(LocalDateTime since);
    
    /**
     * 查找创建时间在指定时间之后的用户
     */
    List<User> findByCreatedAtAfter(LocalDateTime since);
    
    /**
     * 按积分排序获取前N名用户
     */
    @Query("SELECT u FROM User u ORDER BY u.totalPoints DESC")
    List<User> findTopByOrderByTotalPointsDesc(Pageable pageable);
    
    /**
     * 按连续学习天数排序获取前N名用户
     */
    @Query("SELECT u FROM User u ORDER BY u.currentStreak DESC")
    List<User> findTopByOrderByCurrentStreakDesc(Pageable pageable);
    
    /**
     * 查找启用的用户
     */
    List<User> findByEnabledTrue();
    
    /**
     * 查找禁用的用户
     */
    List<User> findByEnabledFalse();
    
    /**
     * 查找邮箱已验证的用户
     */
    List<User> findByEmailVerifiedTrue();
    
    /**
     * 查找邮箱未验证的用户
     */
    List<User> findByEmailVerifiedFalse();
    
    /**
     * 根据英语水平查找用户
     */
    List<User> findByEnglishLevel(User.EnglishLevel englishLevel);
    
    /**
     * 根据角色查找用户
     */
    @Query("SELECT u FROM User u JOIN u.roles r WHERE r = :role")
    List<User> findByRole(@Param("role") User.Role role);
    
    /**
     * 查找最近登录的用户
     */
    @Query("SELECT u FROM User u WHERE u.lastLoginTime >= :since ORDER BY u.lastLoginTime DESC")
    List<User> findRecentlyLoggedInUsers(@Param("since") LocalDateTime since);
    
    /**
     * 查找活跃用户（最近学习过的）
     */
    @Query("SELECT u FROM User u WHERE u.lastStudyTime >= :since ORDER BY u.lastStudyTime DESC")
    List<User> findActiveUsers(@Param("since") LocalDateTime since);
    
    /**
     * 查找连续学习天数大于指定值的用户
     */
    @Query("SELECT u FROM User u WHERE u.currentStreak >= :minStreak ORDER BY u.currentStreak DESC")
    List<User> findUsersByMinStreak(@Param("minStreak") Integer minStreak);
    
    /**
     * 查找积分排行榜
     */
    @Query("SELECT u FROM User u WHERE u.enabled = true ORDER BY u.totalPoints DESC")
    List<User> findTopUsersByPoints();
    
    /**
     * 查找连续学习排行榜
     */
    @Query("SELECT u FROM User u WHERE u.enabled = true ORDER BY u.currentStreak DESC, u.maxStreak DESC")
    List<User> findTopUsersByStreak();
    
    /**
     * 统计用户总数
     */
    @Query("SELECT COUNT(u) FROM User u WHERE u.enabled = true")
    Long countActiveUsers();
    
    /**
     * 统计新注册用户数（指定时间段）
     */
    @Query("SELECT COUNT(u) FROM User u WHERE u.createdAt >= :since")
    Long countNewUsers(@Param("since") LocalDateTime since);
    
    /**
     * 统计活跃用户数（指定时间段内有学习记录）
     */
    @Query("SELECT COUNT(u) FROM User u WHERE u.lastStudyTime >= :since")
    Long countActiveUsersInPeriod(@Param("since") LocalDateTime since);
    
    /**
     * 更新用户最后登录时间
     */
    @Query("UPDATE User u SET u.lastLoginTime = :loginTime WHERE u.id = :userId")
    void updateLastLoginTime(@Param("userId") Long userId, @Param("loginTime") LocalDateTime loginTime);
    
    /**
     * 更新用户最后学习时间
     */
    @Query("UPDATE User u SET u.lastStudyTime = :studyTime WHERE u.id = :userId")
    void updateLastStudyTime(@Param("userId") Long userId, @Param("studyTime") LocalDateTime studyTime);
    
    /**
     * 更新用户连续学习天数
     */
    @Query("UPDATE User u SET u.currentStreak = :currentStreak, u.maxStreak = :maxStreak WHERE u.id = :userId")
    void updateUserStreak(@Param("userId") Long userId, 
                         @Param("currentStreak") Integer currentStreak, 
                         @Param("maxStreak") Integer maxStreak);
    
    /**
     * 更新用户积分
     */
    @Query("UPDATE User u SET u.totalPoints = u.totalPoints + :points WHERE u.id = :userId")
    void addUserPoints(@Param("userId") Long userId, @Param("points") Integer points);
}