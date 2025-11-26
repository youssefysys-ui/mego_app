
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/features/confirm_ride/widgets/location_card.dart';
import 'package:mego_app/features/confirm_ride/widgets/top_header.dart';
import 'package:mego_app/features/confirm_ride/widgets/bottomNav.dart';
import '../../core/shared_widgets/menu/side_bar_menu.dart';
import 'confirm_ride_controller.dart';

class ConfirmRideView extends StatefulWidget {
  final UserRideData userRideData;

  const ConfirmRideView({super.key, required this.userRideData});

  @override
  State<ConfirmRideView> createState() => _ConfirmRideViewState();
}

class _ConfirmRideViewState extends State<ConfirmRideView> {
  late ConfirmRideController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ConfirmRideController());
    controller.initializeRide(widget.userRideData);
  }

  @override
  void dispose() {
    Get.delete<ConfirmRideController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(
        controller: controller,
        userLocationData: widget.userRideData,
      ),
      drawer: const SideBarMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        toolbarHeight: 1,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Google Map taking full screen
          Obx(() => controller.initialCameraPosition.value != null
              ? GoogleMap(
                  onMapCreated: controller.onMapCreated,
                  initialCameraPosition: controller.initialCameraPosition.value!,
                  markers: controller.markers.toSet(),
                  polylines: controller.polylines.toSet(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                )
              : const Center(child: CircularProgressIndicator())),


         TopHeader(),

          LocationCard( controller: controller,
              userRideData: widget.userRideData),
        ],
      ),
    );
  }
}