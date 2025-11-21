// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';

/// Modern Professional AppBar with clean design
PreferredSizeWidget CustomAppBar({
  double height = 84,
  bool isBack=false
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(height),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),

        color: AppColors.appBarColor,
      ),
      child: Stack(
        children: [
          // SVG Background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: SvgPicture.asset(
                AppImages.megoStyleImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button or Menu Button
              if (isBack)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Navigate back using GetX
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 40), // Placeholder for alignment

              // Logo/Title in center if needed
              const Spacer(),

              // Profile Button placeholder
              const SizedBox(width: 40), // Placeholder for alignment
            ],
          ),
        ),
      ),
        ],
      ),
    ),
  );
}