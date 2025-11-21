import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mego_app/core/res/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const SocialButton({
    super.key,
    required this.text,
    required this.iconPath,
    this.width = 310,
    this.height = 62,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!, width: 1),
          backgroundColor: AppColors.socialMediaButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.socialMediaText,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}