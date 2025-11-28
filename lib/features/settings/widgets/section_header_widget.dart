


 import 'package:flutter/material.dart';

import '../../../core/res/app_colors.dart';

class SectionHeaderWidget extends StatelessWidget {
 final String title ;
final  IconData icon ;
  const SectionHeaderWidget({super.key,required this.icon,required this.title});

  @override
  Widget build(BuildContext context) {
    return    Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style:  TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.txtColor,
            fontFamily: 'Roboto',
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
