// API 配置
const API_CONFIG = {
    baseURL: '/api',
    timeout: 30000,
    retryAttempts: 3,
    retryDelay: 1000
};

// API 客户端类
class APIClient {
    constructor(config = {}) {
        this.config = { ...API_CONFIG, ...config };
        this.token = localStorage.getItem('authToken');
    }

    // 设置认证token
    setToken(token) {
        this.token = token;
        if (token) {
            localStorage.setItem('authToken', token);
        } else {
            localStorage.removeItem('authToken');
        }
    }

    // 获取请求头
    getHeaders(contentType = 'application/json') {
        const headers = {
            'Content-Type': contentType
        };

        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }

        return headers;
    }

    // 基础请求方法
    async request(endpoint, options = {}) {
        const url = `${this.config.baseURL}${endpoint}`;
        const config = {
            timeout: this.config.timeout,
            ...options,
            headers: {
                ...this.getHeaders(options.contentType),
                ...options.headers
            }
        };

        try {
            const response = await this.makeRequest(url, config);
            return this.handleResponse(response);
        } catch (error) {
            return this.handleError(error);
        }
    }

    // 发起请求（支持重试）
    async makeRequest(url, config, attempt = 1) {
        try {
            const response = await fetch(url, config);
            return response;
        } catch (error) {
            if (attempt < this.config.retryAttempts) {
                await this.delay(this.config.retryDelay * attempt);
                return this.makeRequest(url, config, attempt + 1);
            }
            throw error;
        }
    }

    // 处理响应
    async handleResponse(response) {
        const contentType = response.headers.get('content-type');
        
        let data;
        if (contentType && contentType.includes('application/json')) {
            data = await response.json();
        } else {
            data = await response.text();
        }

        if (!response.ok) {
            throw new APIError(data.message || 'Request failed', response.status, data);
        }

        return data;
    }

    // 处理错误
    handleError(error) {
        if (error instanceof APIError) {
            throw error;
        }

        if (error.name === 'TypeError' && error.message.includes('fetch')) {
            throw new APIError('网络连接失败', 0);
        }

        throw new APIError(error.message || '未知错误', 0);
    }

    // 延迟函数
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    // GET 请求
    async get(endpoint, params = {}) {
        const queryString = new URLSearchParams(params).toString();
        const url = queryString ? `${endpoint}?${queryString}` : endpoint;
        
        return this.request(url, {
            method: 'GET'
        });
    }

    // POST 请求
    async post(endpoint, data = {}, options = {}) {
        return this.request(endpoint, {
            method: 'POST',
            body: JSON.stringify(data),
            ...options
        });
    }

    // PUT 请求
    async put(endpoint, data = {}) {
        return this.request(endpoint, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    }

    // DELETE 请求
    async delete(endpoint) {
        return this.request(endpoint, {
            method: 'DELETE'
        });
    }

    // 文件上传
    async upload(endpoint, formData) {
        return this.request(endpoint, {
            method: 'POST',
            body: formData,
            contentType: null, // 让浏览器自动设置
            headers: this.token ? { 'Authorization': `Bearer ${this.token}` } : {}
        });
    }
}

// API 错误类
class APIError extends Error {
    constructor(message, status, data = null) {
        super(message);
        this.name = 'APIError';
        this.status = status;
        this.data = data;
    }
}

// 创建API客户端实例
const apiClient = new APIClient();

// 用户相关API
const userAPI = {
    // 用户注册
    async register(userData) {
        return apiClient.post('/users/register', userData);
    },

    // 用户登录
    async login(credentials) {
        const response = await apiClient.post('/users/login', credentials);
        if (response.success && response.data.token) {
            apiClient.setToken(response.data.token);
        }
        return response;
    },

    // 用户登出
    async logout() {
        try {
            await apiClient.post('/users/logout');
        } finally {
            apiClient.setToken(null);
        }
    },

    // 获取用户信息
    async getProfile() {
        return apiClient.get('/users/profile');
    },

    // 更新用户信息
    async updateProfile(userData) {
        return apiClient.put('/users/profile', userData);
    },

    // 修改密码
    async changePassword(passwordData) {
        return apiClient.put('/users/password', passwordData);
    },

    // 获取用户统计
    async getStats() {
        return apiClient.get('/users/stats');
    },

    // 验证token
    async verifyToken() {
        return apiClient.get('/users/verify');
    }
};

// 图片相关API
const imageAPI = {
    // 上传图片
    async upload(file, metadata = {}) {
        const formData = new FormData();
        formData.append('image', file);
        
        // 添加元数据
        Object.keys(metadata).forEach(key => {
            formData.append(key, metadata[key]);
        });
        
        return apiClient.upload('/images/upload', formData);
    },

    // 获取图片列表
    async getList(params = {}) {
        return apiClient.get('/images', params);
    },

    // 获取用户图片
    async getUserImages(params = {}) {
        return apiClient.get('/images/user', params);
    },

    // 获取公共图片
    async getPublicImages(params = {}) {
        return apiClient.get('/images/public', params);
    },

    // 获取图片详情
    async getDetail(imageId) {
        return apiClient.get(`/images/${imageId}`);
    },

    // 更新图片信息
    async update(imageId, data) {
        return apiClient.put(`/images/${imageId}`, data);
    },

    // 删除图片
    async delete(imageId) {
        return apiClient.delete(`/images/${imageId}`);
    },

    // 获取图片缩略图
    async getThumbnail(imageId, size = 'medium') {
        return apiClient.get(`/images/${imageId}/thumbnail`, { size });
    }
};

// 图片处理相关API
const processingAPI = {
    // 美颜处理
    async beauty(imageId, params) {
        return apiClient.post('/processing/beauty', {
            image_id: imageId,
            ...params
        });
    },

    // 滤镜处理
    async filter(imageId, filterType, params = {}) {
        return apiClient.post('/processing/filter', {
            image_id: imageId,
            filter_type: filterType,
            ...params
        });
    },

    // 颜色调整
    async colorAdjust(imageId, params) {
        return apiClient.post('/processing/color', {
            image_id: imageId,
            ...params
        });
    },

    // 背景处理
    async background(imageId, params) {
        return apiClient.post('/processing/background', {
            image_id: imageId,
            ...params
        });
    },

    // 智能修复
    async repair(imageId, params) {
        return apiClient.post('/processing/repair', {
            image_id: imageId,
            ...params
        });
    },

    // 证件照生成
    async idPhoto(imageId, params) {
        return apiClient.post('/processing/id-photo', {
            image_id: imageId,
            ...params
        });
    },

    // 获取处理结果
    async getResult(recordId) {
        return apiClient.get(`/processing/result/${recordId}`);
    },

    // 获取处理记录
    async getRecords(params = {}) {
        return apiClient.get('/processing/records', params);
    },

    // 获取用户处理记录
    async getUserRecords(params = {}) {
        return apiClient.get('/processing/records/user', params);
    },

    // 删除处理记录
    async deleteRecord(recordId) {
        return apiClient.delete(`/processing/records/${recordId}`);
    }
};

// 通用工具函数
const apiUtils = {
    // 处理API错误
    handleError(error) {
        if (error instanceof APIError) {
            switch (error.status) {
                case 401:
                    // 未授权，清除token并跳转登录
                    apiClient.setToken(null);
                    window.location.href = '/login';
                    break;
                case 403:
                    console.error('权限不足');
                    break;
                case 404:
                    console.error('资源不存在');
                    break;
                case 500:
                    console.error('服务器错误');
                    break;
                default:
                    console.error('API错误:', error.message);
            }
        } else {
            console.error('未知错误:', error);
        }
        
        return {
            success: false,
            message: error.message || '操作失败',
            error: error
        };
    },

    // 格式化文件大小
    formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    },

    // 验证图片文件
    validateImageFile(file) {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        const maxSize = 10 * 1024 * 1024; // 10MB
        
        if (!allowedTypes.includes(file.type)) {
            throw new Error('不支持的文件类型');
        }
        
        if (file.size > maxSize) {
            throw new Error('文件大小不能超过10MB');
        }
        
        return true;
    },

    // 生成缩略图
    async generateThumbnail(file, maxWidth = 200, maxHeight = 200, quality = 0.8) {
        return new Promise((resolve, reject) => {
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            const img = new Image();
            
            img.onload = function() {
                // 计算缩略图尺寸
                let { width, height } = img;
                
                if (width > height) {
                    if (width > maxWidth) {
                        height = (height * maxWidth) / width;
                        width = maxWidth;
                    }
                } else {
                    if (height > maxHeight) {
                        width = (width * maxHeight) / height;
                        height = maxHeight;
                    }
                }
                
                canvas.width = width;
                canvas.height = height;
                
                // 绘制缩略图
                ctx.drawImage(img, 0, 0, width, height);
                
                // 转换为blob
                canvas.toBlob(resolve, 'image/jpeg', quality);
            };
            
            img.onerror = reject;
            img.src = URL.createObjectURL(file);
        });
    },

    // 获取图片信息
    async getImageInfo(file) {
        return new Promise((resolve, reject) => {
            const img = new Image();
            
            img.onload = function() {
                resolve({
                    width: img.naturalWidth,
                    height: img.naturalHeight,
                    aspectRatio: img.naturalWidth / img.naturalHeight,
                    size: file.size,
                    type: file.type,
                    name: file.name
                });
            };
            
            img.onerror = reject;
            img.src = URL.createObjectURL(file);
        });
    }
};

// 在浏览器环境中暴露API对象
window.API = {
    APIClient,
    APIError,
    apiClient,
    userAPI,
    imageAPI,
    processingAPI,
    apiUtils
};