// pages/background/background.js
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
    
    // 背景模板相关
    showTemplates: false,
    showAdvanced: false,
    templateCategories: [
      { id: 'solid', name: '纯色背景' },
      { id: 'gradient', name: '渐变背景' },
      { id: 'nature', name: '自然风景' },
      { id: 'office', name: '办公场景' },
      { id: 'studio', name: '摄影棚' }
    ],
    selectedCategory: 'solid',
    selectedTemplate: null,
    currentTemplates: [],
    
    // 高级调节参数
    edgeFeather: 50,
    backgroundOpacity: 100,
    subjectEnhance: 50,
    
    // AI建议
    aiSuggestions: []
  },

  onLoad(options) {
    console.log('背景处理页面加载')
    this.initPage()
  },

  onShow() {
    console.log('背景处理页面显示')
    this.checkCurrentImage()
  },

  // 初始化页面
  initPage() {
    this.checkCurrentImage()
    this.loadBackgroundTemplates()
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
          const uploadRes = await imageAPI.upload(imagePath)
          
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

  // 移除背景
  async removeBackground() {
    if (!this.data.currentImageId) {
      showToast('请先上传图片')
      return
    }

    await this.processBackground('remove')
  },

  // 背景虚化
  async blurBackground() {
    if (!this.data.currentImageId) {
      showToast('请先上传图片')
      return
    }

    await this.processBackground('blur')
  },

  // 显示背景模板
  showBackgroundTemplates() {
    this.setData({
      showTemplates: true
    })
  },

  // 隐藏背景模板
  hideBackgroundTemplates() {
    this.setData({
      showTemplates: false
    })
  },

  // 选择背景分类
  selectCategory(e) {
    const category = e.currentTarget.dataset.category
    this.setData({
      selectedCategory: category,
      selectedTemplate: null
    })
    this.loadTemplatesByCategory(category)
  },

  // 选择背景模板
  selectTemplate(e) {
    const template = e.currentTarget.dataset.template
    this.setData({
      selectedTemplate: template
    })
  },

  // 应用背景模板
  async applyTemplate() {
    if (!this.data.currentImageId || !this.data.selectedTemplate) {
      showToast('请选择背景模板')
      return
    }

    await this.processBackground('replace', {
      template_id: this.data.selectedTemplate.id,
      template_url: this.data.selectedTemplate.url
    })
  },

  // 切换高级调节
  toggleAdvanced() {
    this.setData({
      showAdvanced: !this.data.showAdvanced
    })
  },

  // 边缘羽化调节
  onEdgeFeatherChange(e) {
    this.setData({
      edgeFeather: e.detail.value
    })
  },

  // 背景透明度调节
  onBackgroundOpacityChange(e) {
    this.setData({
      backgroundOpacity: e.detail.value
    })
  },

  // 主体突出度调节
  onSubjectEnhanceChange(e) {
    this.setData({
      subjectEnhance: e.detail.value
    })
  },

  // 应用高级设置
  async applyAdvancedSettings() {
    if (!this.data.currentImageId) {
      showToast('请先上传图片')
      return
    }

    const options = {
      edge_feather: this.data.edgeFeather / 100,
      background_opacity: this.data.backgroundOpacity / 100,
      subject_enhance: this.data.subjectEnhance / 100
    }

    await this.processBackground('advanced', options)
  },

  // 重置高级设置
  resetAdvancedSettings() {
    this.setData({
      edgeFeather: 50,
      backgroundOpacity: 100,
      subjectEnhance: 50
    })
  },

  // 处理背景
  async processBackground(type, options = {}) {
    this.setData({
      processing: true,
      processingText: this.getProcessingText(type)
    })

    try {
      let res
      
      switch (type) {
        case 'remove':
          res = await processingAPI.removeBackground(this.data.currentImageId, options)
          break
        case 'blur':
          res = await processingAPI.blurBackground(this.data.currentImageId, options)
          break
        case 'replace':
          res = await processingAPI.replaceBackground(this.data.currentImageId, options)
          break
        case 'advanced':
          res = await processingAPI.advancedBackground(this.data.currentImageId, options)
          break
        default:
          throw new Error('未知的处理类型')
      }
      
      if (res.success) {
        this.setData({
          processedImage: res.data.processed_image_url,
          activeView: 'processed',
          processing: false,
          showTemplates: false
        })
        showToast('背景处理完成', 'success')
      } else {
        throw new Error(res.message || '处理失败')
      }
    } catch (error) {
      console.error('背景处理失败:', error)
      showToast('处理失败，请重试')
      this.setData({ processing: false })
    }
  },

  // 获取处理文本
  getProcessingText(type) {
    const textMap = {
      remove: '移除背景中...',
      blur: '背景虚化中...',
      replace: '更换背景中...',
      advanced: '高级处理中...'
    }
    return textMap[type] || '处理中...'
  },

  // 加载背景模板
  async loadBackgroundTemplates() {
    try {
      const res = await processingAPI.getBackgroundTemplates()
      
      if (res.success) {
        // 按分类组织模板
        const templates = res.data.templates || []
        this.organizeTemplatesByCategory(templates)
        
        // 加载默认分类的模板
        this.loadTemplatesByCategory(this.data.selectedCategory)
      }
    } catch (error) {
      console.error('加载背景模板失败:', error)
    }
  },

  // 按分类组织模板
  organizeTemplatesByCategory(templates) {
    this.templatesByCategory = {}
    
    templates.forEach(template => {
      const category = template.category || 'solid'
      if (!this.templatesByCategory[category]) {
        this.templatesByCategory[category] = []
      }
      this.templatesByCategory[category].push(template)
    })
  },

  // 按分类加载模板
  loadTemplatesByCategory(category) {
    const templates = this.templatesByCategory?.[category] || this.getDefaultTemplates(category)
    this.setData({
      currentTemplates: templates
    })
  },

  // 获取默认模板
  getDefaultTemplates(category) {
    const defaultTemplates = {
      solid: [
        { id: 'white', name: '白色', thumbnail: '/images/bg-white.png', url: '#ffffff' },
        { id: 'blue', name: '蓝色', thumbnail: '/images/bg-blue.png', url: '#4285f4' },
        { id: 'red', name: '红色', thumbnail: '/images/bg-red.png', url: '#ea4335' },
        { id: 'gray', name: '灰色', thumbnail: '/images/bg-gray.png', url: '#9aa0a6' }
      ],
      gradient: [
        { id: 'sunset', name: '日落', thumbnail: '/images/bg-sunset.png', url: 'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)' },
        { id: 'ocean', name: '海洋', thumbnail: '/images/bg-ocean.png', url: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }
      ]
    }
    
    return defaultTemplates[category] || []
  },

  // 加载AI建议
  async loadAISuggestions() {
    if (!this.data.currentImageId || !app.globalData.isLoggedIn) {
      return
    }

    try {
      const res = await aiAPI.getBackgroundAdvice(this.data.currentImageId)
      
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
    
    if (suggestion.action) {
      switch (suggestion.action) {
        case 'remove':
          await this.removeBackground()
          break
        case 'blur':
          await this.blurBackground()
          break
        case 'replace':
          if (suggestion.template) {
            this.setData({
              selectedTemplate: suggestion.template
            })
            await this.applyTemplate()
          }
          break
      }
    }
  },

  // 分享功能
  onShareAppMessage() {
    return {
      title: 'AI背景处理 - 智能背景编辑工具',
      path: '/pages/background/background',
      imageUrl: this.data.processedImage || this.data.currentImage
    }
  }
})