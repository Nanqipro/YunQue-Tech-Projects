# 微信小程序执行指南

## 前置条件

✅ 您已经安装了 `miniprogram-ci` 工具

## 必要配置步骤

### 1. 配置微信小程序 AppID

编辑 `project.config.json` 文件：

```json
{
  "appid": "your-actual-appid-here",
  // ... 其他配置保持不变
}
```

**获取 AppID 方法：**
- 登录 [微信公众平台](https://mp.weixin.qq.com/)
- 进入小程序管理后台
- 在「设置」→「基本设置」中查看 AppID

### 2. 配置后端 API 地址

#### 方法一：修改 `app.js`

```javascript
globalData: {
  baseUrl: 'http://localhost:5002/api',  // 开发环境
  // baseUrl: 'https://your-domain.com/api',  // 生产环境
  userInfo: null,
  token: null
}
```

#### 方法二：修改 `utils/request.js`

```javascript
const BASE_URL = 'http://localhost:5002';  // 开发环境
// const BASE_URL = 'https://your-domain.com';  // 生产环境
```

### 3. 启动后端服务

在执行小程序之前，确保后端服务正在运行：

```bash
# 在项目根目录
cd /home/nanqipro01/gitlocal/YunQue-Tech-Projects/ai_image_platform_v2/backend
python run.py
```

后端服务将在 `http://localhost:5002` 启动。

## 执行小程序的方法

### 方法一：使用微信开发者工具（推荐）

1. **下载并安装微信开发者工具**
   - 访问：https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html
   - 下载适合您操作系统的版本

2. **导入项目**
   - 打开微信开发者工具
   - 选择「导入项目」
   - 项目目录：`/home/nanqipro01/gitlocal/YunQue-Tech-Projects/ai_image_platform_v2/miniprogram`
   - AppID：输入您的小程序 AppID
   - 项目名称：AI图像处理平台

3. **编译和预览**
   - 点击「编译」按钮
   - 在模拟器中预览小程序
   - 可以点击「预览」生成二维码，在手机微信中扫码体验

### 方法二：使用命令行工具

1. **创建私钥文件**

```bash
# 在小程序目录下创建私钥文件
touch private.key
```

将从微信公众平台下载的私钥内容粘贴到 `private.key` 文件中。

2. **上传代码**

```bash
# 在小程序目录下执行
npx miniprogram-ci upload \
  --pp ./ \
  --pkp ./private.key \
  --appid your-appid \
  --uv 1.0.0 \
  --ud "初始版本"
```

3. **预览代码**

```bash
npx miniprogram-ci preview \
  --pp ./ \
  --pkp ./private.key \
  --appid your-appid \
  --uv 1.0.0 \
  --ud "预览版本" \
  --qr-format terminal
```

### 方法三：本地开发服务器

如果您有微信开发者工具的命令行版本：

```bash
# 启动开发服务器
cli -o --project /home/nanqipro01/gitlocal/YunQue-Tech-Projects/ai_image_platform_v2/miniprogram
```

## 调试和测试

### 1. 网络请求调试

在微信开发者工具中：
- 打开「调试器」→「Network」标签
- 查看 API 请求是否正常
- 检查请求地址是否正确

### 2. 控制台调试

- 打开「调试器」→「Console」标签
- 查看 JavaScript 错误和日志
- 使用 `console.log()` 进行调试

### 3. 真机调试

1. 在微信开发者工具中点击「真机调试」
2. 用手机微信扫描二维码
3. 在手机上进行实际测试

## 常见问题解决

### 1. 网络请求失败

**问题：** API 请求返回错误或超时

**解决方案：**
- 检查后端服务是否启动（`http://localhost:5002`）
- 确认 API 地址配置正确
- 在微信开发者工具中开启「不校验合法域名」

### 2. AppID 相关错误

**问题：** 提示 AppID 无效或未配置

**解决方案：**
- 确认 `project.config.json` 中的 AppID 正确
- 检查 AppID 是否已在微信公众平台注册
- 确保 AppID 对应的小程序状态正常

### 3. 编译错误

**问题：** 小程序编译失败

**解决方案：**
- 检查代码语法错误
- 确认所有必要文件存在
- 查看微信开发者工具的错误提示

### 4. 权限问题

**问题：** 相机、相册等权限被拒绝

**解决方案：**
- 在 `app.json` 中配置必要权限
- 在真机测试时允许相关权限

## 功能测试清单

执行小程序后，建议按以下顺序测试功能：

- [ ] 用户注册和登录
- [ ] 图片上传功能
- [ ] 美颜处理功能
- [ ] 证件照制作功能
- [ ] 背景处理功能
- [ ] 历史记录查看
- [ ] 个人信息管理

## 部署到生产环境

1. **修改 API 地址为生产环境**
2. **上传代码到微信公众平台**
3. **提交审核**
4. **发布上线**

---

## 下一步建议

1. 首先使用**微信开发者工具**进行本地开发和调试
2. 配置正确的 AppID 和 API 地址
3. 确保后端服务正常运行
4. 逐一测试各项功能
5. 进行真机测试验证用户体验

如有问题，请参考微信小程序官方文档：https://developers.weixin.qq.com/miniprogram/dev/framework/