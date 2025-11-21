

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/res/app_colors.dart';
import '../../../core/res/app_images.dart';

class PromotionalMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppImages.logo,
            height: 80,
            width: 80,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have a Nice Day!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Thank you for riding with us',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}