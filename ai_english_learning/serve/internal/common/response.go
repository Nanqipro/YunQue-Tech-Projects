package common

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// Response 通用响应结构
type Response struct {
	Code      int         `json:"code"`
	Message   string      `json:"message"`
	Data      interface{} `json:"data,omitempty"`
	Timestamp string      `json:"timestamp"`
}

// PaginationResponse 分页响应结构
type PaginationResponse struct {
	Code      int         `json:"code"`
	Message   string      `json:"message"`
	Data      interface{} `json:"data"`
	Timestamp string      `json:"timestamp"`
}

// PaginationData 分页数据结构
type PaginationData struct {
	Items      interface{}  `json:"items"`
	Pagination *Pagination `json:"pagination"`
}

// Pagination 分页信息
type Pagination struct {
	Page       int `json:"page"`
	PageSize   int `json:"page_size"`
	Total      int `json:"total"`
	TotalPages int `json:"total_pages"`
}

// SuccessResponse 成功响应
func SuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, Response{
		Code:      http.StatusOK,
		Message:   "success",
		Data:      data,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	})
}

// SuccessWithMessage 带消息的成功响应
func SuccessWithMessage(c *gin.Context, message string, data interface{}) {
	c.JSON(http.StatusOK, Response{
		Code:      http.StatusOK,
		Message:   message,
		Data:      data,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	})
}

// PaginationSuccessResponse 分页成功响应
func PaginationSuccessResponse(c *gin.Context, items interface{}, pagination *Pagination) {
	c.JSON(http.StatusOK, PaginationResponse{
		Code:    http.StatusOK,
		Message: "success",
		Data: PaginationData{
			Items:      items,
			Pagination: pagination,
		},
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	})
}

// ErrorResponse 错误响应
func ErrorResponse(c *gin.Context, code int, message string) {
	c.JSON(code, Response{
		Code:      code,
		Message:   message,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	})
}

// BadRequestResponse 400错误响应
func BadRequestResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusBadRequest, message)
}

// UnauthorizedResponse 401错误响应
func UnauthorizedResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusUnauthorized, message)
}

// ForbiddenResponse 403错误响应
func ForbiddenResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusForbidden, message)
}

// NotFoundResponse 404错误响应
func NotFoundResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusNotFound, message)
}

// InternalServerErrorResponse 500错误响应
func InternalServerErrorResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusInternalServerError, message)
}

// ValidationErrorResponse 参数验证错误响应
func ValidationErrorResponse(c *gin.Context, errors interface{}) {
	c.JSON(http.StatusBadRequest, Response{
		Code:      http.StatusBadRequest,
		Message:   "参数验证失败",
		Data:      errors,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	})
}