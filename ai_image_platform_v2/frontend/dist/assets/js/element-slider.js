// Element Plus 风格滑块组件 JavaScript

// 初始化所有 Element Plus 滑块
function initializeElementSliders() {
    console.log('Initializing Element Plus sliders...');
    // 初始化每个滑块
    initializeSlider('smoothing', 30);
    initializeSlider('whitening', 40);
    initializeSlider('eye-enhancement', 60);
    initializeSlider('lip-adjustment', 25);
    console.log('All sliders initialized');
}

// 初始化单个滑块
function initializeSlider(id, initialValue) {
    console.log(`Initializing slider: ${id}`);
    const slider = document.getElementById(id + '-slider');
    const input = document.getElementById(id);
    
    if (!slider || !input) {
        console.warn(`滑块元素未找到: ${id}`);
        console.log(`Slider element: ${slider}, Input element: ${input}`);
        return;
    }
    
    console.log(`Found elements for ${id}: slider=${!!slider}, input=${!!input}`);

    const bar = slider.querySelector('.el-slider__bar');
    const buttonWrapper = slider.querySelector('.el-slider__button-wrapper');
    const runway = slider.querySelector('.el-slider__runway');
    
    let isDragging = false;
    let startX = 0;
    let startLeft = 0;

    // 设置初始值
    updateSliderValue(id, initialValue);

    // 轨道点击事件
    runway.addEventListener('click', function(e) {
        if (e.target === buttonWrapper || buttonWrapper.contains(e.target)) {
            return;
        }
        
        const rect = runway.getBoundingClientRect();
        const clickX = e.clientX - rect.left;
        const percentage = Math.max(0, Math.min(100, (clickX / rect.width) * 100));
        const value = Math.round(percentage);
        
        updateSliderValue(id, value);
        triggerSliderChange(id, value);
    });

    // 滑块按钮拖拽事件
    buttonWrapper.addEventListener('mousedown', function(e) {
        e.preventDefault();
        isDragging = true;
        startX = e.clientX;
        startLeft = parseFloat(buttonWrapper.style.left) || 0;
        
        document.addEventListener('mousemove', onMouseMove);
        document.addEventListener('mouseup', onMouseUp);
        
        buttonWrapper.style.cursor = 'grabbing';
    });

    function onMouseMove(e) {
        if (!isDragging) return;
        
        const deltaX = e.clientX - startX;
        const rect = runway.getBoundingClientRect();
        const newLeft = startLeft + (deltaX / rect.width) * 100;
        const percentage = Math.max(0, Math.min(100, newLeft));
        const value = Math.round(percentage);
        
        updateSliderValue(id, value);
        triggerSliderChange(id, value);
    }

    function onMouseUp() {
        isDragging = false;
        buttonWrapper.style.cursor = 'grab';
        document.removeEventListener('mousemove', onMouseMove);
        document.removeEventListener('mouseup', onMouseUp);
    }

    // 数字输入框事件
    input.addEventListener('input', function() {
        let value = parseInt(this.value);
        if (isNaN(value)) value = 0;
        value = Math.max(0, Math.min(100, value));
        this.value = value;
        
        updateSliderValue(id, value);
        triggerSliderChange(id, value);
    });

    // 增减按钮事件
    const decreaseBtn = input.closest('.el-input-number').querySelector('.el-input-number__decrease');
    const increaseBtn = input.closest('.el-input-number').querySelector('.el-input-number__increase');
    
    decreaseBtn.addEventListener('click', function() {
        let value = parseInt(input.value) - 1;
        value = Math.max(0, value);
        input.value = value;
        updateSliderValue(id, value);
        triggerSliderChange(id, value);
    });
    
    increaseBtn.addEventListener('click', function() {
        let value = parseInt(input.value) + 1;
        value = Math.min(100, value);
        input.value = value;
        updateSliderValue(id, value);
        triggerSliderChange(id, value);
    });
}

// 更新滑块视觉状态
function updateSliderValue(id, value) {
    const slider = document.getElementById(id + '-slider');
    const input = document.getElementById(id);
    
    if (!slider || !input) return;
    
    const bar = slider.querySelector('.el-slider__bar');
    const buttonWrapper = slider.querySelector('.el-slider__button-wrapper');
    
    // 更新进度条和按钮位置
    bar.style.width = value + '%';
    buttonWrapper.style.left = value + '%';
    
    // 更新输入框值
    input.value = value;
}

// 触发滑块变化事件
function triggerSliderChange(id, value) {
    // 触发美颜预览更新
    if (typeof updateBeautyPreview === 'function') {
        updateBeautyPreview();
    }
    
    // 触发自定义事件
    const event = new CustomEvent('sliderChange', {
        detail: { id: id, value: value }
    });
    document.dispatchEvent(event);
}

// 获取所有滑块值
function getAllSliderValues() {
    return {
        smoothing: parseInt(document.getElementById('smoothing').value) || 30,
        whitening: parseInt(document.getElementById('whitening').value) || 40,
        eyeEnhancement: parseInt(document.getElementById('eye-enhancement').value) || 60,
        lipAdjustment: parseInt(document.getElementById('lip-adjustment').value) || 25
    };
}

// 设置所有滑块值
function setAllSliderValues(values) {
    if (values.smoothing !== undefined) updateSliderValue('smoothing', values.smoothing);
    if (values.whitening !== undefined) updateSliderValue('whitening', values.whitening);
    if (values.eyeEnhancement !== undefined) updateSliderValue('eye-enhancement', values.eyeEnhancement);
    if (values.lipAdjustment !== undefined) updateSliderValue('lip-adjustment', values.lipAdjustment);
}

// 重置所有滑块到默认值
function resetElementSliders() {
    setAllSliderValues({
        smoothing: 30,
        whitening: 40,
        eyeEnhancement: 60,
        lipAdjustment: 25
    });
}

// 应用预设方案
function applyElementSliderPreset(preset) {
    const presets = {
        natural: { smoothing: 20, whitening: 25, eyeEnhancement: 40, lipAdjustment: 15 },
        sweet: { smoothing: 40, whitening: 50, eyeEnhancement: 70, lipAdjustment: 35 },
        glamour: { smoothing: 60, whitening: 70, eyeEnhancement: 85, lipAdjustment: 50 }
    };

    const params = presets[preset];
    if (params) {
        setAllSliderValues(params);
        
        // 触发所有滑块的变化事件
        Object.keys(params).forEach(key => {
            const id = key === 'eyeEnhancement' ? 'eye-enhancement' : 
                      key === 'lipAdjustment' ? 'lip-adjustment' : key;
            triggerSliderChange(id, params[key]);
        });
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    console.log('Element Slider: DOM Content Loaded');
    // 延迟初始化，确保HTML完全加载
    setTimeout(function() {
        console.log('Element Slider: Starting initialization');
        initializeElementSliders();
        console.log('Element Slider: Initialization completed');
    }, 100);
});

// 导出函数供其他脚本使用
window.ElementSlider = {
    initialize: initializeElementSliders,
    getAllValues: getAllSliderValues,
    setAllValues: setAllSliderValues,
    reset: resetElementSliders,
    applyPreset: applyElementSliderPreset
};