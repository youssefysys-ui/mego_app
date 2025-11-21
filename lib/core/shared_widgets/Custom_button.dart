import 'package:flutter/material.dart';
import 'package:mego_app/core/res/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.width = 200,
    this.height = 62,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 21,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
            
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
