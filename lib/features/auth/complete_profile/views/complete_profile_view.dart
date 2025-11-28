import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_images.dart';
import '../controllers/complete_profile_controller.dart';

class CompleteProfileView extends StatelessWidget {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompleteProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Show loading overlay
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        // Conditional UI based on login source
        return controller.loginSource == 'google'
            ? _buildGoogleUserForm(controller, context)
            : _buildPhoneUserForm(controller, context);
      }),
    );
  }

  /// Form for phone login users (need name & email)
  Widget _buildPhoneUserForm(
      CompleteProfileController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  AppImages.logo,
                  height: 60,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info text
            Text(
              'Please complete your profile to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.txtColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 32),

            // Phone number (read-only)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.successColor.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: AppColors.successColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.existingPhone ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        color: AppColors.txtColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppColors.successColor),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Name field
            TextFormField(
              controller: controller.nameController,
              validator: controller.validateName,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.person, color: AppColors.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.failColor, width: 1),
                ),
                labelStyle: TextStyle(fontFamily: 'Roboto', color: AppColors.txtColor),
                hintStyle: TextStyle(fontFamily: 'Roboto', color: Colors.grey[400]),
              ),
              style: TextStyle(fontFamily: 'Roboto', color: AppColors.txtColor),
            ),
            const SizedBox(height: 20),

            // Email field
            TextFormField(
              controller: controller.emailController,
              validator: controller.validateEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.email, color: AppColors.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.failColor, width: 1),
                ),
                labelStyle: TextStyle(fontFamily: 'Roboto', color: AppColors.txtColor),
                hintStyle: TextStyle(fontFamily: 'Roboto', color: Colors.grey[400]),
              ),
              style: TextStyle(fontFamily: 'Roboto', color: AppColors.txtColor),
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: () => controller.savePhoneUserProfile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: AppColors.primaryColor.withOpacity(0.4),
              ),
              child: const Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Form for Google login users (need phone)
  Widget _buildGoogleUserForm(
      CompleteProfileController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                AppImages.logo,
                height: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Profile picture
          if (controller.profileImageUrl.value.isNotEmpty)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(controller.profileImageUrl.value),
                  backgroundColor: AppColors.backgroundColor,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Info text
          Text(
            'One more step! Please verify your phone number',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.txtColor,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 32),

          // Name (read-only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.successColor.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: AppColors.successColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.existingName ?? 'User',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: AppColors.txtColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.check_circle, color: AppColors.successColor),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Email (read-only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.successColor.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.email, color: AppColors.successColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.existingEmail ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: AppColors.txtColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.check_circle, color: AppColors.successColor),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Phone number input
          Form(
            key: controller.formKey,
            child: TextFormField(
              controller: controller.phoneController,
              validator: controller.validatePhone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.phone, color: AppColors.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.failColor, width: 1),
                ),
                labelStyle: TextStyle(fontFamily: 'Roboto', color: AppColors.txtColor),
                hintStyle: TextStyle(fontFamily: 'Roboto', color: Colors.grey[400]),
              ),
              style: TextStyle(fontFamily: 'Roboto', color: AppColors.txtColor),
            ),
          ),
          const SizedBox(height: 32),

          // Send OTP button
          ElevatedButton(
            onPressed: () => controller.sendPhoneOTP(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              shadowColor: AppColors.primaryColor.withOpacity(0.4),
            ),
            child: const Text(
              'Verify Phone Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.infoColor.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.infoColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We\'ll send you an OTP to verify your phone number',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.txtColor,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
