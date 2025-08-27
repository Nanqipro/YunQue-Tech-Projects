import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

/// 重置密码页面
class ResetPasswordScreen extends StatefulWidget {
  final String token;
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _resetSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          '重置密码',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _resetSuccess ? _buildSuccessView() : _buildResetForm(),
      ),
    );
  }

  /// 构建重置密码表单
  Widget _buildResetForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和说明
            Text(
              '设置新密码',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              '为您的账户 ${widget.email} 设置一个新的安全密码',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),

            // 新密码输入框
            CustomTextField(
              controller: _passwordController,
              labelText: '新密码',
              hintText: '请输入新密码',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
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

            // 确认密码输入框
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: '确认新密码',
              hintText: '请再次输入新密码',
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
                if (value != _passwordController.text) {
                  return '两次输入的密码不一致';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // 密码强度提示
            _buildPasswordStrengthIndicator(),
            const SizedBox(height: AppDimensions.spacingXl),

            // 重置密码按钮
            CustomButton(
              text: '重置密码',
              onPressed: _handleResetPassword,
              isLoading: _isLoading,
              width: double.infinity,
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // 返回登录
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
                child: Text(
                  '返回登录',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建成功视图
  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 成功图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // 成功标题
          Text(
            '密码重置成功',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // 成功描述
          Text(
            '您的密码已成功重置，现在可以使用新密码登录您的账户了。',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // 前往登录按钮
          CustomButton(
            text: '前往登录',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  /// 构建密码强度指示器
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final strength = _calculatePasswordStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '密码强度',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        
        // 强度条
        Row(
          children: List.generate(4, (index) {
            Color color;
            if (index < strength) {
              switch (strength) {
                case 1:
                  color = AppColors.error;
                  break;
                case 2:
                  color = Colors.orange;
                  break;
                case 3:
                  color = Colors.yellow;
                  break;
                case 4:
                  color = AppColors.success;
                  break;
                default:
                  color = AppColors.surfaceVariant;
              }
            } else {
              color = AppColors.surfaceVariant;
            }
            
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? AppDimensions.spacingXs : 0,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        
        // 强度文本
        Text(
          _getStrengthText(strength),
          style: AppTextStyles.labelSmall.copyWith(
            color: _getStrengthColor(strength),
          ),
        ),
      ],
    );
  }

  /// 计算密码强度
  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    
    // 长度检查
    if (password.length >= 8) strength++;
    
    // 包含小写字母
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    
    // 包含大写字母
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    
    // 包含数字或特殊字符
    if (password.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }

  /// 获取强度文本
  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return '弱';
      case 2:
        return '一般';
      case 3:
        return '良好';
      case 4:
        return '强';
      default:
        return '';
    }
  }

  /// 获取强度颜色
  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return AppColors.success;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  /// 处理重置密码
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthNotifier>(context, listen: false);
      await authProvider.resetPassword(
        token: widget.token,
        newPassword: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _resetSuccess = true;
        });
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

  /// 显示提示信息
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}