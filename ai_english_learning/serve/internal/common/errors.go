package common

import "errors"

// 业务错误码定义
const (
	// 通用错误码 1000-1999
	ErrCodeSuccess           = 200
	ErrCodeBadRequest        = 400
	ErrCodeUnauthorized      = 401
	ErrCodeForbidden         = 403
	ErrCodeNotFound          = 404
	ErrCodeInternalError     = 500
	ErrCodeValidationFailed  = 1001
	ErrCodeDatabaseError     = 1002
	ErrCodeRedisError        = 1003

	// 用户相关错误码 2000-2999
	ErrCodeUserNotFound      = 2001
	ErrCodeUserExists        = 2002
	ErrCodeInvalidPassword   = 2003
	ErrCodeUserDisabled      = 2004
	ErrCodeEmailExists       = 2005
	ErrCodeUsernameExists    = 2006
	ErrCodeInvalidEmail      = 2007
	ErrCodePasswordTooWeak   = 2008

	// 认证相关错误码 3000-3999
	ErrCodeInvalidToken      = 3001
	ErrCodeTokenExpired      = 3002
	ErrCodeTokenNotFound     = 3003
	ErrCodeRefreshTokenInvalid = 3004
	ErrCodeLoginRequired     = 3005

	// 词汇相关错误码 4000-4999
	ErrCodeVocabularyNotFound = 4001
	ErrCodeCategoryNotFound   = 4002
	ErrCodeWordExists         = 4003
	ErrCodeInvalidDifficulty  = 4004

	// 学习相关错误码 5000-5999
	ErrCodeProgressNotFound   = 5001
	ErrCodeInvalidScore       = 5002
	ErrCodeTestNotFound       = 5003
	ErrCodeExerciseNotFound   = 5004

	// 文件相关错误码 6000-6999
	ErrCodeFileUploadFailed   = 6001
	ErrCodeFileNotFound       = 6002
	ErrCodeInvalidFileType    = 6003
	ErrCodeFileTooLarge       = 6004

	// AI相关错误码 7000-7999
	ErrCodeAIServiceUnavailable = 7001
	ErrCodeAIProcessingFailed   = 7002
	ErrCodeInvalidAudioFormat   = 7003
	ErrCodeSpeechRecognitionFailed = 7004
)

// 错误消息映射
var ErrorMessages = map[int]string{
	// 通用错误
	ErrCodeSuccess:          "操作成功",
	ErrCodeBadRequest:       "请求参数错误",
	ErrCodeUnauthorized:     "未授权访问",
	ErrCodeForbidden:        "禁止访问",
	ErrCodeNotFound:         "资源不存在",
	ErrCodeInternalError:    "服务器内部错误",
	ErrCodeValidationFailed: "参数验证失败",
	ErrCodeDatabaseError:    "数据库操作失败",
	ErrCodeRedisError:       "缓存操作失败",

	// 用户相关错误
	ErrCodeUserNotFound:    "用户不存在",
	ErrCodeUserExists:      "用户已存在",
	ErrCodeInvalidPassword: "密码错误",
	ErrCodeUserDisabled:    "用户已被禁用",
	ErrCodeEmailExists:     "邮箱已被注册",
	ErrCodeUsernameExists:  "用户名已被注册",
	ErrCodeInvalidEmail:    "邮箱格式不正确",
	ErrCodePasswordTooWeak: "密码强度不够",

	// 认证相关错误
	ErrCodeInvalidToken:        "无效的访问令牌",
	ErrCodeTokenExpired:        "访问令牌已过期",
	ErrCodeTokenNotFound:       "访问令牌不存在",
	ErrCodeRefreshTokenInvalid: "刷新令牌无效",
	ErrCodeLoginRequired:       "请先登录",

	// 词汇相关错误
	ErrCodeVocabularyNotFound: "词汇不存在",
	ErrCodeCategoryNotFound:   "词汇分类不存在",
	ErrCodeWordExists:         "词汇已存在",
	ErrCodeInvalidDifficulty:  "无效的难度等级",

	// 学习相关错误
	ErrCodeProgressNotFound: "学习进度不存在",
	ErrCodeInvalidScore:     "无效的分数",
	ErrCodeTestNotFound:     "测试不存在",
	ErrCodeExerciseNotFound: "练习不存在",

	// 文件相关错误
	ErrCodeFileUploadFailed: "文件上传失败",
	ErrCodeFileNotFound:     "文件不存在",
	ErrCodeInvalidFileType:  "不支持的文件类型",
	ErrCodeFileTooLarge:     "文件大小超出限制",

	// AI相关错误
	ErrCodeAIServiceUnavailable:    "AI服务暂不可用",
	ErrCodeAIProcessingFailed:      "AI处理失败",
	ErrCodeInvalidAudioFormat:      "不支持的音频格式",
	ErrCodeSpeechRecognitionFailed: "语音识别失败",
}

// BusinessError 业务错误结构
type BusinessError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (e *BusinessError) Error() string {
	return e.Message
}

// NewBusinessError 创建业务错误
func NewBusinessError(code int, message string) *BusinessError {
	if message == "" {
		if msg, exists := ErrorMessages[code]; exists {
			message = msg
		} else {
			message = "未知错误"
		}
	}
	return &BusinessError{
		Code:    code,
		Message: message,
	}
}

// 预定义的常用错误
var (
	ErrUserNotFound      = NewBusinessError(ErrCodeUserNotFound, "")
	ErrUserExists        = NewBusinessError(ErrCodeUserExists, "")
	ErrInvalidPassword   = NewBusinessError(ErrCodeInvalidPassword, "")
	ErrInvalidToken      = NewBusinessError(ErrCodeInvalidToken, "")
	ErrTokenExpired      = NewBusinessError(ErrCodeTokenExpired, "")
	ErrEmailExists       = NewBusinessError(ErrCodeEmailExists, "")
	ErrUsernameExists    = NewBusinessError(ErrCodeUsernameExists, "")
	ErrVocabularyNotFound = NewBusinessError(ErrCodeVocabularyNotFound, "")
	ErrVocabularyTestNotFound = NewBusinessError(ErrCodeTestNotFound, "")
	ErrDatabaseError     = NewBusinessError(ErrCodeDatabaseError, "")
)

// 通用系统错误
var (
	ErrInvalidInput = errors.New("invalid input")
	ErrNotFound     = errors.New("not found")
	ErrUnauthorized = errors.New("unauthorized")
	ErrForbidden    = errors.New("forbidden")
)