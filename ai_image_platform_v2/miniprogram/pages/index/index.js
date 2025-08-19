// pages/index/index.js
const app = getApp()
const { imageAPI } = require('../../utils/api')
const { chooseImage, previewImage, showToast, formatTime } = require('../../utils/util')

Page({
  data: {
    currentImage: null,
    recentImages: [],
    isLoggedIn: false,
    loading: false,
    loadingText: '处理中...'
  },

  onLoad(options) {
    console.log('首页加载')
    this.checkLoginStatus()
    this.loadRecentImages()
  },

  onShow() {
    console.log('首页显示')
    this.checkLoginStatus()
    this.loadRecentImages()
    
    // 检查是否有全局当前图片
    if (app.globalData.currentImage) {
      this.setData({
        currentImage: app.globalData.currentImage
      })
    }
  },

  onPullDownRefresh() {
    this.loadRecentImages()
    wx.stopPullDownRefresh()
  },

  // 检查登录状态
  checkLoginStatus() {
    this.setData({
      isLoggedIn: app.globalData.isLoggedIn
    })
  },

  // 选择图片
  async chooseImage() {
    try {
      const res = await chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera']
      })

      if (res.tempFilePaths && res.tempFilePaths.length > 0) {
        const imagePath = res.tempFilePaths[0]
        
        this.setData({
          currentImage: imagePath,
          loading: true,
          loadingText: '上传图片中...'
        })

        // 上传图片
        try {
          const uploadRes = await imageAPI.upload(imagePath, !this.data.isLoggedIn)
          
          if (uploadRes.success) {
            const imageData = uploadRes.data
            
            // 更新当前图片信息
            app.globalData.currentImage = imageData.file_url
            this.setData({
              currentImage: imageData.file_url,
              loading: false
            })

            // 刷新最近图片列表
            if (this.data.isLoggedIn) {
              this.loadRecentImages()
            }

            showToast('图片上传成功', 'success')
          } else {
            throw new Error(uploadRes.message || '上传失败')
          }
        } catch (uploadError) {
          console.error('上传失败:', uploadError)
          showToast('上传失败，请重试')
          this.setData({
            currentImage: null,
            loading: false
          })
        }
      }
    } catch (error) {
      console.error('选择图片失败:', error)
      showToast('选择图片失败')
    }
  },

  // 预览图片
  previewImage() {
    if (this.data.currentImage) {
      previewImage(this.data.currentImage)
    }
  },

  // 加载最近图片
  async loadRecentImages() {
    if (!this.data.isLoggedIn) {
      this.setData({ recentImages: [] })
      return
    }

    try {
      const res = await imageAPI.getList(1, 5)
      
      if (res.success && res.data.images) {
        const images = res.data.images.map(img => ({
          ...img,
          thumbnail: imageAPI.getThumbnail(img.id),
          created_time: this.formatImageTime(img.created_at)
        }))
        
        this.setData({
          recentImages: images
        })
      }
    } catch (error) {
      console.error('加载最近图片失败:', error)
    }
  },

  // 格式化图片时间
  formatImageTime(timestamp) {
    const date = new Date(timestamp)
    const now = new Date()
    const diff = now - date
    
    if (diff < 60000) { // 1分钟内
      return '刚刚'
    } else if (diff < 3600000) { // 1小时内
      return `${Math.floor(diff / 60000)}分钟前`
    } else if (diff < 86400000) { // 1天内
      return `${Math.floor(diff / 3600000)}小时前`
    } else {
      return formatTime(date).split(' ')[0] // 只显示日期
    }
  },

  // 查看最近图片
  viewRecentImage(e) {
    const image = e.currentTarget.dataset.image
    app.globalData.currentImage = image.file_url
    this.setData({
      currentImage: image.file_url
    })
  },

  // 导航到美颜页面
  navigateToBeauty() {
    if (!this.data.currentImage) {
      showToast('请先选择图片')
      return
    }
    wx.navigateTo({
      url: '/pages/beauty/beauty'
    })
  },

  // 导航到证件照页面
  navigateToIdPhoto() {
    if (!this.data.currentImage) {
      showToast('请先选择图片')
      return
    }
    wx.navigateTo({
      url: '/pages/idphoto/idphoto'
    })
  },

  // 导航到背景处理页面
  navigateToBackground() {
    if (!this.data.currentImage) {
      showToast('请先选择图片')
      return
    }
    wx.navigateTo({
      url: '/pages/background/background'
    })
  },

  // 导航到历史记录页面
  navigateToHistory() {
    if (!this.data.isLoggedIn) {
      this.navigateToLogin()
      return
    }
    wx.navigateTo({
      url: '/pages/history/history'
    })
  },

  // 导航到登录页面
  navigateToLogin() {
    wx.navigateTo({
      url: '/pages/login/login'
    })
  },

  // 分享功能
  onShareAppMessage() {
    return {
      title: 'AI图像处理平台 - 让每一张照片都更精彩',
      path: '/pages/index/index',
      imageUrl: '/images/share-cover.jpg'
    }
  },

  // 分享到朋友圈
  onShareTimeline() {
    return {
      title: 'AI图像处理平台 - 让每一张照片都更精彩',
      imageUrl: '/images/share-cover.jpg'
    }
  }
})