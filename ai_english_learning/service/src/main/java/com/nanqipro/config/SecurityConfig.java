package com.nanqipro.config;

import com.nanqipro.security.JwtAuthenticationFilter;
import com.nanqipro.security.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * Spring Security配置类
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    
    @Autowired
    private UserDetailsServiceImpl userDetailsService;
    
    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;
    
    /**
     * 密码编码器
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    /**
     * 认证管理器
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
    
    /**
     * 认证提供者
     */
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }
    
    /**
     * CORS配置
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
    
    /**
     * 安全过滤器链
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 禁用CSRF
            .csrf(AbstractHttpConfigurer::disable)
            
            // 启用CORS
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            
            // 会话管理
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            
            // 异常处理
            .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setStatus(401);
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"code\":401,\"message\":\"未授权访问\"}");
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    response.setStatus(403);
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"code\":403,\"message\":\"访问被拒绝\"}");
                })
            )
            
            // 请求授权配置
            .authorizeHttpRequests(authz -> authz
                // 公开接口
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/api/v1/public/**").permitAll()
                
                // API文档相关
                .requestMatchers("/api-docs/**").permitAll()
                .requestMatchers("/swagger-ui/**").permitAll()
                .requestMatchers("/swagger-ui.html").permitAll()
                .requestMatchers("/v3/api-docs/**").permitAll()
                
                // 健康检查
                .requestMatchers("/actuator/health").permitAll()
                
                // 静态资源
                .requestMatchers("/favicon.ico").permitAll()
                .requestMatchers("/error").permitAll()
                
                // 用户相关接口
                .requestMatchers(HttpMethod.GET, "/api/v1/users/profile").hasAnyRole("USER", "PREMIUM", "ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/v1/users/profile").hasAnyRole("USER", "PREMIUM", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/users/avatar").hasAnyRole("USER", "PREMIUM", "ADMIN")
                
                // 词汇相关接口
                .requestMatchers(HttpMethod.GET, "/api/v1/vocabularies/**").hasAnyRole("USER", "PREMIUM", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/vocabularies/study").hasAnyRole("USER", "PREMIUM", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/vocabularies/review").hasAnyRole("USER", "PREMIUM", "ADMIN")
                
                // 阅读相关接口
                .requestMatchers(HttpMethod.GET, "/api/v1/articles/**").hasAnyRole("USER", "PREMIUM", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/articles/*/reading").hasAnyRole("USER", "PREMIUM", "ADMIN")
                
                // 学习记录相关接口
                .requestMatchers(HttpMethod.GET, "/api/v1/study/**").hasAnyRole("USER", "PREMIUM", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/study/**").hasAnyRole("USER", "PREMIUM", "ADMIN")
                
                // AI功能相关接口
                .requestMatchers("/api/v1/ai/**").hasAnyRole("USER", "PREMIUM", "ADMIN")
                
                // 高级功能（仅高级用户和管理员）
                .requestMatchers("/api/v1/premium/**").hasAnyRole("PREMIUM", "ADMIN")
                
                // 管理员接口
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                
                // 其他所有请求都需要认证
                .anyRequest().authenticated()
            )
            
            // 认证提供者
            .authenticationProvider(authenticationProvider())
            
            // 添加JWT过滤器
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}