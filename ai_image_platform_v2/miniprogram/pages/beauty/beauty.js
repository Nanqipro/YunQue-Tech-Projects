// pages/beauty/beauty.js
const app = getApp()
const { imageAPI, aiAPI, processingAPI } = require('../../utils/api')
const { chooseImage, previewImage, showToast, saveImageToPhotosAlbum } = require('../../utils/util')

Page({
  data: {
    currentImage: null,
    processedImage: null,
    activeView: 'processed', // 'original' | 'processed'
    processing: false,
    processingText: '处理中...',
    quickBeautyLevel: null,
    beautyParams: {
      smooth: 30,    // 磨皮
      whiten: 20,    // 美白
      thinFace: 15,  // 瘦脸
      bigEye: 10,    // 大眼
      ruddy: 25      // 红润
    },
    aiSuggestions: [],
    currentImageId: null
  },

  onLoad(options) {
    console.log('美颜页面加载')
    this.initPage()
  },

  onShow() {
    console.log('美颜页面显示')
    this.checkCurrentImage()
  },

  // 初始化页面
  initPage() {
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

            // 重置参数
            this.resetParams()
            
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

  // 快速美颜
  async applyQuickBeauty(e) {
    const level = e.currentTarget.dataset.level
    
    if (!this.data.currentImageId) {
      showToast('请先上传图片')
      return
    }

    // 设置对应的参数
    let params = {}
    switch (level) {
      case 'light':
        params = { smooth: 20, whiten: 15, thinFace: 10, bigEye: 5, ruddy: 15 }
        break
      case 'medium':
        params = { smooth: 40, whiten: 30, thinFace: 25, bigEye: 15, ruddy: 30 }
        break
      case 'heavy':
        params = { smooth: 60, whiten: 45, thinFace: 40, bigEye: 25, ruddy: 45 }
        break
    }

    this.setData({
      quickBeautyLevel: level,
      beautyParams: params
    })

    // 应用美颜
    await this.processBeauty(params)
  },

  // 滑块变化事件
  onSmoothChange(e) {
    this.setData({
      'beautyParams.smooth': e.detail.value,
      quickBeautyLevel: null
    })
  },

  onWhitenChange(e) {
    this.setData({
      'beautyParams.whiten': e.detail.value,
      quickBeautyLevel: null
    })
  },

  onThinFaceChange(e) {
    this.setData({
      'beautyParams.thinFace': e.detail.value,
      quickBeautyLevel: null
    })
  },

  onBigEyeChange(e) {
    this.setData({
      'beautyParams.bigEye': e.detail.value,
      quickBeautyLevel: null
    })
  },

  onRuddyChange(e) {
    this.setData({
      'beautyParams.ruddy': e.detail.value,
      quickBeautyLevel: null
    })
  },

  // 应用美颜
  async applyBeauty() {
    if (!this.data.currentImageId) {
      showToast('请先上传图片')
      return
    }

    await this.processBeauty(this.data.beautyParams)
  },

  // 处理美颜
  async processBeauty(params) {
    this.setData({
      processing: true,
      processingText: 'AI美颜处理中...'
    })

    try {
      const options = {
        smooth: params.smooth / 100,
        whiten: params.whiten / 100,
        thin_face: params.thinFace / 100,
        big_eye: params.bigEye / 100,
        ruddy: params.ruddy / 100
      }

      const res = await processingAPI.beauty(this.data.currentImageId, options)
      
      if (res.success) {
        this.setData({
          processedImage: res.data.processed_image_url,
          activeView: 'processed',
          processing: false
        })
        showToast('美颜处理完成', 'success')
      } else {
        throw new Error(res.message || '处理失败')
      }
    } catch (error) {
      console.error('美颜处理失败:', error)
      showToast('处理失败，请重试')
      this.setData({ processing: false })
    }
  },

  // 重置所有参数
  resetAll() {
    this.resetParams()
    this.setData({
      processedImage: null,
      activeView: 'original'
    })
  },

  // 重置参数
  resetParams() {
    this.setData({
      quickBeautyLevel: null,
      beautyParams: {
        smooth: 30,
        whiten: 20,
        thinFace: 15,
        bigEye: 10,
        ruddy: 25
      }
    })
  },

  // 加载AI建议
  async loadAISuggestions() {
    if (!this.data.currentImageId || !app.globalData.isLoggedIn) {
      return
    }

    try {
      const res = await aiAPI.getBeautyAdvice(this.data.currentImageId)
      
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
    
    if (suggestion.params) {
      this.setData({
        beautyParams: suggestion.params,
        quickBeautyLevel: null
      })
      
      await this.processBeauty(suggestion.params)
    }
  },

  // 分享功能
  onShareAppMessage() {
    return {
      title: 'AI美颜处理 - 让你的照片更美丽',
      path: '/pages/beauty/beauty',
      imageUrl: this.data.processedImage || this.data.currentImage
    }
  }
})