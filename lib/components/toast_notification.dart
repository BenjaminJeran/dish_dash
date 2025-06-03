import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; 

enum ToastType { success, error, info }

class ToastNotification extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;

  const ToastNotification({
    super.key,
    required this.message,
    this.icon,
    this.backgroundColor = AppColors.leafGreen,
    this.textColor = AppColors.white, 
  });

  factory ToastNotification.success(String message) {
    return ToastNotification(
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: AppColors.leafGreen,
      textColor: AppColors.white,
    );
  }

  factory ToastNotification.error(String message) {
    return ToastNotification(
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red.shade700,
      textColor: AppColors.white,
    );
  }

  factory ToastNotification.info(String message) {
    return ToastNotification(
      message: message,
      icon: Icons.info_outline,
      backgroundColor: AppColors.dimGray,
      textColor: AppColors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, 
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
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
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 24),
                  const SizedBox(width: 10),
                ],
                Flexible( // Allow text to wrap if too long
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
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
    );
  }
}