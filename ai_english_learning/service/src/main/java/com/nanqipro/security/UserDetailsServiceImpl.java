package com.nanqipro.security;

import com.nanqipro.entity.User;
import com.nanqipro.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.stream.Collectors;

/**
 * 用户详情服务实现类
 */
@Slf4j
@Service
public class UserDetailsServiceImpl implements UserDetailsService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        log.debug("加载用户信息: {}", username);
        
        User user = userRepository.findByUsernameOrEmail(username, username)
                .orElseThrow(() -> new UsernameNotFoundException("用户不存在: " + username));
        
        if (!user.getEnabled()) {
            throw new UsernameNotFoundException("用户已被禁用: " + username);
        }
        
        return UserPrincipal.create(user);
    }
    
    /**
     * 根据用户ID加载用户信息
     */
    @Transactional(readOnly = true)
    public UserDetails loadUserById(Long id) {
        log.debug("根据ID加载用户信息: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("用户不存在，ID: " + id));
        
        if (!user.getEnabled()) {
            throw new UsernameNotFoundException("用户已被禁用，ID: " + id);
        }
        
        return UserPrincipal.create(user);
    }
    
    /**
     * 用户主体类
     */
    public static class UserPrincipal implements UserDetails {
        private Long id;
        private String username;
        private String email;
        private String password;
        private Collection<? extends GrantedAuthority> authorities;
        private boolean enabled;
        private boolean emailVerified;
        
        public UserPrincipal(Long id, String username, String email, String password, 
                             Collection<? extends GrantedAuthority> authorities, 
                             boolean enabled, boolean emailVerified) {
            this.id = id;
            this.username = username;
            this.email = email;
            this.password = password;
            this.authorities = authorities;
            this.enabled = enabled;
            this.emailVerified = emailVerified;
        }
        
        public static UserPrincipal create(User user) {
            Collection<GrantedAuthority> authorities = user.getRoles().stream()
                    .map(role -> new SimpleGrantedAuthority("ROLE_" + role.name()))
                    .collect(Collectors.toList());
            
            return new UserPrincipal(
                    user.getId(),
                    user.getUsername(),
                    user.getEmail(),
                    user.getPassword(),
                    authorities,
                    user.getEnabled(),
                    user.getEmailVerified()
            );
        }
        
        public Long getId() {
            return id;
        }
        
        public String getEmail() {
            return email;
        }
        
        public boolean isEmailVerified() {
            return emailVerified;
        }
        
        @Override
        public String getUsername() {
            return username;
        }
        
        @Override
        public String getPassword() {
            return password;
        }
        
        @Override
        public Collection<? extends GrantedAuthority> getAuthorities() {
            return authorities;
        }
        
        @Override
        public boolean isAccountNonExpired() {
            return true;
        }
        
        @Override
        public boolean isAccountNonLocked() {
            return true;
        }
        
        @Override
        public boolean isCredentialsNonExpired() {
            return true;
        }
        
        @Override
        public boolean isEnabled() {
            return enabled;
        }
        
        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            UserPrincipal that = (UserPrincipal) o;
            return id.equals(that.id);
        }
        
        @Override
        public int hashCode() {
            return id.hashCode();
        }
    }
}