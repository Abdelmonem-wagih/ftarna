import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern rating bar display
class RatingBar extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double size;
  final bool showReviewCount;
  final Color? activeColor;
  final Color? inactiveColor;
  final MainAxisAlignment alignment;

  const RatingBar({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.size = 16,
    this.showReviewCount = true,
    this.activeColor,
    this.inactiveColor,
    this.alignment = MainAxisAlignment.start,
  });

  const RatingBar.compact({
    super.key,
    required this.rating,
    this.totalReviews = 0,
  })  : size = 14,
        showReviewCount = false,
        activeColor = null,
        inactiveColor = null,
        alignment = MainAxisAlignment.start;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        Icon(
          Icons.star_rounded,
          color: activeColor ?? Colors.amber,
          size: size,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: size * 0.875,
            color: AppTheme.textPrimary,
          ),
        ),
        if (showReviewCount && totalReviews > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($totalReviews)',
            style: TextStyle(
              fontSize: size * 0.75,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Interactive rating bar for reviews
class InteractiveRatingBar extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double>? onRatingChanged;
  final double size;
  final int starCount;
  final bool allowHalfRating;
  final Color? activeColor;
  final Color? inactiveColor;

  const InteractiveRatingBar({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.size = 32,
    this.starCount = 5,
    this.allowHalfRating = true,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<InteractiveRatingBar> createState() => _InteractiveRatingBarState();
}

class _InteractiveRatingBarState extends State<InteractiveRatingBar> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        final starValue = index + 1;
        IconData icon;

        if (_rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (_rating >= starValue - 0.5 && widget.allowHalfRating) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = starValue.toDouble();
            });
            widget.onRatingChanged?.call(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              icon,
              color: _rating >= starValue - 0.5
                  ? (widget.activeColor ?? Colors.amber)
                  : (widget.inactiveColor ?? Colors.grey.shade300),
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}

/// Rating badge
class RatingBadge extends StatelessWidget {
  final double rating;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const RatingBadge({
    super.key,
    required this.rating,
    this.size = 14,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _getRatingColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: textColor ?? Colors.white,
            size: size,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: size * 0.875,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor() {
    if (rating >= 4.5) return AppTheme.successColor;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.0) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
