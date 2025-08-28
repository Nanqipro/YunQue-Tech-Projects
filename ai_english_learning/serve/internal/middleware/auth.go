package middleware

import (
	"net/http"
	"strings"
	"time"

	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/config"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/common"
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/internal/utils"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// JWTClaims JWT声明结构
type JWTClaims struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Type     string `json:"type"` // access, refresh
	jwt.RegisteredClaims
}

// GenerateTokens 生成访问令牌和刷新令牌
func GenerateTokens(userID, username, email string) (accessToken, refreshToken string, err error) {
	cfg := config.GlobalConfig
	now := time.Now()
	
	// 生成访问令牌
	accessClaims := JWTClaims{
		UserID:   userID,
		Username: username,
		Email:    email,
		Type:     "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(time.Duration(cfg.JWT.AccessTokenTTL) * time.Second)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    cfg.App.Name,
			Subject:   userID,
			ID:        utils.GenerateUUID(),
		},
	}
	
	accessTokenObj := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessToken, err = accessTokenObj.SignedString([]byte(cfg.JWT.Secret))
	if err != nil {
		return "", "", err
	}
	
	// 生成刷新令牌
	refreshClaims := JWTClaims{
		UserID:   userID,
		Username: username,
		Email:    email,
		Type:     "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(time.Duration(cfg.JWT.RefreshTokenTTL) * time.Second)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    cfg.App.Name,
			Subject:   userID,
			ID:        utils.GenerateUUID(),
		},
	}
	
	refreshTokenObj := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshToken, err = refreshTokenObj.SignedString([]byte(cfg.JWT.Secret))
	if err != nil {
		return "", "", err
	}
	
	return accessToken, refreshToken, nil
}

// ParseToken 解析JWT令牌
func ParseToken(tokenString string) (*JWTClaims, error) {
	cfg := config.GlobalConfig
	
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(cfg.JWT.Secret), nil
	})
	
	if err != nil {
		return nil, err
	}
	
	if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
		return claims, nil
	}
	
	return nil, jwt.ErrInvalidKey
}

// AuthMiddleware JWT认证中间件
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 从请求头获取token
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			common.UnauthorizedResponse(c, "缺少认证令牌")
			c.Abort()
			return
		}
		
		// 检查Bearer前缀
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			common.UnauthorizedResponse(c, "认证令牌格式错误")
			c.Abort()
			return
		}
		
		tokenString := parts[1]
		
		// 解析token
		claims, err := ParseToken(tokenString)
		if err != nil {
			if err == jwt.ErrTokenExpired {
				common.ErrorResponse(c, http.StatusUnauthorized, "访问令牌已过期")
			} else {
				common.UnauthorizedResponse(c, "无效的访问令牌")
			}
			c.Abort()
			return
		}
		
		// 检查token类型
		if claims.Type != "access" {
			common.UnauthorizedResponse(c, "令牌类型错误")
			c.Abort()
			return
		}
		
		// 将用户信息存储到上下文中
		c.Set("user_id", claims.UserID)
		c.Set("username", claims.Username)
		c.Set("email", claims.Email)
		
		c.Next()
	}
}

// OptionalAuthMiddleware 可选认证中间件（不强制要求登录）
func OptionalAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 从请求头获取token
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}
		
		// 检查Bearer前缀
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.Next()
			return
		}
		
		tokenString := parts[1]
		
		// 解析token
		claims, err := ParseToken(tokenString)
		if err != nil {
			c.Next()
			return
		}
		
		// 检查token类型
		if claims.Type != "access" {
			c.Next()
			return
		}
		
		// 将用户信息存储到上下文中
		c.Set("user_id", claims.UserID)
		c.Set("username", claims.Username)
		c.Set("email", claims.Email)
		
		c.Next()
	}
}