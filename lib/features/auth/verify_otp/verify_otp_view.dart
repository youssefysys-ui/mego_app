import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_widgets/Custom_button.dart';

import 'verify_otp_controller.dart';

class VerifyOtpView extends StatelessWidget {
  final String phoneNumber;
  const VerifyOtpView({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final VerifyOtpController controller = Get.put(VerifyOtpController());
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            SizedBox(height: 20),
            SvgPicture.asset(AppImages.logo, height: 100),
            SizedBox(height: 30),
            Text(
              "Verify OTP".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Enter the 6-digit code sent to\n${phoneNumber}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightTxtColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(height: 40),
            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOtpTextField(
                  controller: controller.otp1Controller,
                  focusNode: controller.otp1FocusNode,
                  nextFocusNode: controller.otp2FocusNode,
                ),
                _buildOtpTextField(
                  controller: controller.otp2Controller,
                  focusNode: controller.otp2FocusNode,
                  previousFocusNode: controller.otp1FocusNode,
                  nextFocusNode: controller.otp3FocusNode,
                ),
                _buildOtpTextField(
                  controller: controller.otp3Controller,
                  focusNode: controller.otp3FocusNode,
                  previousFocusNode: controller.otp2FocusNode,
                  nextFocusNode: controller.otp4FocusNode,
                ),
                _buildOtpTextField(
                  controller: controller.otp4Controller,
                  focusNode: controller.otp4FocusNode,
                  previousFocusNode: controller.otp3FocusNode,
                  nextFocusNode: controller.otp5FocusNode,
                ),
                _buildOtpTextField(
                  controller: controller.otp5Controller,
                  focusNode: controller.otp5FocusNode,
                  previousFocusNode: controller.otp4FocusNode,
                  nextFocusNode: controller.otp6FocusNode,
                ),
                _buildOtpTextField(
                  controller: controller.otp6Controller,
                  focusNode: controller.otp6FocusNode,
                  previousFocusNode: controller.otp5FocusNode,
                  isLast: true,
                ),
              ],
            ),
            
            SizedBox(height: 40),
            
            // Verify Button
            GetBuilder<VerifyOtpController>(
              builder: (controller) => CustomButton(
                text: controller.isLoading ? 'Verifying...' : 'Verify OTP',
                onPressed: () {
                  if (!controller.isLoading) {
                    controller.verifyOtp(context, phoneNumber);
                  }
                },
              ),
            ),
            
            SizedBox(height: 20),
            
            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code?".tr,
                  style: TextStyle(
                    color: AppColors.lightTxtColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () => controller.resendOtp(context,phoneNumber),
                  child: Text(
                    "Resend".tr,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
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

  Widget _buildOtpTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? previousFocusNode,
    FocusNode? nextFocusNode,
    bool isLast = false,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && nextFocusNode != null) {
            nextFocusNode.requestFocus();
          } else if (value.isEmpty && previousFocusNode != null) {
            previousFocusNode.requestFocus();
          }
        },
      ),
    );
  }
}
