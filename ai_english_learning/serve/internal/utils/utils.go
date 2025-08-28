package utils

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

// HashPassword 对密码进行哈希加密
func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(bytes), err
}

// CheckPasswordHash 验证密码哈希
func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// GenerateUUID 生成UUID
func GenerateUUID() string {
	return uuid.New().String()
}

// GenerateRandomString 生成指定长度的随机字符串
func GenerateRandomString(length int) (string, error) {
	bytes := make([]byte, length/2)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil
}

// IsValidEmail 验证邮箱格式
func IsValidEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	regex := regexp.MustCompile(pattern)
	return regex.MatchString(email)
}

// IsValidPhone 验证手机号格式（中国大陆）
func IsValidPhone(phone string) bool {
	pattern := `^1[3-9]\d{9}$`
	regex := regexp.MustCompile(pattern)
	return regex.MatchString(phone)
}

// IsStrongPassword 验证密码强度
func IsStrongPassword(password string) bool {
	if len(password) < 8 {
		return false
	}
	
	// 至少包含一个数字
	hasNumber := regexp.MustCompile(`[0-9]`).MatchString(password)
	// 至少包含一个小写字母
	hasLower := regexp.MustCompile(`[a-z]`).MatchString(password)
	// 至少包含一个大写字母
	hasUpper := regexp.MustCompile(`[A-Z]`).MatchString(password)
	// 至少包含一个特殊字符
	hasSpecial := regexp.MustCompile(`[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]`).MatchString(password)
	
	return hasNumber && hasLower && hasUpper && hasSpecial
}

// GetPaginationParams 从请求中获取分页参数
func GetPaginationParams(c *gin.Context) (page, pageSize int) {
	pageStr := c.DefaultQuery("page", "1")
	pageSizeStr := c.DefaultQuery("page_size", "20")
	
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}
	
	pageSize, err = strconv.Atoi(pageSizeStr)
	if err != nil || pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	
	return page, pageSize
}

// CalculateOffset 计算数据库查询偏移量
func CalculateOffset(page, pageSize int) int {
	return (page - 1) * pageSize
}

// CalculateTotalPages 计算总页数
func CalculateTotalPages(total, pageSize int) int {
	if total == 0 {
		return 0
	}
	return (total + pageSize - 1) / pageSize
}

// StringToInt 字符串转整数，带默认值
func StringToInt(str string, defaultValue int) int {
	if str == "" {
		return defaultValue
	}
	value, err := strconv.Atoi(str)
	if err != nil {
		return defaultValue
	}
	return value
}

// StringToBool 字符串转布尔值，带默认值
func StringToBool(str string, defaultValue bool) bool {
	if str == "" {
		return defaultValue
	}
	value, err := strconv.ParseBool(str)
	if err != nil {
		return defaultValue
	}
	return value
}

// TrimSpaces 去除字符串前后空格
func TrimSpaces(str string) string {
	return strings.TrimSpace(str)
}

// FormatTime 格式化时间
func FormatTime(t time.Time) string {
	return t.Format("2006-01-02 15:04:05")
}

// ParseTime 解析时间字符串
func ParseTime(timeStr string) (time.Time, error) {
	return time.Parse("2006-01-02 15:04:05", timeStr)
}

// GetUserIDFromContext 从Gin上下文中获取用户ID
func GetUserIDFromContext(c *gin.Context) (string, bool) {
	userID, exists := c.Get("user_id")
	if !exists {
		return "", false
	}
	if id, ok := userID.(string); ok {
		return id, true
	}
	return "", false
}

// SetUserIDToContext 将用户ID设置到Gin上下文中
func SetUserIDToContext(c *gin.Context, userID string) {
	c.Set("user_id", userID)
}

// Contains 检查切片是否包含指定元素
func Contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

// RemoveDuplicates 去除字符串切片中的重复元素
func RemoveDuplicates(slice []string) []string {
	keys := make(map[string]bool)
	result := []string{}
	
	for _, item := range slice {
		if !keys[item] {
			keys[item] = true
			result = append(result, item)
		}
	}
	
	return result
}

// GenerateFileName 生成文件名
func GenerateFileName(originalName string) string {
	ext := ""
	if dotIndex := strings.LastIndex(originalName, "."); dotIndex != -1 {
		ext = originalName[dotIndex:]
	}
	return fmt.Sprintf("%d_%s%s", time.Now().Unix(), GenerateUUID()[:8], ext)
}

// GetClientIP 获取客户端IP地址
func GetClientIP(c *gin.Context) string {
	// 尝试从X-Forwarded-For头获取
	if ip := c.GetHeader("X-Forwarded-For"); ip != "" {
		if index := strings.Index(ip, ","); index != -1 {
			return strings.TrimSpace(ip[:index])
		}
		return strings.TrimSpace(ip)
	}
	
	// 尝试从X-Real-IP头获取
	if ip := c.GetHeader("X-Real-IP"); ip != "" {
		return strings.TrimSpace(ip)
	}
	
	// 使用RemoteAddr
	return c.ClientIP()
}