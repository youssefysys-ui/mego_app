import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/features/trip_tracking&completed&rating/controllers/trip_tracking_controller.dart';
import 'package:mego_app/features/trip_tracking&completed&rating/widgets/map_section.dart';
import 'package:mego_app/features/trip_tracking&completed&rating/widgets/trip_info_section.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/shared_models/ride_model.dart';

class TripTrackingView extends StatelessWidget {
  final UserRideData userRideData;
  final DriverModel? driverModel;
  final RideModel ride;

  const TripTrackingView({
    Key? key,
    required this.userRideData,
    required this.ride,
    this.driverModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {


    // Initialize controller with ride data
    Get.put(TripTrackingController(
      userRideData: userRideData,
      driverModel: driverModel,
      rideModel: ride
    ));

    return GetBuilder<TripTrackingController>(
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(height: 83),
        body: Stack(
          children: [
            // Full screen map
            MapSectionWidget(controller: controller),

            // Top left menu button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    print("RIDE DATA: ${ride.toJson()}");
                  },
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),

            // Bottom trip info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: TripInfoSection(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}