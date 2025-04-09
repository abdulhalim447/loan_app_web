import 'package:flutter/material.dart';
import 'package:world_bank_loan/core/theme/app_theme.dart';

class DataCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final IconData icon;
  final bool isGradient;
  final bool hasGlow;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? trailing;
  final String? subtitle;

  const DataCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isGradient = false,
    this.hasGlow = false,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cardBackground = isGradient
        ? null // Will use gradient decoration instead
        : backgroundColor ?? Colors.white;

    final textColor =
        foregroundColor ?? (isGradient ? Colors.white : AppTheme.textDark);

    final cardDecoration = isGradient
        ? BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: AppTheme.authorityBlue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ],
          )
        : BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: cardDecoration,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isGradient
                        ? Colors.white.withOpacity(0.2)
                        : AppTheme.authorityBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isGradient ? Colors.white : AppTheme.authorityBlue,
                    size: 24,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor.withOpacity(0.8),
                  ),
            ),
            SizedBox(height: 8),
            value is Widget
                ? value
                : Text(
                    value.toString(),
                    style: AppTheme.financialTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
            if (subtitle != null) ...[
              SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacity(0.7),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SmallDataCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const SmallDataCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
    this.titleStyle,
    this.valueStyle,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppTheme.neutral200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: padding ?? EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize ?? 28,
                color: AppTheme.authorityBlue,
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: titleStyle ??
                    Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neutral600,
                        ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
