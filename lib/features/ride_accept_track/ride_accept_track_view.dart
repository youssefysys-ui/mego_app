import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/core/shared_widgets/driver_info_card.dart';
import 'package:mego_app/core/shared_widgets/payment_card_widget.dart';
import 'package:mego_app/features/ride_accept_track/widgets/build_driver_info_card.dart';
import 'package:mego_app/features/ride_accept_track/widgets/build_map_area.dart';
import '../../core/shared_models/user_ride_data.dart';
import '../../core/shared_models/driver_model.dart';
import 'controllers/rider_accept_track_controller.dart' show RiderAcceptTrackController;

class RideAcceptTrackView extends StatelessWidget {
  final String rideId;
  final UserRideData userRideData;
  final DriverModel driverModel;
  const RideAcceptTrackView({
    Key? key,
    required this.rideId,
    required this.userRideData,
    required this.driverModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller with ride ID, driver data, and user ride data
    RiderAcceptTrackController controller = Get.put(RiderAcceptTrackController(
      rideId: rideId,
      driverModel: driverModel,
      userRideData: userRideData,
    ));
    
    return GetBuilder<RiderAcceptTrackController>(
      builder: (_) => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar:CustomAppBar(height: 80),
        body: SafeArea(
          child: Column(
            children: [
              // Map Area
              Expanded(
                child: BuildMapArea(controller: controller, driverModel: driverModel),
              ),
              Padding(
                padding: const EdgeInsets.only(left:12.0,right:12),
                child: Column(
                  children: [
                    BuildDriverInfoCard(
                      controller: controller,
                      userRideData: userRideData,
                      driverModel: driverModel,
                    ),

                  ],
                ),


              ),
              // Driver Info and Actions

            ],
          ),
        ),
      ),
    );
  }


}
