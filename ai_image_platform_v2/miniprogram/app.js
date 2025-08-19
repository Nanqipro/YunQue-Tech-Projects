// app.js
App({
  globalData: {
    userInfo: null,
    token: null,
    baseUrl: 'http://localhost:5002/api', // 请替换为实际的API地址
    currentImage: null,
    isLoggedIn: false
  },

  onLaunch() {
    console.log('小程序启动')
    
    // 检查登录状态
    this.checkLoginStatus()
    
    // 获取系统信息
    this.getSystemInfo()
  },

  onShow() {
    console.log('小程序显示')
  },

  onHide() {
    console.log('小程序隐藏')
  },

  onError(msg) {
    console.error('小程序错误:', msg)
  },

  // 检查登录状态
  checkLoginStatus() {
    const token = wx.getStorageSync('token')
    const userInfo = wx.getStorageSync('userInfo')
    
    if (token && userInfo) {
      this.globalData.token = token
      this.globalData.userInfo = userInfo
      this.globalData.isLoggedIn = true
      
      // 验证token有效性
      this.verifyToken()
    }
  },

  // 验证token有效性
  verifyToken() {
    wx.request({
      url: `${this.globalData.baseUrl}/users/verify-token`,
      method: 'POST',
      header: {
        'Authorization': `Bearer ${this.globalData.token}`,
        'Content-Type': 'application/json'
      },
      success: (res) => {
        if (res.statusCode === 200 && res.data.valid) {
          this.globalData.userInfo = res.data.user
          this.globalData.isLoggedIn = true
          wx.setStorageSync('userInfo', res.data.user)
        } else {
          this.logout()
        }
      },
      fail: () => {
        this.logout()
      }
    })
  },

  // 获取系统信息
  getSystemInfo() {
    wx.getSystemInfo({
      success: (res) => {
        this.globalData.systemInfo = res
        console.log('系统信息:', res)
      }
    })
  },

  // 登录
  login(username, password) {
    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.globalData.baseUrl}/users/login`,
        method: 'POST',
        data: {
          username: username,
          password: password
        },
        header: {
          'Content-Type': 'application/json'
        },
        success: (res) => {
          if (res.statusCode === 200 && res.data.success) {
            const { token, user } = res.data.data
            
            // 保存登录信息
            this.globalData.token = token
            this.globalData.userInfo = user
            this.globalData.isLoggedIn = true
            
            wx.setStorageSync('token', token)
            wx.setStorageSync('userInfo', user)
            
            resolve(res.data)
          } else {
            reject(res.data)
          }
        },
        fail: (err) => {
          reject(err)
        }
      })
    })
  },

  // 注册
  register(userData) {
    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.globalData.baseUrl}/users/register`,
        method: 'POST',
        data: userData,
        header: {
          'Content-Type': 'application/json'
        },
        success: (res) => {
          if (res.statusCode === 201 && res.data.success) {
            resolve(res.data)
          } else {
            reject(res.data)
          }
        },
        fail: (err) => {
          reject(err)
        }
      })
    })
  },

  // 登出
  logout() {
    this.globalData.token = null
    this.globalData.userInfo = null
    this.globalData.isLoggedIn = false
    this.globalData.currentImage = null
    
    wx.removeStorageSync('token')
    wx.removeStorageSync('userInfo')
    
    // 跳转到登录页
    wx.reLaunch({
      url: '/pages/login/login'
    })
  },

  // 显示提示信息
  showToast(title, icon = 'none', duration = 2000) {
    wx.showToast({
      title: title,
      icon: icon,
      duration: duration
    })
  },

  // 显示加载中
  showLoading(title = '加载中...') {
    wx.showLoading({
      title: title,
      mask: true
    })
  },

  // 隐藏加载中
  hideLoading() {
    wx.hideLoading()
  },

  // 网络请求封装
  request(options) {
    return new Promise((resolve, reject) => {
      const defaultOptions = {
        header: {
          'Content-Type': 'application/json'
        }
      }

      // 如果已登录，添加认证头
      if (this.globalData.token) {
        defaultOptions.header['Authorization'] = `Bearer ${this.globalData.token}`
      }

      const requestOptions = Object.assign({}, defaultOptions, options)
      requestOptions.url = `${this.globalData.baseUrl}${options.url}`

      wx.request({
        ...requestOptions,
        success: (res) => {
          if (res.statusCode === 401) {
            // token过期，重新登录
            this.logout()
            reject(new Error('登录已过期'))
            return
          }
          resolve(res)
        },
        fail: (err) => {
          reject(err)
        }
      })
    })
  }
})