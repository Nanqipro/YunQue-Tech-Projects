import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../../core/models/user_model.dart';

/// 个人信息管理页面
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // 个人信息控制器
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  
  // 密码修改控制器
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 加载用户数据
  void _loadUserData() {
    final authState = ref.read(authProvider);
    final user = authState.user;
    
    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _phoneController.text = user.profile?.phone ?? '';
      _bioController.text = user.profile?.bio ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          '个人信息',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_tabController.index == 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Text(
                _isEditing ? '取消' : '编辑',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '基本信息'),
            Tab(text: '安全设置'),
            Tab(text: '学习偏好'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildSecurityTab(),
          _buildPreferencesTab(),
        ],
      ),
    );
  }

  /// 基本信息标签页
  Widget _buildBasicInfoTab() {
    return Consumer(builder: (context, ref, child) {
      final authState = ref.watch(authProvider);
      final user = authState.user;
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 头像
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.surfaceVariant,
                      backgroundImage: user?.profile?.avatar != null
                          ? NetworkImage(user!.profile!.avatar!)
                          : null,
                      child: user?.profile?.avatar == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.onSurfaceVariant,
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _handleAvatarChange,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              // 用户名
              CustomTextField(
                controller: _usernameController,
                labelText: '用户名',
                prefixIcon: Icons.person_outline,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  if (value.length < 3) {
                    return '用户名至少3个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // 邮箱
              CustomTextField(
                controller: _emailController,
                labelText: '邮箱',
                prefixIcon: Icons.email_outlined,
                enabled: false, // 邮箱不允许修改
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // 手机号
              CustomTextField(
                controller: _phoneController,
                labelText: '手机号',
                prefixIcon: Icons.phone_outlined,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                      return '请输入有效的手机号';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // 个人简介
              CustomTextField(
                controller: _bioController,
                labelText: '个人简介',
                prefixIcon: Icons.edit_outlined,
                enabled: _isEditing,
                maxLines: 3,
                hintText: '介绍一下自己吧...',
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              // 保存按钮
              if (_isEditing)
                CustomButton(
                  text: '保存修改',
                  onPressed: _handleSaveProfile,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
            ],
          ),
        ),
      );
    });
  }

  /// 安全设置标签页
  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 修改密码
          Text(
            '修改密码',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 当前密码
          CustomTextField(
            controller: _currentPasswordController,
            labelText: '当前密码',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureCurrentPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入当前密码';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // 新密码
          CustomTextField(
            controller: _newPasswordController,
            labelText: '新密码',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入新密码';
              }
              if (value.length < 8) {
                return '密码至少8个字符';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return '密码必须包含大小写字母和数字';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // 确认新密码
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: '确认新密码',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请确认新密码';
              }
              if (value != _newPasswordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // 修改密码按钮
          CustomButton(
            text: '修改密码',
            onPressed: _handleChangePassword,
            isLoading: _isLoading,
            width: double.infinity,
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // 其他安全选项
          _buildSecurityOption(
            icon: Icons.security,
            title: '两步验证',
            subtitle: '为您的账户添加额外的安全保护',
            onTap: () => _showSnackBar('两步验证功能即将上线'),
          ),
          _buildSecurityOption(
            icon: Icons.devices,
            title: '设备管理',
            subtitle: '查看和管理已登录的设备',
            onTap: () => _showSnackBar('设备管理功能即将上线'),
          ),
          _buildSecurityOption(
            icon: Icons.history,
            title: '登录历史',
            subtitle: '查看最近的登录记录',
            onTap: () => _showSnackBar('登录历史功能即将上线'),
          ),
        ],
      ),
    );
  }

  /// 学习偏好标签页
  Widget _buildPreferencesTab() {
    return Consumer(builder: (context, ref, child) {
      final authState = ref.watch(authProvider);
      final user = authState.user;
      final settings = user?.profile?.settings;
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '学习设置',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            
            _buildPreferenceOption(
              icon: Icons.notifications,
              title: '学习提醒',
              subtitle: '每日学习提醒通知',
              value: settings?.notificationsEnabled ?? true,
              onChanged: (value) => _updateSetting('notificationsEnabled', value),
            ),
            _buildPreferenceOption(
              icon: Icons.volume_up,
              title: '音效',
              subtitle: '学习过程中的音效反馈',
              value: settings?.soundEnabled ?? true,
              onChanged: (value) => _updateSetting('soundEnabled', value),
            ),
            _buildPreferenceOption(
              icon: Icons.vibration,
              title: '震动反馈',
              subtitle: '操作时的震动反馈',
              value: settings?.vibrationEnabled ?? true,
              onChanged: (value) => _updateSetting('vibrationEnabled', value),
            ),
            
            const SizedBox(height: AppDimensions.spacingXl),
            
            Text(
              '学习目标',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            
            _buildGoalOption(
              title: '每日单词目标',
              value: '${settings?.dailyWordGoal ?? 20} 个',
              onTap: () => _showGoalDialog('dailyWordGoal', settings?.dailyWordGoal ?? 20),
            ),
            _buildGoalOption(
              title: '每日学习时长',
              value: '${settings?.dailyStudyMinutes ?? 30} 分钟',
              onTap: () => _showGoalDialog('dailyStudyMinutes', settings?.dailyStudyMinutes ?? 30),
            ),
            
            const SizedBox(height: AppDimensions.spacingXl),
            
            Text(
              '英语水平',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            
            _buildLevelOption(
              title: '当前水平',
              value: _getLevelText(user?.profile?.englishLevel ?? EnglishLevel.beginner),
              onTap: () => _showLevelDialog(),
            ),
          ],
        ),
      );
    });
  }

  /// 构建安全选项
  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  /// 构建偏好选项
  Widget _buildPreferenceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
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

  /// 构建目标选项
  Widget _buildGoalOption({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  /// 构建水平选项
  Widget _buildLevelOption({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  /// 处理头像更改
  void _handleAvatarChange() {
    // TODO: 实现头像更改功能
    _showSnackBar('头像更改功能即将上线');
  }

  /// 处理保存个人信息
  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.updateProfile(
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        _showSnackBar('个人信息更新成功', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 处理修改密码
  Future<void> _handleChangePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('请填写所有密码字段');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('两次输入的新密码不一致');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _showSnackBar('密码修改成功', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 更新设置
  void _updateSetting(String key, bool value) {
    // TODO: 实现设置更新
    _showSnackBar('设置已更新', isSuccess: true);
  }

  /// 显示目标设置对话框
  void _showGoalDialog(String type, int currentValue) {
    // TODO: 实现目标设置对话框
    _showSnackBar('目标设置功能即将上线');
  }

  /// 显示水平选择对话框
  void _showLevelDialog() {
    // TODO: 实现水平选择对话框
    _showSnackBar('水平设置功能即将上线');
  }

  /// 获取水平文本
  String _getLevelText(EnglishLevel level) {
    switch (level) {
      case EnglishLevel.beginner:
        return '初级';
      case EnglishLevel.elementary:
        return '基础';
      case EnglishLevel.intermediate:
        return '中级';
      case EnglishLevel.upperIntermediate:
        return '中高级';
      case EnglishLevel.advanced:
        return '高级';
      case EnglishLevel.proficient:
        return '精通';
      case EnglishLevel.expert:
        return '专家';
    }
  }

  /// 显示提示信息
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
    );
  }
}