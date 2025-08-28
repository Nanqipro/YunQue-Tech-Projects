// main.go
package main

import (
	"github.com/Nanqipro/YunQue-Tech-Projects/ai_english_learning/serve/api" // 注意修改为你的模块路径
)

func main() {
	// 从 api 包获取配置好的路由引擎
	router := api.SetupRouter()

	// 启动服务
	router.Run(":8080") // 监听在 8080 端口
}
