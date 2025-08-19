// 用户认证管理
class Auth {
    constructor() {
        this.token = localStorage.getItem('auth_token');
        this.user = JSON.parse(localStorage.getItem('user_info') || 'null');
    }

    // 检查是否已登录
    isAuthenticated() {
        return !!this.token;
    }

    // 获取当前用户信息
    getCurrentUser() {
        return this.user;
    }

    // 获取认证token
    getToken() {
        return this.token;
    }

    // 登录
    async login(username, password) {
        try {
            const response = await API.post('/auth/login', {
                username,
                password
            });

            if (response.token) {
                this.token = response.token;
                this.user = response.user;
                localStorage.setItem('auth_token', this.token);
                localStorage.setItem('user_info', JSON.stringify(this.user));
                return true;
            }
            return false;
        } catch (error) {
            console.error('Login failed:', error);
            return false;
        }
    }

    // 登出
    logout() {
        this.token = null;
        this.user = null;
        localStorage.removeItem('auth_token');
        localStorage.removeItem('user_info');
    }

    // 注册
    async register(userData) {
        try {
            const response = await API.post('/auth/register', userData);
            return response;
        } catch (error) {
            console.error('Registration failed:', error);
            throw error;
        }
    }

    // 获取带认证头的请求配置
    getAuthHeaders() {
        return this.token ? {
            'Authorization': `Bearer ${this.token}`
        } : {};
    }
}

// 创建全局认证实例
window.auth = new Auth();