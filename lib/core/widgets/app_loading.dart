import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern loading indicator
class AppLoading extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppLoading({
    super.key,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
  });

  const AppLoading.small({super.key})
      : size = 24,
        strokeWidth = 2,
        color = null;

  const AppLoading.large({super.key})
      : size = 56,
        strokeWidth = 4,
        color = null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(
          color ?? AppTheme.primaryColor,
        ),
      ),
    );
  }
}

/// Full-screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? barrierColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: barrierColor ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLoading(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Page loading indicator centered
class PageLoading extends StatelessWidget {
  final String? message;

  const PageLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLoading(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline loading indicator
class InlineLoading extends StatelessWidget {
  final String message;
  final Color? color;

  const InlineLoading({
    super.key,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              color ?? AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          message,
          style: TextStyle(
            color: color ?? AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
