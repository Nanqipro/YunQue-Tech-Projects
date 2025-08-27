import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// 404页面 - 页面未找到
class NotFoundScreen extends StatelessWidget {
  final String? routeName;
  
  const NotFoundScreen({
    super.key,
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 404图标
              Icon(
                Icons.error_outline,
                size: AppDimensions.iconXxl * 2,
                color: AppColors.outline,
              ),
              
              SizedBox(height: AppDimensions.spacingXl),
              
              // 标题
              Text(
                '页面未找到',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppDimensions.spacingMd),
              
              // 描述
              Text(
                routeName != null 
                    ? '路由 "$routeName" 不存在'
                    : '您访问的页面不存在或已被移除',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppDimensions.spacingXxl),
              
              // 返回按钮
              ElevatedButton.icon(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXl,
                    vertical: AppDimensions.spacingMd,
                  ),
                ),
              ),
              
              SizedBox(height: AppDimensions.spacingMd),
              
              // 回到首页按钮
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                },
                child: Text(
                  '回到首页',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}