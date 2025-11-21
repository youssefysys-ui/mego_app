

import 'package:flutter/material.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_models/ride_model.dart';
import 'package:mego_app/features/ride_accept_track/controllers/rider_accept_track_controller.dart';

class BuildStatusHeader extends StatelessWidget {
  final RiderAcceptTrackController controller;
  const BuildStatusHeader({super.key,required this.controller});

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<RideModel?>(
      stream: controller.rideStream,
      builder: (context, snapshot) {
        final ride = snapshot.data ?? controller.currentRide;
        
        String statusText = 'Your driver is coming';
        Color statusColor = const Color(0xFF8B1538); // Burgundy color matching screenshot
        
        if (ride != null) {
          if (ride.isInProgress) {
            statusText = 'Your driver is coming';
            statusColor = const Color(0xFF8B1538); // Burgundy
          } else if (ride.isCompleted) {
            statusText = 'Ride completed';
            statusColor = Colors.green;
          } else if (ride.isStarted) {
            statusText = 'Your driver is coming';
            statusColor = AppColors.buttonColor; // Burgundy
          }
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: statusColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Text(
            statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        );
      },
    );
  }
}