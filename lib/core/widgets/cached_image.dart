import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern cached image widget with placeholder and error handling
class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppTheme.textSecondary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Restaurant logo image
class RestaurantLogo extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;

  const RestaurantLogo({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return AppCachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: borderRadius,
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          Icons.restaurant,
          color: AppTheme.primaryColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}

/// Product image
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double height;
  final double borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height = 120,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return AppCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius,
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.dividerColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Icon(
          Icons.fastfood_outlined,
          color: AppTheme.textSecondary,
          size: 40,
        ),
      ),
    );
  }
}

/// Cover image with gradient overlay
class CoverImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final Widget? child;
  final List<Color>? gradientColors;

  const CoverImage({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.child,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppCachedImage(
            imageUrl: imageUrl,
            height: height,
            fit: BoxFit.cover,
            errorWidget: Container(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: const Center(
                child: Icon(
                  Icons.restaurant,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors ??
                    [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Avatar image
class AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? name;
  final Color? backgroundColor;

  const AvatarImage({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.name,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: AppCachedImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
        ),
      );
    }

    final initials = name != null
        ? name!.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join()
        : '';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              )
            : Icon(
                Icons.person,
                color: AppTheme.primaryColor,
                size: size * 0.5,
              ),
      ),
    );
  }
}
