// API 配置和请求函数
// 使用已存在的API_BASE_URL或设置默认值
window.API_BASE_URL = window.API_BASE_URL || 'http://localhost:8000';

// API 请求封装
class API {
    static async request(endpoint, options = {}) {
        const url = `${window.API_BASE_URL}${endpoint}`;
        const config = {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        };

        try {
            const response = await fetch(url, config);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return await response.json();
        } catch (error) {
            console.error('API request failed:', error);
            throw error;
        }
    }

    static async get(endpoint, options = {}) {
        return this.request(endpoint, { method: 'GET', ...options });
    }

    static async post(endpoint, data, options = {}) {
        return this.request(endpoint, {
            method: 'POST',
            body: JSON.stringify(data),
            ...options
        });
    }

    static async put(endpoint, data, options = {}) {
        return this.request(endpoint, {
            method: 'PUT',
            body: JSON.stringify(data),
            ...options
        });
    }

    static async delete(endpoint, options = {}) {
        return this.request(endpoint, { method: 'DELETE', ...options });
    }
}

// 导出API类
window.API = API;