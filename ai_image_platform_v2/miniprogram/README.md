# AI图像处理平台 - 微信小程序

这是一个基于微信小程序的AI图像处理平台，提供美颜、证件照制作、背景处理等功能。

## 项目结构

```
miniprogram/
├── app.js                 # 小程序入口文件
├── app.json              # 小程序全局配置
├── app.wxss              # 小程序全局样式
├── project.config.json   # 项目配置文件
├── sitemap.json          # 站点地图配置
├── pages/                # 页面目录
│   ├── index/           # 首页
│   ├── login/           # 登录页
│   ├── beauty/          # 美颜处理页
│   ├── idphoto/         # 证件照制作页
│   ├── background/      # 背景处理页
│   ├── history/         # 历史记录页
│   └── profile/         # 个人中心页
├── components/          # 自定义组件
│   ├── image-cropper/   # 图片裁剪组件
│   └── loading/         # 加载组件
└── utils/               # 工具函数
    ├── api.js          # API接口封装
    ├── request.js      # 网络请求工具
    └── util.js         # 通用工具函数
```

## 主要功能

### 1. 用户系统
- 微信登录
- 用户信息管理
- 历史记录查看

### 2. 图像处理功能
- **美颜处理**: 磨皮、美白、瘦脸等
- **证件照制作**: 自动抠图、背景替换、尺寸调整
- **背景处理**: 背景移除、背景替换、背景模糊

### 3. 图片管理
- 图片上传和预览
- 处理历史记录
- 图片下载和分享

## 技术特点

### 1. 组件化开发
- 自定义图片裁剪组件
- 可复用的加载组件
- 模块化的页面结构

### 2. API集成
- 统一的API服务层
- 完善的错误处理
- 自动token管理

### 3. 用户体验
- 响应式设计
- 流畅的动画效果
- 深色模式支持

## 开发指南

### 1. 环境准备
1. 安装微信开发者工具
2. 获取小程序AppID
3. 配置后端API地址

### 2. 配置说明

#### app.js 全局配置
```javascript
globalData: {
  baseUrl: 'https://your-api-domain.com/api', // 修改为实际API地址
  // 其他配置...
}
```

#### project.config.json 项目配置
```json
{
  "appid": "your-app-id", // 修改为实际AppID
  // 其他配置...
}
```

### 3. API接口

所有API接口都在 `utils/api.js` 中定义，主要包括：

- **用户相关**: 登录、注册、用户信息
- **图片处理**: 美颜、证件照、背景处理
- **文件上传**: 图片上传和下载
- **历史记录**: 处理记录管理

### 4. 组件使用

#### 图片裁剪组件
```xml
<image-cropper
  visible="{{showCropper}}"
  image-path="{{imagePath}}"
  default-aspect-ratio="{{1}}"
  bind:confirm="onCropConfirm"
  bind:cancel="onCropCancel"
/>
```

#### 加载组件
```xml
<loading
  visible="{{loading}}"
  text="处理中..."
  type="circle"
  show-progress="{{true}}"
  progress="{{progress}}"
/>
```

## 部署说明

### 1. 开发环境
1. 用微信开发者工具打开项目
2. 修改 `app.js` 中的 `baseUrl` 为开发环境API地址
3. 点击编译运行

### 2. 生产环境
1. 修改 `app.js` 中的 `baseUrl` 为生产环境API地址
2. 在微信开发者工具中点击上传
3. 在微信公众平台提交审核

## 注意事项

### 1. 权限配置
确保在 `app.json` 中配置了必要的权限：
```json
{
  "permission": {
    "scope.userInfo": {
      "desc": "用于完善用户资料"
    },
    "scope.writePhotosAlbum": {
      "desc": "用于保存处理后的图片"
    }
  }
}
```

### 2. 网络配置
在微信公众平台配置服务器域名，包括：
- request合法域名
- uploadFile合法域名
- downloadFile合法域名

### 3. 图片处理
- 支持的图片格式：jpg, png, webp
- 最大图片尺寸：10MB
- 建议图片分辨率：不超过4096x4096

## 常见问题

### 1. 图片上传失败
- 检查网络连接
- 确认API地址配置正确
- 检查图片格式和大小

### 2. 处理速度慢
- 建议压缩图片后再处理
- 检查网络环境
- 联系后端优化处理算法

### 3. 登录问题
- 确认AppID配置正确
- 检查微信登录权限
- 确认后端登录接口正常

## 更新日志

### v1.0.0 (2024-01-20)
- 初始版本发布
- 实现基础图像处理功能
- 完成用户系统和历史记录

## 技术支持

如有问题，请联系开发团队或查看项目文档。