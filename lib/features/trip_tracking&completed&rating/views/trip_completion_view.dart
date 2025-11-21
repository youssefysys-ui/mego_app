import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/shared_models/models.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/core/shared_widgets/Custom_button.dart';
import 'package:mego_app/core/shared_widgets/driver_info_card.dart';
import 'package:mego_app/core/shared_widgets/payment_card_widget.dart';

import '../trip_comp_widgets/promotional_widget.dart';
import '../trip_comp_widgets/title_section.dart';
import 'rate_driver_view.dart';

class TripCompletionView extends StatefulWidget {
  final RideModel ride;
  final DriverModel? driverModel;
  final double fareAmount;

  const TripCompletionView({
    Key? key,
    required this.ride,
    this.driverModel,
    required this.fareAmount,
  }) : super(key: key);

  @override
  State<TripCompletionView> createState() => _TripCompletionViewState();
}

class _TripCompletionViewState extends State<TripCompletionView> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isBack: false, height: 110),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            TitleSection(fareAmount: widget.ride.totalPrice ?? 0.0),
            const SizedBox(height: 24),
            DriverInfoCard(driverModel: widget.driverModel!),
            const SizedBox(height: 20),
            PaymentCardWidget(rideModel: widget.ride),
            const SizedBox(height: 28),
            PromotionalMessage(),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 28.0,right: 28),
              child: CustomButton(
                text: 'Rate Driver',
                onPressed: () {
                  // Get.to(RateDriverView(driverModel:widget.driverModel!
                  //     , rideId: widget.ride.id));
                  if (widget.driverModel != null) {
                    showDialog(
                      context: context,
                      builder: (context) => RateDriverView(
                        driverModel: widget.driverModel!,
                        rideId: widget.ride.id,
                      ),
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Driver information not available',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


}

// ==================== WIDGETS ====================




