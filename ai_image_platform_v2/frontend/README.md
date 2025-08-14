# AI图像处理平台 - 前端

这是AI图像处理平台的前端部分，使用现代Web技术构建的响应式单页应用。

## 技术栈

- **HTML5** - 语义化标记
- **CSS3** - 现代样式和动画
- **JavaScript (ES6+)** - 核心逻辑
- **jQuery** - DOM操作和AJAX
- **Webpack** - 模块打包和构建
- **PostCSS** - CSS后处理
- **Babel** - JavaScript转译

## 项目结构

```
frontend/
├── public/                 # 静态资源
│   └── index.html         # 主HTML文件
├── src/                   # 源代码
│   ├── api/              # API接口
│   │   └── api.js        # API客户端
│   ├── assets/           # 资源文件
│   │   ├── css/          # 样式文件
│   │   │   ├── style.css # 主样式
│   │   │   ├── modal.css # 模态框样式
│   │   │   └── notifications.css # 通知样式
│   │   ├── js/           # JavaScript文件
│   │   │   └── main.js   # 主逻辑
│   │   └── images/       # 图片资源
│   ├── components/       # 组件（预留）
│   ├── pages/           # 页面（预留）
│   └── utils/           # 工具函数（预留）
├── dist/                # 构建输出
├── tests/               # 测试文件
├── package.json         # 项目配置
├── webpack.config.js    # Webpack配置
└── README.md           # 项目说明
```

## 功能特性

### 🎨 图像处理工具
- **美颜功能**: 磨皮、美白、眼部增强、唇部增强
- **滤镜效果**: 复古、黑白、棕褐、冷色调、暖色调
- **颜色调整**: 亮度、对比度、饱和度、色相
- **背景处理**: 背景虚化、边缘羽化
- **智能修复**: 噪点去除、划痕修复

### 🖥️ 用户界面
- **响应式设计**: 适配桌面、平板、手机
- **现代UI**: 渐变背景、圆角设计、阴影效果
- **交互动画**: 平滑过渡、悬停效果
- **拖拽上传**: 支持拖拽文件上传
- **实时预览**: 参数调整实时预览

### 🔧 开发特性
- **模块化架构**: ES6模块、组件化设计
- **构建优化**: Webpack打包、代码分割
- **开发工具**: 热重载、源码映射
- **代码质量**: ESLint、Prettier
- **性能优化**: 资源压缩、缓存策略

## 快速开始

### 环境要求

- Node.js >= 14.0.0
- npm >= 6.0.0

### 安装依赖

```bash
cd frontend
npm install
```

### 开发模式

```bash
# 启动开发服务器
npm run dev

# 或使用Webpack开发服务器
npm run watch
```

访问 http://localhost:3000

### 生产构建

```bash
# 构建生产版本
npm run build

# 预览构建结果
npm run preview
```

## 开发指南

### 添加新功能

1. **添加新工具**:
   - 在 `main.js` 中添加工具面板函数
   - 在 `style.css` 中添加相应样式
   - 在 `api.js` 中添加API调用

2. **添加新页面**:
   - 在 `src/pages/` 中创建页面文件
   - 在 `src/components/` 中创建可复用组件
   - 更新路由配置

3. **添加新样式**:
   - 在 `src/assets/css/` 中创建样式文件
   - 在主样式文件中导入
   - 使用BEM命名规范

### 代码规范

```bash
# 代码检查
npm run lint

# 自动修复
npm run lint:fix

# 代码格式化
npm run format
```

### 测试

```bash
# 运行测试
npm test

# 监听模式
npm run test:watch
```

## API集成

### 配置API地址

在 `src/api/api.js` 中配置后端API地址：

```javascript
const API_CONFIG = {
    baseURL: 'http://localhost:5000/api',
    timeout: 30000
};
```

### 使用API

```javascript
// 上传图片
const response = await API.imageAPI.upload(file);

// 处理图片
const result = await API.processingAPI.beauty(imageId, params);

// 用户登录
const user = await API.userAPI.login(credentials);
```

## 部署

### 静态部署

```bash
# 构建生产版本
npm run build

# 部署dist目录到静态服务器
cp -r dist/* /var/www/html/
```

### Nginx配置

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/html;
    index index.html;
    
    # 处理单页应用路由
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API代理
    location /api {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Docker部署

```dockerfile
# Dockerfile
FROM node:16-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 性能优化

### 图片优化
- 使用WebP格式
- 实现懒加载
- 生成多尺寸缩略图

### 代码优化
- 代码分割和懒加载
- Tree Shaking去除无用代码
- 压缩和混淆

### 缓存策略
- 静态资源长期缓存
- API响应缓存
- Service Worker离线缓存

## 浏览器支持

- Chrome >= 60
- Firefox >= 60
- Safari >= 12
- Edge >= 79

## 故障排除

### 常见问题

1. **构建失败**
   - 检查Node.js版本
   - 清除node_modules重新安装
   - 检查依赖版本兼容性

2. **API调用失败**
   - 检查后端服务是否启动
   - 检查API地址配置
   - 检查CORS设置

3. **样式问题**
   - 检查CSS文件导入
   - 检查浏览器兼容性
   - 清除浏览器缓存

### 调试工具

- Chrome DevTools
- Vue DevTools (如果使用Vue)
- Webpack Bundle Analyzer

## 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 许可证

MIT License

## 联系方式

- 项目地址: https://github.com/your-username/ai-image-platform
- 问题反馈: https://github.com/your-username/ai-image-platform/issues
- 邮箱: your-email@example.com