import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import '../../core/res/app_colors.dart';
import '../../core/shared_models/coupon_model.dart';
import 'coupons_controller.dart';

class CouponsView extends StatelessWidget {
  const CouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponsController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(height: 91,isBack: true),

      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading your coupons...',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: AppColors.socialMediaText,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: AppColors.failColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops!',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.txtColor,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: AppColors.socialMediaText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.loadCoupons,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.coupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: AppColors.socialMediaText,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Coupons Yet',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.txtColor,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'You don\'t have any coupons at the moment.\nCheck back later for exciting offers!',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: AppColors.socialMediaText,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.insertTestDataToSupabase,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Test Coupons'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: controller.refreshCoupons,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                _buildSummaryCard(controller),
                const SizedBox(height: 24),

                // Active Coupons Section
                if (controller.activeCoupons.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Active Coupons',
                    controller.activeCoupons.length,
                    Icons.local_offer_rounded,
                    AppColors.successColor,
                  ),
                  const SizedBox(height: 12),
                  ...controller.activeCoupons.map(
                    (coupon) => _buildCouponCard(coupon, controller, true),
                  ),
                  const SizedBox(height: 24),
                ],

                // Expired Coupons Section
                if (controller.expiredCoupons.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Expired Coupons',
                    controller.expiredCoupons.length,
                    Icons.event_busy_rounded,
                    AppColors.socialMediaText,
                  ),
                  const SizedBox(height: 12),
                  ...controller.expiredCoupons.map(
                    (coupon) => _buildCouponCard(coupon, controller, false),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(CouponsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.appSurfaceColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 40,
              color: AppColors.whiteColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Coupons',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.coupons.length}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.buttonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.activeCoupons.length} Active',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.txtColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCouponCard(Coupon coupon, CouponsController controller, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Discount Badge Background Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: isActive ? 0.05 : 0.02,
              child: Icon(
                Icons.confirmation_number_rounded,
                size: 120,
                color: AppColors.primaryColor,
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Coupon Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.appSurfaceColor,
                                ],
                              )
                            : null,
                        color: isActive ? null : AppColors.socialMediaText,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.discount_rounded,
                        color: AppColors.whiteColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Coupon Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.getCouponTypeName(coupon.type),
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isActive ? AppColors.txtColor : AppColors.socialMediaText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.getCouponDescription(coupon.type),
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.socialMediaText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.successColor.withValues(alpha: 0.15)
                            : AppColors.failColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.cancel,
                            size: 14,
                            color: isActive ? AppColors.successColor : AppColors.failColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'Active' : 'Expired',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isActive ? AppColors.successColor : AppColors.failColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.socialMediaText.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Footer Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Valid Until
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: isActive ? AppColors.iconColor : AppColors.socialMediaText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.formatDate(coupon.validUntil),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.txtColor : AppColors.socialMediaText,
                          ),
                        ),
                      ],
                    ),

                    // Use Button or Deactivate
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.buttonColor,
                              AppColors.buttonColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),

                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            const SizedBox(width: 6),
                            Text(
                              'Use Now',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
