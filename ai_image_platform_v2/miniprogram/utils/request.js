// utils/request.js
const app = getApp()

// 请求基础配置
const BASE_URL = 'https://api.example.com' // 替换为实际的API地址
const TIMEOUT = 10000 // 请求超时时间

/**
 * 网络请求封装
 * @param {object} options 请求选项
 */
function request(options) {
  return new Promise((resolve, reject) => {
    // 显示加载状态
    if (options.showLoading !== false) {
      wx.showLoading({
        title: options.loadingText || '请求中...',
        mask: true
      })
    }

    // 构建完整的请求URL
    const url = options.url.startsWith('http') ? options.url : `${BASE_URL}${options.url}`
    
    // 构建请求头
    const header = {
      'Content-Type': 'application/json',
      ...options.header
    }
    
    // 添加认证token
    if (app.globalData.token) {
      header['Authorization'] = `Bearer ${app.globalData.token}`
    }
    
    // 添加设备信息
    const systemInfo = wx.getSystemInfoSync()
    header['X-Device-Type'] = 'miniprogram'
    header['X-Device-Platform'] = systemInfo.platform
    header['X-App-Version'] = app.globalData.version || '1.0.0'
    
    // 发起请求
    wx.request({
      url,
      method: options.method || 'GET',
      data: options.data || {},
      header,
      timeout: options.timeout || TIMEOUT,
      dataType: options.dataType || 'json',
      responseType: options.responseType || 'text',
      
      success: (res) => {
        // 隐藏加载状态
        if (options.showLoading !== false) {
          wx.hideLoading()
        }
        
        // 处理响应
        handleResponse(res, resolve, reject, options)
      },
      
      fail: (err) => {
        // 隐藏加载状态
        if (options.showLoading !== false) {
          wx.hideLoading()
        }
        
        // 处理请求失败
        handleError(err, reject, options)
      }
    })
  })
}

/**
 * 处理响应
 * @param {object} res 响应对象
 * @param {function} resolve Promise resolve
 * @param {function} reject Promise reject
 * @param {object} options 请求选项
 */
function handleResponse(res, resolve, reject, options) {
  const { statusCode, data } = res
  
  // HTTP状态码检查
  if (statusCode >= 200 && statusCode < 300) {
    // 成功响应
    if (data && typeof data === 'object') {
      // 业务状态码检查
      if (data.success !== undefined) {
        if (data.success) {
          resolve(data)
        } else {
          // 业务失败
          const error = new Error(data.message || '请求失败')
          error.code = data.code
          error.data = data
          
          // 显示错误提示
          if (options.showError !== false) {
            showErrorToast(data.message || '请求失败')
          }
          
          reject(error)
        }
      } else {
        // 没有业务状态码，直接返回数据
        resolve(data)
      }
    } else {
      // 非对象响应，直接返回
      resolve(data)
    }
  } else {
    // HTTP错误状态码
    handleHttpError(statusCode, data, reject, options)
  }
}

/**
 * 处理HTTP错误
 * @param {number} statusCode 状态码
 * @param {any} data 响应数据
 * @param {function} reject Promise reject
 * @param {object} options 请求选项
 */
function handleHttpError(statusCode, data, reject, options) {
  let message = '请求失败'
  
  switch (statusCode) {
    case 400:
      message = '请求参数错误'
      break
    case 401:
      message = '未授权，请重新登录'
      // 清除登录状态
      handleUnauthorized()
      break
    case 403:
      message = '拒绝访问'
      break
    case 404:
      message = '请求的资源不存在'
      break
    case 408:
      message = '请求超时'
      break
    case 500:
      message = '服务器内部错误'
      break
    case 502:
      message = '网关错误'
      break
    case 503:
      message = '服务不可用'
      break
    case 504:
      message = '网关超时'
      break
    default:
      message = `请求失败 (${statusCode})`
  }
  
  // 如果响应数据中有错误信息，优先使用
  if (data && data.message) {
    message = data.message
  }
  
  const error = new Error(message)
  error.statusCode = statusCode
  error.data = data
  
  // 显示错误提示
  if (options.showError !== false) {
    showErrorToast(message)
  }
  
  reject(error)
}

/**
 * 处理请求失败
 * @param {object} err 错误对象
 * @param {function} reject Promise reject
 * @param {object} options 请求选项
 */
function handleError(err, reject, options) {
  let message = '网络请求失败'
  
  if (err.errMsg) {
    if (err.errMsg.includes('timeout')) {
      message = '请求超时，请检查网络连接'
    } else if (err.errMsg.includes('fail')) {
      message = '网络连接失败，请检查网络设置'
    }
  }
  
  const error = new Error(message)
  error.originalError = err
  
  // 显示错误提示
  if (options.showError !== false) {
    showErrorToast(message)
  }
  
  reject(error)
}

/**
 * 处理未授权情况
 */
function handleUnauthorized() {
  // 清除本地存储的认证信息
  wx.removeStorageSync('token')
  wx.removeStorageSync('userInfo')
  
  // 清除全局状态
  if (app.globalData) {
    app.globalData.token = ''
    app.globalData.userInfo = {}
    app.globalData.isLoggedIn = false
  }
  
  // 跳转到登录页面
  wx.navigateTo({
    url: '/pages/login/login'
  })
}

/**
 * 显示错误提示
 * @param {string} message 错误信息
 */
function showErrorToast(message) {
  wx.showToast({
    title: message,
    icon: 'none',
    duration: 3000
  })
}

/**
 * GET请求
 * @param {string} url 请求地址
 * @param {object} data 请求参数
 * @param {object} options 请求选项
 */
function get(url, data = {}, options = {}) {
  return request({
    url,
    method: 'GET',
    data,
    ...options
  })
}

/**
 * POST请求
 * @param {string} url 请求地址
 * @param {object} data 请求数据
 * @param {object} options 请求选项
 */
function post(url, data = {}, options = {}) {
  return request({
    url,
    method: 'POST',
    data,
    ...options
  })
}

/**
 * PUT请求
 * @param {string} url 请求地址
 * @param {object} data 请求数据
 * @param {object} options 请求选项
 */
function put(url, data = {}, options = {}) {
  return request({
    url,
    method: 'PUT',
    data,
    ...options
  })
}

/**
 * DELETE请求
 * @param {string} url 请求地址
 * @param {object} data 请求数据
 * @param {object} options 请求选项
 */
function del(url, data = {}, options = {}) {
  return request({
    url,
    method: 'DELETE',
    data,
    ...options
  })
}

/**
 * 文件上传
 * @param {string} url 上传地址
 * @param {string} filePath 文件路径
 * @param {object} formData 表单数据
 * @param {object} options 上传选项
 */
function upload(url, filePath, formData = {}, options = {}) {
  return new Promise((resolve, reject) => {
    // 显示上传进度
    if (options.showProgress !== false) {
      wx.showLoading({
        title: '上传中...',
        mask: true
      })
    }
    
    // 构建完整的上传URL
    const uploadUrl = url.startsWith('http') ? url : `${BASE_URL}${url}`
    
    // 构建请求头
    const header = {
      ...options.header
    }
    
    // 添加认证token
    if (app.globalData.token) {
      header['Authorization'] = `Bearer ${app.globalData.token}`
    }
    
    // 发起上传
    const uploadTask = wx.uploadFile({
      url: uploadUrl,
      filePath,
      name: options.name || 'file',
      formData,
      header,
      
      success: (res) => {
        // 隐藏进度
        if (options.showProgress !== false) {
          wx.hideLoading()
        }
        
        try {
          const data = JSON.parse(res.data)
          if (data.success) {
            resolve(data)
          } else {
            const error = new Error(data.message || '上传失败')
            error.data = data
            reject(error)
          }
        } catch (err) {
          const error = new Error('响应解析失败')
          error.originalError = err
          reject(error)
        }
      },
      
      fail: (err) => {
        // 隐藏进度
        if (options.showProgress !== false) {
          wx.hideLoading()
        }
        
        const error = new Error('上传失败')
        error.originalError = err
        reject(error)
      }
    })
    
    // 监听上传进度
    if (options.onProgress && typeof options.onProgress === 'function') {
      uploadTask.onProgressUpdate(options.onProgress)
    }
  })
}

/**
 * 下载文件
 * @param {string} url 下载地址
 * @param {object} options 下载选项
 */
function download(url, options = {}) {
  return new Promise((resolve, reject) => {
    // 显示下载进度
    if (options.showProgress !== false) {
      wx.showLoading({
        title: '下载中...',
        mask: true
      })
    }
    
    // 构建请求头
    const header = {
      ...options.header
    }
    
    // 添加认证token
    if (app.globalData.token) {
      header['Authorization'] = `Bearer ${app.globalData.token}`
    }
    
    // 发起下载
    const downloadTask = wx.downloadFile({
      url,
      header,
      
      success: (res) => {
        // 隐藏进度
        if (options.showProgress !== false) {
          wx.hideLoading()
        }
        
        if (res.statusCode === 200) {
          resolve(res)
        } else {
          const error = new Error('下载失败')
          error.statusCode = res.statusCode
          reject(error)
        }
      },
      
      fail: (err) => {
        // 隐藏进度
        if (options.showProgress !== false) {
          wx.hideLoading()
        }
        
        const error = new Error('下载失败')
        error.originalError = err
        reject(error)
      }
    })
    
    // 监听下载进度
    if (options.onProgress && typeof options.onProgress === 'function') {
      downloadTask.onProgressUpdate(options.onProgress)
    }
  })
}

module.exports = {
  request,
  get,
  post,
  put,
  delete: del,
  upload,
  download,
  BASE_URL
}