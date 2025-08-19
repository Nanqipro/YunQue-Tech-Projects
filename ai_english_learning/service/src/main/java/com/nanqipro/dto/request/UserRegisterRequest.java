package com.nanqipro.dto.request;

import com.nanqipro.entity.User;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;

/**
 * 用户注册请求DTO
 */
@Data
public class UserRegisterRequest {
    
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度必须在3-20个字符之间")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "用户名只能包含字母、数字和下划线")
    private String username;
    
    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度必须在6-20个字符之间")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{6,}$", 
             message = "密码必须包含至少一个大写字母、一个小写字母和一个数字")
    private String password;
    
    @NotBlank(message = "确认密码不能为空")
    private String confirmPassword;
    
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
    private Integer dailyGoal = 10; // 默认每日学习10个单词
    
    /**
     * 验证密码确认
     */
    public boolean isPasswordConfirmed() {
        return password != null && password.equals(confirmPassword);
    }
}