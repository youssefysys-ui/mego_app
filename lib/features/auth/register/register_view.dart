import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/features/auth/register/register_controller.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_images.dart';
import '../../../core/shared_widgets/Custom_button.dart';
import '../../../core/shared_widgets/custom_textformfield.dart';
import '../../../core/shared_widgets/social_button.dart';


class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    return Scaffold(
      appBar:CustomAppBar(height: 65,isBack: true),
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Image.asset(AppImages.blurLogo, height: 100),
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        "More than a ride, it's MEGo",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    SizedBox(height: 30),


                    // Name Field
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0, right: 38),
                      child: CustomTextFormField(
                        hint: 'Name'.tr,
                        prefixIcon: AppImages.nameIcon,
                        type: TextInputType.name,
                        controller: controller.nameController,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Email Field
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0, right: 38),
                      child: CustomTextFormField(
                        hint: 'E-mail'.tr,
                        prefixIcon: AppImages.emailIcon,
                        type: TextInputType.emailAddress,
                        controller: controller.emailController,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Phone Field
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0, right: 38),
                      child: CustomTextFormField(
                        hint: 'Phone'.tr,
                        prefixIcon: AppImages.phone,
                        type: TextInputType.phone,
                        controller: controller.phoneController,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Sign Up Button
                    GetBuilder<RegisterController>(
                      builder: (controller) => CustomButton(
                        text: controller.isLoading
                            ? 'Signing up...'.tr
                            : 'Sign Up'.tr,
                        onPressed: () {
                          if (!controller.isLoading) {
                            controller.register(context);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),

                    // Terms and Conditions Checkbox
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 38.0),
                      child: GetBuilder<RegisterController>(
                        builder: (controller) => Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: controller.agreedToTerms,
                                onChanged: controller.toggleTermsAgreement,
                                activeColor: AppColors.primaryColor,
                              ),
                            ),
                          SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Open Terms of Service
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                  ),
                                  children: [
                                    TextSpan(text: 'By signing up, you agree to the '.tr),
                                    TextSpan(
                                      text: 'Terms of service'.tr,
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: ' and '.tr),
                                    TextSpan(
                                      text: 'Privacy policy'.tr,
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                    ),
                    SizedBox(height: 24),

                    // Social Login Buttons
                    Padding(
                      padding: const EdgeInsets.only(left: 48.0, right: 48),
                      child: SocialButton(
                        text: 'continue with Google'.tr,
                        iconPath: AppImages.google,
                        onPressed: () {
                          controller.signInWithGoogle();
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 48.0, right: 48),
                      child: SocialButton(
                        text: 'continue with Apple'.tr,
                        iconPath: AppImages.apple,
                        onPressed: () {
                          controller.signInWithApple();
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    // Bottom Vector and Sign In Link
                    Stack(
                      children: [
                        SvgPicture.asset(AppImages.loginVector),
                        Positioned(
                          bottom: 39,
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?".tr,
                                style: TextStyle(
                                  color: AppColors.lightTxtColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Text(
                                  "Sign in".tr,
                                  style: TextStyle(
                                    color: AppColors.lightTxtColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                    decoration: TextDecoration.underline,
                                  ),
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
        ));
  }
}