package utils

import (
	"errors"
	"time"

	"ai_english_learning/config"
	"github.com/golang-jwt/jwt/v5"
)

// Claims JWT声明结构
type Claims struct {
	UserID   uint   `json:"user_id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	jwt.RegisteredClaims
}

// GenerateToken 生成JWT token
func GenerateToken(userID uint, username, email string) (string, error) {
	now := time.Now()
	expireTime := now.Add(time.Duration(config.AppConfig.JWT.ExpireTime) * time.Hour)

	claims := Claims{
		UserID:   userID,
		Username: username,
		Email:    email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expireTime),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    config.AppConfig.App.Name,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(config.AppConfig.JWT.Secret))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// ParseToken 解析JWT token
func ParseToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(config.AppConfig.JWT.Secret), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid token")
}

// RefreshToken 刷新token
func RefreshToken(tokenString string) (string, error) {
	claims, err := ParseToken(tokenString)
	if err != nil {
		return "", err
	}

	// 检查token是否即将过期（在过期前1小时内可以刷新）
	if time.Until(claims.ExpiresAt.Time) > time.Hour {
		return "", errors.New("token is not close to expiration")
	}

	// 生成新token
	return GenerateToken(claims.UserID, claims.Username, claims.Email)
}

// ValidateToken 验证token是否有效
func ValidateToken(tokenString string) bool {
	_, err := ParseToken(tokenString)
	return err == nil
}