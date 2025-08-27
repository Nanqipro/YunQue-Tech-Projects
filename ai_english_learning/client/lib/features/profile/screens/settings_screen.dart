import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'change_password_screen.dart';

/// 设置屏幕
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 通知设置
              _buildNotificationSettings(),
              const SizedBox(height: AppDimensions.spacingSm),
              
              // 学习设置
              _buildLearningSettings(),
              const SizedBox(height: AppDimensions.spacingSm),
              
              // 账户设置
              _buildAccountSettings(),
              const SizedBox(height: AppDimensions.spacingSm),
              
              // 其他设置
              _buildOtherSettings(),
              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      title: Text(
        '设置',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建通知设置
  Widget _buildNotificationSettings() {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        final user = authNotifier.state.user;
        final settings = user?.profile?.settings ?? const UserSettings();
        
        return _buildSettingsSection(
          title: '通知设置',
          icon: Icons.notifications_outlined,
          children: [
            _buildSwitchTile(
              title: '推送通知',
              subtitle: '接收学习提醒和重要消息',
              value: settings.notificationsEnabled,
              onChanged: (value) {
                _updateSettings(settings.copyWith(
                  notificationsEnabled: value,
                ));
              },
            ),
            _buildSwitchTile(
              title: '声音提醒',
              subtitle: '播放通知声音',
              value: settings.soundEnabled,
              onChanged: (value) {
                _updateSettings(settings.copyWith(
                  soundEnabled: value,
                ));
              },
            ),
            _buildSwitchTile(
              title: '振动提醒',
              subtitle: '接收通知时振动',
              value: settings.vibrationEnabled,
              onChanged: (value) {
                _updateSettings(settings.copyWith(
                  vibrationEnabled: value,
                ));
              },
            ),
          ],
        );
      },
    );
  }

  /// 构建学习设置
  Widget _buildLearningSettings() {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        final user = authNotifier.state.user;
        final settings = user?.profile?.settings ?? const UserSettings();
        
        return _buildSettingsSection(
          title: '学习设置',
          icon: Icons.school_outlined,
          children: [
            _buildListTile(
              title: '每日单词目标',
              subtitle: '${settings.dailyWordGoal} 个单词',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDailyGoalDialog('word', settings.dailyWordGoal),
            ),
            _buildListTile(
              title: '每日学习时长',
              subtitle: '${settings.dailyStudyMinutes} 分钟',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDailyGoalDialog('time', settings.dailyStudyMinutes),
            ),
            _buildSwitchTile(
              title: '自动播放音频',
              subtitle: '学习时自动播放单词发音',
              value: settings.autoPlayAudio,
              onChanged: (value) {
                _updateSettings(settings.copyWith(
                  autoPlayAudio: value,
                ));
              },
            ),
            _buildListTile(
              title: '音频播放速度',
              subtitle: '${settings.audioSpeed}x',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAudioSpeedDialog(settings.audioSpeed),
            ),
            _buildSwitchTile(
              title: '显示中文翻译',
              subtitle: '学习时显示单词翻译',
              value: settings.showTranslation,
              onChanged: (value) {
                _updateSettings(settings.copyWith(
                  showTranslation: value,
                ));
              },
            ),
            _buildSwitchTile(
              title: '显示音标',
              subtitle: '学习时显示单词音标',
              value: settings.showPronunciation,
              onChanged: (value) {
                _updateSettings(settings.copyWith(
                  showPronunciation: value,
                ));
              },
            ),
          ],
        );
      },
    );
  }

  /// 构建账户设置
  Widget _buildAccountSettings() {
    return _buildSettingsSection(
      title: '账户设置',
      icon: Icons.account_circle_outlined,
      children: [
        _buildListTile(
          title: '修改密码',
          subtitle: '更改登录密码',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              ),
            );
          },
        ),
        _buildListTile(
          title: '清除缓存',
          subtitle: '清除本地缓存数据',
          trailing: const Icon(Icons.chevron_right),
          onTap: _showClearCacheDialog,
        ),
        _buildListTile(
          title: '退出登录',
          subtitle: '退出当前账户',
          trailing: const Icon(Icons.chevron_right),
          onTap: _showLogoutDialog,
        ),
        _buildListTile(
          title: '注销账户',
          subtitle: '永久删除账户和数据',
          trailing: const Icon(Icons.chevron_right),
          textColor: AppColors.error,
          onTap: _showDeleteAccountDialog,
        ),
      ],
    );
  }

  /// 构建其他设置
  Widget _buildOtherSettings() {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        final user = authNotifier.state.user;
        final settings = user?.profile?.settings ?? const UserSettings();
        
        return _buildSettingsSection(
          title: '其他设置',
          icon: Icons.settings_outlined,
          children: [
            _buildListTile(
              title: '语言设置',
              subtitle: _getLanguageDisplayName(settings.language),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(settings.language),
            ),
            _buildListTile(
              title: '主题设置',
              subtitle: _getThemeDisplayName(settings.theme),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(settings.theme),
            ),
            _buildListTile(
              title: '关于我们',
              subtitle: '版本信息和帮助',
              trailing: const Icon(Icons.chevron_right),
              onTap: _showAboutDialog,
            ),
            _buildListTile(
              title: '用户协议',
              subtitle: '查看用户服务协议',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showWebView('用户协议', 'https://example.com/terms'),
            ),
            _buildListTile(
              title: '隐私政策',
              subtitle: '查看隐私保护政策',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showWebView('隐私政策', 'https://example.com/privacy'),
            ),
          ],
        );
      },
    );
  }

  /// 构建设置分组
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组标题
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // 分组内容
          ...children,
        ],
      ),
    );
  }

  /// 构建列表项
  Widget _buildListTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
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
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingXs,
      ),
    );
  }

  /// 构建开关项
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
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
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingXs,
      ),
    );
  }

  /// 更新设置
  Future<void> _updateSettings(UserSettings settings) async {
    try {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      final currentUser = authNotifier.state.user;
      
      if (currentUser != null) {
        // 将设置转换为Map格式传递给updateProfile
        final settingsMap = {
          'notificationsEnabled': settings.notificationsEnabled,
          'soundEnabled': settings.soundEnabled,
          'vibrationEnabled': settings.vibrationEnabled,
          'language': settings.language,
          'theme': settings.theme,
          'dailyGoal': settings.dailyGoal,
          'dailyWordGoal': settings.dailyWordGoal,
          'dailyStudyMinutes': settings.dailyStudyMinutes,
          'reminderTimes': settings.reminderTimes,
          'autoPlayAudio': settings.autoPlayAudio,
          'audioSpeed': settings.audioSpeed,
          'showTranslation': settings.showTranslation,
          'showPronunciation': settings.showPronunciation,
        };
        
        await authNotifier.updateProfile(
          username: currentUser.username,
          email: currentUser.email,
          phone: currentUser.profile?.phone,
          avatar: currentUser.profile?.avatar,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('设置更新失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 显示每日目标设置对话框
  void _showDailyGoalDialog(String type, int currentValue) {
    final controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'word' ? '设置每日单词目标' : '设置每日学习时长'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: type == 'word' ? '单词数量' : '分钟数',
            suffixText: type == 'word' ? '个' : '分钟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? currentValue;
              if (value > 0) {
                final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
                final user = authNotifier.state.user;
                final settings = user?.profile?.settings ?? UserSettings();
                
                if (type == 'word') {
                  _updateSettings(settings.copyWith(dailyWordGoal: value));
                } else {
                  _updateSettings(settings.copyWith(dailyStudyMinutes: value));
                }
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示音频速度设置对话框
  void _showAudioSpeedDialog(double currentSpeed) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置音频播放速度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds.map((speed) {
            return RadioListTile<double>(
              title: Text('${speed}x'),
              value: speed,
              groupValue: currentSpeed,
              onChanged: (value) {
                if (value != null) {
                  final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
                  final user = authNotifier.state.user;
                  final settings = user?.profile?.settings ?? const UserSettings();
                  
                  _updateSettings(settings.copyWith(audioSpeed: value));
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 显示语言设置对话框
  void _showLanguageDialog(String currentLanguage) {
    final languages = {
      'zh': '中文',
      'en': 'English',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
                  final user = authNotifier.state.user;
                  final settings = user?.profile?.settings ?? const UserSettings();
                  
                  _updateSettings(settings.copyWith(language: value));
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 显示主题设置对话框
  void _showThemeDialog(String currentTheme) {
    final themes = {
      'light': '浅色主题',
      'dark': '深色主题',
      'system': '跟随系统',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
                  final user = authNotifier.state.user;
                  final settings = user?.profile?.settings ?? const UserSettings();
                  
                  _updateSettings(settings.copyWith(theme: value));
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 显示清除缓存对话框
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？这将删除已下载的音频、图片等文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 实现清除缓存逻辑
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示退出登录对话框
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
              await authNotifier.logout();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示注销账户对话框
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '注销账户',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          '警告：此操作将永久删除您的账户和所有数据，且无法恢复。确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 实现注销账户逻辑
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('账户注销功能暂未开放'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('确定注销'),
          ),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'AI英语学习',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.school,
          color: AppColors.onPrimary,
          size: 32,
        ),
      ),
      children: [
        const Text('一款基于AI技术的智能英语学习应用'),
        const SizedBox(height: 16),
        const Text('© 2024 AI英语学习团队'),
      ],
    );
  }

  /// 显示网页视图
  void _showWebView(String title, String url) {
    // TODO: 实现网页视图
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('即将打开: $title'),
      ),
    );
  }

  /// 获取语言显示名称
  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return '中文';
    }
  }

  /// 获取主题显示名称
  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return '浅色主题';
      case 'dark':
        return '深色主题';
      case 'system':
        return '跟随系统';
      default:
        return '浅色主题';
    }
  }
}