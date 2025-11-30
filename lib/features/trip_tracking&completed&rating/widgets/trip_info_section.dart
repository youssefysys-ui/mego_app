import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_models/ride_model.dart';
import 'package:mego_app/core/shared_widgets/driver_info_card.dart';
import '../controllers/trip_tracking_controller.dart';
import '../../../core/shared_widgets/payment_card_widget.dart';
import '../views/trip_completion_view.dart';


class TripInfoSection extends StatelessWidget {
  final TripTrackingController controller;

  const TripInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:(){
        Get.to(TripCompletionView(ride: controller.rideModel,
        driverModel: controller.driverModel,
          fareAmount: controller.rideModel.totalPrice,
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top:3.0,right: 20,left: 20,bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top:6,left: 10,right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with brand colors
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          TextSpan(
                            text: 'Have a Nice Trip With ',
                            style: TextStyle(color: AppColors.primaryColor,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          TextSpan(
                            text: 'ME',
                            style: TextStyle(color: AppColors.primaryColor,
                              fontStyle:FontStyle.italic,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          TextSpan(
                            text: 'GO',
                            style: TextStyle(color: AppColors.buttonColor,
                              fontStyle:FontStyle.italic,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 9),

                    // Driver info card
                    DriverInfoCard(driverModel: controller.driverModel!),


                    const SizedBox(height: 16),

                    // Payment and price row
                    PaymentCardWidget(rideModel:controller.rideModel,
                    ),



                    const SizedBox(height: 16),

                    // Arrival time button with distance
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 33,right: 33,
                          top: 7,
                          bottom: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'you will arrive at ${controller.estimatedArrivalTime}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.remainingDistance,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}