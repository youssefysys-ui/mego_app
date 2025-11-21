


 import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mego_app/core/res/app_images.dart';

import '../../../core/res/app_colors.dart';
import '../../../core/shared_models/user_ride_data.dart';
import '../confirm_ride_controller.dart';

class LocationCard extends StatelessWidget {
  final UserRideData userRideData;
  final ConfirmRideController controller;
  const LocationCard({super.key,required this.userRideData,required this.controller});

  @override
  Widget build(BuildContext context) {
    return   Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  SvgPicture.asset(AppImages.location, width: 16, height: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                    userRideData.placeFrom,
                      style: TextStyle(
                        color: AppColors.txtColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(width: 8),

                    Text(
                        controller.formatFare(userRideData.est_time),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,

                        )),
                  ],
                ),
              ),

              Row(
                children: [
                  SvgPicture.asset(AppImages.yellowLocation, width: 16, height: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                    userRideData.placeTo,
                      style: TextStyle(
                        color: AppColors.txtColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
