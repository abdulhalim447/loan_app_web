import 'package:flutter/material.dart';
import 'package:world_bank_loan/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isGradient;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? color;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isGradient = false,
    this.icon,
    this.width,
    this.height = 56,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine button colors
    final backgroundColor =
        color ?? (isOutlined ? Colors.transparent : AppTheme.authorityBlue);
    final foregroundColor =
        textColor ?? (isOutlined ? AppTheme.authorityBlue : Colors.white);

    // Create the button child
    Widget buttonChild = isLoading
        ? Shimmer.fromColors(
            baseColor: foregroundColor,
            highlightColor: foregroundColor.withOpacity(0.5),
            child: Text(
              'Please wait...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );

    // Create the button with appropriate styling
    if (isGradient) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.authorityBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: buttonChild,
        ),
      );
    } else if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            side: BorderSide(color: AppTheme.authorityBlue, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: buttonChild,
        ),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 2,
            shadowColor: backgroundColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: buttonChild,
        ),
      );
    }
  }
}
