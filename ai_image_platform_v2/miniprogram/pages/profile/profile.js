// pages/profile/profile.js
const app = getApp()
const { userAPI, uploadAPI } = require('../../utils/api')
const { showToast, showModal, chooseImage } = require('../../utils/util')

Page({
  data: {
    isLoggedIn: false,
    userInfo: {},
    userStats: {},
    loading: false,
    loadingText: '加载中...',
    appVersion: '1.0.0',
    
    // 会员等级信息
    levelText: '免费用户',
    levelDesc: '每日10次免费处理'
  },

  onLoad(options) {
    console.log('个人中心页面加载')
    this.checkAppVersion()
  },

  onShow() {
    console.log('个人中心页面显示')
    this.checkLoginStatus()
    if (this.data.isLoggedIn) {
      this.loadUserInfo()
      this.loadUserStats()
    }
  },

  onPullDownRefresh() {
    if (this.data.isLoggedIn) {
      this.loadUserInfo()
      this.loadUserStats()
    }
    wx.stopPullDownRefresh()
  },

  // 检查登录状态
  checkLoginStatus() {
    const isLoggedIn = app.globalData.isLoggedIn
    const userInfo = app.globalData.userInfo || {}
    
    this.setData({
      isLoggedIn,
      userInfo
    })
    
    this.updateLevelInfo(userInfo)
  },

  // 更新等级信息
  updateLevelInfo(userInfo) {
    let levelText = '免费用户'
    let levelDesc = '每日10次免费处理'
    
    if (userInfo.is_vip) {
      levelText = 'VIP会员'
      levelDesc = '无限次数 · 高清输出'
    } else if (userInfo.level === 'premium') {
      levelText = '高级用户'
      levelDesc = '每日50次处理'
    }
    
    this.setData({
      levelText,
      levelDesc
    })
  },

  // 加载用户信息
  async loadUserInfo() {
    if (!this.data.isLoggedIn) return
    
    try {
      const res = await userAPI.getUserInfo()
      
      if (res.success) {
        const userInfo = res.data
        
        // 更新全局用户信息
        app.globalData.userInfo = userInfo
        
        this.setData({
          userInfo
        })
        
        this.updateLevelInfo(userInfo)
      } else {
        console.error('获取用户信息失败:', res.message)
      }
    } catch (error) {
      console.error('加载用户信息失败:', error)
    }
  },

  // 加载用户统计
  async loadUserStats() {
    if (!this.data.isLoggedIn) return
    
    try {
      const res = await userAPI.getUserStats()
      
      if (res.success) {
        this.setData({
          userStats: res.data
        })
      } else {
        console.error('获取用户统计失败:', res.message)
      }
    } catch (error) {
      console.error('加载用户统计失败:', error)
    }
  },

  // 检查应用版本
  checkAppVersion() {
    const accountInfo = wx.getAccountInfoSync()
    const version = accountInfo.miniProgram.version || '1.0.0'
    
    this.setData({
      appVersion: version
    })
  },

  // 更换头像
  async changeAvatar() {
    if (!this.data.isLoggedIn) {
      this.goToLogin()
      return
    }
    
    try {
      // 选择图片
      const imageRes = await chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera']
      })
      
      if (!imageRes.tempFilePaths || imageRes.tempFilePaths.length === 0) {
        return
      }
      
      this.setData({
        loading: true,
        loadingText: '上传头像中...'
      })
      
      // 上传头像
      const uploadRes = await uploadAPI.uploadAvatar(imageRes.tempFilePaths[0])
      
      if (uploadRes.success) {
        // 更新用户头像
        const updateRes = await userAPI.updateUserInfo({
          avatar: uploadRes.data.url
        })
        
        if (updateRes.success) {
          const newUserInfo = {
            ...this.data.userInfo,
            avatar: uploadRes.data.url
          }
          
          // 更新全局和本地用户信息
          app.globalData.userInfo = newUserInfo
          this.setData({
            userInfo: newUserInfo
          })
          
          showToast('头像更新成功', 'success')
        } else {
          throw new Error(updateRes.message || '更新头像失败')
        }
      } else {
        throw new Error(uploadRes.message || '上传头像失败')
      }
    } catch (error) {
      console.error('更换头像失败:', error)
      showToast('更换头像失败，请重试')
    } finally {
      this.setData({ loading: false })
    }
  },

  // 跳转到VIP页面
  goToVip() {
    if (!this.data.isLoggedIn) {
      this.goToLogin()
      return
    }
    
    wx.navigateTo({
      url: '/pages/vip/vip'
    })
  },

  // 跳转到历史记录
  goToHistory() {
    if (!this.data.isLoggedIn) {
      this.goToLogin()
      return
    }
    
    wx.navigateTo({
      url: '/pages/history/history'
    })
  },

  // 跳转到收藏页面
  goToFavorites() {
    if (!this.data.isLoggedIn) {
      this.goToLogin()
      return
    }
    
    wx.navigateTo({
      url: '/pages/favorites/favorites'
    })
  },

  // 跳转到设置页面
  goToSettings() {
    if (!this.data.isLoggedIn) {
      this.goToLogin()
      return
    }
    
    wx.navigateTo({
      url: '/pages/settings/settings'
    })
  },

  // 跳转到帮助页面
  goToHelp() {
    wx.navigateTo({
      url: '/pages/help/help'
    })
  },

  // 跳转到关于页面
  goToAbout() {
    wx.navigateTo({
      url: '/pages/about/about'
    })
  },

  // 跳转到登录页面
  goToLogin() {
    wx.navigateTo({
      url: '/pages/login/login'
    })
  },

  // 退出登录
  async logout() {
    const res = await showModal('确认退出', '确定要退出登录吗？', {
      showCancel: true,
      confirmText: '退出',
      cancelText: '取消'
    })
    
    if (!res.confirm) return
    
    this.setData({
      loading: true,
      loadingText: '退出中...'
    })
    
    try {
      // 调用退出登录API
      await userAPI.logout()
      
      // 清除本地存储
      wx.removeStorageSync('token')
      wx.removeStorageSync('userInfo')
      
      // 清除全局数据
      app.globalData.isLoggedIn = false
      app.globalData.userInfo = {}
      app.globalData.token = ''
      
      // 更新页面状态
      this.setData({
        isLoggedIn: false,
        userInfo: {},
        userStats: {},
        levelText: '免费用户',
        levelDesc: '每日10次免费处理'
      })
      
      showToast('已退出登录', 'success')
      
      // 延迟跳转到首页
      setTimeout(() => {
        wx.switchTab({
          url: '/pages/index/index'
        })
      }, 1000)
    } catch (error) {
      console.error('退出登录失败:', error)
      showToast('退出失败，请重试')
    } finally {
      this.setData({ loading: false })
    }
  },

  // 分享功能
  onShareAppMessage() {
    return {
      title: 'AI图像处理平台 - 专业的图片处理工具',
      path: '/pages/index/index',
      imageUrl: '/images/share-cover.jpg'
    }
  },

  onShareTimeline() {
    return {
      title: 'AI图像处理平台 - 专业的图片处理工具',
      query: '',
      imageUrl: '/images/share-cover.jpg'
    }
  }
})