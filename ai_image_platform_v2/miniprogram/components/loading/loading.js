// components/loading/loading.js
Component({
  properties: {
    // 是否显示加载
    visible: {
      type: Boolean,
      value: false
    },
    // 加载文本
    text: {
      type: String,
      value: '加载中...'
    },
    // 加载动画类型
    type: {
      type: String,
      value: 'circle' // circle, spinner, pulse, wave, dots
    },
    // 是否显示进度
    showProgress: {
      type: Boolean,
      value: false
    },
    // 进度值 (0-100)
    progress: {
      type: Number,
      value: 0
    },
    // 是否显示取消按钮
    showCancel: {
      type: Boolean,
      value: false
    },
    // 是否可以点击遮罩关闭
    maskClosable: {
      type: Boolean,
      value: false
    }
  },

  data: {
    // 内部状态
  },

  methods: {
    // 取消按钮点击
    onCancel() {
      this.triggerEvent('cancel')
    },

    // 遮罩点击
    onMaskTap() {
      if (this.data.maskClosable) {
        this.triggerEvent('close')
      }
    },

    // 显示加载
    show(options = {}) {
      const {
        text = '加载中...',
        type = 'circle',
        showProgress = false,
        progress = 0,
        showCancel = false
      } = options

      this.setData({
        visible: true,
        text,
        type,
        showProgress,
        progress,
        showCancel
      })
    },

    // 隐藏加载
    hide() {
      this.setData({
        visible: false
      })
    },

    // 更新进度
    updateProgress(progress) {
      this.setData({
        progress: Math.max(0, Math.min(100, progress))
      })
    },

    // 更新文本
    updateText(text) {
      this.setData({ text })
    }
  }
})