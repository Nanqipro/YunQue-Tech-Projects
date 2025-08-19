package com.nanqipro.dto.request;

import com.nanqipro.entity.User;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;

/**
 * 用户更新请求DTO
 */
@Data
public class UserUpdateRequest {
    
    @Size(max = 50, message = "昵称长度不能超过50个字符")
    private String nickname;
    
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
    
    private User.Gender gender;
    
    @Past(message = "出生日期必须是过去的日期")
    private LocalDate birthDate;
    
    private User.EnglishLevel englishLevel;
    
    @Size(max = 200, message = "学习目标长度不能超过200个字符")
    private String learningGoal;
    
    @Min(value = 1, message = "每日目标必须大于0")
    @Max(value = 1000, message = "每日目标不能超过1000")
    private Integer dailyGoal;
    
    /**
     * 头像URL
     */
    @Size(max = 500, message = "头像URL长度不能超过500个字符")
    private String avatarUrl;
    
    /**
     * 个人简介
     */
    @Size(max = 500, message = "个人简介长度不能超过500个字符")
    private String bio;
    
    /**
     * 时区
     */
    private String timezone;
    
    /**
     * 语言偏好
     */
    private String language;
    
    /**
     * 通知设置
     */
    private Boolean emailNotification;
    private Boolean pushNotification;
    private Boolean studyReminder;
    
    /**
     * 隐私设置
     */
    private Boolean profilePublic;
    private Boolean showProgress;
    private Boolean showAchievements;
}