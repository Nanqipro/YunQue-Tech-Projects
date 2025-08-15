// 全局变量
let currentImage = null;
let currentTool = null;
const isProcessing = false;
let authToken = localStorage.getItem('authToken') || null;
let currentUser = null;

// 通用认证头设置函数
function getAuthHeaders() {
    const headers = {
        'Content-Type': 'application/json'
    };

    if (authToken) {
        headers['Authorization'] = `Bearer ${authToken}`;
    }

    return headers;
}

// 确保AJAX请求设置认证头的辅助函数
function ensureAuthHeader(xhr) {
    if (authToken) {
        xhr.setRequestHeader('Authorization', `Bearer ${authToken}`);
        console.log('已设置认证头');
    } else {
        console.warn('未设置认证头 - authToken不存在');
    }
}

// API 基础URL
const API_BASE_URL = 'http://127.0.0.1:5002/api';

// 初始化应用
$(document).ready(function () {
    initializeApp();
    bindEvents();
    checkAuthStatus();
});

// 初始化应用
function initializeApp() {
    console.log('AI图像处理平台初始化...');

    // 设置API客户端的token
    if (authToken) {
        window.API.apiClient.setToken(authToken);
    }

    // 隐藏初始加载遮罩
    hideLoading();

    // 初始化拖拽上传
    initializeDragDrop();

    // 初始化工具面板
    initializeToolPanels();

    // 初始化美颜界面
    initializeBeautyInterface();

    // 初始化通知功能
    initializeNotifications();

    // 更新状态栏
    updateStatusBar('就绪');

    // 延迟设置默认工具，避免初始化时的递归问题
    setTimeout(() => {
        selectTool('beauty', 'beauty');
    }, 100);
}

// 初始化通知功能
function initializeNotifications() {
    // 初始化通知权限
    initNotificationPermission();

    // 检查用户是否已登录
    const token = localStorage.getItem('authToken');
    if (token) {
        // 更新通知徽章
        updateNotificationBadge();

        // 定期检查新通知
        setInterval(() => {
            updateNotificationBadge();
        }, 60000); // 每分钟检查一次

        // 启动实时通知检查
        initNotificationRealtime();
    }
}

// 绑定事件
function bindEvents() {
    // 工具选择（使用委托事件避免重复绑定）
    $(document).on('click.toolitem', '.tool-item', function () {
        $('.tool-item').removeClass('active');
        $(this).addClass('active');
        const category = $(this).data('category');
        const tool = $(this).data('tool');
        selectTool(category, tool);
    });

    // 文件上传事件绑定
    $('#image-input').on('change', handleFileSelect);

    // 上传区域点击触发文件选择（但避免与label重复）
    $(document).on('click', '.upload-container', function (e) {
        // 如果点击的是label或按钮，不重复触发
        if ($(e.target).closest('label').length > 0) {
            console.log('点击的是label，不重复触发文件选择');
            return;
        }

        console.log('上传区域被点击');
        const fileInput = document.getElementById('image-input');
        if (fileInput) {
            console.log('触发文件选择器');
            fileInput.click();
        } else {
            console.error('找不到文件输入框');
        }
    });

    // 文件选择现在通过label标签自动处理，无需JavaScript干预
    console.log('文件选择功能已通过HTML label标签实现');

    // 处理按钮（使用委托事件避免重复绑定）
    $(document).on('click.buttons', '#process-btn', function (e) {
        e.preventDefault();
        console.log('美颜按钮被点击 (ID选择器)');
        processBeautyImage();
    });
    $(document).on('click.buttons', '#resetBtn', resetImage);
    $(document).on('click.buttons', '#downloadBtn', downloadImage);
    $(document).on('click', '.btn-process-beauty', function (e) {
        e.preventDefault();
        console.log('美颜按钮被点击 (类选择器)');
        processBeautyImage();
    });
    $(document).on('click', '.btn-process-id-photo', processIdPhoto);
    $(document).on('click', '.btn-process-background', processBackground);

    // 创建防抖函数实例
    const debouncedPreviewEffect = debounce(previewEffect, 300);

    // 滑块控件（使用命名空间避免重复绑定）
    $(document).on('input.slider', '.slider', function () {
        const value = $(this).val();
        $(this).siblings('.slider-value').text(value);
        if (currentImage && !isProcessing) {
            debouncedPreviewEffect();
        }
    });

    // 美颜滑块值更新
    $(document).on('input', '.beauty-slider', function () {
        const value = $(this).val();
        $(this).siblings('.parameter-label').find('.parameter-value').text(value);
        updateBeautyPreview();
    });

    // 预设方案选择
    $(document).on('click', '.preset-btn', function () {
        $('.preset-btn').removeClass('active');
        $(this).addClass('active');
        applyBeautyPreset($(this).data('preset'));
    });

    // 图片对比控制
    $(document).on('click', '.btn-compare', toggleImageComparison);
    $(document).on('click', '.btn-zoom-in', zoomIn);
    $(document).on('click', '.btn-zoom-out', zoomOut);
    $(document).on('click', '.btn-fullscreen', toggleFullscreen);

    // 重置按钮
    $(document).on('click', '.btn-reset-params', resetBeautyParams);

    // 下载按钮
    $(document).on('click', '.btn-download-result', downloadImage);

    // 选择框（使用委托事件避免重复绑定）
    $(document).on('change.formselect', '.form-select', function () {
        if (currentImage && !isProcessing) {
            previewEffect();
        }
    });

    // 用户菜单（使用委托事件避免重复绑定）
    $(document).on('click.usermenu', '.user-profile', function (e) {
        e.stopPropagation();
        $('.user-dropdown').toggleClass('show');
    });

    $(document).on('click', function () {
        $('.user-dropdown').removeClass('show');
    });

    // 登录/注册（使用委托事件避免重复绑定）
    $(document).on('click.auth', '#loginBtn', showLoginModal);
    $(document).on('click.auth', '#registerBtn', showRegisterModal);
    $(document).on('click.auth', '#logout-btn', logout);

    // 顶部菜单栏功能按钮
    $(document).on('click', '#help-btn', showHelpCenter);
    $(document).on('click', '#history-btn', showHistoryPanel);
    $(document).on('click', '#favorites-btn', showFavoritesPanel);
    $(document).on('click', '#notifications-btn', showNotificationsPanel);
    $(document).on('click', '#user-menu-btn', function (e) {
        e.stopPropagation();
        $('.user-dropdown').toggleClass('show');
    });

    // 模态框内的切换按钮
    $(document).on('click.auth', '#show-register', function () {
        $('#login-modal').hide();
        $('#register-modal').show();
    });
    $(document).on('click.auth', '#show-login', function () {
        $('#register-modal').hide();
        $('#login-modal').show();
    });

    // 模态框（使用委托事件避免重复绑定）
    $(document).on('click.modal', '.modal-close', closeModal);
    $(document).on('click.modal', '.modal-overlay', function (e) {
        if (e.target === this) {
            closeModal();
        }
    });

    // 表单提交（使用委托事件避免重复绑定）
    $(document).on('submit.forms', '#login-form', handleLogin);
    $(document).on('submit.forms', '#register-form', handleRegister);

    // 键盘快捷键
    $(document).on('keydown', handleKeyboardShortcuts);

    // ESC键关闭模态框
    $(document).on('keydown', function (e) {
        if (e.key === 'Escape') {
            closeModal();
        }
    });
}

// 选择工具
function selectTool(category, tool) {
    // 更新UI状态
    $('.tool-item').removeClass('active');
    $(`.tool-item[data-category="${category}"][data-tool="${tool}"]`).addClass('active');

    // 更新当前工具
    currentTool = { category, tool };

    // 更新面板
    updateToolPanel(category, tool);

    // 更新页面标题
    updatePageTitle(category, tool);

    // 启用处理按钮
    if (currentImage) {
        $('#process-btn').prop('disabled', false);
        console.log('已启用处理按钮，当前图片ID:', currentImage.id);
    } else {
        $('#process-btn').prop('disabled', true);
        console.log('处理按钮已禁用，未选择图片');
    }

    // 启用美颜面板（移除disabled类）
    $('#beauty-panel').removeClass('disabled');

    console.log('工具选择完成:', category, tool, '面板已启用');
}

// 更新工具面板
function updateToolPanel(category, tool) {
    const panelContent = $('.panel-content');

    console.log('更新工具面板:', category, tool);

    switch (category) {
        case 'beauty':
            // 根据具体的美颜工具更新面板内容
            console.log('切换到美颜面板:', tool);
            if (tool === 'beauty') {
                // 智能美颜 - 恢复HTML中已定义的面板内容
                console.log('恢复HTML中的智能美颜面板');
                restoreBeautyPanel();
            } else {
                // 其他美颜工具 - 动态生成面板内容
                panelContent.html(getBeautyPanel(tool));
            }
            break;
        case 'filters':
            panelContent.html(getFiltersPanel(tool));
            break;
        case 'color':
            panelContent.html(getColorPanel(tool));
            break;
        case 'background':
            panelContent.html(getBackgroundPanel(tool));
            break;
        case 'repair':
            panelContent.html(getRepairPanel(tool));
            break;
        case 'id-photo':
            panelContent.html(getIdPhotoPanel(tool));
            break;
        default:
            console.log('未知工具类别:', category);
            panelContent.html('<p>请选择一个工具</p>');
    }

    // 确保面板启用状态正确
    setTimeout(() => {
        if (window.simpleImageManager && window.simpleImageManager.getCurrentImage()) {
            console.log('面板更新后启用功能');
            window.simpleImageManager.enableCurrentModuleFeatures();
        }

        // 调试：检查面板内容是否正确更新
        console.log('面板内容更新完成，当前内容:', panelContent.html());
        console.log('面板是否可见:', panelContent.is(':visible'));
        console.log('美颜面板状态:', $('#beauty-panel').hasClass('disabled') ? '已禁用' : '已启用');

        // 确保面板可见
        if (category === 'beauty') {
            $('#beauty-panel').removeClass('disabled');
            console.log('美颜面板已确保启用');
        }
    }, 100);
}

// 获取美颜面板
function getBeautyPanel(tool) {
    switch (tool) {
        case 'beauty':
            return `
                <div class="property-group">
                    <div class="property-label">美颜强度</div>
                    <div class="slider-container">
                        <input type="range" class="slider" id="beautyStrength" min="0" max="100" value="50">
                        <span class="slider-value">50</span>
                    </div>
                </div>
                
                <div class="property-group">
                    <div class="property-label">磨皮程度</div>
                    <div class="slider-container">
                        <input type="range" class="slider" id="smoothing" min="0" max="100" value="30">
                        <span class="slider-value">30</span>
                    </div>
                </div>
                
                <div class="property-group">
                    <div class="property-label">美白程度</div>
                    <div class="slider-container">
                        <input type="range" class="slider" id="whitening" min="0" max="100" value="40">
                        <span class="slider-value">40</span>
                    </div>
                </div>
                
                <div class="property-group">
                    <div class="property-label">眼部增强</div>
                    <div class="slider-container">
                        <input type="range" class="slider" id="eyeEnhancement" min="0" max="100" value="60">
                        <span class="slider-value">60</span>
                    </div>
                </div>
                
                <div class="property-group">
                    <div class="property-label">唇色调整</div>
                    <div class="slider-container">
                        <input type="range" class="slider" id="lipAdjustment" min="0" max="100" value="25">
                        <span class="slider-value">25</span>
                    </div>
                </div>
                

                
                <div class="ai-suggestions">
                    <div class="ai-title">
                        🤖 AI智能建议
                    </div>
                    <div class="ai-suggestion">💡 建议增强眼部亮度</div>
                    <div class="ai-suggestion">🎨 推荐暖色调滤镜</div>
                    <div class="ai-suggestion">✨ 可尝试柔光效果</div>
                </div>
            `;
        default:
            return '<p>选择美颜工具</p>';
    }
}

// 获取滤镜面板
function getFiltersPanel(tool) {
    return `
        <div class="control-group">
            <label class="control-label">滤镜强度</label>
            <div class="slider-container">
                <input type="range" class="slider" id="filterIntensity" min="0" max="100" value="80">
                <span class="slider-value">80</span>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label">混合模式</label>
            <select class="form-select" id="blendMode">
                <option value="normal">正常</option>
                <option value="multiply">正片叠底</option>
                <option value="screen">滤色</option>
                <option value="overlay">叠加</option>
                <option value="soft-light">柔光</option>
            </select>
        </div>
    `;
}

// 获取颜色调整面板
function getColorPanel(tool) {
    return `
        <div class="control-group">
            <label class="control-label">亮度</label>
            <div class="slider-container">
                <input type="range" class="slider" id="brightness" min="-100" max="100" value="0">
                <span class="slider-value">0</span>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label">对比度</label>
            <div class="slider-container">
                <input type="range" class="slider" id="contrast" min="-100" max="100" value="0">
                <span class="slider-value">0</span>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label">饱和度</label>
            <div class="slider-container">
                <input type="range" class="slider" id="saturation" min="-100" max="100" value="0">
                <span class="slider-value">0</span>
            </div>
        </div>
    `;
}

// 获取背景处理面板
function getBackgroundPanel(tool) {
    return `
        <div class="control-group">
            <label class="control-label">背景类型</label>
            <select class="form-select" id="backgroundType">
                <option value="remove">移除背景</option>
                <option value="replace">替换背景</option>
                <option value="blur">背景模糊</option>
            </select>
        </div>
        <div class="control-group">
            <label class="control-label">处理强度</label>
            <div class="slider-container">
                <input type="range" class="slider" id="backgroundIntensity" min="0" max="100" value="80">
                <span class="slider-value">80</span>
            </div>
        </div>
        <div class="control-group">
            <button class="btn-process-background btn-primary" id="processBackground" disabled>
                <i class="fas fa-magic"></i>
                处理背景
            </button>
        </div>
    `;
}

// 获取智能修复面板
function getRepairPanel(tool) {
    return `
        <div class="control-group">
            <label class="control-label">修复类型</label>
            <select class="form-select" id="repairType">
                <option value="scratch">划痕修复</option>
                <option value="noise">噪点去除</option>
                <option value="enhance">细节增强</option>
            </select>
        </div>
        <div class="control-group">
            <label class="control-label">修复强度</label>
            <div class="slider-container">
                <input type="range" class="slider" id="repairIntensity" min="0" max="100" value="60">
                <span class="slider-value">60</span>
            </div>
        </div>
    `;
}

// 获取证件照面板
function getIdPhotoPanel(tool) {
    return `
        <div class="control-group">
            <label class="control-label">证件照类型</label>
            <select class="form-select" id="photoType">
                <option value="1_inch">1寸照片 (295×413)</option>
                <option value="2_inch">2寸照片 (413×579)</option>
                <option value="passport">护照照片 (390×567)</option>
                <option value="id_card">身份证照片 (358×441)</option>
            </select>
        </div>
        <div class="control-group">
            <label class="control-label">背景颜色</label>
            <select class="form-select" id="backgroundColor">
                <option value="white">白色背景</option>
                <option value="blue">蓝色背景</option>
                <option value="red">红色背景</option>
            </select>
        </div>
        <div class="control-group">
            <label class="control-label">美颜强度</label>
            <div class="slider-container">
                <input type="range" class="slider" id="beautyStrength" min="0" max="100" value="30">
                <span class="slider-value">30</span>
            </div>
        </div>
        <div class="control-group">
            <div class="checkbox-container">
                <input type="checkbox" id="autoCrop" checked>
                <label for="autoCrop">自动裁剪人脸</label>
            </div>
        </div>
        <div class="control-group">
            <button class="btn-process-id-photo btn-primary" id="processIdPhoto" disabled>
                <i class="fas fa-user-tie"></i>
                生成证件照
            </button>
        </div>
    `;
}

// 更新页面标题
function updatePageTitle(category, tool) {
    const titles = {
        beauty: { beauty: 'AI美颜', smooth: '磨皮', whiten: '美白', eyes: '眼部', lips: '唇部' },
        filters: { vintage: '复古', modern: '现代', artistic: '艺术' },
        color: { brightness: '亮度', contrast: '对比度', saturation: '饱和度' },
        background: { remove: '背景移除', replace: '背景替换', blur: '背景模糊' },
        repair: { scratch: '划痕修复', noise: '噪点去除', enhance: '细节增强' },
        'id-photo': { generate: '证件照生成' }
    };

    const title = titles[category]?.[tool] || '图像处理';
    $('.page-title').text(title);
}

// 初始化工具面板
function initializeToolPanels() {
    // 默认显示美颜面板
    updateToolPanel('beauty', 'beauty');
}

// 初始化美颜界面
function initializeBeautyInterface() {
    // 美颜界面已在HTML中定义，这里可以添加特定的初始化逻辑
    console.log('美颜界面初始化完成');

    // 确保控制面板初始状态为禁用
    $('#beauty-panel').addClass('disabled');
}

// 更新状态栏
function updateStatusBar(message) {
    $('.status-text').text(message);
}

// 显示通知
function showNotification(message, type = 'info') {
    const notification = $(`
        <div class="notification ${type}">
            <span>${message}</span>
            <button class="notification-close">&times;</button>
        </div>
    `);

    $('body').append(notification);

    // 自动关闭
    setTimeout(() => {
        notification.fadeOut(() => notification.remove());
    }, 3000);

    // 手动关闭
    notification.find('.notification-close').click(() => {
        notification.fadeOut(() => notification.remove());
    });
}

// 显示加载状态
function showLoading(message = '处理中...') {
    $('.loading-overlay .loading-text').text(message);
    $('.loading-overlay').show();
}

// 隐藏加载状态
function hideLoading() {
    $('.loading-overlay').hide();
}

// 防抖函数
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// 处理图像
function processImage() {
    if (!currentImage || !currentTool) {
        showNotification('请先上传图片并选择工具', 'warning');
        return;
    }

    // 实现图像处理逻辑
    showLoading('正在处理图像...');

    // 模拟处理时间
    setTimeout(() => {
        hideLoading();
        showNotification('图像处理完成', 'success');
    }, 2000);
}

// 重置图像
function resetImage() {
    if (currentImage) {
        // 重置到原始状态
        showNotification('图像已重置', 'info');
    }
}

// 下载图像
function downloadImage() {
    if (currentImage) {
        // 实现下载逻辑
        showNotification('图像下载中...', 'info');
    }
}

// 预览效果
function previewEffect() {
    // 实现实时预览逻辑
    console.log('预览效果更新');
}

// 检查认证状态
function checkAuthStatus() {
    if (authToken) {
        // 验证token有效性
        $.ajax({
            url: `${API_BASE_URL}/users/verify-token`,
            type: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            success: function (response) {
                if (response.valid) {
                    currentUser = response.user;
                    updateUserInterface();
                    console.log('Token验证成功，用户已登录:', currentUser);
                }
            },
            error: function (xhr, status, error) {
                // Token无效，清除本地存储
                localStorage.removeItem('authToken');
                authToken = null;
                currentUser = null;
                // 更新UI状态
                updateUserInterface();
                // 静默处理401错误，不在控制台显示
                if (xhr.status !== 401) {
                    console.error('Token验证失败:', error);
                }
            }
        });
    }
}

// 更新用户界面
function updateUserInterface() {
    if (currentUser) {
        $('#loginBtn').hide();
        $('#registerBtn').hide();
        $('.auth-buttons').hide();
        $('.user-info').show();
        $('.user-name').text(currentUser.username);
        $('.user-dropdown').removeClass('show');

        // 用户已登录，检查是否有图片来决定是否启用证件照按钮
        updateProcessingButtons();
    } else {
        $('#loginBtn').show();
        $('#registerBtn').show();
        $('.auth-buttons').show();
        $('.user-info').hide();
        $('.user-dropdown').removeClass('show');

        // 用户未登录时禁用证件照按钮
        $('.btn-process-id-photo').prop('disabled', true);
    }
}

// 更新处理按钮状态
function updateProcessingButtons() {
    console.log('updateProcessingButtons called:', {
        currentUser: currentUser,
        currentImage: currentImage,
        hasUser: !!currentUser,
        hasImage: !!currentImage
    });

    // 只有用户已登录且有图片时才启用证件照按钮
    if (currentUser && currentImage) {
        console.log('启用证件照按钮');
        $('.btn-process-id-photo').prop('disabled', false);
        $('#processIdPhoto').prop('disabled', false); // 同时启用ID选择器
    } else {
        console.log('禁用证件照按钮 - 原因:', {
            noUser: !currentUser,
            noImage: !currentImage
        });
        $('.btn-process-id-photo').prop('disabled', true);
        $('#processIdPhoto').prop('disabled', true); // 同时禁用ID选择器
    }
}

// 显示登录模态框
function showLoginModal() {
    $('#login-modal').show();
    $('#modal-overlay').show();
}

// 显示注册模态框
function showRegisterModal() {
    $('#register-modal').show();
    $('#modal-overlay').show();
}

// 关闭模态框
function closeModal() {
    $('.modal').hide();
    $('#modal-overlay').hide();

    // 关闭通知面板
    $('#notifications-modal').hide();
    $('.modal-overlay').hide();
}

// 处理登录
function handleLogin(e) {
    e.preventDefault();
    const formData = new FormData(e.target);

    $.ajax({
        url: `${API_BASE_URL}/users/login`,
        type: 'POST',
        data: JSON.stringify({
            username: formData.get('username'),
            password: formData.get('password')
        }),
        contentType: 'application/json',
        success: function (response) {
            if (response.success && response.data && response.data.token) {
                authToken = response.data.token;
                localStorage.setItem('authToken', authToken);
                // 设置API客户端的token
                window.API.apiClient.setToken(authToken);
                currentUser = response.data.user;
                updateUserInterface();
                closeModal();
                showNotification('登录成功', 'success');
            } else {
                showNotification(response.message || '登录失败', 'error');
            }
        },
        error: function (xhr) {
            const response = xhr.responseJSON;
            let errorMessage = '登录失败';

            if (xhr.status === 401) {
                errorMessage = '用户名或密码错误';
            } else if (xhr.status === 400) {
                errorMessage = response?.message || '输入信息有误，请检查';
            } else if (xhr.status === 500) {
                errorMessage = '服务器错误，请稍后重试';
            }

            showNotification(errorMessage, 'error');
            console.error('登录失败:', xhr.status, response);
        }
    });
}

// 处理注册
function handleRegister(e) {
    e.preventDefault();
    const formData = new FormData(e.target);

    // 获取表单数据
    const username = formData.get('username');
    const email = formData.get('email');
    const password = formData.get('password');
    const confirmPassword = formData.get('confirmPassword');

    // 前端验证
    if (!username || !email || !password || !confirmPassword) {
        showNotification('请填写所有必填字段', 'error');
        return;
    }

    // 验证用户名长度
    if (username.length < 3 || username.length > 50) {
        showNotification('用户名长度必须在3-50个字符之间', 'error');
        return;
    }

    // 验证密码长度
    if (password.length < 6) {
        showNotification('密码长度至少6个字符', 'error');
        return;
    }

    // 验证密码确认
    if (password !== confirmPassword) {
        showNotification('两次输入的密码不一致', 'error');
        return;
    }

    // 验证邮箱格式
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        showNotification('请输入有效的邮箱地址', 'error');
        return;
    }

    $.ajax({
        url: `${API_BASE_URL}/users/register`,
        type: 'POST',
        data: JSON.stringify({
            username: username,
            email: email,
            password: password
        }),
        contentType: 'application/json',
        success: function (response) {
            if (response.success) {
                showNotification('注册成功，请登录', 'success');
                $('#register-modal').hide();
                $('#login-modal').show();
                // 清空表单
                e.target.reset();
            } else {
                showNotification(response.message || '注册失败', 'error');
            }
        },
        error: function (xhr) {
            const response = xhr.responseJSON;
            let errorMessage = '注册失败';

            if (xhr.status === 409) {
                if (response?.message?.includes('用户名已存在')) {
                    errorMessage = '用户名已存在，请选择其他用户名';
                } else if (response?.message?.includes('邮箱已被注册')) {
                    errorMessage = '邮箱已被注册，请使用其他邮箱';
                } else {
                    errorMessage = response?.message || '用户信息冲突，请检查输入';
                }
            } else if (xhr.status === 400) {
                errorMessage = response?.message || '输入信息有误，请检查';
            } else if (xhr.status === 500) {
                errorMessage = '服务器错误，请稍后重试';
            }

            showNotification(errorMessage, 'error');
            console.error('注册失败:', xhr.status, response);
        }
    });
}

// 登出
function logout() {
    localStorage.removeItem('authToken');
    authToken = null;
    window.API.apiClient.setToken(null);
    currentUser = null;
    updateUserInterface();
    showNotification('已登出', 'info');
}

// 键盘快捷键处理
function handleKeyboardShortcuts(e) {
    // Ctrl/Cmd + O: 打开文件
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'o') {
        e.preventDefault();
        e.stopPropagation();
        // 触发文件选择
        const input = $('#image-input');
        input.val(''); // 清除之前的选择
        input.click();
    }

    // Ctrl/Cmd + S: 保存/下载
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
        e.preventDefault();
        downloadImage();
    }

    // Ctrl/Cmd + Z: 重置
    if ((e.ctrlKey || e.metaKey) && e.key === 'z') {
        e.preventDefault();
        resetImage();
    }
}

// 初始化拖拽上传
function initializeDragDrop() {
    const uploadArea = $('.upload-area');

    uploadArea.on('dragover', function (e) {
        e.preventDefault();
        $(this).addClass('drag-over');
    });

    uploadArea.on('dragleave', function (e) {
        e.preventDefault();
        $(this).removeClass('drag-over');
    });

    uploadArea.on('drop', function (e) {
        e.preventDefault();
        $(this).removeClass('drag-over');

        const files = e.originalEvent.dataTransfer.files;
        if (files.length > 0) {
            handleFile(files[0]);
        }
    });
}

// 处理文件选择
function handleFileSelect(e) {
    console.log('文件选择事件触发', e);
    const file = e.target.files[0];
    if (file) {
        console.log('选择的文件:', file.name, file.size, file.type);
        // 立即显示选择的文件信息
        showNotification(`已选择: ${file.name}`, 'info');
        handleFile(file);
        // 清除文件选择，以便能够重新选择相同的文件
        e.target.value = '';
    } else {
        console.log('没有选择文件');
    }
}

// 处理文件
async function handleFile(file) {
    // 验证文件类型
    if (!file.type.startsWith('image/')) {
        showNotification('请选择图片文件', 'error');
        return;
    }

    // 验证文件大小（10MB限制）
    if (file.size > 10 * 1024 * 1024) {
        showNotification('文件大小不能超过10MB', 'error');
        return;
    }

    // 显示加载状态
    showLoading('正在上传图片...');

    // 确保API客户端的token与当前authToken同步
    if (authToken && window.API.apiClient.token !== authToken) {
        console.log('同步API客户端token用于图片上传');
        window.API.apiClient.setToken(authToken);
    }

    try {
        // 使用统一的API客户端上传图片
        console.log('使用API客户端上传图片，token:', window.API.apiClient.token ? 'exists' : 'none');
        const response = await window.API.imageAPI.upload(file);

        hideLoading();
        if (response.success) {
            // 同时设置全局变量和简化版管理器
            currentImage = response.data;
            console.log('图片上传成功，设置currentImage:', currentImage);

            if (window.simpleImageManager) {
                window.simpleImageManager.setCurrentImage(response.data);
                console.log('图片已设置到简化版管理器:', response.data);
            } else {
                // 后备方案，保持原有逻辑
                displayImage(response.data.url);
            }

            showNotification('图片上传成功', 'success');
            updateStatusBar(`已上传: ${file.name} (${formatFileSize(file.size)})`);
        } else {
            showNotification(response.message || '上传失败', 'error');
        }
    } catch (error) {
        hideLoading();
        console.error('图片上传错误:', error);
        showNotification(error.message || '上传失败', 'error');
    }
}

// 显示图片
function displayImage(imageUrl) {
    // 隐藏上传区域
    $('#upload-section').hide();

    // 显示图片对比区域
    $('#image-comparison').show();

    // 设置原始图片
    const originalImage = $('#original-image');
    originalImage.attr('src', imageUrl);

    // 等待图片加载完成
    originalImage.on('load', function () {
        // 显示原始图片
        originalImage.show();

        // 隐藏占位内容
        $('#placeholder-content').hide();

        // 启用美颜控制面板
        $('#beauty-panel').removeClass('disabled');

        // 启用开始美颜按钮
        $('#process-btn').prop('disabled', false);

        // 更新处理按钮状态（包括证件照按钮）
        console.log('调用updateProcessingButtons');
        updateProcessingButtons();

        // 如果有简化版管理器，也调用其功能启用
        if (window.simpleImageManager) {
            window.simpleImageManager.enableCurrentModuleFeatures();
        }

        // 更新文件信息
        if (currentImage) {
            $('.file-info .file-name').text(currentImage.filename || '未知文件');
            $('.file-info .file-size').text(formatFileSize(currentImage.size || 0));
        }
    }).on('error', function () {
        // 图片加载失败
        showNotification('图片加载失败', 'error');
        // 重置界面
        $('#upload-section').show();
        $('#image-comparison').hide();
    });
}

// 显示美颜界面
function displayBeautyInterface(imageUrl) {
    // 设置美颜界面的图片
    $('#beauty-image').attr('src', imageUrl);

    // 启用美颜控制面板
    $('#beauty-panel').removeClass('disabled');

    // 更新文件信息
    $('.file-info .file-name').text(currentImage?.filename || '未知文件');
    $('.file-info .file-size').text(formatFileSize(currentImage?.size || 0));
}

// 放大图片
function zoomIn() {
    // 实现放大逻辑
    console.log('放大图片');
}

// 缩小图片
function zoomOut() {
    // 实现缩小逻辑
    console.log('缩小图片');
}

// 重置缩放
function resetZoom() {
    // 实现重置缩放逻辑
    console.log('重置缩放');
}

// 处理美颜图片
async function processBeautyImage() {
    console.log('processBeautyImage 函数被调用');
    console.log('当前图片:', currentImage);
    console.log('当前用户:', currentUser);
    console.log('认证token:', authToken);

    if (!currentImage) {
        console.error('没有当前图片，无法处理');
        showNotification('请先上传图片', 'warning');
        return;
    }

    console.log('开始美颜处理流程...');

    // 显示处理指示器
    $('#processing-indicator').show();

    // 获取美颜参数
    const params = {
        smoothing: parseFloat($('#smoothing').val() || 30) / 100,
        whitening: parseFloat($('#whitening').val() || 40) / 100,
        eye_enhancement: parseFloat($('#eye-enhancement').val() || 60) / 100,
        lip_enhancement: parseFloat($('#lip-adjustment').val() || 25) / 100,
        ai_mode: true
    };

    // 禁用处理按钮
    $('.btn-process-beauty').prop('disabled', true);

    showLoading('正在进行AI美颜处理...');

    // 使用统一的API客户端进行美颜处理
    console.log('发送美颜请求，authToken:', authToken);
    console.log('API客户端token:', window.API.apiClient.token);
    console.log('Using API client instead of jQuery AJAX');

    // 确保API客户端的token与当前authToken同步
    if (authToken && window.API.apiClient.token !== authToken) {
        console.log('同步API客户端token');
        window.API.apiClient.setToken(authToken);
    }

    try {
        const response = await window.API.processingAPI.beauty(currentImage.id, params);
        console.log('Beauty processing success response:', response);

        hideLoading();
        // 隐藏处理指示器
        $('#processing-indicator').hide();
        // 启用处理按钮
        $('.btn-process-beauty').prop('disabled', false);

        if (response.success) {
            showNotification('美颜处理完成', 'success');
            // 更新图片显示
            if (response.data.result_url) {
                loadProcessedImage(response.data.result_url);
            }
        } else {
            showNotification(response.message || '处理失败', 'error');
        }
    } catch (error) {
        console.error('Beauty processing error:', error);

        hideLoading();
        // 隐藏处理指示器
        $('#processing-indicator').hide();
        // 启用处理按钮
        $('.btn-process-beauty').prop('disabled', false);
        // 显示占位内容
        $('#processed-image').hide();
        $('#placeholder-content').show();

        showNotification(error.message || '美颜处理失败', 'error');
    }
}

// 处理证件照生成
function processIdPhoto() {
    if (!currentImage) {
        showNotification('请先上传图片', 'warning');
        return;
    }

    // 显示处理指示器
    $('#processing-indicator').show();

    // 获取证件照参数
    const params = {
        photo_type: $('#photoType').val() || 'passport',
        background_color: $('#backgroundColor').val() || 'white',
        beauty_strength: parseFloat($('#beautyStrength').val() || 30),
        auto_crop: $('#autoCrop').is(':checked')
    };

    console.log('证件照参数:', params);
    console.log('背景色选择器值:', $('#backgroundColor').val());
    console.log('当前图片ID:', currentImage ? currentImage.id : 'null');

    // 禁用处理按钮
    $('.btn-process-id-photo').prop('disabled', true);

    showLoading('正在生成证件照...');

    // 调用证件照生成接口
    console.log('发送证件照请求到:', `${API_BASE_URL}/processing/id-photo`);
    console.log('请求数据:', {
        image_id: currentImage.id,
        ...params
    });

    $.ajax({
        url: `${API_BASE_URL}/processing/id-photo`,
        type: 'POST',
        data: JSON.stringify({
            image_id: currentImage.id,
            ...params
        }),
        contentType: 'application/json',
        headers: authToken ? { 'Authorization': `Bearer ${authToken}` } : {},
        timeout: 60000, // 60秒超时
        beforeSend: function (xhr) {
            // 使用辅助函数确保设置认证头
            ensureAuthHeader(xhr);
            console.log('发送请求前，认证token:', authToken ? '存在' : '不存在');
            console.log('请求URL:', `${API_BASE_URL}/processing/id-photo`);
        },
        success: function (response, textStatus, xhr) {
            console.log('证件照处理响应状态:', textStatus);
            console.log('证件照处理响应:', response);
            console.log('响应头:', xhr.getAllResponseHeaders());

            hideLoading();
            // 隐藏处理指示器
            $('#processing-indicator').hide();
            // 启用处理按钮
            $('.btn-process-id-photo').prop('disabled', false);

            if (response && response.success) {
                showNotification('证件照生成完成', 'success');
                console.log('证件照生成成功，结果URL:', response.data?.result_url);
                // 更新图片显示
                if (response.data && response.data.result_url) {
                    loadProcessedImage(response.data.result_url);
                } else {
                    console.warn('响应中缺少result_url，完整响应:', response);
                    showNotification('响应格式错误：缺少结果URL', 'error');
                }
            } else {
                console.error('证件照生成失败，响应:', response);
                showNotification(response?.message || '生成失败', 'error');
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            console.error('AJAX请求失败:', {
                textStatus: textStatus,
                errorThrown: errorThrown,
                status: xhr.status,
                statusText: xhr.statusText,
                responseText: xhr.responseText,
                responseJSON: xhr.responseJSON
            });

            hideLoading();
            // 隐藏处理指示器
            $('#processing-indicator').hide();
            // 启用处理按钮
            $('.btn-process-id-photo').prop('disabled', false);
            // 显示占位内容
            $('#processed-image').hide();
            $('#placeholder-content').show();

            let errorMessage = '生成失败';
            if (textStatus === 'timeout') {
                errorMessage = '请求超时，请重试';
            } else if (xhr.responseJSON && xhr.responseJSON.message) {
                errorMessage = xhr.responseJSON.message;
            } else if (xhr.responseJSON && xhr.responseJSON.error) {
                errorMessage = xhr.responseJSON.error;
            } else if (errorThrown) {
                errorMessage = errorThrown;
            }

            showNotification(errorMessage, 'error');
        }
    });
}

// 处理背景替换
function processBackground() {
    if (!currentImage) {
        showNotification('请先上传图片', 'warning');
        return;
    }

    // 显示处理指示器
    $('#processing-indicator').show();

    // 获取背景处理参数
    const params = {
        background_type: $('#backgroundType').val() || 'remove',
        intensity: parseFloat($('#backgroundIntensity').val() || 80) / 100
    };

    // 禁用处理按钮
    $('.btn-process-background').prop('disabled', true);

    showLoading('正在处理背景...');

    // 调用背景处理接口
    $.ajax({
        url: `${API_BASE_URL}/processing/background`,
        type: 'POST',
        data: JSON.stringify({
            image_id: currentImage.id,
            ...params
        }),
        contentType: 'application/json',
        headers: authToken ? { 'Authorization': `Bearer ${authToken}` } : {},
        beforeSend: function (xhr) {
            // 使用辅助函数确保设置认证头
            ensureAuthHeader(xhr);
            console.log('背景处理请求，认证token:', authToken ? '存在' : '不存在');
        },
        success: function (response) {
            hideLoading();
            // 隐藏处理指示器
            $('#processing-indicator').hide();
            // 启用处理按钮
            $('.btn-process-background').prop('disabled', false);

            if (response.success) {
                showNotification('背景处理完成', 'success');
                // 更新图片显示
                if (response.data.result_url) {
                    loadProcessedImage(response.data.result_url);
                }
            } else {
                showNotification(response.message || '处理失败', 'error');
            }
        },
        error: function (xhr) {
            console.error('Background processing error:', {
                status: xhr.status,
                statusText: xhr.statusText,
                responseText: xhr.responseText,
                responseJSON: xhr.responseJSON
            });
            hideLoading();
            // 隐藏处理指示器
            $('#processing-indicator').hide();
            // 启用处理按钮
            $('.btn-process-background').prop('disabled', false);
            // 显示占位内容
            $('#processed-image').hide();
            $('#placeholder-content').show();

            const response = xhr.responseJSON;
            showNotification(response?.message || '背景处理失败', 'error');
        }
    });
}

// 更新美颜预览
function updateBeautyPreview() {
    // 实现实时预览逻辑
    console.log('更新美颜预览');
}

// 应用美颜预设
function applyBeautyPreset(preset) {
    const presets = {
        natural: { beauty_strength: 30, smoothing: 20, whitening: 25, eye_enhancement: 40, lip_adjustment: 15 },
        sweet: { beauty_strength: 60, smoothing: 40, whitening: 50, eye_enhancement: 70, lip_adjustment: 35 },
        glamour: { beauty_strength: 80, smoothing: 60, whitening: 70, eye_enhancement: 85, lip_adjustment: 50 }
    };

    const params = presets[preset];
    if (params) {
        $('#beauty-strength').val(params.beauty_strength).trigger('input');
        $('#smoothing').val(params.smoothing).trigger('input');
        $('#whitening').val(params.whitening).trigger('input');
        $('#eye-enhancement').val(params.eye_enhancement).trigger('input');
        $('#lip-adjustment').val(params.lip_adjustment).trigger('input');
    }
}

// 切换图片对比
function toggleImageComparison() {
    // 实现对比功能
    console.log('切换图片对比');
}

// 切换全屏
function toggleFullscreen() {
    if (document.fullscreenElement) {
        document.exitFullscreen();
    } else {
        document.documentElement.requestFullscreen();
    }
}

// 重置美颜参数
function resetBeautyParams() {
    $('#beauty-strength').val(50).trigger('input');
    $('#smoothing').val(30).trigger('input');
    $('#whitening').val(40).trigger('input');
    $('#eye-enhancement').val(60).trigger('input');
    $('#lip-adjustment').val(25).trigger('input');

    // 移除预设选择
    $('.preset-btn').removeClass('active');

    showNotification('参数已重置', 'info');
}

// 格式化文件大小
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// 显示帮助中心
function showHelpCenter() {
    const helpModal = $(`
        <div class="modal-overlay" id="help-modal">
            <div class="modal help-modal">
                <div class="modal-header">
                    <h3>帮助中心</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="help-content">
                        <div class="help-section">
                            <h4>🚀 快速开始</h4>
                            <p>1. 点击上传区域或拖拽图片到页面</p>
                            <p>2. 选择需要的处理工具</p>
                            <p>3. 调整参数并点击处理</p>
                            <p>4. 下载处理后的图片</p>
                        </div>
                        
                        <div class="help-section">
                            <h4>⌨️ 快捷键</h4>
                            <p><kbd>Ctrl/Cmd + O</kbd> - 打开文件</p>
                            <p><kbd>Ctrl/Cmd + S</kbd> - 下载图片</p>
                            <p><kbd>Ctrl/Cmd + Z</kbd> - 重置图片</p>
                            <p><kbd>Esc</kbd> - 关闭弹窗</p>
                        </div>
                        
                        <div class="help-section">
                            <h4>📝 支持格式</h4>
                            <p>图片格式：JPG, PNG, GIF, WebP</p>
                            <p>最大大小：10MB</p>
                        </div>
                        
                        <div class="help-section">
                            <h4>🛠️ 功能说明</h4>
                            <p><strong>AI美颜：</strong>智能面部美化，包含磨皮、美白、眼部增强等</p>
                            <p><strong>滤镜效果：</strong>多种艺术滤镜，营造不同氛围</p>
                            <p><strong>颜色调整：</strong>精确控制亮度、对比度、饱和度</p>
                            <p><strong>背景处理：</strong>智能背景移除、替换、模糊</p>
                            <p><strong>智能修复：</strong>去除瑕疵、噪点，增强细节</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    $('body').append(helpModal);
    helpModal.show();
}

// 显示历史记录面板
function showHistoryPanel() {
    if (!authToken) {
        showNotification('请先登录查看历史记录', 'warning');
        return;
    }

    showLoading('加载历史记录...');

    $.ajax({
        url: `${API_BASE_URL}/processing/history`,
        type: 'GET',
        headers: {
            'Authorization': `Bearer ${authToken}`,
            'Content-Type': 'application/json'
        },
        success: function (response) {
            hideLoading();
            if (response.success) {
                displayHistoryModal(response.data);
            } else {
                showNotification(response.message || '加载失败', 'error');
            }
        },
        error: function (xhr) {
            hideLoading();
            const response = xhr.responseJSON;
            showNotification(response?.message || '加载失败', 'error');
        }
    });
}

// 显示历史记录模态框
function displayHistoryModal(records) {
    const historyModal = $(`
        <div class="modal-overlay" id="history-modal">
            <div class="modal history-modal">
                <div class="modal-header">
                    <h3>处理历史</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="history-list">
                        ${records.map(record => `
                            <div class="history-item">
                                <div class="history-image">
                                    <img src="${record.original_url}" alt="原图">
                                </div>
                                <div class="history-info">
                                    <h4>${record.operation_type}</h4>
                                    <p>处理时间：${new Date(record.created_at).toLocaleString()}</p>
                                    <p>状态：${record.status === 'completed' ? '已完成' : '处理中'}</p>
                                </div>
                                <div class="history-actions">
                                    ${record.status === 'completed' ? `
                                        <button class="btn-secondary" onclick="viewHistoryResult(${record.id})">查看结果</button>
                                        <button class="btn-primary" onclick="downloadHistoryResult(${record.id})">下载</button>
                                    ` : ''}
                                    <button class="btn-danger" onclick="deleteHistoryRecord(${record.id})">删除</button>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                </div>
            </div>
        </div>
    `);

    $('body').append(historyModal);
    historyModal.show();
}

// 显示收藏面板
function showFavoritesPanel() {
    const favoritesModal = $(`
        <div class="modal-overlay" id="favorites-modal">
            <div class="modal favorites-modal">
                <div class="modal-header">
                    <h3>我的收藏</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="favorites-list">
                        <div class="empty-state">
                            <i class="fas fa-heart"></i>
                            <p>暂无收藏内容</p>
                            <p>处理完成的图片可以添加到收藏</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    $('body').append(favoritesModal);
    favoritesModal.show();
}

// 获取通知图标
function getNotificationIcon(type) {
    const icons = {
        'info': 'fas fa-info-circle',
        'success': 'fas fa-check-circle',
        'warning': 'fas fa-exclamation-triangle',
        'error': 'fas fa-times-circle'
    };
    return icons[type] || icons['info'];
}

// 获取分类名称
function getCategoryName(category) {
    const categories = {
        'system': '系统通知',
        'processing': '处理通知',
        'user': '用户通知'
    };
    return categories[category] || '其他';
}

// 初始化实时通知
function initNotificationRealtime() {
    // 每30秒检查一次新通知
    setInterval(() => {
        checkNewNotifications();
    }, 30000);
}

// 检查新通知
function checkNewNotifications() {
    // 实现检查新通知的逻辑
    updateNotificationBadge();
}

// 显示通知面板
async function showNotificationsPanel() {
    if (!authToken) {
        showNotification('请先登录查看通知', 'warning');
        return;
    }

    try {
        const notifications = await fetchNotifications();

        const notificationsModal = $(`
            <div class="modal-overlay" id="notifications-modal">
                <div class="modal notifications-modal">
                    <div class="modal-header">
                        <h3><i class="fas fa-bell"></i> 通知中心</h3>
                        <button class="modal-close">&times;</button>
                    </div>
                    <div class="modal-body">
                        <div class="notifications-toolbar">
                            <div class="toolbar-left">
                                <select id="notification-filter" class="form-select">
                                    <option value="all">全部通知</option>
                                    <option value="unread">未读通知</option>
                                    <option value="system">系统通知</option>
                                    <option value="processing">处理通知</option>
                                    <option value="user">用户通知</option>
                                </select>
                                <input type="text" id="notification-search" class="form-input" placeholder="搜索通知...">
                            </div>
                            <div class="toolbar-right">
                                <button class="btn-secondary" onclick="toggleSelectAll()">全选</button>
                                <button class="btn-primary" onclick="batchMarkAsRead()">标记已读</button>
                                <button class="btn-danger" onclick="batchDelete()">批量删除</button>
                                <button class="btn-warning" onclick="clearAllNotifications()">清空全部</button>
                            </div>
                        </div>
                        
                        <div class="notifications-list" id="notifications-list">
                            ${notifications.map(notification => `
                                <div class="notification-item ${notification.is_read ? '' : 'unread'}" data-id="${notification.id}">
                                    <div class="notification-checkbox">
                                        <input type="checkbox" class="notification-select" value="${notification.id}">
                                    </div>
                                    <div class="notification-icon">
                                        <i class="${getNotificationIcon(notification.type)}"></i>
                                    </div>
                                    <div class="notification-content">
                                        <div class="notification-header">
                                            <h4 class="notification-title">${notification.title}</h4>
                                            <span class="notification-time">${new Date(notification.created_at).toLocaleString()}</span>
                                        </div>
                                        <p class="notification-message">${notification.message}</p>
                                        <div class="notification-meta">
                                            <span class="notification-category">${getCategoryName(notification.category)}</span>
                                            <span class="notification-priority priority-${notification.priority}">${notification.priority}</span>
                                        </div>
                                    </div>
                                    <div class="notification-actions">
                                        <button class="btn-icon" onclick="viewNotificationDetail(${notification.id})" title="查看详情">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <button class="btn-icon" onclick="handleNotificationAction('mark_read', ${notification.id})" title="标记已读">
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <button class="btn-icon btn-danger" onclick="handleNotificationAction('delete', ${notification.id})" title="删除">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                        
                        <div class="notifications-pagination">
                            <button class="btn-secondary" onclick="loadMoreNotifications()" id="load-more-btn">
                                加载更多
                            </button>
                        </div>
                        
                        <div class="notifications-settings">
                            <button class="btn-link" onclick="showNotificationSettings()">
                                <i class="fas fa-cog"></i> 通知设置
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `);

        $('body').append(notificationsModal);
        notificationsModal.show();

        // 绑定筛选和搜索事件
        $('#notification-filter').on('change', filterNotifications);
        $('#notification-search').on('input', debounce(filterNotifications, 300));

        // 添加点击遮罩层关闭功能
        notificationsModal.on('click', function (e) {
            if (e.target === this) {
                closeModal();
            }
        });

        // 添加ESC键关闭功能
        $(document).on('keydown.notifications', function (e) {
            if (e.key === 'Escape') {
                closeModal();
                $(document).off('keydown.notifications');
            }
        });

    } catch (error) {
        showNotification('加载通知失败', 'error');
    }
}

// 筛选通知
function filterNotifications() {
    const filter = $('#notification-filter').val();
    const search = $('#notification-search').val().toLowerCase();

    $('.notification-item').each(function () {
        const $item = $(this);
        const title = $item.find('.notification-title').text().toLowerCase();
        const message = $item.find('.notification-message').text().toLowerCase();
        const category = $item.find('.notification-category').text().toLowerCase();
        const isRead = !$item.hasClass('unread');

        let showItem = true;

        // 应用筛选
        if (filter === 'unread' && isRead) {
            showItem = false;
        } else if (filter !== 'all' && filter !== 'unread' && !category.includes(filter)) {
            showItem = false;
        }

        // 应用搜索
        if (search && !title.includes(search) && !message.includes(search)) {
            showItem = false;
        }

        $item.toggle(showItem);
    });
}

// 查看通知详情
function viewNotificationDetail(id) {
    const notificationItem = $(`.notification-item[data-id="${id}"]`);
    const title = notificationItem.find('.notification-title').text();
    const message = notificationItem.find('.notification-message').text();
    const time = notificationItem.find('.notification-time').text();
    const category = notificationItem.find('.notification-category').text();

    const detailModal = $(`
        <div class="modal-overlay" id="notification-detail-modal">
            <div class="modal notification-detail-modal">
                <div class="modal-header">
                    <h3>通知详情</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="notification-detail">
                        <h4>${title}</h4>
                        <div class="detail-meta">
                            <span class="detail-time"><i class="fas fa-clock"></i> ${time}</span>
                            <span class="detail-category"><i class="fas fa-tag"></i> ${category}</span>
                        </div>
                        <div class="detail-content">
                            <p>${message}</p>
                        </div>
                        <div class="detail-actions">
                            <button class="btn-primary" onclick="markAsRead(${id})">标记已读</button>
                            <button class="btn-danger" onclick="deleteNotification(${id})">删除</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    $('body').append(detailModal);
    detailModal.show();

    // 自动标记为已读
    markAsRead(id);
}

// 处理通知操作
function handleNotificationAction(action, id) {
    if (action === 'mark_read') {
        markAsRead(id);
    } else if (action === 'delete') {
        deleteNotification(id);
    }
}

// 切换全选
function toggleSelectAll() {
    const checkboxes = $('.notification-select:visible');
    const allChecked = checkboxes.length > 0 && checkboxes.filter(':checked').length === checkboxes.length;

    checkboxes.prop('checked', !allChecked);
}

// 批量标记已读
function batchMarkAsRead() {
    const selectedIds = $('.notification-select:checked').map(function () {
        return $(this).val();
    }).get();

    selectedIds.forEach(id => markAsRead(id));
}

// 批量删除
function batchDelete() {
    const selectedIds = $('.notification-select:checked').map(function () {
        return $(this).val();
    }).get();

    if (selectedIds.length === 0) {
        showNotification('请选择要删除的通知', 'warning');
        return;
    }

    selectedIds.forEach(id => deleteNotification(id));
}

// 清空所有通知
function clearAllNotifications() {
    if (confirm('确定要清空所有通知吗？此操作不可恢复。')) {
        $('.notification-item').each(function () {
            const id = $(this).data('id');
            deleteNotification(id);
        });
    }
}

// 加载更多通知
function loadMoreNotifications() {
    const currentCount = $('.notification-item').length;
    const nextPage = Math.floor(currentCount / 10) + 1;

    fetchNotifications(nextPage).then(notifications => {
        if (notifications.length === 0) {
            $('#load-more-btn').hide();
            showNotification('没有更多通知了', 'info');
            return;
        }

        const notificationsList = $('#notifications-list');
        notifications.forEach(notification => {
            const notificationHtml = `
                <div class="notification-item ${notification.is_read ? '' : 'unread'}" data-id="${notification.id}">
                    <div class="notification-checkbox">
                        <input type="checkbox" class="notification-select" value="${notification.id}">
                    </div>
                    <div class="notification-icon">
                        <i class="${getNotificationIcon(notification.type)}"></i>
                    </div>
                    <div class="notification-content">
                        <div class="notification-header">
                            <h4 class="notification-title">${notification.title}</h4>
                            <span class="notification-time">${new Date(notification.created_at).toLocaleString()}</span>
                        </div>
                        <p class="notification-message">${notification.message}</p>
                        <div class="notification-meta">
                            <span class="notification-category">${getCategoryName(notification.category)}</span>
                            <span class="notification-priority priority-${notification.priority}">${notification.priority}</span>
                        </div>
                    </div>
                    <div class="notification-actions">
                        <button class="btn-icon" onclick="viewNotificationDetail(${notification.id})" title="查看详情">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn-icon" onclick="handleNotificationAction('mark_read', ${notification.id})" title="标记已读">
                            <i class="fas fa-check"></i>
                        </button>
                        <button class="btn-icon btn-danger" onclick="handleNotificationAction('delete', ${notification.id})" title="删除">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            `;
            notificationsList.append(notificationHtml);
        });
    }).catch(error => {
        showNotification('加载失败', 'error');
    });
}

// 显示通知设置
function showNotificationSettings() {
    const settings = getNotificationSettings();

    const settingsModal = $(`
        <div class="modal-overlay" id="notification-settings-modal">
            <div class="modal notification-settings-modal">
                <div class="modal-header">
                    <h3>通知设置</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="settings-form">
                        <div class="setting-group">
                            <h4>通知类型</h4>
                            <label class="setting-item">
                                <input type="checkbox" id="enable-system" ${settings.system ? 'checked' : ''}>
                                <span>系统通知</span>
                            </label>
                            <label class="setting-item">
                                <input type="checkbox" id="enable-processing" ${settings.processing ? 'checked' : ''}>
                                <span>处理通知</span>
                            </label>
                            <label class="setting-item">
                                <input type="checkbox" id="enable-user" ${settings.user ? 'checked' : ''}>
                                <span>用户通知</span>
                            </label>
                        </div>
                        
                        <div class="setting-group">
                            <h4>通知方式</h4>
                            <label class="setting-item">
                                <input type="checkbox" id="enable-browser" ${settings.browser ? 'checked' : ''}>
                                <span>浏览器通知</span>
                            </label>
                            <label class="setting-item">
                                <input type="checkbox" id="enable-sound" ${settings.sound ? 'checked' : ''}>
                                <span>声音提醒</span>
                            </label>
                        </div>
                        
                        <div class="setting-group">
                            <h4>自动清理</h4>
                            <label class="setting-item">
                                <span>自动删除已读通知（天）：</span>
                                <input type="number" id="auto-delete-days" value="${settings.autoDeleteDays}" min="1" max="365">
                            </label>
                        </div>
                        
                        <div class="settings-actions">
                            <button class="btn-primary" onclick="saveNotificationSettings()">保存设置</button>
                            <button class="btn-secondary" onclick="closeModal()">取消</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    $('body').append(settingsModal);
    settingsModal.show();
}

// 保存通知设置
function saveNotificationSettings() {
    const settings = {
        system: $('#enable-system').is(':checked'),
        processing: $('#enable-processing').is(':checked'),
        user: $('#enable-user').is(':checked'),
        browser: $('#enable-browser').is(':checked'),
        sound: $('#enable-sound').is(':checked'),
        autoDeleteDays: parseInt($('#auto-delete-days').val()) || 30
    };

    localStorage.setItem('notificationSettings', JSON.stringify(settings));

    // 如果启用了浏览器通知，请求权限
    if (settings.browser) {
        initNotificationPermission();
    }

    closeModal();
    showNotification('设置已保存', 'success');
}

// 获取通知设置
function getNotificationSettings() {
    const defaultSettings = {
        system: true,
        processing: true,
        user: true,
        browser: true,
        sound: false,
        autoDeleteDays: 30
    };

    const saved = localStorage.getItem('notificationSettings');
    return saved ? { ...defaultSettings, ...JSON.parse(saved) } : defaultSettings;
}

// 初始化通知权限
function initNotificationPermission() {
    if ('Notification' in window && Notification.permission === 'default') {
        Notification.requestPermission().then(permission => {
            if (permission === 'granted') {
                showNotification('浏览器通知已启用', 'success');
            }
        });
    }
}

// 显示浏览器通知
function showBrowserNotification(title, message, icon = '/assets/images/logo.png') {
    if ('Notification' in window && Notification.permission === 'granted') {
        const notification = new Notification(title, {
            body: message,
            icon: icon,
            tag: 'ai-image-platform'
        });

        notification.onclick = function () {
            window.focus();
            notification.close();
        };

        setTimeout(() => {
            notification.close();
        }, 5000);
    }
}

// 获取通知列表
async function fetchNotifications(page = 1, limit = 10) {
    const token = localStorage.getItem('authToken');
    if (!token) {
        return [];
    }

    try {
        const response = await $.ajax({
            url: `${API_BASE_URL}/notifications?page=${page}&limit=${limit}`,
            type: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.success) {
            return response.data.notifications || [];
        }
        return [];
    } catch (error) {
        console.error('获取通知失败:', error);
        return [];
    }
}

// 标记通知为已读
function markAsRead(id) {
    markNotificationAsRead(id).then(() => {
        $(`.notification-item[data-id="${id}"]`).removeClass('unread');
        updateNotificationBadge();
    });
}

// 删除通知
function deleteNotification(id) {
    deleteNotificationAPI(id).then(() => {
        $(`.notification-item[data-id="${id}"]`).remove();
        updateNotificationBadge();
        showNotification('通知已删除', 'success');
    });
}

// 标记通知为已读API
async function markNotificationAsRead(id) {
    const token = localStorage.getItem('authToken');
    if (!token) return;

    try {
        await $.ajax({
            url: `${API_BASE_URL}/notifications/${id}/read`,
            type: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
    } catch (error) {
        console.error('标记已读失败:', error);
    }
}

// 删除通知API
async function deleteNotificationAPI(id) {
    const token = localStorage.getItem('authToken');
    if (!token) return;

    try {
        await $.ajax({
            url: `${API_BASE_URL}/notifications/${id}`,
            type: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
    } catch (error) {
        console.error('删除通知失败:', error);
    }
}

// 更新通知徽章
async function updateNotificationBadge() {
    const token = localStorage.getItem('authToken');
    if (!token) {
        $('.notification-badge').hide();
        return;
    }

    try {
        const response = await $.ajax({
            url: `${API_BASE_URL}/notifications/unread-count`,
            type: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.success) {
            const count = response.data.count;
            if (count > 0) {
                $('.notification-badge').text(count > 99 ? '99+' : count).show();
            } else {
                $('.notification-badge').hide();
            }
        }
    } catch (error) {
        // 静默处理401错误，不在控制台显示
        if (error.status !== 401) {
            console.error('获取未读通知数量失败:', error);
        }
        $('.notification-badge').hide();
    }
}

// 显示设置面板
function showSettingsPanel() {
    const settingsModal = $(`
        <div class="modal-overlay" id="settings-modal">
            <div class="modal settings-modal">
                <div class="modal-header">
                    <h3>系统设置</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="settings-tabs">
                        <div class="tab-nav">
                            <button class="tab-btn active" data-tab="general">常规设置</button>
                            <button class="tab-btn" data-tab="processing">处理设置</button>
                            <button class="tab-btn" data-tab="account">账户设置</button>
                        </div>
                        
                        <div class="tab-content">
                            <div class="tab-pane active" id="general-tab">
                                <div class="setting-group">
                                    <h4>界面设置</h4>
                                    <label class="setting-item">
                                        <span>主题模式</span>
                                        <select class="form-select">
                                            <option value="light">浅色模式</option>
                                            <option value="dark">深色模式</option>
                                            <option value="auto">跟随系统</option>
                                        </select>
                                    </label>
                                    <label class="setting-item">
                                        <span>语言</span>
                                        <select class="form-select">
                                            <option value="zh-CN">简体中文</option>
                                            <option value="en-US">English</option>
                                        </select>
                                    </label>
                                </div>
                            </div>
                            
                            <div class="tab-pane" id="processing-tab">
                                <div class="setting-group">
                                    <h4>处理设置</h4>
                                    <label class="setting-item">
                                        <span>默认图片质量</span>
                                        <select class="form-select">
                                            <option value="high">高质量</option>
                                            <option value="medium">中等质量</option>
                                            <option value="low">低质量</option>
                                        </select>
                                    </label>
                                    <label class="setting-item">
                                        <span>自动保存处理结果</span>
                                        <input type="checkbox" checked>
                                    </label>
                                </div>
                            </div>
                            
                            <div class="tab-pane" id="account-tab">
                                <div class="setting-group">
                                    <h4>账户信息</h4>
                                    <div class="account-info">
                                        <p>用户名：${currentUser?.username || '未登录'}</p>
                                        <p>邮箱：${currentUser?.email || '未设置'}</p>
                                        <p>注册时间：${currentUser?.created_at ? new Date(currentUser.created_at).toLocaleDateString() : '未知'}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    $('body').append(settingsModal);
    settingsModal.show();

    // 绑定标签切换事件
    settingsModal.find('.tab-btn').on('click', function () {
        const tabId = $(this).data('tab');
        settingsModal.find('.tab-btn').removeClass('active');
        settingsModal.find('.tab-pane').removeClass('active');
        $(this).addClass('active');
        settingsModal.find(`#${tabId}-tab`).addClass('active');
    });
}

// 显示计费面板
function showBillingPanel() {
    const billingModal = $(`
        <div class="modal-overlay" id="billing-modal">
            <div class="modal billing-modal">
                <div class="modal-header">
                    <h3>计费信息</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="billing-info">
                        <div class="current-plan">
                            <h4>当前套餐</h4>
                            <div class="plan-card">
                                <h5>免费版</h5>
                                <p>每月10次免费处理</p>
                                <p>已使用：3/10</p>
                            </div>
                        </div>
                        
                        <div class="upgrade-options">
                            <h4>升级选项</h4>
                            <div class="plan-options">
                                <div class="plan-option">
                                    <h5>基础版</h5>
                                    <p class="price">¥29/月</p>
                                    <ul>
                                        <li>每月100次处理</li>
                                        <li>高级滤镜</li>
                                        <li>优先处理</li>
                                    </ul>
                                    <button class="btn-primary">选择套餐</button>
                                </div>
                                
                                <div class="plan-option">
                                    <h5>专业版</h5>
                                    <p class="price">¥99/月</p>
                                    <ul>
                                        <li>无限次处理</li>
                                        <li>所有功能</li>
                                        <li>API访问</li>
                                        <li>技术支持</li>
                                    </ul>
                                    <button class="btn-primary">选择套餐</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    $('body').append(billingModal);
    billingModal.show();
}

// 显示使用统计面板
function showUsageStatsPanel() {
    const statsModal = $(`
        <div class="modal-overlay" id="stats-modal">
            <div class="modal stats-modal">
                <div class="modal-header">
                    <h3>使用统计</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="stats-overview">
                        <div class="stat-card">
                            <h4>本月处理次数</h4>
                            <p class="stat-number">23</p>
                        </div>
                        <div class="stat-card">
                            <h4>总处理次数</h4>
                            <p class="stat-number">156</p>
                        </div>
                        <div class="stat-card">
                            <h4>节省时间</h4>
                            <p class="stat-number">12.5小时</p>
                        </div>
                        <div class="stat-card">
                            <h4>最常用功能</h4>
                            <p class="stat-number">AI美颜</p>
                        </div>
                    </div>
                    
                    <div class="stats-chart">
                        <h4>使用趋势</h4>
                        <div class="chart-placeholder">
                            <p>图表加载中...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    $('body').append(statsModal);
    statsModal.show();
}

// 显示反馈面板
function showFeedbackPanel() {
    const feedbackModal = $(`
        <div class="modal-overlay" id="feedback-modal">
            <div class="modal feedback-modal">
                <div class="modal-header">
                    <h3>意见反馈</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <form class="feedback-form">
                        <div class="form-group">
                            <label>反馈类型</label>
                            <select class="form-select" required>
                                <option value="">请选择</option>
                                <option value="bug">Bug报告</option>
                                <option value="feature">功能建议</option>
                                <option value="improvement">改进建议</option>
                                <option value="other">其他</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>详细描述</label>
                            <textarea class="form-textarea" rows="5" placeholder="请详细描述您的问题或建议..." required></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label>联系邮箱（可选）</label>
                            <input type="email" class="form-input" placeholder="如需回复请填写邮箱">
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn-primary">提交反馈</button>
                            <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    `);

    $('body').append(feedbackModal);
    feedbackModal.show();

    // 绑定表单提交事件
    feedbackModal.find('.feedback-form').on('submit', function (e) {
        e.preventDefault();
        showNotification('反馈已提交，感谢您的建议！', 'success');
        closeModal();
    });
}

// 切换用户菜单
function toggleUserMenu() {
    $('.user-dropdown').toggleClass('show');
}

// 加载处理后的图片（带认证）
function loadProcessedImage(resultUrl) {
    console.log('Loading processed image:', resultUrl);
    console.log('API_BASE_URL:', API_BASE_URL);
    console.log('authToken exists:', !!authToken);

    if (!authToken) {
        showNotification('需要登录才能查看处理结果', 'warning');
        return;
    }

    // resultUrl已经包含/api前缀，所以只需要添加基础URL（不含/api）
    const baseUrl = API_BASE_URL.replace('/api', '');
    const fullUrl = `${baseUrl}${resultUrl}`;
    console.log('Full URL:', fullUrl);

    // 使用fetch API获取图片数据
    fetch(fullUrl, {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${authToken}`
        }
    })
        .then(response => {
            console.log('Response status:', response.status);
            console.log('Response ok:', response.ok);
            if (!response.ok) {
                throw new Error(`获取图片失败: ${response.status} ${response.statusText}`);
            }
            return response.blob();
        })
        .then(blob => {
            console.log('Blob received, size:', blob.size);
            // 创建图片URL
            const imageUrl = URL.createObjectURL(blob);
            console.log('Created blob URL:', imageUrl);
            const processedImage = $('#processed-image');

            // 清除之前的事件监听器
            processedImage.off('load error');

            // 设置图片源
            processedImage.attr('src', imageUrl);
            console.log('Set image src to:', imageUrl);

            // 等待图片加载完成
            processedImage.on('load', function () {
                console.log('Image loaded successfully');
                processedImage.show();
                $('#placeholder-content').hide();
                console.log('Image displayed, placeholder hidden');
            }).on('error', function () {
                console.error('Image load error');
                showNotification('处理后的图片加载失败', 'error');
                URL.revokeObjectURL(imageUrl); // 清理内存
            });
        })
        .catch(error => {
            console.error('加载处理后图片失败:', error);
            showNotification(`处理后的图片加载失败: ${error.message}`, 'error');
        });
}

// 恢复原始的美颜面板内容
function restoreBeautyPanel() {
    console.log('正在恢复原始美颜面板...');

    // 恢复HTML中定义的原始美颜面板内容（与原始HTML完全一致）
    const originalBeautyPanel = `
        <!-- 磨皮设置 -->
        <div class="parameter-group">
            <div class="group-header">
                <i class="fas fa-hand-sparkles"></i>
                <span class="group-title">磨皮设置</span>
            </div>
            <div class="parameter-item">
                <div class="parameter-label">
                    <span>磨皮强度</span>
                    <span class="parameter-value" id="smoothing-value">30</span>
                </div>
                <div class="slider-container">
                    <input type="range" class="beauty-slider" id="smoothing" min="0" max="100" value="30">
                    <div class="slider-track"></div>
                </div>
                <div class="parameter-tips">适度磨皮，保持肌肤自然质感</div>
            </div>
        </div>

        <!-- 美白设置 -->
        <div class="parameter-group">
            <div class="group-header">
                <i class="fas fa-sun"></i>
                <span class="group-title">美白设置</span>
            </div>
            <div class="parameter-item">
                <div class="parameter-label">
                    <span>美白程度</span>
                    <span class="parameter-value" id="whitening-value">40</span>
                </div>
                <div class="slider-container">
                    <input type="range" class="beauty-slider" id="whitening" min="0" max="100" value="40">
                    <div class="slider-track"></div>
                </div>
                <div class="parameter-tips">自然提亮肤色，避免过度美白</div>
            </div>
        </div>

        <!-- 眼部增强 -->
        <div class="parameter-group">
            <div class="group-header">
                <i class="fas fa-eye"></i>
                <span class="group-title">眼部增强</span>
            </div>
            <div class="parameter-item">
                <div class="parameter-label">
                    <span>增强程度</span>
                    <span class="parameter-value" id="eye-enhancement-value">60</span>
                </div>
                <div class="slider-container">
                    <input type="range" class="beauty-slider" id="eye-enhancement" min="0" max="100" value="60">
                    <div class="slider-track"></div>
                </div>
                <div class="parameter-tips">增强眼部轮廓，提升神采</div>
            </div>
        </div>

        <!-- 唇部调整 -->
        <div class="parameter-group">
            <div class="group-header">
                <i class="fas fa-kiss"></i>
                <span class="group-title">唇部调整</span>
            </div>
            <div class="parameter-item">
                <div class="parameter-label">
                    <span>唇色增强</span>
                    <span class="parameter-value" id="lip-adjustment-value">25</span>
                </div>
                <div class="slider-container">
                    <input type="range" class="beauty-slider" id="lip-adjustment" min="0" max="100" value="25">
                    <div class="slider-track"></div>
                </div>
                <div class="parameter-tips">自然提升唇部色彩饱和度</div>
            </div>
        </div>

        <!-- 预设方案 -->
        <div class="preset-section">
            <div class="preset-header">
                <i class="fas fa-magic"></i>
                <span>快速预设</span>
            </div>
            <div class="preset-buttons">
                <button class="preset-btn" data-preset="natural">
                    <i class="fas fa-leaf"></i>
                    <span>自然</span>
                </button>
                <button class="preset-btn" data-preset="sweet">
                    <i class="fas fa-heart"></i>
                    <span>甜美</span>
                </button>
                <button class="preset-btn" data-preset="elegant">
                    <i class="fas fa-gem"></i>
                    <span>优雅</span>
                </button>
                <button class="preset-btn" data-preset="fresh">
                    <i class="fas fa-snowflake"></i>
                    <span>清新</span>
                </button>
            </div>
        </div>

        <!-- AI建议 -->
        <div class="ai-suggestions">
            <div class="ai-header">
                <i class="fas fa-robot"></i>
                <span>AI智能建议</span>
            </div>
            <div class="suggestion-list" id="suggestion-list">
                <div class="suggestion-item">
                    <i class="fas fa-lightbulb"></i>
                    <span>上传照片后获取个性化建议</span>
                </div>
            </div>
        </div>
    `;

    // 更新面板内容
    $('.panel-content').html(originalBeautyPanel);

    // 确保操作按钮部分存在
    const panelActions = $('.panel-actions');
    if (panelActions.length === 0) {
        // 如果panel-actions不存在，创建它
        const actionsHtml = `
                <div class="panel-actions">
                    <button class="btn-process-beauty" id="process-btn" disabled>
                        <i class="fas fa-magic"></i>
                        <span>开始美颜</span>
                        <div class="btn-loading" style="display: none;">
                            <div class="loading-spinner"></div>
                        </div>
                    </button>
                </div>
            `;
        $('.beauty-panel').append(actionsHtml);
        console.log('已创建操作按钮容器');
    } else {
        // 如果存在，确保按钮内容正确
        panelActions.html(`
                <button class="btn-process-beauty" id="process-btn" disabled>
                    <i class="fas fa-magic"></i>
                    <span>开始美颜</span>
                    <div class="btn-loading" style="display: none;">
                        <div class="loading-spinner"></div>
                    </div>
                </button>
            `);
        console.log('已更新操作按钮内容');
    }

    // 重新绑定事件（如果需要）
    console.log('美颜面板已完全恢复');
}