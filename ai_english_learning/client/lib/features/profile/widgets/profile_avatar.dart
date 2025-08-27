import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

/// 个人资料头像组件
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? selectedImage;
  final double size;
  final bool isEditing;
  final VoidCallback? onImageSelected;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.selectedImage,
    this.size = 80,
    this.isEditing = false,
    this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 头像
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarImage(),
          ),
        ),
        
        // 编辑按钮
        if (isEditing)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onImageSelected,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
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
                  color: AppColors.onPrimary,
                  size: size * 0.15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建头像图片
  Widget _buildAvatarImage() {
    // 优先显示选中的图片
    if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }
    
    // 显示网络图片
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        },
      );
    }
    
    // 默认头像
    return _buildDefaultAvatar();
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        color: AppColors.onPrimary,
        size: size * 0.5,
      ),
    );
  }
}