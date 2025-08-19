// utils/util.js

/**
 * 格式化时间
 */
const formatTime = date => {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  const hour = date.getHours()
  const minute = date.getMinutes()
  const second = date.getSeconds()

  return `${[year, month, day].map(formatNumber).join('/')} ${[hour, minute, second].map(formatNumber).join(':')}`
}

const formatNumber = n => {
  n = n.toString()
  return n[1] ? n : `0${n}`
}

/**
 * 格式化文件大小
 */
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

/**
 * 防抖函数
 */
const debounce = (func, wait) => {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

/**
 * 节流函数
 */
const throttle = (func, limit) => {
  let inThrottle
  return function() {
    const args = arguments
    const context = this
    if (!inThrottle) {
      func.apply(context, args)
      inThrottle = true
      setTimeout(() => inThrottle = false, limit)
    }
  }
}

/**
 * 深拷贝
 */
const deepClone = (obj) => {
  if (obj === null || typeof obj !== 'object') return obj
  if (obj instanceof Date) return new Date(obj.getTime())
  if (obj instanceof Array) return obj.map(item => deepClone(item))
  if (typeof obj === 'object') {
    const clonedObj = {}
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        clonedObj[key] = deepClone(obj[key])
      }
    }
    return clonedObj
  }
}

/**
 * 生成随机字符串
 */
const generateRandomString = (length = 8) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  let result = ''
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
}

/**
 * 验证邮箱格式
 */
const validateEmail = (email) => {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return re.test(email)
}

/**
 * 验证手机号格式
 */
const validatePhone = (phone) => {
  const re = /^1[3-9]\d{9}$/
  return re.test(phone)
}

/**
 * 验证密码强度
 */
const validatePassword = (password) => {
  // 至少8位，包含大小写字母和数字
  const re = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/
  return re.test(password)
}

/**
 * 获取图片信息
 */
const getImageInfo = (src) => {
  return new Promise((resolve, reject) => {
    wx.getImageInfo({
      src: src,
      success: resolve,
      fail: reject
    })
  })
}

/**
 * 压缩图片
 */
const compressImage = (src, quality = 0.8) => {
  return new Promise((resolve, reject) => {
    wx.compressImage({
      src: src,
      quality: quality,
      success: resolve,
      fail: reject
    })
  })
}

/**
 * 选择图片
 */
const chooseImage = (options = {}) => {
  const defaultOptions = {
    count: 1,
    sizeType: ['original', 'compressed'],
    sourceType: ['album', 'camera']
  }
  
  return new Promise((resolve, reject) => {
    wx.chooseImage({
      ...defaultOptions,
      ...options,
      success: resolve,
      fail: reject
    })
  })
}

/**
 * 预览图片
 */
const previewImage = (current, urls = []) => {
  wx.previewImage({
    current: current,
    urls: urls.length > 0 ? urls : [current]
  })
}

/**
 * 保存图片到相册
 */
const saveImageToPhotosAlbum = (filePath) => {
  return new Promise((resolve, reject) => {
    wx.saveImageToPhotosAlbum({
      filePath: filePath,
      success: resolve,
      fail: reject
    })
  })
}

/**
 * 显示操作菜单
 */
const showActionSheet = (itemList) => {
  return new Promise((resolve, reject) => {
    wx.showActionSheet({
      itemList: itemList,
      success: (res) => {
        resolve(res.tapIndex)
      },
      fail: reject
    })
  })
}

/**
 * 显示确认对话框
 */
const showConfirm = (title, content) => {
  return new Promise((resolve, reject) => {
    wx.showModal({
      title: title,
      content: content,
      success: (res) => {
        if (res.confirm) {
          resolve(true)
        } else {
          resolve(false)
        }
      },
      fail: reject
    })
  })
}

/**
 * 显示提示框
 */
const showToast = (title, icon = 'none', duration = 2000) => {
  wx.showToast({
    title: title,
    icon: icon,
    duration: duration
  })
}

/**
 * 显示加载提示
 */
const showLoading = (title = '加载中...') => {
  wx.showLoading({
    title: title,
    mask: true
  })
}

/**
 * 隐藏加载提示
 */
const hideLoading = () => {
  wx.hideLoading()
}

/**
 * 设置导航栏标题
 */
const setNavigationBarTitle = (title) => {
  wx.setNavigationBarTitle({
    title: title
  })
}

/**
 * 获取系统信息
 */
const getSystemInfo = () => {
  return new Promise((resolve, reject) => {
    wx.getSystemInfo({
      success: resolve,
      fail: reject
    })
  })
}

/**
 * 获取网络类型
 */
const getNetworkType = () => {
  return new Promise((resolve, reject) => {
    wx.getNetworkType({
      success: resolve,
      fail: reject
    })
  })
}

/**
 * 检查网络状态
 */
const checkNetworkStatus = async () => {
  try {
    const res = await getNetworkType()
    return res.networkType !== 'none'
  } catch (error) {
    return false
  }
}

/**
 * 本地存储操作
 */
const storage = {
  set: (key, data) => {
    try {
      wx.setStorageSync(key, data)
      return true
    } catch (error) {
      console.error('存储失败:', error)
      return false
    }
  },
  
  get: (key, defaultValue = null) => {
    try {
      const data = wx.getStorageSync(key)
      return data || defaultValue
    } catch (error) {
      console.error('读取存储失败:', error)
      return defaultValue
    }
  },
  
  remove: (key) => {
    try {
      wx.removeStorageSync(key)
      return true
    } catch (error) {
      console.error('删除存储失败:', error)
      return false
    }
  },
  
  clear: () => {
    try {
      wx.clearStorageSync()
      return true
    } catch (error) {
      console.error('清空存储失败:', error)
      return false
    }
  }
}

/**
 * 页面跳转封装
 */
const navigation = {
  // 保留当前页面，跳转到应用内的某个页面
  navigateTo: (url) => {
    wx.navigateTo({ url })
  },
  
  // 关闭当前页面，跳转到应用内的某个页面
  redirectTo: (url) => {
    wx.redirectTo({ url })
  },
  
  // 跳转到 tabBar 页面，并关闭其他所有非 tabBar 页面
  switchTab: (url) => {
    wx.switchTab({ url })
  },
  
  // 关闭所有页面，打开到应用内的某个页面
  reLaunch: (url) => {
    wx.reLaunch({ url })
  },
  
  // 关闭当前页面，返回上一页面或多级页面
  navigateBack: (delta = 1) => {
    wx.navigateBack({ delta })
  }
}

module.exports = {
  formatTime,
  formatFileSize,
  debounce,
  throttle,
  deepClone,
  generateRandomString,
  validateEmail,
  validatePhone,
  validatePassword,
  getImageInfo,
  compressImage,
  chooseImage,
  previewImage,
  saveImageToPhotosAlbum,
  showActionSheet,
  showConfirm,
  showToast,
  showLoading,
  hideLoading,
  setNavigationBarTitle,
  getSystemInfo,
  getNetworkType,
  checkNetworkStatus,
  storage,
  navigation
}