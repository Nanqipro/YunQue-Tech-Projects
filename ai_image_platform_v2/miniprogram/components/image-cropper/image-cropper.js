// components/image-cropper/image-cropper.js
Component({
  properties: {
    // 是否显示裁剪器
    visible: {
      type: Boolean,
      value: false
    },
    // 图片路径
    imagePath: {
      type: String,
      value: ''
    },
    // 默认宽高比
    defaultAspectRatio: {
      type: Number,
      value: 0 // 0表示自由比例
    },
    // 输出图片质量
    quality: {
      type: Number,
      value: 0.8
    },
    // 输出图片格式
    fileType: {
      type: String,
      value: 'jpg'
    }
  },

  data: {
    // 画布上下文
    ctx: null,
    // 画布尺寸
    canvasWidth: 0,
    canvasHeight: 0,
    // 图片信息
    imageInfo: {
      width: 0,
      height: 0,
      x: 0,
      y: 0,
      scale: 1,
      rotation: 0,
      flipX: false,
      flipY: false
    },
    // 裁剪框
    cropBox: {
      left: 50,
      top: 100,
      width: 200,
      height: 200
    },
    // 当前宽高比
    aspectRatio: 0,
    // 是否显示网格
    showGrid: false,
    // 触摸状态
    touching: false,
    touchType: '', // move, resize
    touchDirection: '', // nw, ne, sw, se
    lastTouch: { x: 0, y: 0 },
    // 控制状态
    controlling: false
  },

  lifetimes: {
    attached() {
      this.initCanvas()
    }
  },

  observers: {
    'visible': function(visible) {
      if (visible && this.data.imagePath) {
        this.loadImage()
      }
    },
    'imagePath': function(path) {
      if (path && this.data.visible) {
        this.loadImage()
      }
    },
    'defaultAspectRatio': function(ratio) {
      this.setData({ aspectRatio: ratio })
      this.updateCropBox()
    }
  },

  methods: {
    // 初始化画布
    initCanvas() {
      const query = this.createSelectorQuery()
      query.select('.cropper-canvas').boundingClientRect(rect => {
        if (rect) {
          this.setData({
            canvasWidth: rect.width,
            canvasHeight: rect.height
          })
          
          const ctx = wx.createCanvasContext('cropperCanvas', this)
          this.setData({ ctx })
        }
      }).exec()
    },

    // 加载图片
    loadImage() {
      const { imagePath } = this.data
      if (!imagePath) return

      wx.getImageInfo({
        src: imagePath,
        success: (res) => {
          const { canvasWidth, canvasHeight } = this.data
          const { width: imgWidth, height: imgHeight } = res
          
          // 计算图片在画布中的显示尺寸和位置
          const scale = Math.min(canvasWidth / imgWidth, canvasHeight / imgHeight) * 0.8
          const displayWidth = imgWidth * scale
          const displayHeight = imgHeight * scale
          const x = (canvasWidth - displayWidth) / 2
          const y = (canvasHeight - displayHeight) / 2
          
          this.setData({
            imageInfo: {
              width: displayWidth,
              height: displayHeight,
              x,
              y,
              scale,
              rotation: 0,
              flipX: false,
              flipY: false,
              originalWidth: imgWidth,
              originalHeight: imgHeight
            }
          })
          
          // 初始化裁剪框
          this.initCropBox()
          // 绘制图片
          this.drawImage()
        },
        fail: (err) => {
          console.error('加载图片失败:', err)
          wx.showToast({
            title: '图片加载失败',
            icon: 'none'
          })
        }
      })
    },

    // 初始化裁剪框
    initCropBox() {
      const { imageInfo, aspectRatio } = this.data
      const { x, y, width, height } = imageInfo
      
      let cropWidth, cropHeight
      
      if (aspectRatio > 0) {
        // 固定比例
        const maxSize = Math.min(width, height) * 0.8
        if (aspectRatio >= 1) {
          cropWidth = maxSize
          cropHeight = maxSize / aspectRatio
        } else {
          cropHeight = maxSize
          cropWidth = maxSize * aspectRatio
        }
      } else {
        // 自由比例
        cropWidth = width * 0.8
        cropHeight = height * 0.8
      }
      
      const cropX = x + (width - cropWidth) / 2
      const cropY = y + (height - cropHeight) / 2
      
      this.setData({
        cropBox: {
          left: cropX,
          top: cropY,
          width: cropWidth,
          height: cropHeight
        }
      })
    },

    // 绘制图片
    drawImage() {
      const { ctx, canvasWidth, canvasHeight, imageInfo, imagePath } = this.data
      if (!ctx) return
      
      // 清空画布
      ctx.clearRect(0, 0, canvasWidth, canvasHeight)
      
      // 保存画布状态
      ctx.save()
      
      // 设置变换
      const { x, y, width, height, rotation, flipX, flipY } = imageInfo
      const centerX = x + width / 2
      const centerY = y + height / 2
      
      ctx.translate(centerX, centerY)
      ctx.rotate(rotation * Math.PI / 180)
      ctx.scale(flipX ? -1 : 1, flipY ? -1 : 1)
      
      // 绘制图片
      ctx.drawImage(imagePath, -width / 2, -height / 2, width, height)
      
      // 恢复画布状态
      ctx.restore()
      
      // 提交绘制
      ctx.draw()
    },

    // 触摸开始
    onTouchStart(e) {
      const touch = e.touches[0]
      this.setData({
        touching: true,
        touchType: 'move',
        lastTouch: { x: touch.clientX, y: touch.clientY },
        showGrid: true
      })
    },

    // 触摸移动
    onTouchMove(e) {
      if (!this.data.touching) return
      
      const touch = e.touches[0]
      const { lastTouch, cropBox, touchType } = this.data
      const deltaX = touch.clientX - lastTouch.x
      const deltaY = touch.clientY - lastTouch.y
      
      if (touchType === 'move') {
        // 移动裁剪框
        const newLeft = cropBox.left + deltaX
        const newTop = cropBox.top + deltaY
        
        this.setData({
          cropBox: {
            ...cropBox,
            left: this.constrainPosition(newLeft, 'x'),
            top: this.constrainPosition(newTop, 'y')
          },
          lastTouch: { x: touch.clientX, y: touch.clientY }
        })
      }
    },

    // 触摸结束
    onTouchEnd() {
      this.setData({
        touching: false,
        touchType: '',
        showGrid: false
      })
    },

    // 控制点触摸开始
    onControlStart(e) {
      const { type, direction } = e.currentTarget.dataset
      const touch = e.touches[0]
      
      this.setData({
        controlling: true,
        touchType: type,
        touchDirection: direction,
        lastTouch: { x: touch.clientX, y: touch.clientY },
        showGrid: true
      })
      
      e.stopPropagation()
    },

    // 控制点触摸移动
    onControlMove(e) {
      if (!this.data.controlling) return
      
      const touch = e.touches[0]
      const { lastTouch, cropBox, touchDirection, aspectRatio } = this.data
      const deltaX = touch.clientX - lastTouch.x
      const deltaY = touch.clientY - lastTouch.y
      
      let newCropBox = { ...cropBox }
      
      // 根据方向调整裁剪框
      switch (touchDirection) {
        case 'nw': // 左上角
          newCropBox.left += deltaX
          newCropBox.top += deltaY
          newCropBox.width -= deltaX
          newCropBox.height -= deltaY
          break
        case 'ne': // 右上角
          newCropBox.top += deltaY
          newCropBox.width += deltaX
          newCropBox.height -= deltaY
          break
        case 'sw': // 左下角
          newCropBox.left += deltaX
          newCropBox.width -= deltaX
          newCropBox.height += deltaY
          break
        case 'se': // 右下角
          newCropBox.width += deltaX
          newCropBox.height += deltaY
          break
      }
      
      // 保持宽高比
      if (aspectRatio > 0) {
        if (Math.abs(deltaX) > Math.abs(deltaY)) {
          newCropBox.height = newCropBox.width / aspectRatio
        } else {
          newCropBox.width = newCropBox.height * aspectRatio
        }
      }
      
      // 限制最小尺寸
      newCropBox.width = Math.max(50, newCropBox.width)
      newCropBox.height = Math.max(50, newCropBox.height)
      
      // 限制位置
      newCropBox = this.constrainCropBox(newCropBox)
      
      this.setData({
        cropBox: newCropBox,
        lastTouch: { x: touch.clientX, y: touch.clientY }
      })
      
      e.stopPropagation()
    },

    // 控制点触摸结束
    onControlEnd() {
      this.setData({
        controlling: false,
        touchType: '',
        touchDirection: '',
        showGrid: false
      })
    },

    // 限制位置
    constrainPosition(value, axis) {
      const { imageInfo, cropBox } = this.data
      const { x, y, width, height } = imageInfo
      
      if (axis === 'x') {
        return Math.max(x, Math.min(value, x + width - cropBox.width))
      } else {
        return Math.max(y, Math.min(value, y + height - cropBox.height))
      }
    },

    // 限制裁剪框
    constrainCropBox(cropBox) {
      const { imageInfo } = this.data
      const { x, y, width, height } = imageInfo
      
      // 限制位置
      cropBox.left = Math.max(x, Math.min(cropBox.left, x + width - cropBox.width))
      cropBox.top = Math.max(y, Math.min(cropBox.top, y + height - cropBox.height))
      
      // 限制尺寸
      cropBox.width = Math.min(cropBox.width, x + width - cropBox.left)
      cropBox.height = Math.min(cropBox.height, y + height - cropBox.top)
      
      return cropBox
    },

    // 左旋转
    onRotateLeft() {
      const { imageInfo } = this.data
      const newRotation = imageInfo.rotation - 90
      
      this.setData({
        imageInfo: {
          ...imageInfo,
          rotation: newRotation
        }
      })
      
      this.drawImage()
    },

    // 右旋转
    onRotateRight() {
      const { imageInfo } = this.data
      const newRotation = imageInfo.rotation + 90
      
      this.setData({
        imageInfo: {
          ...imageInfo,
          rotation: newRotation
        }
      })
      
      this.drawImage()
    },

    // 水平翻转
    onFlipHorizontal() {
      const { imageInfo } = this.data
      
      this.setData({
        imageInfo: {
          ...imageInfo,
          flipX: !imageInfo.flipX
        }
      })
      
      this.drawImage()
    },

    // 垂直翻转
    onFlipVertical() {
      const { imageInfo } = this.data
      
      this.setData({
        imageInfo: {
          ...imageInfo,
          flipY: !imageInfo.flipY
        }
      })
      
      this.drawImage()
    },

    // 比例改变
    onRatioChange(e) {
      const ratio = parseFloat(e.currentTarget.dataset.ratio)
      this.setData({ aspectRatio: ratio })
      this.updateCropBox()
    },

    // 更新裁剪框
    updateCropBox() {
      const { aspectRatio, cropBox } = this.data
      
      if (aspectRatio > 0) {
        const newHeight = cropBox.width / aspectRatio
        const newCropBox = {
          ...cropBox,
          height: newHeight
        }
        
        this.setData({
          cropBox: this.constrainCropBox(newCropBox)
        })
      }
    },

    // 取消
    onCancel() {
      this.triggerEvent('cancel')
    },

    // 确认裁剪
    onConfirm() {
      this.cropImage()
    },

    // 裁剪图片
    cropImage() {
      const { cropBox, imageInfo, quality, fileType } = this.data
      
      // 计算裁剪区域在原图中的位置和尺寸
      const scaleX = imageInfo.originalWidth / imageInfo.width
      const scaleY = imageInfo.originalHeight / imageInfo.height
      
      const cropX = (cropBox.left - imageInfo.x) * scaleX
      const cropY = (cropBox.top - imageInfo.y) * scaleY
      const cropWidth = cropBox.width * scaleX
      const cropHeight = cropBox.height * scaleY
      
      // 创建临时画布进行裁剪
      const tempCanvasId = 'tempCropCanvas'
      const tempCtx = wx.createCanvasContext(tempCanvasId, this)
      
      // 设置画布尺寸
      tempCtx.clearRect(0, 0, cropWidth, cropHeight)
      
      // 绘制裁剪后的图片
      tempCtx.drawImage(
        this.data.imagePath,
        cropX, cropY, cropWidth, cropHeight,
        0, 0, cropWidth, cropHeight
      )
      
      tempCtx.draw(false, () => {
        // 导出图片
        wx.canvasToTempFilePath({
          canvasId: tempCanvasId,
          quality,
          fileType,
          success: (res) => {
            this.triggerEvent('confirm', {
              tempFilePath: res.tempFilePath,
              cropInfo: {
                x: cropX,
                y: cropY,
                width: cropWidth,
                height: cropHeight
              }
            })
          },
          fail: (err) => {
            console.error('裁剪失败:', err)
            wx.showToast({
              title: '裁剪失败',
              icon: 'none'
            })
          }
        }, this)
      })
    }
  }
})