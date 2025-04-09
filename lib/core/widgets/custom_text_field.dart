import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:world_bank_loan/core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final String? helperText;
  final bool showLabel;
  final bool isDense;
  final Color? fillColor;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.inputFormatters,
    this.contentPadding,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.helperText,
    this.showLabel = true,
    this.isDense = false,
    this.fillColor,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = isDense
        ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.neutral700,
                ),
          ),
          SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            filled: true,
            fillColor: fillColor ?? Colors.white,
            errorMaxLines: 2,
            isDense: isDense,
            contentPadding: contentPadding ?? defaultPadding,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.authorityBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.error, width: 1.5),
            ),
            helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.neutral600,
                ),
            errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.error,
                ),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.neutral500,
                ),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textDark,
              ),
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          autofocus: autofocus,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          textCapitalization: textCapitalization,
        ),
      ],
    );
  }
}
