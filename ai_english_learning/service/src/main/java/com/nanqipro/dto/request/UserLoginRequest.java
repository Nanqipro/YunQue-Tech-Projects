package com.nanqipro.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 用户登录请求DTO
 */
@Data
public class UserLoginRequest {
    
    @NotBlank(message = "用户名或邮箱不能为空")
    private String usernameOrEmail;
    
    @NotBlank(message = "密码不能为空")
    private String password;
    
    /**
     * 记住我选项
     */
    private boolean rememberMe = false;
    
    /**
     * 设备类型
     */
    private String deviceType;
    
    /**
     * 设备ID
     */
    private String deviceId;
    
    /**
     * 客户端版本
     */
    private String clientVersion;
    
    /**
     * 平台信息
     */
    private String platform;
}