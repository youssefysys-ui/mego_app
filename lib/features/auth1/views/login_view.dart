import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';

import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';


class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // App Logo
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SvgPicture.asset(
                        AppImages.logo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue to your account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.txtColor.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.iconColor,
                  ),
                  validator: controller.validateEmail,
                ),

                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  controller: controller.passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.iconColor,
                  ),
                  validator: controller.validatePassword,
                ),

                const SizedBox(height: 16),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                Obx(() => CustomButton(
                  text: 'Sign In',
                  onPressed: controller.signInWithEmail,
                  isLoading: controller.isLoading.value,
                )),

                const SizedBox(height: 30),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: SurfaceColors.dividerColor,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.txtColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: SurfaceColors.dividerColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Register Link
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.txtColor,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Get.toNamed('/register'),
                            child: Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Reset Password',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a password reset link.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.txtColor),
            ),
          ),
          Obx(() => CustomButton(
            text: 'Send Reset Link',
            width: 140,
            height: 40,
            onPressed: () {
              if (emailController.text.isEmail) {
                controller.resetPassword(emailController.text.trim());
                Get.back();
              }
            },
            isLoading: controller.isLoading.value,
          )),
        ],
      ),
    );
  }
}