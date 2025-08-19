// pages/register/register.js
const { userAPI } = require('../../utils/api')
const { validateEmail, validatePhone, validatePassword, showToast, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    // 表单数据
    formData: {
      username: '',
      email: '',
      phone: '',
      password: '',
      confirmPassword: '',
      verificationCode: ''
    },
    
    // 错误信息
    errors: {},
    
    // 界面状态
    showPassword: false,
    showConfirmPassword: false,
    loading: false,
    loadingText: '注册中...',
    agreedToTerms: false,
    
    // 验证码相关
    canSendCode: true,
    codeButtonText: '发送验证码',
    countdown: 0
  },

  onLoad(options) {
    console.log('注册页面加载')
  },

  onShow() {
    // 清空表单数据
    this.setData({
      formData: {
        username: '',
        email: '',
        phone: '',
        password: '',
        confirmPassword: '',
        verificationCode: ''
      },
      errors: {},
      agreedToTerms: false
    })
  },

  // 输入事件处理
  onUsernameInput(e) {
    this.setData({
      'formData.username': e.detail.value,
      'errors.username': ''
    })
    this.validateUsername(e.detail.value)
  },

  onEmailInput(e) {
    this.setData({
      'formData.email': e.detail.value,
      'errors.email': ''
    })
    this.validateEmailField(e.detail.value)
  },

  onPhoneInput(e) {
    this.setData({
      'formData.phone': e.detail.value,
      'errors.phone': ''
    })
    this.validatePhoneField(e.detail.value)
  },

  onPasswordInput(e) {
    this.setData({
      'formData.password': e.detail.value,
      'errors.password': ''
    })
    this.validatePasswordField(e.detail.value)
  },

  onConfirmPasswordInput(e) {
    this.setData({
      'formData.confirmPassword': e.detail.value,
      'errors.confirmPassword': ''
    })
    this.validateConfirmPassword(e.detail.value)
  },

  onVerificationCodeInput(e) {
    this.setData({
      'formData.verificationCode': e.detail.value,
      'errors.verificationCode': ''
    })
  },

  // 密码显示切换
  togglePassword() {
    this.setData({
      showPassword: !this.data.showPassword
    })
  },

  toggleConfirmPassword() {
    this.setData({
      showConfirmPassword: !this.data.showConfirmPassword
    })
  },

  // 服务条款同意
  onTermsChange(e) {
    this.setData({
      agreedToTerms: e.detail.value.includes('agree')
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

  // 发送验证码
  async sendVerificationCode() {
    if (!this.data.canSendCode) return
    
    const { phone, email } = this.data.formData
    
    if (!phone && !email) {
      showToast('请先输入手机号或邮箱')
      return
    }
    
    try {
      showLoading('发送中...')
      
      // 调用发送验证码API
      await userAPI.sendVerificationCode({
        phone: phone || undefined,
        email: email || undefined,
        type: 'register'
      })
      
      hideLoading()
      showToast('验证码已发送')
      
      // 开始倒计时
      this.startCountdown()
      
    } catch (error) {
      hideLoading()
      showToast(error.message || '发送失败')
    }
  },

  // 开始倒计时
  startCountdown() {
    let countdown = 60
    this.setData({
      canSendCode: false,
      countdown: countdown,
      codeButtonText: `${countdown}s后重发`
    })
    
    const timer = setInterval(() => {
      countdown--
      if (countdown <= 0) {
        clearInterval(timer)
        this.setData({
          canSendCode: true,
          countdown: 0,
          codeButtonText: '发送验证码'
        })
      } else {
        this.setData({
          countdown: countdown,
          codeButtonText: `${countdown}s后重发`
        })
      }
    }, 1000)
  },

  // 表单验证
  validateUsername(username) {
    if (!username) {
      this.setData({ 'errors.username': '请输入用户名' })
      return false
    }
    if (username.length < 3) {
      this.setData({ 'errors.username': '用户名至少3个字符' })
      return false
    }
    if (username.length > 20) {
      this.setData({ 'errors.username': '用户名不能超过20个字符' })
      return false
    }
    if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]+$/.test(username)) {
      this.setData({ 'errors.username': '用户名只能包含字母、数字、下划线和中文' })
      return false
    }
    return true
  },

  validateEmailField(email) {
    if (!email) {
      this.setData({ 'errors.email': '请输入邮箱地址' })
      return false
    }
    if (!validateEmail(email)) {
      this.setData({ 'errors.email': '请输入正确的邮箱地址' })
      return false
    }
    return true
  },

  validatePhoneField(phone) {
    if (!phone) {
      this.setData({ 'errors.phone': '请输入手机号' })
      return false
    }
    if (!validatePhone(phone)) {
      this.setData({ 'errors.phone': '请输入正确的手机号' })
      return false
    }
    return true
  },

  validatePasswordField(password) {
    if (!password) {
      this.setData({ 'errors.password': '请输入密码' })
      return false
    }
    if (!validatePassword(password)) {
      this.setData({ 'errors.password': '密码至少8位，包含字母和数字' })
      return false
    }
    return true
  },

  validateConfirmPassword(confirmPassword) {
    if (!confirmPassword) {
      this.setData({ 'errors.confirmPassword': '请确认密码' })
      return false
    }
    if (confirmPassword !== this.data.formData.password) {
      this.setData({ 'errors.confirmPassword': '两次输入的密码不一致' })
      return false
    }
    return true
  },

  validateVerificationCode(code) {
    if (!code) {
      this.setData({ 'errors.verificationCode': '请输入验证码' })
      return false
    }
    if (code.length !== 6) {
      this.setData({ 'errors.verificationCode': '验证码应为6位数字' })
      return false
    }
    return true
  },

  // 验证整个表单
  validateForm() {
    const { formData } = this.data
    let isValid = true
    
    if (!this.validateUsername(formData.username)) isValid = false
    if (!this.validateEmailField(formData.email)) isValid = false
    if (!this.validatePhoneField(formData.phone)) isValid = false
    if (!this.validatePasswordField(formData.password)) isValid = false
    if (!this.validateConfirmPassword(formData.confirmPassword)) isValid = false
    if (!this.validateVerificationCode(formData.verificationCode)) isValid = false
    
    if (!this.data.agreedToTerms) {
      showToast('请同意服务条款和隐私政策')
      isValid = false
    }
    
    return isValid
  },

  // 检查是否可以注册
  get canRegister() {
    const { formData, agreedToTerms } = this.data
    return formData.username && 
           formData.email && 
           formData.phone && 
           formData.password && 
           formData.confirmPassword && 
           formData.verificationCode && 
           agreedToTerms
  },

  // 处理注册
  async handleRegister() {
    if (this.data.loading) return
    
    if (!this.validateForm()) {
      return
    }
    
    try {
      this.setData({ 
        loading: true,
        loadingText: '注册中...'
      })
      
      const { formData } = this.data
      const registerData = {
        username: formData.username,
        email: formData.email,
        phone: formData.phone,
        password: formData.password,
        verificationCode: formData.verificationCode
      }
      
      const result = await userAPI.register(registerData)
      
      this.setData({ loading: false })
      
      if (result.success) {
        showToast('注册成功')
        
        // 延迟跳转到登录页
        setTimeout(() => {
          wx.redirectTo({
            url: '/pages/login/login'
          })
        }, 1500)
      } else {
        showToast(result.message || '注册失败')
      }
      
    } catch (error) {
      this.setData({ loading: false })
      console.error('注册失败:', error)
      showToast(error.message || '注册失败，请重试')
    }
  },

  // 跳转到登录页
  goToLogin() {
    wx.redirectTo({
      url: '/pages/login/login'
    })
  },

  onUnload() {
    // 清理定时器
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer)
    }
  }
})