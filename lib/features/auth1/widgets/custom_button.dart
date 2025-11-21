import 'package:flutter/material.dart';
import 'package:mego_app/core/res/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Widget? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 12,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textColor ?? AppColors.primaryColor,
                        ),
                      ),
                    )
                  : (icon ?? const SizedBox.shrink()),
              label: Text(
                isLoading ? 'Loading...' : text,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor ?? AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: backgroundColor ?? Colors.transparent,
                side: BorderSide(
                  color: textColor ?? AppColors.primaryColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
              ),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textColor ?? AppColors.whiteColor,
                        ),
                      ),
                    )
                  : (icon ?? const SizedBox.shrink()),
              label: Text(
                isLoading ? 'Loading...' : text,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor ?? AppColors.whiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppColors.buttonColor,
                foregroundColor: textColor ?? AppColors.whiteColor,
                elevation: 2,
                shadowColor: AppColors.primaryColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
    );
  }
}