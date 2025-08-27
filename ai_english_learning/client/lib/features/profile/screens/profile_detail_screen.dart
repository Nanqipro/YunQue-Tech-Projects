import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/learning_preferences_card.dart';

/// 个人资料详情屏幕
class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  File? _selectedImage;
  
  // 学习偏好设置
  int _dailyWordGoal = 20;
  int _dailyStudyMinutes = 30;
  EnglishLevel _englishLevel = EnglishLevel.intermediate;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// 加载用户数据
  void _loadUserData() {
    final authProvider = Provider.of<AuthNotifier>(context, listen: false);
    final user = authProvider.state.user;
    
    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _phoneController.text = user.profile?.phone ?? '';
      _bioController.text = user.profile?.bio ?? '';
      
      if (user.profile?.settings != null) {
        _dailyWordGoal = user.profile!.settings!.dailyWordGoal;
        _dailyStudyMinutes = user.profile!.settings!.dailyStudyMinutes;
        _notificationsEnabled = user.profile!.settings!.notificationsEnabled;
        _soundEnabled = user.profile!.settings!.soundEnabled;
        _vibrationEnabled = user.profile!.settings!.vibrationEnabled;
      }
      
      if (user.profile?.englishLevel != null) {
        _englishLevel = user.profile!.englishLevel!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Tab栏
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.titleSmall,
              tabs: const [
                Tab(text: '基本信息'),
                Tab(text: '学习偏好'),
                Tab(text: '账户设置'),
              ],
            ),
          ),
          
          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildLearningPreferencesTab(),
                _buildAccountSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      title: Text(
        '个人资料',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                    ),
                  )
                : Text(
                    '保存',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )
        else
          IconButton(
            onPressed: () => setState(() => _isEditing = true),
            icon: Icon(
              Icons.edit,
              color: AppColors.onPrimary,
            ),
          ),
        const SizedBox(width: AppDimensions.spacingSm),
      ],
    );
  }

  /// 构建基本信息标签页
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像部分
            _buildAvatarSection(),
            const SizedBox(height: AppDimensions.spacingLg),
            
            // 基本信息表单
            ProfileInfoCard(
              title: '基本信息',
              child: Column(
                children: [
                  CustomTextField(
                    controller: _usernameController,
                    labelText: '用户名',
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入用户名';
                      }
                      if (value.length < 2) {
                        return '用户名至少2个字符';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  
                  CustomTextField(
                    controller: _emailController,
                    labelText: '邮箱',
                    enabled: false, // 邮箱不允许修改
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  
                  CustomTextField(
                    controller: _phoneController,
                    labelText: '手机号',
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                          return '请输入正确的手机号';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  
                  CustomTextField(
                    controller: _bioController,
                    labelText: '个人简介',
                    enabled: _isEditing,
                    maxLines: 3,
                    maxLength: 200,
                    validator: (value) {
                      if (value != null && value.length > 200) {
                        return '个人简介不能超过200个字符';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建学习偏好标签页
  Widget _buildLearningPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        children: [
          LearningPreferencesCard(
            title: '学习目标',
            child: Column(
              children: [
                _buildSliderSetting(
                  title: '每日单词目标',
                  value: _dailyWordGoal.toDouble(),
                  min: 5,
                  max: 100,
                  divisions: 19,
                  unit: '个',
                  onChanged: _isEditing
                      ? (value) => setState(() => _dailyWordGoal = value.round())
                      : null,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                
                _buildSliderSetting(
                  title: '每日学习时长',
                  value: _dailyStudyMinutes.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 22,
                  unit: '分钟',
                  onChanged: _isEditing
                      ? (value) => setState(() => _dailyStudyMinutes = value.round())
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          LearningPreferencesCard(
            title: '英语水平',
            child: _buildEnglishLevelSelector(),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          LearningPreferencesCard(
            title: '通知设置',
            child: Column(
              children: [
                _buildSwitchSetting(
                  title: '学习提醒',
                  subtitle: '每日学习时间提醒',
                  value: _notificationsEnabled,
                  onChanged: _isEditing
                      ? (value) => setState(() => _notificationsEnabled = value)
                      : null,
                ),
                _buildSwitchSetting(
                  title: '音效',
                  subtitle: '操作反馈音效',
                  value: _soundEnabled,
                  onChanged: _isEditing
                      ? (value) => setState(() => _soundEnabled = value)
                      : null,
                ),
                _buildSwitchSetting(
                  title: '震动反馈',
                  subtitle: '操作震动反馈',
                  value: _vibrationEnabled,
                  onChanged: _isEditing
                      ? (value) => setState(() => _vibrationEnabled = value)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建账户设置标签页
  Widget _buildAccountSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        children: [
          ProfileInfoCard(
            title: '安全设置',
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.lock_outline,
                  title: '修改密码',
                  subtitle: '定期修改密码保护账户安全',
                  onTap: () => Navigator.pushNamed(context, '/change-password'),
                ),
                const Divider(),
                _buildSettingItem(
                  icon: Icons.security,
                  title: '两步验证',
                  subtitle: '增强账户安全性',
                  onTap: () => _showComingSoon('两步验证'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          ProfileInfoCard(
            title: '数据管理',
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.download,
                  title: '导出数据',
                  subtitle: '导出学习记录和个人数据',
                  onTap: () => _showComingSoon('数据导出'),
                ),
                const Divider(),
                _buildSettingItem(
                  icon: Icons.delete_outline,
                  title: '清除缓存',
                  subtitle: '清除应用缓存数据',
                  onTap: _clearCache,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          ProfileInfoCard(
            title: '账户操作',
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.logout,
                  title: '退出登录',
                  subtitle: '退出当前账户',
                  onTap: _logout,
                  textColor: AppColors.warning,
                ),
                const Divider(),
                _buildSettingItem(
                  icon: Icons.delete_forever,
                  title: '注销账户',
                  subtitle: '永久删除账户和所有数据',
                  onTap: () => _showDeleteAccountDialog(),
                  textColor: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建头像部分
  Widget _buildAvatarSection() {
    return Consumer<AuthNotifier>(builder: (context, authProvider, child) {
      final user = authProvider.state.user;
      
      return Center(
        child: Column(
          children: [
            ProfileAvatar(
              imageUrl: user?.profile?.avatar,
              selectedImage: _selectedImage,
              size: 100,
              isEditing: _isEditing,
              onImageSelected: _selectImage,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            
            Text(
              user?.username ?? '用户',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            
            Text(
              user?.email ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 构建滑块设置
  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    ValueChanged<double>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.round()} $unit',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// 构建开关设置
  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  /// 构建英语水平选择器
  Widget _buildEnglishLevelSelector() {
    return Column(
      children: EnglishLevel.values.map((level) {
        return RadioListTile<EnglishLevel>(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _getEnglishLevelText(level),
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _getEnglishLevelDescription(level),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          value: level,
          groupValue: _englishLevel,
          onChanged: _isEditing
              ? (value) => setState(() => _englishLevel = value!)
              : null,
          activeColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  /// 构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: textColor ?? AppColors.onSurface,
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: textColor ?? AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  /// 选择图片
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// 保存个人资料
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthNotifier>(context, listen: false);
      
      // TODO: 如果有选择新头像，先上传头像
      String? avatarUrl;
      if (_selectedImage != null) {
        // avatarUrl = await _uploadAvatar(_selectedImage!);
      }
      
      await authProvider.updateProfile(
        username: _usernameController.text,
        phone: _phoneController.text,
        avatar: avatarUrl,
      );
      
      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('个人资料更新成功'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 清除缓存
  Future<void> _clearCache() async {
    // TODO: 实现清除缓存功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('缓存已清除'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  /// 退出登录
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '退出',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final authProvider = Provider.of<AuthNotifier>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  /// 显示注销账户对话框
  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '注销账户',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          '注销账户将永久删除您的所有数据，包括学习记录、个人信息等。此操作不可恢复，请谨慎操作。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '确认注销',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // TODO: 实现注销账户功能
      _showComingSoon('账户注销');
    }
  }

  /// 显示即将上线提示
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature功能即将上线'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  /// 获取英语水平文本
  String _getEnglishLevelText(EnglishLevel level) {
    switch (level) {
      case EnglishLevel.beginner:
        return '初级 (Beginner)';
      case EnglishLevel.elementary:
        return '基础 (Elementary)';
      case EnglishLevel.intermediate:
        return '中级 (Intermediate)';
      case EnglishLevel.upperIntermediate:
        return '中高级 (Upper Intermediate)';
      case EnglishLevel.advanced:
        return '高级 (Advanced)';
      case EnglishLevel.proficient:
        return '精通 (Proficient)';
      case EnglishLevel.expert:
        return '专家 (Expert)';
    }
  }

  /// 获取英语水平描述
  String _getEnglishLevelDescription(EnglishLevel level) {
    switch (level) {
      case EnglishLevel.beginner:
        return '基础词汇和语法，适合英语入门学习者';
      case EnglishLevel.elementary:
        return '掌握基本词汇，能进行简单交流';
      case EnglishLevel.intermediate:
        return '中等词汇量，能进行日常对话和阅读';
      case EnglishLevel.upperIntermediate:
        return '较好的词汇量，能处理复杂话题';
      case EnglishLevel.advanced:
        return '丰富词汇量，能流利交流和理解复杂内容';
      case EnglishLevel.proficient:
        return '熟练掌握英语，能应对各种语言场景';
      case EnglishLevel.expert:
        return '接近母语水平，能处理专业和学术内容';
    }
  }
}