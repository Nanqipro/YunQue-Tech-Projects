import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

/// 忘记密码页面
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  _emailSent ? '邮件已发送' : '忘记密码',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  _emailSent 
                      ? '我们已向您的邮箱发送了重置密码的链接，请查收邮件并按照说明操作。'
                      : '请输入您的邮箱地址，我们将向您发送重置密码的链接。',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                if (!_emailSent) ...[
                  // 邮箱输入框
                  CustomTextField(
                    controller: _emailController,
                    labelText: '邮箱',
                    hintText: '请输入您的邮箱地址',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入邮箱地址';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return '请输入有效的邮箱地址';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // 发送重置链接按钮
                  CustomButton(
                    text: '发送重置链接',
                    onPressed: _handleSendResetLink,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                ] else ...[
                  // 成功图标
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 60,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // 重新发送按钮
                  CustomButton(
                    text: '重新发送',
                    onPressed: _handleResendEmail,
                    isLoading: _isLoading,
                    width: double.infinity,
                    isOutlined: true,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),

                  // 返回登录按钮
                  CustomButton(
                    text: '返回登录',
                    onPressed: () => Navigator.of(context).pop(),
                    width: double.infinity,
                  ),
                ],
                
                const SizedBox(height: AppDimensions.spacingXl),

                // 帮助信息
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Text(
                            '温馨提示',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        '• 请检查您的垃圾邮件文件夹\n• 重置链接将在24小时后过期\n• 如果仍未收到邮件，请联系客服',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spacingXl),

                // 联系客服
                Center(
                  child: GestureDetector(
                    onTap: _handleContactSupport,
                    child: Text(
                      '联系客服',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 处理发送重置链接
  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthNotifier>(context, listen: false);
      await authProvider.forgotPassword(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _emailSent = true;
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

  /// 处理重新发送邮件
  Future<void> _handleResendEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthNotifier>(context, listen: false);
      await authProvider.forgotPassword(_emailController.text.trim());

      if (mounted) {
        _showSnackBar('重置链接已重新发送', isSuccess: true);
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

  /// 处理联系客服
  void _handleContactSupport() {
    // TODO: 实现联系客服功能
    _showSnackBar('客服功能即将上线');
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