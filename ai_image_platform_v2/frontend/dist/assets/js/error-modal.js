/**
 * 错误提示弹窗组件
 * 用于显示详细的错误信息，替换简单的通知系统
 */

class ErrorModal {
    constructor() {
        this.isVisible = false;
        this.currentModal = null;
    }

    /**
     * 显示错误弹窗
     * @param {Object} options - 错误信息配置
     * @param {string} options.title - 错误标题
     * @param {string} options.message - 错误详细信息
     * @param {string} options.type - 错误类型 (error, warning, info)
     * @param {Array} options.suggestions - 建议解决方案
     * @param {Function} options.onConfirm - 确认回调
     * @param {Function} options.onCancel - 取消回调
     * @param {boolean} options.showRetry - 是否显示重试按钮
     */
    show(options = {}) {
        // 如果已有弹窗，先关闭
        if (this.isVisible) {
            this.hide();
        }

        const {
            title = '操作失败',
            message = '发生了未知错误',
            type = 'error',
            suggestions = [],
            onConfirm = null,
            onCancel = null,
            showRetry = false
        } = options;

        // 创建弹窗HTML
        const modalHtml = this.createModalHtml({
            title,
            message,
            type,
            suggestions,
            showRetry
        });

        // 添加到页面
        $('body').append(modalHtml);
        this.currentModal = $('#error-modal');
        this.isVisible = true;

        // 绑定事件
        this.bindEvents(onConfirm, onCancel);

        // 显示动画
        this.currentModal.fadeIn(300);

        // 自动聚焦到确认按钮
        setTimeout(() => {
            this.currentModal.find('.btn-confirm').focus();
        }, 100);
    }

    /**
     * 创建弹窗HTML
     */
    createModalHtml({ title, message, type, suggestions, showRetry }) {
        const iconClass = this.getIconClass(type);
        const typeClass = `error-modal-${type}`;
        
        const suggestionsHtml = suggestions.length > 0 ? `
            <div class="error-suggestions">
                <h4><i class="fas fa-lightbulb"></i> 建议解决方案：</h4>
                <ul>
                    ${suggestions.map(suggestion => `<li>${suggestion}</li>`).join('')}
                </ul>
            </div>
        ` : '';

        const retryButton = showRetry ? `
            <button class="btn btn-secondary btn-retry">
                <i class="fas fa-redo"></i> 重试
            </button>
        ` : '';

        return `
            <div class="modal-overlay error-modal-overlay" id="error-modal">
                <div class="modal error-modal ${typeClass}">
                    <div class="error-modal-header">
                        <div class="error-icon">
                            <i class="${iconClass}"></i>
                        </div>
                        <h3 class="error-title">${title}</h3>
                        <button class="modal-close error-modal-close">&times;</button>
                    </div>
                    <div class="error-modal-body">
                        <div class="error-message">
                            <p>${message}</p>
                        </div>
                        ${suggestionsHtml}
                    </div>
                    <div class="error-modal-footer">
                        <div class="error-modal-actions">
                            ${retryButton}
                            <button class="btn btn-secondary btn-cancel">取消</button>
                            <button class="btn btn-primary btn-confirm">确定</button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    /**
     * 获取图标类名
     */
    getIconClass(type) {
        const icons = {
            'error': 'fas fa-exclamation-circle',
            'warning': 'fas fa-exclamation-triangle',
            'info': 'fas fa-info-circle',
            'success': 'fas fa-check-circle'
        };
        return icons[type] || icons['error'];
    }

    /**
     * 绑定事件
     */
    bindEvents(onConfirm, onCancel) {
        const modal = this.currentModal;

        // 确认按钮
        modal.find('.btn-confirm').on('click', () => {
            if (onConfirm && typeof onConfirm === 'function') {
                onConfirm();
            }
            this.hide();
        });

        // 取消按钮
        modal.find('.btn-cancel').on('click', () => {
            if (onCancel && typeof onCancel === 'function') {
                onCancel();
            }
            this.hide();
        });

        // 重试按钮
        modal.find('.btn-retry').on('click', () => {
            if (onConfirm && typeof onConfirm === 'function') {
                onConfirm();
            }
            this.hide();
        });

        // 关闭按钮
        modal.find('.error-modal-close').on('click', () => {
            this.hide();
        });

        // 点击遮罩层关闭
        modal.on('click', (e) => {
            if (e.target === modal[0]) {
                this.hide();
            }
        });

        // ESC键关闭
        $(document).on('keydown.error-modal', (e) => {
            if (e.key === 'Escape') {
                this.hide();
            }
        });
    }

    /**
     * 隐藏弹窗
     */
    hide() {
        if (!this.isVisible || !this.currentModal) {
            return;
        }

        this.currentModal.fadeOut(300, () => {
            this.currentModal.remove();
            this.currentModal = null;
            this.isVisible = false;
        });

        // 移除键盘事件监听
        $(document).off('keydown.error-modal');
    }

    /**
     * 显示登录错误
     */
    showLoginError(errorCode, message) {
        const errorConfigs = {
            'INVALID_CREDENTIALS': {
                title: '登录失败',
                message: '用户名或密码错误',
                suggestions: [
                    '请检查用户名和密码是否正确',
                    '确认大小写是否正确',
                    '如果忘记密码，请点击"忘记密码"重置'
                ]
            },
            'USER_NOT_FOUND': {
                title: '用户不存在',
                message: '该用户名不存在',
                suggestions: [
                    '请检查用户名是否正确',
                    '如果还没有账户，请先注册'
                ]
            },
            'ACCOUNT_DISABLED': {
                title: '账户已被禁用',
                message: '您的账户已被管理员禁用',
                suggestions: [
                    '请联系客服了解详情',
                    '检查是否违反了使用条款'
                ]
            },
            'VALIDATION_ERROR': {
                title: '输入验证失败',
                message: message || '请检查输入信息',
                suggestions: [
                    '用户名和密码不能为空',
                    '请确保输入格式正确'
                ]
            },
            'SERVER_ERROR': {
                title: '服务器错误',
                message: '服务器暂时无法处理请求',
                suggestions: [
                    '请稍后重试',
                    '如果问题持续存在，请联系技术支持'
                ],
                showRetry: true
            }
        };

        const config = errorConfigs[errorCode] || {
            title: '登录失败',
            message: message || '发生未知错误',
            suggestions: ['请稍后重试']
        };

        this.show(config);
    }

    /**
     * 显示注册错误
     */
    showRegisterError(errorCode, message) {
        const errorConfigs = {
            'USERNAME_EXISTS': {
                title: '用户名已存在',
                message: '该用户名已被其他用户使用',
                suggestions: [
                    '请选择其他用户名',
                    '可以在用户名后添加数字或字符',
                    '用户名需要是唯一的'
                ]
            },
            'EMAIL_EXISTS': {
                title: '邮箱已被注册',
                message: '该邮箱地址已被其他用户注册',
                suggestions: [
                    '请使用其他邮箱地址',
                    '如果这是您的邮箱，可能您已经注册过了',
                    '请尝试登录或找回密码'
                ]
            },
            'PASSWORD_MISMATCH': {
                title: '密码不一致',
                message: '两次输入的密码不相同',
                suggestions: [
                    '请确保两次输入的密码完全相同',
                    '注意密码的大小写',
                    '可以使用"显示密码"功能检查'
                ]
            },
            'PASSWORD_TOO_SHORT': {
                title: '密码长度不足',
                message: '密码长度至少需要6个字符',
                suggestions: [
                    '密码至少包含6个字符',
                    '建议使用字母、数字和特殊字符组合',
                    '避免使用过于简单的密码'
                ]
            },
            'USERNAME_TOO_SHORT': {
                title: '用户名长度不足',
                message: '用户名长度必须在3-50个字符之间',
                suggestions: [
                    '用户名至少需要3个字符',
                    '用户名最多50个字符',
                    '可以使用字母、数字和下划线'
                ]
            },
            'INVALID_EMAIL': {
                title: '邮箱格式错误',
                message: '请输入有效的邮箱地址',
                suggestions: [
                    '邮箱格式：example@domain.com',
                    '请检查邮箱地址是否完整',
                    '确保包含@符号和域名'
                ]
            },
            'VALIDATION_ERROR': {
                title: '输入验证失败',
                message: message || '请检查输入信息',
                suggestions: [
                    '请填写所有必填字段',
                    '确保输入格式正确',
                    '检查用户名、邮箱和密码'
                ]
            },
            'SERVER_ERROR': {
                title: '注册失败',
                message: '服务器暂时无法处理注册请求',
                suggestions: [
                    '请稍后重试',
                    '如果问题持续存在，请联系技术支持'
                ],
                showRetry: true
            }
        };

        const config = errorConfigs[errorCode] || {
            title: '注册失败',
            message: message || '发生未知错误',
            suggestions: ['请稍后重试']
        };

        this.show(config);
    }
}

// 创建全局实例
window.errorModal = new ErrorModal();

// 兼容性函数，用于替换原有的showNotification
window.showErrorModal = function(options) {
    if (typeof options === 'string') {
        // 兼容原有的简单字符串调用
        window.errorModal.show({
            message: options,
            type: 'error'
        });
    } else {
        window.errorModal.show(options);
    }
};