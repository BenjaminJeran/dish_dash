import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class AnimatedToastNotification extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;

  const AnimatedToastNotification({
    super.key,
    required this.message,
    this.icon,
    this.backgroundColor = AppColors.leafGreen,
    this.textColor = AppColors.white,
    this.duration = const Duration(seconds: 3),
  });

  factory AnimatedToastNotification.success(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return AnimatedToastNotification(
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: AppColors.leafGreen,
      textColor: AppColors.white,
      duration: duration,
    );
  }

  factory AnimatedToastNotification.error(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return AnimatedToastNotification(
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red.shade700,
      textColor: AppColors.white,
      duration: duration,
    );
  }

  factory AnimatedToastNotification.info(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return AnimatedToastNotification(
      message: message,
      icon: Icons.info_outline,
      backgroundColor: AppColors.dimGray,
      textColor: AppColors.white,
      duration: duration,
    );
  }

  @override
  State<AnimatedToastNotification> createState() =>
      _AnimatedToastNotificationState();
}

class _AnimatedToastNotificationState extends State<AnimatedToastNotification>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade in
    Future.delayed(Duration.zero, () {
      setState(() => _opacity = 1.0);
    });

    // Fade out before removal
    Future.delayed(widget.duration - const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _opacity = 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 500),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.textColor, size: 24),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
