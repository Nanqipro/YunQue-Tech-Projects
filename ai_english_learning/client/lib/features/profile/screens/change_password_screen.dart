import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';

/// 修改密码屏幕
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和说明
                _buildHeader(),
                const SizedBox(height: AppDimensions.spacingXl),
                
                // 密码输入表单
                _buildPasswordForm(),
                const SizedBox(height: AppDimensions.spacingXl),
                
                // 密码强度提示
                _buildPasswordStrengthTips(),
                const SizedBox(height: AppDimensions.spacingXl),
                
                // 提交按钮
                _buildSubmitButton(),
              ],
            ),
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
        '修改密码',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '安全提示',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    
                    Text(
                      '为了您的账户安全，建议定期更换密码，并使用包含字母、数字和特殊字符的强密码。',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建密码表单
  Widget _buildPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
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
        children: [
          // 当前密码
          CustomTextField(
            controller: _currentPasswordController,
            labelText: '当前密码',
            hintText: '请输入当前密码',
            obscureText: _obscureCurrentPassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
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
            hintText: '请输入新密码',
            obscureText: _obscureNewPassword,
            prefixIcon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
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
                return '密码长度至少8位';
              }
              if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                return '密码必须包含字母和数字';
              }
              if (value == _currentPasswordController.text) {
                return '新密码不能与当前密码相同';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // 触发密码强度更新
            },
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 确认新密码
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: '确认新密码',
            hintText: '请再次输入新密码',
            obscureText: _obscureConfirmPassword,
            prefixIcon: Icons.lock_clock,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
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
          
          // 密码强度指示器
          if (_newPasswordController.text.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            _buildPasswordStrengthIndicator(),
          ],
        ],
      ),
    );
  }

  /// 构建密码强度指示器
  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    final strength = _calculatePasswordStrength(password);
    
    Color strengthColor;
    String strengthText;
    
    switch (strength) {
      case 0:
      case 1:
        strengthColor = AppColors.error;
        strengthText = '弱';
        break;
      case 2:
        strengthColor = AppColors.warning;
        strengthText = '中';
        break;
      case 3:
      case 4:
        strengthColor = AppColors.success;
        strengthText = '强';
        break;
      default:
        strengthColor = AppColors.onSurfaceVariant;
        strengthText = '未知';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '密码强度',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              strengthText,
              style: AppTextStyles.bodySmall.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        
        // 强度条
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? AppDimensions.spacingXs : 0,
                ),
                decoration: BoxDecoration(
                  color: index < strength
                      ? strengthColor
                      : AppColors.onSurfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 构建密码强度提示
  Widget _buildPasswordStrengthTips() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.onSurfaceVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '密码要求',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          
          ..._getPasswordRequirements().map((requirement) {
            final isValid = _checkPasswordRequirement(
              _newPasswordController.text,
              requirement['type'],
            );
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
              child: Row(
                children: [
                  Icon(
                    isValid ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isValid ? AppColors.success : AppColors.onSurfaceVariant,
                    size: 16,
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  
                  Expanded(
                    child: Text(
                      requirement['text'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isValid ? AppColors.success : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton() {
    return CustomButton(
      text: '修改密码',
      onPressed: _isLoading ? null : _changePassword,
      isLoading: _isLoading,
      width: double.infinity,
    );
  }

  /// 计算密码强度
  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    
    // 长度检查
    if (password.length >= 8) strength++;
    
    // 包含小写字母
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    
    // 包含大写字母或数字
    if (RegExp(r'[A-Z0-9]').hasMatch(password)) strength++;
    
    // 包含特殊字符
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    return strength;
  }

  /// 获取密码要求列表
  List<Map<String, dynamic>> _getPasswordRequirements() {
    return [
      {'type': 'length', 'text': '至少8个字符'},
      {'type': 'letter', 'text': '包含字母'},
      {'type': 'number', 'text': '包含数字'},
      {'type': 'special', 'text': '包含特殊字符（推荐）'},
    ];
  }

  /// 检查密码要求
  bool _checkPasswordRequirement(String password, String type) {
    switch (type) {
      case 'length':
        return password.length >= 8;
      case 'letter':
        return RegExp(r'[a-zA-Z]').hasMatch(password);
      case 'number':
        return RegExp(r'\d').hasMatch(password);
      case 'special':
        return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      default:
        return false;
    }
  }

  /// 修改密码
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthNotifier>(context, listen: false);
      
      await authProvider.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('密码修改成功'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('密码修改失败: $e'),
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
}