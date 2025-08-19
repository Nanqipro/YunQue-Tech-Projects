// pages/login/login.js
const app = getApp()
const { userAPI } = require('../../utils/api')
const { validateEmail, showToast } = require('../../utils/util')

Page({
  data: {
    isLoginMode: true, // true: 登录模式, false: 注册模式
    showPassword: false,
    loading: false,
    loadingText: '登录中...',
    agreedToTerms: false,
    formData: {
      username: '',
      email: '',
      password: '',
      confirmPassword: ''
    },
    errors: {}
  },

  onLoad(options) {
    console.log('登录页面加载')
    
    // 检查是否已经登录
    if (app.globalData.isLoggedIn) {
      this.redirectToIndex()
    }
    
    // 检查是否指定了模式
    if (options.mode === 'register') {
      this.setData({
        isLoginMode: false
      })
    }
  },

  // 用户名输入
  onUsernameInput(e) {
    this.setData({
      'formData.username': e.detail.value,
      'errors.username': ''
    })
  },

  // 邮箱输入
  onEmailInput(e) {
    this.setData({
      'formData.email': e.detail.value,
      'errors.email': ''
    })
  },

  // 密码输入
  onPasswordInput(e) {
    this.setData({
      'formData.password': e.detail.value,
      'errors.password': ''
    })
  },

  // 确认密码输入
  onConfirmPasswordInput(e) {
    this.setData({
      'formData.confirmPassword': e.detail.value,
      'errors.confirmPassword': ''
    })
  },

  // 切换密码显示
  togglePassword() {
    this.setData({
      showPassword: !this.data.showPassword
    })
  },

  // 切换登录/注册模式
  switchMode() {
    const newMode = !this.data.isLoginMode
    this.setData({
      isLoginMode: newMode,
      errors: {},
      formData: {
        username: this.data.formData.username,
        email: '',
        password: '',
        confirmPassword: ''
      }
    })
  },

  // 服务条款同意状态变化
  onTermsChange(e) {
    this.setData({
      agreedToTerms: e.detail.value.includes('agree')
    })
  },

  // 表单验证
  validateForm() {
    const { formData, isLoginMode, agreedToTerms } = this.data
    const errors = {}

    // 用户名验证
    if (!formData.username.trim()) {
      errors.username = '请输入用户名'
    } else if (formData.username.length < 3) {
      errors.username = '用户名至少3个字符'
    } else if (formData.username.length > 20) {
      errors.username = '用户名不能超过20个字符'
    } else if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]+$/.test(formData.username)) {
      errors.username = '用户名只能包含字母、数字、下划线和中文'
    }

    // 邮箱验证（注册时）
    if (!isLoginMode) {
      if (!formData.email.trim()) {
        errors.email = '请输入邮箱地址'
      } else if (!validateEmail(formData.email)) {
        errors.email = '请输入有效的邮箱地址'
      }
    }

    // 密码验证
    if (!formData.password) {
      errors.password = '请输入密码'
    } else if (formData.password.length < 6) {
      errors.password = '密码至少6个字符'
    } else if (formData.password.length > 50) {
      errors.password = '密码不能超过50个字符'
    }

    // 确认密码验证（注册时）
    if (!isLoginMode) {
      if (!formData.confirmPassword) {
        errors.confirmPassword = '请确认密码'
      } else if (formData.password !== formData.confirmPassword) {
        errors.confirmPassword = '两次输入的密码不一致'
      }

      // 服务条款验证
      if (!agreedToTerms) {
        showToast('请先同意服务条款和隐私政策')
        return false
      }
    }

    this.setData({ errors })
    return Object.keys(errors).length === 0
  },

  // 表单提交
  async handleSubmit() {
    if (!this.validateForm()) {
      return
    }

    const { formData, isLoginMode } = this.data

    this.setData({
      loading: true,
      loadingText: isLoginMode ? '登录中...' : '注册中...'
    })

    try {
      if (isLoginMode) {
        // 登录
        await this.handleLogin()
      } else {
        // 注册
        await this.handleRegister()
      }
    } catch (error) {
      console.error('操作失败:', error)
      showToast(error.message || '操作失败，请重试')
    } finally {
      this.setData({
        loading: false
      })
    }
  },

  // 处理登录
  async handleLogin() {
    const { formData } = this.data

    try {
      const res = await userAPI.login(formData.username, formData.password)
      
      if (res.success) {
        const { token, user } = res.data
        
        // 保存登录信息到全局状态
        app.globalData.token = token
        app.globalData.userInfo = user
        app.globalData.isLoggedIn = true
        
        // 保存到本地存储
        wx.setStorageSync('token', token)
        wx.setStorageSync('userInfo', user)
        
        showToast('登录成功', 'success')
        
        // 延迟跳转，让用户看到成功提示
        setTimeout(() => {
          this.redirectToIndex()
        }, 1500)
      } else {
        throw new Error(res.message || '登录失败')
      }
    } catch (error) {
      if (error.message.includes('用户名') || error.message.includes('密码')) {
        this.setData({
          'errors.username': '用户名或密码错误',
          'errors.password': '用户名或密码错误'
        })
      }
      throw error
    }
  },

  // 处理注册
  async handleRegister() {
    const { formData } = this.data

    try {
      const userData = {
        username: formData.username,
        email: formData.email,
        password: formData.password
      }

      const res = await userAPI.register(userData)
      
      if (res.success) {
        showToast('注册成功，请登录', 'success')
        
        // 切换到登录模式，保留用户名
        this.setData({
          isLoginMode: true,
          formData: {
            username: formData.username,
            email: '',
            password: '',
            confirmPassword: ''
          },
          errors: {}
        })
      } else {
        throw new Error(res.message || '注册失败')
      }
    } catch (error) {
      if (error.message.includes('用户名')) {
        this.setData({
          'errors.username': '用户名已存在'
        })
      } else if (error.message.includes('邮箱')) {
        this.setData({
          'errors.email': '邮箱已被注册'
        })
      }
      throw error
    }
  },

  // 游客登录
  guestLogin() {
    showToast('游客模式，功能受限', 'none')
    
    // 设置游客状态
    app.globalData.isLoggedIn = false
    app.globalData.userInfo = null
    app.globalData.token = null
    
    this.redirectToIndex()
  },

  // 跳转到首页
  redirectToIndex() {
    wx.reLaunch({
      url: '/pages/index/index'
    })
  },

  // 显示服务条款
  showTerms() {
    wx.showModal({
      title: '服务条款',
      content: '这里是服务条款的内容...',
      showCancel: false,
      confirmText: '我知道了'
    })
  },

  // 显示隐私政策
  showPrivacy() {
    wx.showModal({
      title: '隐私政策',
      content: '这里是隐私政策的内容...',
      showCancel: false,
      confirmText: '我知道了'
    })
  },

  // 分享功能
  onShareAppMessage() {
    return {
      title: 'AI图像处理平台 - 让每一张照片都更精彩',
      path: '/pages/index/index'
    }
  }
})