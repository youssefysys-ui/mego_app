


 import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/res/app_colors.dart';
import '../../../core/res/app_images.dart';
import '../../customer_support/customer_chat.dart';
import '../settings_controller.dart';

class SupportCard extends StatelessWidget {
 final  SettingsController controller;
 final BuildContext context;
  const SupportCard({super.key,required this.controller,required this.context});

  @override
  Widget build(BuildContext context) {
  return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardColor.withOpacity(0.99),
            AppColors.backgroundColor.withOpacity(0.87),

          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.infoColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.infoColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(CustomerChatView());
          },

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    AppImages.customerSupportIcon,
                    width: 28,
                    height: 28,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Support',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.txtColor,
                          fontFamily: 'Roboto',
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chat with our support team',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.txtColor.withOpacity(0.6),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primaryColor,
                    size: 16,
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
