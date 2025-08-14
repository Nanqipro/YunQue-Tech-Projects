# AI模型集成文档

## 概述

本平台集成了阿里云通义千问大模型，提供智能图像分析和处理建议功能。通过AI模型，用户可以获得专业的图像分析报告、美颜建议、风格推荐等智能服务。

## 功能特性

### 🔍 图像分析
- **内容识别**: 自动识别图片中的物体、场景、人物等
- **质量评估**: 分析图片的清晰度、曝光、色彩等质量指标
- **构图分析**: 评估图片的构图规则和视觉效果
- **风格识别**: 识别图片的艺术风格和拍摄风格

### 💄 美颜建议
- **皮肤分析**: 分析皮肤状态，提供磨皮建议
- **五官优化**: 针对眼部、唇部等提供增强建议
- **光线评估**: 分析光线条件，建议调整参数
- **整体优化**: 提供综合的美颜处理方案

### 🎨 风格推荐
- **滤镜推荐**: 根据图片内容推荐合适的滤镜
- **色调建议**: 提供色彩调整的具体参数
- **艺术风格**: 推荐适合的艺术处理风格
- **后期建议**: 提供专业的后期处理建议

### 📐 构图优化
- **构图类型**: 识别当前构图类型
- **视觉焦点**: 分析图片的视觉重点
- **平衡性**: 评估画面的平衡性
- **裁剪建议**: 提供优化的裁剪方案

## 配置说明

### 1. 获取API密钥

1. 访问 [阿里云DashScope控制台](https://dashscope.console.aliyun.com/)
2. 注册并登录阿里云账号
3. 开通DashScope服务
4. 创建API密钥
5. 复制API密钥备用

### 2. 环境配置

复制 `.env.example` 为 `.env` 并配置以下参数：

```bash
# 通义千问API配置
QWEN_API_KEY=your-qwen-api-key-here
QWEN_MODEL_NAME=qwen-turbo
QWEN_VL_MODEL_NAME=qwen-vl-plus

# AI功能开关
ENABLE_IMAGE_ANALYSIS=true
ENABLE_SMART_ENHANCEMENT=true
ENABLE_STYLE_TRANSFER=true
ENABLE_OBJECT_DETECTION=true
ENABLE_FACE_RECOGNITION=true
```

### 3. 安装依赖

```bash
pip install -r requirements.txt
```

主要新增依赖：
- `dashscope>=1.14.0` - 通义千问官方SDK
- `alibabacloud_tea_openapi>=0.3.7` - 阿里云SDK
- `orjson>=3.9.0` - 高性能JSON处理

## API接口

### 图像分析

```http
POST /api/ai/analyze
Content-Type: application/json
Authorization: Bearer <token>

{
    "image_id": 123,
    "analysis_type": "general_analysis"
}
```

**分析类型**:
- `general_analysis` - 综合分析
- `beauty_analysis` - 美颜分析
- `style_recommendation` - 风格推荐
- `composition_analysis` - 构图分析

### 美颜建议

```http
POST /api/ai/beauty-suggestions
Content-Type: application/json
Authorization: Bearer <token>

{
    "image_id": 123
}
```

### 风格推荐

```http
POST /api/ai/style-recommendations
Content-Type: application/json
Authorization: Bearer <token>

{
    "image_id": 123
}
```

### 处理建议

```http
POST /api/ai/processing-suggestions
Content-Type: application/json
Authorization: Bearer <token>

{
    "image_id": 123
}
```

### 配置信息

```http
GET /api/ai/config
Authorization: Bearer <token>
```

### 健康检查

```http
GET /api/ai/health
```

## 响应格式

### 成功响应

```json
{
    "success": true,
    "message": "分析完成",
    "analysis": "这是一张人像照片，主体清晰，光线充足...",
    "analysis_type": "general_analysis"
}
```

### 处理建议响应

```json
{
    "success": true,
    "message": "建议生成完成",
    "suggestions": [
        {
            "type": "beauty",
            "title": "美颜处理",
            "description": "检测到人像，建议进行美颜处理",
            "params": {
                "smoothing": 30,
                "whitening": 20,
                "eye_enhancement": 15,
                "lip_enhancement": 10
            },
            "priority": "high"
        }
    ],
    "analysis": "详细的分析结果..."
}
```

### 错误响应

```json
{
    "success": false,
    "message": "分析失败: API密钥无效"
}
```

## 配置参数说明

### AI模型参数

| 参数 | 说明 | 默认值 | 范围 |
|------|------|--------|------|
| `TEMPERATURE` | 生成文本的随机性 | 0.7 | 0.0-1.0 |
| `MAX_TOKENS` | 最大生成token数 | 2000 | 1-4000 |
| `TOP_P` | 核采样参数 | 0.8 | 0.0-1.0 |
| `REQUEST_TIMEOUT` | 请求超时时间(秒) | 30 | 5-120 |
| `MAX_RETRIES` | 最大重试次数 | 3 | 1-10 |

### 功能开关

| 开关 | 说明 | 默认值 |
|------|------|--------|
| `ENABLE_IMAGE_ANALYSIS` | 图像分析功能 | true |
| `ENABLE_SMART_ENHANCEMENT` | 智能增强功能 | true |
| `ENABLE_STYLE_TRANSFER` | 风格转换功能 | true |
| `ENABLE_OBJECT_DETECTION` | 物体检测功能 | true |
| `ENABLE_FACE_RECOGNITION` | 人脸识别功能 | true |

## 使用示例

### Python客户端示例

```python
import requests

# 获取访问令牌
auth_response = requests.post('http://localhost:5002/api/users/login', json={
    'username': 'demo',
    'password': 'demo123'
})
token = auth_response.json()['access_token']

# 上传图片
with open('test_image.jpg', 'rb') as f:
    upload_response = requests.post(
        'http://localhost:5002/api/images/upload',
        files={'file': f},
        headers={'Authorization': f'Bearer {token}'}
    )
image_id = upload_response.json()['image']['id']

# 分析图片
analysis_response = requests.post(
    'http://localhost:5002/api/ai/analyze',
    json={'image_id': image_id, 'analysis_type': 'general_analysis'},
    headers={'Authorization': f'Bearer {token}'}
)
print(analysis_response.json()['analysis'])

# 获取处理建议
suggestions_response = requests.post(
    'http://localhost:5002/api/ai/processing-suggestions',
    json={'image_id': image_id},
    headers={'Authorization': f'Bearer {token}'}
)
print(suggestions_response.json()['suggestions'])
```

### JavaScript客户端示例

```javascript
// 分析图片
async function analyzeImage(imageId, token) {
    const response = await fetch('/api/ai/analyze', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
            image_id: imageId,
            analysis_type: 'general_analysis'
        })
    });
    
    const result = await response.json();
    if (result.success) {
        console.log('分析结果:', result.analysis);
    } else {
        console.error('分析失败:', result.message);
    }
}

// 获取美颜建议
async function getBeautySuggestions(imageId, token) {
    const response = await fetch('/api/ai/beauty-suggestions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ image_id: imageId })
    });
    
    const result = await response.json();
    if (result.success) {
        console.log('美颜建议:', result.analysis);
    }
}
```

## 故障排除

### 常见问题

1. **API密钥无效**
   - 检查 `QWEN_API_KEY` 是否正确配置
   - 确认API密钥是否已激活
   - 检查账户余额是否充足

2. **请求超时**
   - 增加 `AI_REQUEST_TIMEOUT` 值
   - 检查网络连接
   - 尝试使用更小的图片

3. **功能被禁用**
   - 检查相关功能开关是否为 `true`
   - 确认环境配置是否正确加载

4. **图片格式不支持**
   - 确认图片格式在支持列表中
   - 检查图片大小是否超过限制

### 调试方法

1. **启用调试日志**
   ```bash
   export FLASK_DEBUG=true
   export LOG_LEVEL=DEBUG
   ```

2. **测试API连接**
   ```http
   GET /api/ai/test-connection
   Authorization: Bearer <admin-token>
   ```

3. **检查健康状态**
   ```http
   GET /api/ai/health
   ```

## 性能优化

### 1. 图片预处理
- 压缩大图片以减少传输时间
- 使用适当的图片格式
- 设置合理的图片质量阈值

### 2. 缓存策略
- 缓存分析结果避免重复请求
- 使用Redis存储常用分析结果
- 设置合理的缓存过期时间

### 3. 并发控制
- 限制同时进行的AI请求数量
- 使用队列处理大量请求
- 实现请求优先级机制

## 安全考虑

### 1. API密钥保护
- 不要在代码中硬编码API密钥
- 使用环境变量存储敏感信息
- 定期轮换API密钥

### 2. 数据隐私
- 图片数据仅用于分析，不会被存储
- 分析结果可选择性保存
- 遵循数据保护法规

### 3. 访问控制
- 实现用户认证和授权
- 限制API调用频率
- 记录和监控API使用情况

## 费用说明

通义千问API按调用次数计费，具体费用请参考[阿里云DashScope定价](https://help.aliyun.com/zh/dashscope/developer-reference/api-details)。

建议：
- 在开发环境使用较小的模型以节省成本
- 实现结果缓存减少重复调用
- 监控API使用量避免超出预算

## 更新日志

### v1.0.0 (2024-01-XX)
- 集成通义千问文本和视觉模型
- 实现图像分析功能
- 添加美颜建议功能
- 支持风格推荐
- 提供构图分析
- 实现智能处理建议

## 技术支持

如有问题，请参考：
- [阿里云DashScope文档](https://help.aliyun.com/zh/dashscope/)
- [通义千问API文档](https://help.aliyun.com/zh/dashscope/developer-reference/api-details)
- 项目GitHub Issues