// pages/idphoto/idphoto.js
const app = getApp()
const { imageAPI, aiAPI, processingAPI } = require('../../utils/api')
const { chooseImage, previewImage, showToast, saveImageToPhotosAlbum } = require('../../utils/util')

Page({
  data: {
    currentImage: null,
    processedImage: null,
    activeView: 'processed',
    processing: false,
    processingText: '处理中...',
    currentImageId: null,
    
    // 证件照规格
    specList: [
      { id: 'passport', name: '护照照片', width: 390, height: 567 },
      { id: 'id_card', name: '身份证', width: 358, height: 441 },
      { id: 'driver_license', name: '驾驶证', width: 260, height: 378 },
      { id: 'student_card', name: '学生证', width: 480, height: 640 },
      { id: 'work_permit', name: '工作证', width: 413, height: 531 },
      { id: 'visa', name: '签证照片', width: 354, height: 472 },
      { id: 'graduation', name: '毕业照', width: 480, height: 640 },
      { id: 'resume', name: '简历照片', width: 295, height: 413 }
    ],
    selectedSpec: null,
    
    // 背景颜色
    backgroundColors: [
      { name: '白色', value: '#ffffff' },
      { name: '蓝色', value: '#4285f4' },
      { name: '红色', value: '#ea4335' },
      { name: '灰色', value: '#9aa0a6' }
    ],
    selectedBackground: '#ffffff',
    
    // 高级选项
    enableBeauty: true,
    autoCrop: true,
    smartDress: false,
    
    // AI建议
    aiSuggestions: []
  },

  onLoad(options) {
    console.log('证件照页面加载')
    this.initPage()
  },

  onShow() {
    console.log('证件照页面显示')
    this.checkCurrentImage()
  },

  // 初始化页面
  initPage() {
    // 设置默认规格
    this.setData({
      selectedSpec: this.data.specList[0]
    })
    
    this.checkCurrentImage()
    this.loadAISuggestions()
  },

  // 检查当前图片
  checkCurrentImage() {
    if (app.globalData.currentImage) {
      this.setData({
        currentImage: app.globalData.currentImage
      })
    }
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
          processing: true,
          processingText: '上传图片中...'
        })

        try {
          const uploadRes = await imageAPI.upload(imagePath, !app.globalData.isLoggedIn)
          
          if (uploadRes.success) {
            const imageData = uploadRes.data
            
            app.globalData.currentImage = imageData.file_url
            this.setData({
              currentImage: imageData.file_url,
              currentImageId: imageData.id,
              processedImage: null,
              processing: false
            })

            // 加载AI建议
            this.loadAISuggestions()

            showToast('图片上传成功', 'success')
          } else {
            throw new Error(uploadRes.message || '上传失败')
          }
        } catch (uploadError) {
          console.error('上传失败:', uploadError)
          showToast('上传失败，请重试')
          this.setData({ processing: false })
        }
      }
    } catch (error) {
      console.error('选择图片失败:', error)
      showToast('选择图片失败')
    }
  },

  // 预览图片
  previewImage() {
    const { currentImage, processedImage, activeView } = this.data
    const imageToPreview = activeView === 'processed' && processedImage ? processedImage : currentImage
    
    if (imageToPreview) {
      const urls = processedImage ? [currentImage, processedImage] : [currentImage]
      previewImage(imageToPreview, urls)
    }
  },

  // 保存图片
  async saveImage() {
    if (!this.data.processedImage) {
      showToast('没有处理后的图片')
      return
    }

    try {
      // 下载图片到本地
      const downloadRes = await new Promise((resolve, reject) => {
        wx.downloadFile({
          url: this.data.processedImage,
          success: resolve,
          fail: reject
        })
      })

      if (downloadRes.statusCode === 200) {
        // 保存到相册
        await saveImageToPhotosAlbum(downloadRes.tempFilePath)
        showToast('保存成功', 'success')
      } else {
        throw new Error('下载失败')
      }
    } catch (error) {
      console.error('保存失败:', error)
      showToast('保存失败，请重试')
    }
  },

  // 切换视图
  switchView(e) {
    const view = e.currentTarget.dataset.view
    this.setData({
      activeView: view
    })
  },

  // 选择规格
  selectSpec(e) {
    const spec = e.currentTarget.dataset.spec
    this.setData({
      selectedSpec: spec
    })
  },

  // 选择背景颜色
  selectBackground(e) {
    const color = e.currentTarget.dataset.color
    this.setData({
      selectedBackground: color
    })
  },

  // 切换美颜
  toggleBeauty(e) {
    this.setData({
      enableBeauty: e.detail.value
    })
  },

  // 切换自动裁剪
  toggleAutoCrop(e) {
    this.setData({
      autoCrop: e.detail.value
    })
  },

  // 切换智能换装
  toggleSmartDress(e) {
    this.setData({
      smartDress: e.detail.value
    })
  },

  // 生成证件照
  async generateIdPhoto() {
    if (!this.data.currentImageId) {
      showToast('请先上传图片')
      return
    }

    if (!this.data.selectedSpec) {
      showToast('请选择证件照规格')
      return
    }

    this.setData({
      processing: true,
      processingText: '生成证件照中...'
    })

    try {
      const options = {
        spec_type: this.data.selectedSpec.id,
        width: this.data.selectedSpec.width,
        height: this.data.selectedSpec.height,
        background_color: this.data.selectedBackground,
        enable_beauty: this.data.enableBeauty,
        auto_crop: this.data.autoCrop,
        smart_dress: this.data.smartDress
      }

      const res = await processingAPI.idPhoto(this.data.currentImageId, options)
      
      if (res.success) {
        this.setData({
          processedImage: res.data.processed_image_url,
          activeView: 'processed',
          processing: false
        })
        showToast('证件照生成完成', 'success')
      } else {
        throw new Error(res.message || '生成失败')
      }
    } catch (error) {
      console.error('证件照生成失败:', error)
      showToast('生成失败，请重试')
      this.setData({ processing: false })
    }
  },

  // 加载AI建议
  async loadAISuggestions() {
    if (!this.data.currentImageId || !app.globalData.isLoggedIn) {
      return
    }

    try {
      const res = await aiAPI.getIdPhotoAdvice(this.data.currentImageId)
      
      if (res.success && res.data.suggestions) {
        this.setData({
          aiSuggestions: res.data.suggestions
        })
      }
    } catch (error) {
      console.error('加载AI建议失败:', error)
    }
  },

  // 应用AI建议
  async applySuggestion(e) {
    const suggestion = e.currentTarget.dataset.suggestion
    
    if (suggestion.spec) {
      // 查找对应的规格
      const spec = this.data.specList.find(s => s.id === suggestion.spec)
      if (spec) {
        this.setData({
          selectedSpec: spec
        })
      }
    }
    
    if (suggestion.background) {
      this.setData({
        selectedBackground: suggestion.background
      })
    }
    
    if (suggestion.options) {
      this.setData({
        enableBeauty: suggestion.options.enableBeauty !== undefined ? suggestion.options.enableBeauty : this.data.enableBeauty,
        autoCrop: suggestion.options.autoCrop !== undefined ? suggestion.options.autoCrop : this.data.autoCrop,
        smartDress: suggestion.options.smartDress !== undefined ? suggestion.options.smartDress : this.data.smartDress
      })
    }
    
    // 自动生成
    if (suggestion.autoGenerate) {
      await this.generateIdPhoto()
    }
  },

  // 分享功能
  onShareAppMessage() {
    return {
      title: 'AI证件照制作 - 专业证件照一键生成',
      path: '/pages/idphoto/idphoto',
      imageUrl: this.data.processedImage || this.data.currentImage
    }
  }
})