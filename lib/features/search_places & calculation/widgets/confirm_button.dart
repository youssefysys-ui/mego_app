
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/confirm_ride/confirm_ride_view.dart';
import 'package:mego_app/features/search_places%20&%20calculation/controllers/est_services_controller.dart';
import 'package:mego_app/features/search_places%20&%20calculation/controllers/search_places_controller.dart';
import '../../../core/local_db/local_db.dart';
import 'coupon_discount_widget.dart';

class ConfirmButton extends StatelessWidget {
  final SearchPlacesController controller;
  const ConfirmButton({super.key,required this.controller});

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<SearchPlacesController>(
        builder: (_) {
          // Show button only when both places are selected
          if (controller.selectedFromPlace != null && 
              controller.selectedToPlace != null) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      // Route Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // From location
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.my_location,
                                    color: AppColors.primaryColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'From',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        controller.selectedFromPlace!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Divider line
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              height: 1,
                              color: Colors.grey[200],
                            ),
                            
                            // To location
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'To',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        controller.selectedToPlace!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Coupon Discount Widget (only show if coupon is applied)
                      if (controller.appliedCoupon != null) ...[
                        GetBuilder<SearchPlacesController>(
                          builder: (_) {
                            if (controller.appliedCoupon != null &&
                                controller.selectedFromPlace != null &&
                                controller.selectedToPlace != null) {
                              // Calculate price with discount
                              final estServicesController = Get.find<EstServicesController>();
                              final priceInfo = estServicesController.calculatePriceWithDiscount(
                                controller.selectedFromPlace!.latitude,
                                controller.selectedFromPlace!.longitude,
                                controller.selectedToPlace!.latitude,
                                controller.selectedToPlace!.longitude,
                                controller.appliedCoupon,
                              );
                              
                              return CouponDiscountWidget(
                                originalPrice: priceInfo['originalPrice']!,
                                discount: priceInfo['discount']!,
                                finalPrice: priceInfo['finalPrice']!,
                                couponType: controller.appliedCoupon!.type,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ] else
                        const SizedBox(height: 4),
                      
                      // Confirm Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _confirmRide(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Confirm Ride',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
  }

   Future<void> _confirmRide() async {

     final userId = Storage.userId;
         //localStorage.userId;
    if (controller.selectedFromPlace == null || controller.selectedToPlace == null) {
      Get.snackbar(
        'Error',
        'Please select both pickup and destination locations',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {


      // PROCESS 2: Check if user data exists in local_db
      final userEmail = Storage.userEmail;
      print("User Email: $userEmail");


      //controller.getCurrentUserId();
      if (userEmail == null) {
        appMessageFail(text: 'Please login to continue', context: Get.context!);

        return;
      }

      // Calculate estimated time and price using EstServicesController
      final estServicesController = Get.find<EstServicesController>();
      
      // Calculate price with discount if coupon is applied
      final priceInfo = estServicesController.calculatePriceWithDiscount(
        controller.selectedFromPlace!.latitude,
        controller.selectedFromPlace!.longitude,
        controller.selectedToPlace!.latitude,
        controller.selectedToPlace!.longitude,
        controller.appliedCoupon, // Pass applied coupon
      );

      final estimatedTime = estServicesController.calculateEstimatedTime(
        controller.selectedFromPlace!.latitude,
        controller.selectedFromPlace!.longitude,
        controller.selectedToPlace!.latitude,
        controller.selectedToPlace!.longitude,
      );
      // Create UserRideData with calculated estimated price and time
      UserRideData userRideData = UserRideData(
        userId: userId.toString(),
        latFrom: controller.selectedFromPlace!.latitude,
        latTo: controller.selectedToPlace!.latitude,
        lngFrom: controller.selectedFromPlace!.longitude,
        lngTo: controller.selectedToPlace!.longitude,
        placeFrom: controller.selectedFromPlace!.name,
        placeTo: controller.selectedToPlace!.name,
        est_time: estimatedTime,
        est_price: priceInfo['finalPrice']!, // Use final price after discount
        rideRequestId: null, // Will be created when user confirms in ConfirmRideView
        couponId: controller.appliedCoupon?.id, // Pass coupon ID
        originalPrice: priceInfo['originalPrice'], // Original price before discount
        discountAmount: priceInfo['discount'], // Discount amount
      );

      // Navigate directly to confirm ride view 
      Get.to(() => ConfirmRideView(userRideData: userRideData),
        transition: Transition.cupertinoDialog,
        duration: const Duration(milliseconds: 500),
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}