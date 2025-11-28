

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/res/app_colors.dart';
import '../../../core/res/app_images.dart';

Widget BuildAppInfoSection() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SvgPicture.asset(
            AppImages.logo,
            height: 50,
          ),
        ),
        const SizedBox(height: 16),

        Text("More than a ride, it's MEGo",
          style: TextStyle(color: AppColors.primaryColor,
            fontSize: 19,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        )
      ],
    ),
  );
}