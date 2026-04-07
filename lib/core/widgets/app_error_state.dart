import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Modern error state widget
class AppErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final String? errorCode;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onRetry;
  final double iconSize;

  const AppErrorState({
    super.key,
    required this.title,
    this.description,
    this.errorCode,
    this.icon = Icons.error_outline,
    this.actionText,
    this.onRetry,
    this.iconSize = 80,
  });

  /// General error state
  const AppErrorState.general({
    super.key,
    this.title = 'Something went wrong',
    this.description = 'Please try again later',
    this.errorCode,
    this.actionText = 'Try Again',
    this.onRetry,
  })  : icon = Icons.error_outline,
        iconSize = 80;

  /// Network error state
  const AppErrorState.network({
    super.key,
    this.title = 'No internet connection',
    this.description = 'Please check your connection and try again',
    this.errorCode,
    this.actionText = 'Try Again',
    this.onRetry,
  })  : icon = Icons.wifi_off,
        iconSize = 80;

  /// Server error state
  const AppErrorState.server({
    super.key,
    this.title = 'Server error',
    this.description = 'Our servers are having issues. Please try again later',
    this.errorCode,
    this.actionText = 'Try Again',
    this.onRetry,
  })  : icon = Icons.cloud_off,
        iconSize = 80;

  /// Not found error state
  const AppErrorState.notFound({
    super.key,
    this.title = 'Not found',
    this.description = 'The content you\'re looking for doesn\'t exist',
    this.errorCode,
    this.actionText = 'Go Back',
    this.onRetry,
  })  : icon = Icons.search_off,
        iconSize = 80;

  /// Permission denied error state
  const AppErrorState.permissionDenied({
    super.key,
    this.title = 'Permission denied',
    this.description = 'You don\'t have access to this content',
    this.errorCode,
    this.actionText,
    this.onRetry,
  })  : icon = Icons.lock_outline,
        iconSize = 80;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (errorCode != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Error: $errorCode',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          if (actionText != null && onRetry != null) ...[
            const SizedBox(height: 24),
            AppButton.primary(
              text: actionText!,
              onPressed: onRetry,
              leadingIcon: Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline error widget for smaller error displays
class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
