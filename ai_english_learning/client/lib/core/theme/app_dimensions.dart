/// 应用尺寸配置
class AppDimensions {
  // 私有构造函数，防止实例化
  AppDimensions._();
  
  // ============ 间距 ============
  
  /// 极小间距
  static const double spacingXs = 4.0;
  
  /// 小间距
  static const double spacingSm = 8.0;
  
  /// 中等间距
  static const double spacingMd = 16.0;
  
  /// 大间距
  static const double spacingLg = 24.0;
  
  /// 超大间距
  static const double spacingXl = 32.0;
  
  /// 超超大间距
  static const double spacingXxl = 48.0;
  
  // ============ 内边距 ============
  
  /// 页面内边距
  static const double pagePadding = spacingMd;
  
  /// 卡片内边距
  static const double cardPadding = spacingMd;
  
  /// 按钮内边距
  static const double buttonPadding = spacingMd;
  
  /// 输入框内边距
  static const double inputPadding = spacingMd;
  
  /// 列表项内边距
  static const double listItemPadding = spacingMd;
  
  /// 对话框内边距
  static const double dialogPadding = spacingLg;
  
  /// 底部导航栏内边距
  static const double bottomNavPadding = spacingSm;
  
  /// AppBar内边距
  static const double appBarPadding = spacingMd;
  
  // ============ 外边距 ============
  
  /// 页面外边距
  static const double pageMargin = spacingMd;
  
  /// 卡片外边距
  static const double cardMargin = spacingSm;
  
  /// 按钮外边距
  static const double buttonMargin = spacingSm;
  
  /// 输入框外边距
  static const double inputMargin = spacingSm;
  
  /// 列表项外边距
  static const double listItemMargin = spacingXs;
  
  /// 对话框外边距
  static const double dialogMargin = spacingLg;
  
  // ============ 圆角半径 ============
  
  /// 极小圆角
  static const double radiusXs = 4.0;
  
  /// 小圆角
  static const double radiusSm = 8.0;
  
  /// 中等圆角
  static const double radiusMd = 12.0;
  
  /// 大圆角
  static const double radiusLg = 16.0;
  
  /// 超大圆角
  static const double radiusXl = 20.0;
  
  /// 圆形
  static const double radiusCircle = 999.0;
  
  // ============ 组件圆角 ============
  
  /// 按钮圆角
  static const double buttonRadius = radiusSm;
  
  /// 卡片圆角
  static const double cardRadius = radiusMd;
  
  /// 输入框圆角
  static const double inputRadius = radiusSm;
  
  /// 对话框圆角
  static const double dialogRadius = radiusLg;
  
  /// 底部弹窗圆角
  static const double bottomSheetRadius = radiusLg;
  
  /// 芯片圆角
  static const double chipRadius = radiusLg;
  
  /// 头像圆角
  static const double avatarRadius = radiusCircle;
  
  /// 图片圆角
  static const double imageRadius = radiusSm;
  
  // ============ 高度 ============
  
  /// AppBar高度
  static const double appBarHeight = 56.0;
  
  /// 底部导航栏高度
  static const double bottomNavHeight = 80.0;
  
  /// 标签栏高度
  static const double tabBarHeight = 48.0;
  
  /// 按钮高度
  static const double buttonHeight = 48.0;
  
  /// 小按钮高度
  static const double buttonHeightSm = 36.0;
  
  /// 大按钮高度
  static const double buttonHeightLg = 56.0;
  
  /// 输入框高度
  static const double inputHeight = 56.0;
  
  /// 列表项高度
  static const double listItemHeight = 56.0;
  
  /// 小列表项高度
  static const double listItemHeightSm = 48.0;
  
  /// 大列表项高度
  static const double listItemHeightLg = 72.0;
  
  /// 工具栏高度
  static const double toolbarHeight = 56.0;
  
  /// 搜索栏高度
  static const double searchBarHeight = 48.0;
  
  /// 进度条高度
  static const double progressBarHeight = 4.0;
  
  /// 分割线高度
  static const double dividerHeight = 1.0;
  
  // ============ 宽度 ============
  
  /// 最小按钮宽度
  static const double buttonMinWidth = 64.0;
  
  /// 侧边栏宽度
  static const double drawerWidth = 304.0;
  
  /// 分割线宽度
  static const double dividerWidth = 1.0;
  
  /// 边框宽度
  static const double borderWidth = 1.0;
  
  /// 粗边框宽度
  static const double borderWidthThick = 2.0;
  
  // ============ 图标尺寸 ============
  
  /// 极小图标
  static const double iconXs = 16.0;
  
  /// 小图标
  static const double iconSm = 20.0;
  
  /// 中等图标
  static const double iconMd = 24.0;
  
  /// 大图标
  static const double iconLg = 32.0;
  
  /// 超大图标
  static const double iconXl = 48.0;
  
  /// 超超大图标
  static const double iconXxl = 64.0;
  
  // ============ 头像尺寸 ============
  
  /// 小头像
  static const double avatarSm = 32.0;
  
  /// 中等头像
  static const double avatarMd = 48.0;
  
  /// 大头像
  static const double avatarLg = 64.0;
  
  /// 超大头像
  static const double avatarXl = 96.0;
  
  // ============ 阴影 ============
  
  /// 阴影偏移
  static const double shadowOffset = 2.0;
  
  /// 阴影模糊半径
  static const double shadowBlurRadius = 8.0;
  
  /// 阴影扩散半径
  static const double shadowSpreadRadius = 0.0;
  
  // ============ 动画持续时间 ============
  
  /// 快速动画
  static const Duration animationFast = Duration(milliseconds: 150);
  
  /// 中等动画
  static const Duration animationMedium = Duration(milliseconds: 300);
  
  /// 慢速动画
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // ============ 学习相关尺寸 ============
  
  /// 单词卡片高度
  static const double wordCardHeight = 200.0;
  
  /// 单词卡片宽度
  static const double wordCardWidth = 300.0;
  
  /// 进度圆环大小
  static const double progressCircleSize = 120.0;
  
  /// 等级徽章大小
  static const double levelBadgeSize = 40.0;
  
  /// 成就徽章大小
  static const double achievementBadgeSize = 60.0;
  
  /// 音频播放器高度
  static const double audioPlayerHeight = 80.0;
  
  /// 练习题选项高度
  static const double exerciseOptionHeight = 48.0;
  
  /// 学习统计卡片高度
  static const double statsCardHeight = 120.0;
  
  // ============ 响应式断点 ============
  
  /// 手机断点
  static const double mobileBreakpoint = 600.0;
  
  /// 平板断点
  static const double tabletBreakpoint = 900.0;
  
  /// 桌面断点
  static const double desktopBreakpoint = 1200.0;
  
  // ============ 最大宽度 ============
  
  /// 内容最大宽度
  static const double maxContentWidth = 1200.0;
  
  /// 对话框最大宽度
  static const double maxDialogWidth = 560.0;
  
  /// 卡片最大宽度
  static const double maxCardWidth = 400.0;
  
  // ============ 最小尺寸 ============
  
  /// 最小触摸目标尺寸
  static const double minTouchTarget = 48.0;
  
  /// 最小按钮尺寸
  static const double minButtonSize = 36.0;
  
  // ============ 网格布局 ============
  
  /// 网格间距
  static const double gridSpacing = spacingSm;
  
  /// 网格交叉轴间距
  static const double gridCrossAxisSpacing = spacingSm;
  
  /// 网格主轴间距
  static const double gridMainAxisSpacing = spacingSm;
  
  /// 网格子项宽高比
  static const double gridChildAspectRatio = 1.0;
  
  // ============ 列表布局 ============
  
  /// 列表分割线缩进
  static const double listDividerIndent = spacingMd;
  
  /// 列表分割线结束缩进
  static const double listDividerEndIndent = spacingMd;
  
  // ============ 浮动操作按钮 ============
  
  /// 浮动操作按钮大小
  static const double fabSize = 56.0;
  
  /// 小浮动操作按钮大小
  static const double fabSizeSmall = 40.0;
  
  /// 大浮动操作按钮大小
  static const double fabSizeLarge = 96.0;
  
  /// 浮动操作按钮边距
  static const double fabMargin = spacingMd;
  
  // ============ 辅助方法 ============
  
  /// 根据屏幕宽度获取响应式间距
  static double getResponsiveSpacing(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return spacingSm;
    } else if (screenWidth < tabletBreakpoint) {
      return spacingMd;
    } else {
      return spacingLg;
    }
  }
  
  /// 根据屏幕宽度获取响应式内边距
  static double getResponsivePadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return spacingMd;
    } else if (screenWidth < tabletBreakpoint) {
      return spacingLg;
    } else {
      return spacingXl;
    }
  }
  
  /// 根据屏幕宽度判断是否为移动设备
  static bool isMobile(double screenWidth) {
    return screenWidth < mobileBreakpoint;
  }
  
  /// 根据屏幕宽度判断是否为平板设备
  static bool isTablet(double screenWidth) {
    return screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;
  }
  
  /// 根据屏幕宽度判断是否为桌面设备
  static bool isDesktop(double screenWidth) {
    return screenWidth >= desktopBreakpoint;
  }
}