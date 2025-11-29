import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_models/ride_model.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/shared_widgets/driver_info_card.dart';
import 'package:mego_app/core/shared_widgets/payment_card_widget.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/ride_accept_track/controllers/rider_accept_track_controller.dart';

class BuildDriverInfoCard extends StatelessWidget {
  final RiderAcceptTrackController controller;
  final UserRideData userRideData;
  final DriverModel driverModel;

  const BuildDriverInfoCard({
    super.key,
    required this.controller,
    required this.userRideData,
    required this.driverModel,
  });

  /// Get driver rating text
  String _getDriverRatingText() {
    if (driverModel.rate != null) {
      final reviewsCount = _calculateReviewsCount(driverModel.rate!);
      return '${driverModel.rate!.toStringAsFixed(1)} ($reviewsCount reviews)';
    }
    return '4.5 (120 reviews)';
  }

  /// Calculate reviews count based on rating
  int _calculateReviewsCount(double rating) {
    final random = Random();
    final baseReviews = (rating * 100).toInt();
    return baseReviews + random.nextInt(100);
  }

  /// Get driver profile image
  String _getDriverProfileImage() {
    return driverModel.profileImage ?? 'https://png.pngtree.com/png-clipart/20230927/original/pngtree-man-avatar-image-for-profile-png-image_13001877.png';
    //'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D&fm=jpg&q=60&w=3000';
    //'https://i.pravatar.cc/150?u=default';
  }

  /// Get car plate number
  String _getPlateNumber() {
    return driverModel.carInfo?['plate_number'] ?? 'N/A';
  }

  /// Get estimated time text
  String _getEstimatedTimeText() {
    if (controller.estimatedArrival.isEmpty) {
      return '800m (5mins away)';
    }
    return '${controller.estimatedArrival}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RideModel?>(
      stream: controller.rideStream,
      builder: (context, snapshot) {
        final ride = snapshot.data ?? controller.currentRide;
        if (ride == null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Header
                _buildStatusHeader(ride),

                const SizedBox(height: 16),

                // Driver Info Container
                DriverInfoCard(driverModel: driverModel),
               // _buildDriverInfoContainer(),

                const SizedBox(height: 12),

                // Payment Info
               // _buildPaymentInfo(ride),
                PaymentCardWidget(rideModel:ride),

                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(),

                // Test Mode Controls (if active)
                if (controller.isSimulating) ...[
                  const SizedBox(height: 16),
                  _buildTestModeControls(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build status header with countdown
  Widget _buildStatusHeader(RideModel ride) {
    String statusText = controller.driverStatusMessage;

    return Text(
      statusText,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
        color: AppColors.primaryColor,
        height: 1.2,
      ),
    );
  }







  /// Build action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Call Button
        Expanded(
          child: ElevatedButton(
            onPressed: (){
              appMessageSuccess(text: 'call driver available soon ', context: Get.context!);
            },
            //controller.callDriver,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: AppColors.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Call',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // OR Text
        Text(
          'OR',
          style: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Roboto',
          ),
        ),

        const SizedBox(width: 12),

        // Message Button
        Expanded(
          child: ElevatedButton(
            onPressed: (){
              appMessageSuccess(text: 'chat available soon ', context: Get.context!);
            },
            //controller.messageDriver,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: AppColors.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build test mode controls
  Widget _buildTestModeControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.buttonColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Test Mode Header
          Row(
            children: [
              Icon(
                Icons.science_outlined,
                color: AppColors.buttonColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Test Mode Active',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Start Trip Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.startTripMode,
              icon: const Icon(Icons.navigation, size: 18),
              label: const Text(
                'START TRIP NOW',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // // Stop Simulation Button
          // SizedBox(
          //   width: double.infinity,
          //   child: OutlinedButton(
          //     onPressed: controller.stopSimulation,
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: AppColors.buttonColor,
          //       side: const BorderSide(
          //         color: AppColors.buttonColor,
          //         width: 1.5,
          //       ),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       padding: const EdgeInsets.symmetric(vertical: 12),
          //     ),
          //     child: const Text(
          //       'Stop Simulation',
          //       style: TextStyle(
          //         fontWeight: FontWeight.w600,
          //         fontSize: 14,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}