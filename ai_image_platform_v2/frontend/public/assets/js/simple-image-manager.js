/**
 * 简化版图片状态管理器
 * 只实现核心的跨模块图片共享功能，不改变原有界面
 */

class SimpleImageManager {
    constructor() {
        this.currentImage = null; // 当前图片
        this.init();
    }

    init() {
        console.log('简化版图片管理器初始化');

        // 监听模块切换
        this.bindModuleSwitching();
    }

    /**
 * 设置当前图片（由上传函数调用）
 */
    setCurrentImage(imageData) {
        this.currentImage = imageData;

        // 更新全局变量以保持兼容性
        window.currentImage = this.currentImage;

        // 确保图片在界面中正确显示
        this.updateImageDisplay();

        // 立即启用相关功能
        this.enableCurrentModuleFeatures();

        console.log('当前图片已设置:', this.currentImage);
    }

    /**
     * 获取当前图片
     */
    getCurrentImage() {
        return this.currentImage;
    }

    /**
     * 监听模块切换事件
     */
    bindModuleSwitching() {
        // 监听侧边栏功能切换
        $(document).on('click', '.tool-item', (e) => {
            console.log('模块切换，保持当前图片状态');

            // 如果有当前图片，确保在新模块中可用
            if (this.currentImage) {
                // 延迟一点执行，确保模块切换完成
                setTimeout(() => {
                    this.updateImageDisplay();
                    this.enableCurrentModuleFeatures();
                }, 100);
            }
        });
    }

    /**
     * 更新图片显示（保持原有界面不变）
     */
    updateImageDisplay() {
        if (!this.currentImage) return;

        // 确保图片在主界面正确显示
        $('#upload-section').hide();
        $('#image-comparison').show();

        // 设置原始图片
        const $originalImage = $('#original-image');
        $originalImage.attr('src', this.currentImage.url);
        $originalImage.show();

        // 隐藏占位内容
        $('#placeholder-content').hide();

        // 更新文件信息
        $('.file-info .file-name').text(this.currentImage.filename || '未知文件');
        $('.file-info .file-size').text(this.formatFileSize(this.currentImage.size || 0));

        console.log('图片显示已更新');
    }

    /**
 * 启用当前模块的功能
 */
    enableCurrentModuleFeatures() {
        if (!this.currentImage) {
            console.log('没有当前图片，无法启用功能');
            return;
        }

        console.log('启用模块功能，当前用户:', window.currentUser ? '已登录' : '未登录');
        console.log('当前图片:', this.currentImage);

        // 启用所有处理相关的按钮和面板
        $('.panel').removeClass('disabled');
        $('#beauty-panel').removeClass('disabled'); // 确保美颜面板启用
        $('#process-btn').prop('disabled', false);

        // 如果用户已登录，启用需要认证的功能
        if (window.currentUser) {
            $('.btn-process-id-photo').prop('disabled', false);
            $('#processIdPhoto').prop('disabled', false); // 确保ID选择器也启用
            $('.btn-process-background').prop('disabled', false);
            console.log('已启用证件照和背景处理按钮');
        } else {
            console.log('用户未登录，跳过证件照功能启用');
        }

        // 调用原有的按钮状态更新函数
        if (typeof updateProcessingButtons === 'function') {
            updateProcessingButtons();
            console.log('已调用 updateProcessingButtons');
        } else {
            console.log('updateProcessingButtons 函数未找到');
        }

        console.log('当前模块功能已启用');
    }

    /**
     * 格式化文件大小
     */
    formatFileSize(bytes) {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
}

// 创建全局简化版图片管理器实例
window.simpleImageManager = new SimpleImageManager();

console.log('简化版图片管理器已加载');
