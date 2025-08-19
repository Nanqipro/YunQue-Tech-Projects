// pages/history/history.js
const app = getApp()
const { imageAPI, processingAPI } = require('../../utils/api')
const { previewImage, showToast, saveImageToPhotosAlbum, showModal, formatTime } = require('../../utils/util')

Page({
  data: {
    historyList: [],
    loading: false,
    processing: false,
    processingText: '处理中...',
    hasMore: true,
    page: 1,
    pageSize: 10,
    
    // 筛选和排序
    filterTabs: [
      { id: 'all', name: '全部' },
      { id: 'beauty', name: '美颜' },
      { id: 'idphoto', name: '证件照' },
      { id: 'background', name: '背景处理' }
    ],
    activeFilter: 'all',
    sortOptions: [
      { id: 'time_desc', name: '时间降序' },
      { id: 'time_asc', name: '时间升序' },
      { id: 'type', name: '按类型' }
    ],
    sortIndex: 0,
    
    // 批量操作
    batchMode: false,
    showBatchActions: false,
    selectedItems: []
  },

  onLoad(options) {
    console.log('历史记录页面加载')
    this.checkLoginStatus()
  },

  onShow() {
    console.log('历史记录页面显示')
    this.refreshHistory()
  },

  onPullDownRefresh() {
    this.refreshHistory()
  },

  onReachBottom() {
    if (this.data.hasMore && !this.data.loading) {
      this.loadMore()
    }
  },

  // 检查登录状态
  checkLoginStatus() {
    if (!app.globalData.isLoggedIn) {
      showModal('提示', '请先登录查看历史记录', {
        showCancel: true,
        confirmText: '去登录',
        cancelText: '取消'
      }).then(res => {
        if (res.confirm) {
          wx.navigateTo({
            url: '/pages/login/login'
          })
        } else {
          wx.navigateBack()
        }
      })
      return false
    }
    return true
  },

  // 刷新历史记录
  async refreshHistory() {
    if (!this.checkLoginStatus()) return
    
    this.setData({
      page: 1,
      hasMore: true,
      historyList: []
    })
    
    await this.loadHistory()
    
    // 停止下拉刷新
    wx.stopPullDownRefresh()
  },

  // 加载历史记录
  async loadHistory() {
    if (this.data.loading) return
    
    this.setData({ loading: true })
    
    try {
      const params = {
        page: this.data.page,
        page_size: this.data.pageSize,
        filter: this.data.activeFilter,
        sort: this.data.sortOptions[this.data.sortIndex].id
      }
      
      const res = await processingAPI.getHistory(params)
      
      if (res.success) {
        const newList = res.data.records || []
        
        // 格式化数据
        const formattedList = newList.map(item => this.formatHistoryItem(item))
        
        this.setData({
          historyList: this.data.page === 1 ? formattedList : [...this.data.historyList, ...formattedList],
          hasMore: newList.length === this.data.pageSize,
          loading: false
        })
      } else {
        throw new Error(res.message || '加载失败')
      }
    } catch (error) {
      console.error('加载历史记录失败:', error)
      showToast('加载失败，请重试')
      this.setData({ loading: false })
    }
  },

  // 格式化历史记录项
  formatHistoryItem(item) {
    const typeMap = {
      beauty: 'AI美颜',
      idphoto: '证件照',
      background: '背景处理',
      filter: '滤镜',
      enhance: '图片增强'
    }
    
    const statusMap = {
      completed: '已完成',
      processing: '处理中',
      failed: '失败'
    }
    
    return {
      ...item,
      process_type_name: typeMap[item.process_type] || item.process_type,
      status_name: statusMap[item.status] || item.status,
      formatted_time: formatTime(item.created_at),
      description: this.getProcessDescription(item)
    }
  },

  // 获取处理描述
  getProcessDescription(item) {
    const descriptions = {
      beauty: '智能美颜处理',
      idphoto: `${item.options?.spec_type || '标准'}证件照`,
      background: item.options?.action === 'remove' ? '背景移除' : '背景处理',
      filter: `${item.options?.filter_name || ''}滤镜`,
      enhance: '图片质量增强'
    }
    
    return descriptions[item.process_type] || '图片处理'
  },

  // 切换筛选
  switchFilter(e) {
    const filter = e.currentTarget.dataset.filter
    this.setData({
      activeFilter: filter
    })
    this.refreshHistory()
  },

  // 排序变化
  onSortChange(e) {
    this.setData({
      sortIndex: e.detail.value
    })
    this.refreshHistory()
  },

  // 加载更多
  loadMore() {
    if (!this.data.hasMore || this.data.loading) return
    
    this.setData({
      page: this.data.page + 1
    })
    this.loadHistory()
  },

  // 查看历史详情
  viewHistoryDetail(e) {
    if (this.data.batchMode) {
      this.toggleItemSelection(e)
      return
    }
    
    const item = e.currentTarget.dataset.item
    
    // 设置当前图片到全局
    app.globalData.currentImage = item.original_image_url
    
    // 根据处理类型跳转到对应页面
    const pageMap = {
      beauty: '/pages/beauty/beauty',
      idphoto: '/pages/idphoto/idphoto',
      background: '/pages/background/background'
    }
    
    const targetPage = pageMap[item.process_type]
    if (targetPage) {
      wx.navigateTo({
        url: targetPage
      })
    }
  },

  // 预览图片
  previewImages(e) {
    const item = e.currentTarget.dataset.item
    const urls = [item.original_image_url, item.processed_image_url]
    previewImage(item.processed_image_url, urls)
  },

  // 下载图片
  async downloadImage(e) {
    const item = e.currentTarget.dataset.item
    
    this.setData({
      processing: true,
      processingText: '下载中...'
    })
    
    try {
      // 下载图片到本地
      const downloadRes = await new Promise((resolve, reject) => {
        wx.downloadFile({
          url: item.processed_image_url,
          success: resolve,
          fail: reject
        })
      })

      if (downloadRes.statusCode === 200) {
        // 保存到相册
        await saveImageToPhotosAlbum(downloadRes.tempFilePath)
        showToast('下载成功', 'success')
      } else {
        throw new Error('下载失败')
      }
    } catch (error) {
      console.error('下载失败:', error)
      showToast('下载失败，请重试')
    } finally {
      this.setData({ processing: false })
    }
  },

  // 分享图片
  shareImage(e) {
    const item = e.currentTarget.dataset.item
    
    wx.showShareMenu({
      withShareTicket: true,
      menus: ['shareAppMessage', 'shareTimeline']
    })
    
    // 设置分享内容
    this.shareData = {
      title: `我的${item.process_type_name}作品`,
      path: '/pages/index/index',
      imageUrl: item.processed_image_url
    }
  },

  // 删除历史记录
  async deleteHistory(e) {
    const item = e.currentTarget.dataset.item
    
    const res = await showModal('确认删除', '确定要删除这条历史记录吗？', {
      showCancel: true,
      confirmText: '删除',
      cancelText: '取消'
    })
    
    if (!res.confirm) return
    
    this.setData({
      processing: true,
      processingText: '删除中...'
    })
    
    try {
      const deleteRes = await processingAPI.deleteHistory(item.id)
      
      if (deleteRes.success) {
        // 从列表中移除
        const newList = this.data.historyList.filter(historyItem => historyItem.id !== item.id)
        this.setData({
          historyList: newList
        })
        showToast('删除成功', 'success')
      } else {
        throw new Error(deleteRes.message || '删除失败')
      }
    } catch (error) {
      console.error('删除失败:', error)
      showToast('删除失败，请重试')
    } finally {
      this.setData({ processing: false })
    }
  },

  // 切换批量模式
  toggleBatchMode() {
    const newBatchMode = !this.data.batchMode
    this.setData({
      batchMode: newBatchMode,
      showBatchActions: newBatchMode && this.data.selectedItems.length > 0,
      selectedItems: newBatchMode ? this.data.selectedItems : []
    })
  },

  // 切换项目选择
  toggleItemSelection(e) {
    const item = e.currentTarget.dataset.item
    const selectedItems = [...this.data.selectedItems]
    const index = selectedItems.findIndex(selected => selected.id === item.id)
    
    if (index > -1) {
      selectedItems.splice(index, 1)
    } else {
      selectedItems.push(item)
    }
    
    this.setData({
      selectedItems,
      showBatchActions: selectedItems.length > 0
    })
  },

  // 取消批量操作
  cancelBatch() {
    this.setData({
      batchMode: false,
      showBatchActions: false,
      selectedItems: []
    })
  },

  // 批量下载
  async batchDownload() {
    if (this.data.selectedItems.length === 0) {
      showToast('请选择要下载的项目')
      return
    }
    
    this.setData({
      processing: true,
      processingText: `下载中 (0/${this.data.selectedItems.length})...`
    })
    
    try {
      for (let i = 0; i < this.data.selectedItems.length; i++) {
        const item = this.data.selectedItems[i]
        
        this.setData({
          processingText: `下载中 (${i + 1}/${this.data.selectedItems.length})...`
        })
        
        // 下载图片
        const downloadRes = await new Promise((resolve, reject) => {
          wx.downloadFile({
            url: item.processed_image_url,
            success: resolve,
            fail: reject
          })
        })

        if (downloadRes.statusCode === 200) {
          await saveImageToPhotosAlbum(downloadRes.tempFilePath)
        }
      }
      
      showToast('批量下载完成', 'success')
      this.cancelBatch()
    } catch (error) {
      console.error('批量下载失败:', error)
      showToast('部分下载失败，请重试')
    } finally {
      this.setData({ processing: false })
    }
  },

  // 批量删除
  async batchDelete() {
    if (this.data.selectedItems.length === 0) {
      showToast('请选择要删除的项目')
      return
    }
    
    const res = await showModal('确认删除', `确定要删除选中的 ${this.data.selectedItems.length} 条记录吗？`, {
      showCancel: true,
      confirmText: '删除',
      cancelText: '取消'
    })
    
    if (!res.confirm) return
    
    this.setData({
      processing: true,
      processingText: `删除中 (0/${this.data.selectedItems.length})...`
    })
    
    try {
      const deletePromises = this.data.selectedItems.map((item, index) => {
        this.setData({
          processingText: `删除中 (${index + 1}/${this.data.selectedItems.length})...`
        })
        return processingAPI.deleteHistory(item.id)
      })
      
      await Promise.all(deletePromises)
      
      // 从列表中移除已删除的项目
      const selectedIds = this.data.selectedItems.map(item => item.id)
      const newList = this.data.historyList.filter(item => !selectedIds.includes(item.id))
      
      this.setData({
        historyList: newList
      })
      
      showToast('批量删除完成', 'success')
      this.cancelBatch()
    } catch (error) {
      console.error('批量删除失败:', error)
      showToast('部分删除失败，请重试')
    } finally {
      this.setData({ processing: false })
    }
  },

  // 跳转到首页
  goToIndex() {
    wx.switchTab({
      url: '/pages/index/index'
    })
  },

  // 分享功能
  onShareAppMessage() {
    return this.shareData || {
      title: 'AI图像处理平台 - 我的处理历史',
      path: '/pages/index/index'
    }
  }
})