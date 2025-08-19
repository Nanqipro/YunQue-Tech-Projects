package com.nanqipro.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.Set;

/**
 * 用户实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Entity
@Table(name = "users")
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 50, message = "用户名长度必须在3-50个字符之间")
    @Column(unique = true, nullable = false, length = 50)
    private String username;
    
    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    @Column(unique = true, nullable = false, length = 100)
    private String email;
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, message = "密码长度不能少于6个字符")
    @Column(nullable = false)
    private String password;
    
    @Column(length = 50)
    private String nickname;
    
    @Column(name = "avatar_url")
    private String avatarUrl;
    
    @Column(name = "phone_number", length = 20)
    private String phoneNumber;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Gender gender = Gender.UNKNOWN;
    
    @Column(name = "birth_date")
    private LocalDateTime birthDate;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "english_level", nullable = false)
    private EnglishLevel englishLevel = EnglishLevel.BEGINNER;
    
    @Column(name = "learning_goal")
    private String learningGoal;
    
    @Column(name = "daily_goal", nullable = false)
    private Integer dailyGoal = 10;
    
    @Column(name = "total_points", nullable = false)
    private Integer totalPoints = 0;
    
    @Column(name = "current_streak", nullable = false)
    private Integer currentStreak = 0;
    
    @Column(name = "max_streak", nullable = false)
    private Integer maxStreak = 0;
    
    @Column(name = "last_login_time")
    private LocalDateTime lastLoginTime;
    
    @Column(name = "last_study_time")
    private LocalDateTime lastStudyTime;
    
    @Column(nullable = false)
    private Boolean enabled = true;
    
    @Column(name = "email_verified", nullable = false)
    private Boolean emailVerified = false;
    
    @ElementCollection(targetClass = Role.class, fetch = FetchType.EAGER)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role")
    private Set<Role> roles;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    /**
     * 性别枚举
     */
    public enum Gender {
        MALE, FEMALE, UNKNOWN
    }
    
    /**
     * 英语水平枚举
     */
    public enum EnglishLevel {
        BEGINNER,    // 初级
        ELEMENTARY,  // 基础
        INTERMEDIATE,// 中级
        ADVANCED,    // 高级
        EXPERT       // 专家
    }
    
    /**
     * 用户角色枚举
     */
    public enum Role {
        USER,        // 普通用户
        PREMIUM,     // 高级用户
        ADMIN        // 管理员
    }
}