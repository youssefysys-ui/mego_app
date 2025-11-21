import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/features/trip_tracking&completed&rating/controllers/rate_driver_controller.dart';

class RateDriverView extends StatelessWidget {
  final DriverModel driverModel;
  final String rideId;

  const RateDriverView({
    Key? key,
    required this.driverModel,
    required this.rideId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(RateDriverController(
      driverModel: driverModel,
      rideId: rideId,
    ));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GetBuilder<RateDriverController>(
        builder: (controller) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  'Rate Your Trip',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                ),

                const SizedBox(height: 24),

                // Driver info
                _DriverInfoSection(driverModel: driverModel),

                const SizedBox(height: 32),

                // Rating stars
                Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.txtColor,
                    fontFamily: 'Roboto',
                  ),
                ),

                const SizedBox(height: 16),

                // Star rating
                _StarRating(
                  rating: controller.selectedRating,
                  onRatingChanged: controller.setRating,
                ),

                const SizedBox(height: 24),

                // Comment section
                _CommentSection(controller: controller),

                const SizedBox(height: 24),

                // Submit button
                _SubmitButton(
                  isLoading: controller.isLoading,
                  onPressed: () => controller.submitRating(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Driver info section
class _DriverInfoSection extends StatelessWidget {
  final DriverModel driverModel;

  const _DriverInfoSection({required this.driverModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Driver avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.buttonColor,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: driverModel.profileImage != null &&
                      driverModel.profileImage!.isNotEmpty
                  ? Image.network(
                      driverModel.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.primaryColor,
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Driver details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverModel.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.txtColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/star.svg',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      driverModel.rate?.toStringAsFixed(1) ?? '4.9',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Roboto',
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

// Star rating widget
class _StarRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;

  const _StarRating({
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= rating;

        return GestureDetector(
          onTap: () => onRatingChanged(starNumber),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                'assets/images/star.svg',

                width: 33,
                height: 33,
                color:
                isSelected
                    ? AppColors.primaryColor
                    : Colors.grey[300],
             //   AppColors.primaryColor,
                // colorFilter: isSelected
                //     ? null // Use original color from SVG
                //     : ColorFilter.mode(
                //         Colors.grey[300]!,
                //         BlendMode.srcIn,
                //       ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Comment section
class _CommentSection extends StatelessWidget {
  final RateDriverController controller;

  const _CommentSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a comment (optional)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.txtColor,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Share your experience...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontFamily: 'Roboto',
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.txtColor,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }
}

// Submit button
class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Submit Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                ),
              ),
      ),
    );
  }
}
