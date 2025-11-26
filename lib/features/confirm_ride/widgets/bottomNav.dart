import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import '../../coupons/coupons_controller.dart';
import '../../coupons/coupons_view.dart';
import '../../search_places & calculation/controllers/search_places_controller.dart';
import '../confirm_ride_controller.dart';

class BottomNav extends StatelessWidget {
  final ConfirmRideController controller;
  final UserRideData userLocationData;

  const BottomNav({
    super.key,
    required this.controller,
    required this.userLocationData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 35,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Ride type section
            _buildRideSection(),
            
            const SizedBox(height: 10),
            
            // Payment method section
            _buildPaymentMethodSection(),
            
            const SizedBox(height: 10),
            
            // Find offers button
            _buildFindOffersButton(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRideSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color(0xffF5EFE6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AppImages.car,
                  width: 40,
                  height: 40,
                ),
                
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ride',
                      style: TextStyle(
                        fontSize: 15,
                         fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor
                      ),
                    ),
                    Text(
                      'Affordable Rides',
                      style: TextStyle(
                        fontSize: 14,
                         fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Colors.grey[300],
                height: 1,
              ),
            ),

            const SizedBox(height: 4),
            
            // Fare adjustment row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: controller.decreaseFare,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: AppColors.primaryColor,
                      size: 21,
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                Column(
                  children: [
                    Obx(() => Text(
                      '${controller.fareAmount.value.toStringAsFixed(0)}€',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    )),
                    Obx(() => Text(
                      'Recommended: ${controller.recommendedFare.value.toStringAsFixed(0)}€',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Roboto',
                        color: Colors.grey[600],
                      ),
                    )),
                  ],
                ),
                
                const SizedBox(width: 20),
                
                GestureDetector(
                  onTap: controller.increaseFare,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primaryColor,
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 19,
                ),
                SizedBox(width: 30),
                Text(
                  'Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Cash option
            Obx(() => GestureDetector(
              onTap: () => controller.selectPaymentMethod('Cash'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.selectedPaymentMethod.value == 'Cash' 
                      ? AppColors.buttonColor
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.money,
                      color: controller.selectedPaymentMethod.value == 'Cash' 
                          ? AppColors.primaryColor
                          : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cash',
                      style: TextStyle(
                        color: controller.selectedPaymentMethod.value == 'Cash' 
                            ? AppColors.primaryColor 
                            : Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 6),
            
            // Card option
            Obx(() => GestureDetector(
              onTap: () => controller.selectPaymentMethod('Card'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.selectedPaymentMethod.value == 'Card' 
                      ? AppColors.buttonColor
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: controller.selectedPaymentMethod.value == 'Card' 
                          ? Colors.white 
                          : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Card',
                      style: TextStyle(
                        color: controller.selectedPaymentMethod.value == 'Card' 
                            ? AppColors.primaryColor
                            : Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    // Try to get SearchPlacesController if exists
    final searchController = Get.isRegistered<SearchPlacesController>() 
        ? Get.find<SearchPlacesController>() 
        : null;
    
    if (searchController == null) {
      return const SizedBox.shrink();
    }
    
    return GetBuilder<SearchPlacesController>(
      builder: (_) {
        final appliedCoupon = searchController.appliedCoupon;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: appliedCoupon != null 
                  ? AppColors.successColor.withValues(alpha: 0.1)
                  : AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: appliedCoupon != null 
                    ? AppColors.successColor.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: appliedCoupon != null 
                ? _buildAppliedCouponWidget(appliedCoupon, searchController)
                : _buildApplyCouponButton(),
          ),
        );
      },
    );
  }

  Widget _buildAppliedCouponWidget(coupon, SearchPlacesController searchController) {
    // Get CouponsController to access helper methods
    final couponsController = Get.isRegistered<CouponsController>()
        ? Get.find<CouponsController>()
        : null;
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.confirmation_number_rounded,
                color: AppColors.successColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    couponsController?.getCouponTypeName(coupon.type) ?? 'Coupon Applied',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successColor,
                    ),
                  ),
                  Text(
                    couponsController?.getCouponDescription(coupon.type) ?? 'Discount applied',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => searchController.removeCoupon(),
              icon: Icon(
                Icons.close,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplyCouponButton() {
    return InkWell(
      onTap: () async {
        final couponsController = Get.put(CouponsController());
        await Get.to(() => const CouponsView());
        
        // Check if coupon was selected
        if (couponsController.selectedCoupon.value != null) {
          final searchController = Get.find<SearchPlacesController>();
          searchController.applyCoupon(couponsController.selectedCoupon.value!);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            color: AppColors.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Apply Coupon',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primaryColor,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildFindOffersButton() {
    return SizedBox(
      width: 223,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.findOffers,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              )
            : const Text(
                'Find Offers',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
      )),
    );
  }
}