// api/handlers/hello_handler.go
package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// HelloHandler 处理 /hello 请求
func HelloHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "Hello from a structured project!",
	})
}
