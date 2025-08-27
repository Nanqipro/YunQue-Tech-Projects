import 'package:flutter/material.dart';

/// 错误显示组件
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;
  final Color? iconColor;
  final TextAlign textAlign;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryText,
    this.padding,
    this.showIcon = true,
    this.iconColor,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: iconColor ?? theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
          ],
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: textAlign,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: textAlign,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryText ?? '重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 页面错误组件
class PageErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final bool showAppBar;
  final String? appBarTitle;
  final VoidCallback? onBack;

  const PageErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.showAppBar = false,
    this.appBarTitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: appBarTitle != null ? Text(appBarTitle!) : null,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              leading: onBack != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: onBack,
                    )
                  : null,
            )
          : null,
      body: Center(
        child: ErrorDisplayWidget(
          title: title ?? '出错了',
          message: message,
          onRetry: onRetry,
        ),
      ),
    );
  }
}

/// 网络错误组件
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;
  final EdgeInsetsGeometry? padding;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: '网络连接失败',
      message: customMessage ?? '请检查网络连接后重试',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      padding: padding,
    );
  }
}

/// 空数据组件
class EmptyDataWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;

  const EmptyDataWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionText,
    this.padding,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: iconColor ?? theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText ?? '添加'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 搜索无结果组件
class NoSearchResultWidget extends StatelessWidget {
  final String query;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry? padding;

  const NoSearchResultWidget({
    super.key,
    required this.query,
    this.onClear,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyDataWidget(
      title: '未找到相关结果',
      message: '没有找到与"$query"相关的内容\n请尝试其他关键词',
      icon: Icons.search_off,
      onAction: onClear,
      actionText: '清除搜索',
      padding: padding,
    );
  }
}

/// 权限错误组件
class PermissionErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRequestPermission;
  final EdgeInsetsGeometry? padding;

  const PermissionErrorWidget({
    super.key,
    required this.message,
    this.onRequestPermission,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: '权限不足',
      message: message,
      icon: Icons.lock_outline,
      onRetry: onRequestPermission,
      retryText: '授权',
      padding: padding,
      iconColor: Theme.of(context).colorScheme.warning,
    );
  }
}

/// 服务器错误组件
class ServerErrorWidget extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? padding;

  const ServerErrorWidget({
    super.key,
    this.customMessage,
    this.onRetry,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: '服务器错误',
      message: customMessage ?? '服务器暂时无法响应，请稍后重试',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      padding: padding,
    );
  }
}

/// 通用错误处理器
class ErrorHandler {
  static Widget handleError(
    Object error, {
    VoidCallback? onRetry,
    EdgeInsetsGeometry? padding,
  }) {
    if (error.toString().contains('network') || 
        error.toString().contains('connection')) {
      return NetworkErrorWidget(
        onRetry: onRetry,
        padding: padding,
      );
    }
    
    if (error.toString().contains('permission')) {
      return PermissionErrorWidget(
        message: error.toString(),
        onRequestPermission: onRetry,
        padding: padding,
      );
    }
    
    if (error.toString().contains('server') || 
        error.toString().contains('500')) {
      return ServerErrorWidget(
        onRetry: onRetry,
        padding: padding,
      );
    }
    
    return ErrorDisplayWidget(
      message: error.toString(),
      onRetry: onRetry,
      padding: padding,
    );
  }
}

/// 错误边界组件
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;
  final void Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          ErrorHandler.handleError(_error!);
    }
    
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 重置错误状态
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    widget.onError?.call(error, stackTrace);
    if (mounted) {
      setState(() {
        _error = error;
      });
    }
  }
}

/// 扩展 ColorScheme 以支持警告颜色
extension ColorSchemeExtension on ColorScheme {
  Color get warning => const Color(0xFFFF9800);
  Color get onWarning => const Color(0xFF000000);
}