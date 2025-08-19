// utils/api.js
const app = getApp()

class ApiService {
  constructor() {
    this.baseUrl = app.globalData.baseUrl
  }

  // 通用请求方法
  request(options) {
    return new Promise((resolve, reject) => {
      const defaultOptions = {
        header: {
          'Content-Type': 'application/json'
        }
      }

      // 如果已登录，添加认证头
      if (app.globalData.token) {
        defaultOptions.header['Authorization'] = `Bearer ${app.globalData.token}`
      }

      const requestOptions = Object.assign({}, defaultOptions, options)
      requestOptions.url = `${this.baseUrl}${options.url}`

      wx.request({
        ...requestOptions,
        success: (res) => {
          if (res.statusCode === 401) {
            // token过期，重新登录
            app.logout()
            reject(new Error('登录已过期'))
            return
          }
          
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(res.data)
          } else {
            reject(res.data || new Error(`请求失败: ${res.statusCode}`))
          }
        },
        fail: (err) => {
          reject(err)
        }
      })
    })
  }

  // 文件上传
  uploadFile(filePath, formData = {}) {
    return new Promise((resolve, reject) => {
      const uploadTask = wx.uploadFile({
        url: `${this.baseUrl}/images/upload`,
        filePath: filePath,
        name: 'image',
        formData: formData,
        header: {
          'Authorization': `Bearer ${app.globalData.token}`
        },
        success: (res) => {
          if (res.statusCode === 200) {
            try {
              const data = JSON.parse(res.data)
              resolve(data)
            } catch (e) {
              reject(new Error('响应数据解析失败'))
            }
          } else {
            reject(new Error(`上传失败: ${res.statusCode}`))
          }
        },
        fail: (err) => {
          reject(err)
        }
      })

      return uploadTask
    })
  }
}

// 用户相关API
class UserAPI extends ApiService {
  // 用户注册
  register(userData) {
    return this.request({
      url: '/users/register',
      method: 'POST',
      data: userData
    })
  }

  // 用户登录
  login(username, password) {
    return this.request({
      url: '/users/login',
      method: 'POST',
      data: {
        username,
        password
      }
    })
  }

  // 验证token
  verifyToken() {
    return this.request({
      url: '/users/verify-token',
      method: 'POST'
    })
  }

  // 获取用户信息
  getProfile() {
    return this.request({
      url: '/users/profile',
      method: 'GET'
    })
  }

  // 更新用户信息
  updateProfile(userData) {
    return this.request({
      url: '/users/profile',
      method: 'PUT',
      data: userData
    })
  }

  // 修改密码
  changePassword(oldPassword, newPassword) {
    return this.request({
      url: '/users/change-password',
      method: 'POST',
      data: {
        old_password: oldPassword,
        new_password: newPassword
      }
    })
  }

  // 获取用户统计信息
  getStats() {
    return this.request({
      url: '/users/stats',
      method: 'GET'
    })
  }

  // 登出
  logout() {
    return this.request({
      url: '/users/logout',
      method: 'POST'
    })
  }
}

// 图片相关API
class ImageAPI extends ApiService {
  // 上传图片
  upload(filePath) {
    return this.uploadFile(filePath, {})
  }

  // 获取图片列表
  getList(page = 1, limit = 20) {
    return this.request({
      url: `/images?page=${page}&limit=${limit}`,
      method: 'GET'
    })
  }

  // 获取单张图片信息
  getById(imageId) {
    return this.request({
      url: `/images/${imageId}`,
      method: 'GET'
    })
  }

  // 获取图片文件
  getFile(imageId) {
    return `${this.baseUrl}/images/${imageId}/file`
  }

  // 获取缩略图
  getThumbnail(imageId) {
    return `${this.baseUrl}/images/${imageId}/thumbnail`
  }

  // 更新图片信息
  update(imageId, data) {
    return this.request({
      url: `/images/${imageId}`,
      method: 'PUT',
      data: data
    })
  }

  // 删除图片
  delete(imageId) {
    return this.request({
      url: `/images/${imageId}`,
      method: 'DELETE'
    })
  }
}

// AI处理相关API
class AIAPI extends ApiService {
  // 图片分析
  analyze(imageId) {
    return this.request({
      url: '/ai/analyze',
      method: 'POST',
      data: { image_id: imageId }
    })
  }

  // 获取美颜建议
  getBeautyAdvice(imageId) {
    return this.request({
      url: '/ai/beauty-advice',
      method: 'POST',
      data: { image_id: imageId }
    })
  }

  // 获取风格推荐
  getStyleRecommendations(imageId) {
    return this.request({
      url: '/ai/style-recommendations',
      method: 'POST',
      data: { image_id: imageId }
    })
  }

  // 获取处理建议
  getProcessingAdvice(imageId) {
    return this.request({
      url: '/ai/processing-advice',
      method: 'POST',
      data: { image_id: imageId }
    })
  }

  // 获取构图分析
  getCompositionAnalysis(imageId) {
    return this.request({
      url: '/ai/composition-analysis',
      method: 'POST',
      data: { image_id: imageId }
    })
  }

  // 获取AI配置
  getConfig() {
    return this.request({
      url: '/ai/config',
      method: 'GET'
    })
  }

  // AI服务连接测试
  testConnection() {
    return this.request({
      url: '/ai/test-connection',
      method: 'GET'
    })
  }

  // 健康检查
  healthCheck() {
    return this.request({
      url: '/ai/health',
      method: 'GET'
    })
  }
}

// 图片处理相关API
class ProcessingAPI extends ApiService {
  // 美颜处理
  beauty(imageId, options = {}) {
    return this.request({
      url: '/processing/beauty',
      method: 'POST',
      data: {
        image_id: imageId,
        ...options
      }
    })
  }

  // 证件照生成
  idPhoto(imageId, options = {}) {
    return this.request({
      url: '/processing/id-photo',
      method: 'POST',
      data: {
        image_id: imageId,
        background_color: options.backgroundColor || 'white',
        size: options.size || '1inch',
        ...options
      }
    })
  }

  // 背景处理
  background(imageId, options = {}) {
    return this.request({
      url: '/processing/background',
      method: 'POST',
      data: {
        image_id: imageId,
        action: options.action || 'remove',
        background_image: options.backgroundImage,
        ...options
      }
    })
  }

  // 滤镜效果
  filter(imageId, filterType, intensity = 0.5) {
    return this.request({
      url: '/processing/filter',
      method: 'POST',
      data: {
        image_id: imageId,
        filter_type: filterType,
        intensity: intensity
      }
    })
  }

  // 图片增强
  enhance(imageId, options = {}) {
    return this.request({
      url: '/processing/enhance',
      method: 'POST',
      data: {
        image_id: imageId,
        brightness: options.brightness || 0,
        contrast: options.contrast || 0,
        saturation: options.saturation || 0,
        sharpness: options.sharpness || 0
      }
    })
  }
}

// 导出API实例
const userAPI = new UserAPI()
const imageAPI = new ImageAPI()
const aiAPI = new AIAPI()
const processingAPI = new ProcessingAPI()

module.exports = {
  userAPI,
  imageAPI,
  aiAPI,
  processingAPI
}