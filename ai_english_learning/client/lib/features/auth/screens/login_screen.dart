import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

/// 登录页面
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(authProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed(Routes.register);
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed(Routes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppDimensions.spacingXxl),
                
                // Logo和标题
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.school,
                        size: 60,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingLg),
                    Text(
                      'AI英语学习',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      '智能化英语学习平台',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppDimensions.spacingXxl),
                
                // 登录表单
                Text(
                  '登录',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: AppDimensions.spacingLg),
                
                // 邮箱输入框
                CustomTextField(
                  controller: _emailController,
                  labelText: '邮箱',
                  hintText: '请输入邮箱地址',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邮箱地址';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: AppDimensions.spacingMd),
                
                // 密码输入框
                CustomTextField(
                  controller: _passwordController,
                  labelText: '密码',
                  hintText: '请输入密码',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码长度不能少于6位';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: AppDimensions.spacingMd),
                
                // 记住我和忘记密码
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      '记住我',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: Text(
                        '忘记密码？',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppDimensions.spacingLg),
                
                // 登录按钮
                CustomButton(
                  text: '登录',
                  onPressed: isLoading ? null : _handleLogin,
                  isLoading: isLoading,
                ),
                
                SizedBox(height: AppDimensions.spacingLg),
                
                // 分割线
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.onSurface.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
                      child: Text(
                        '或',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppDimensions.spacingLg),
                
                // 第三方登录按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: 实现微信登录
                        },
                        icon: Icon(
                          Icons.wechat,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          '微信登录',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingMd,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: 实现QQ登录
                        },
                        icon: Icon(
                          Icons.account_circle,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'QQ登录',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingMd,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppDimensions.spacingXl),
                
                // 注册链接
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '还没有账号？',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: Text(
                        '立即注册',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}