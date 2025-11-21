// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mego_app/core/res/app_colors.dart';
// import 'package:mego_app/core/res/app_images.dart';
//
// import '../../../core/shared_widgets/Custom_button.dart';
// import '../controllers/auth_controller.dart';
// import '../widgets/custom_text_field.dart';
//
// class RegisterView extends GetView<AuthController> {
//   const RegisterView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: AppColors.primaryColor,
//           ),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: controller.registerFormKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//
//                 // App Logo
//                 Center(
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.primaryColor.withOpacity(0.1),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: Image.asset(
//                         AppImages.logo,
//                         //appLogo,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 // Welcome Text
//                 Text(
//                   'Create Account',
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     color: AppColors.primaryColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 Text(
//                   'Sign up to get started with your account',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     color: AppColors.txtColor.withOpacity(0.7),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 // Name Field
//                 CustomTextField(
//                   controller: controller.nameController,
//                   labelText: 'Full Name',
//                   hintText: 'Enter your full name',
//                   textInputAction: TextInputAction.next,
//                   prefixIcon: Icon(
//                     Icons.person_outline,
//                     color: AppColors.iconColor,
//                   ),
//                   validator: controller.validateName,
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Email Field
//                 CustomTextField(
//                   controller: controller.emailController,
//                   labelText: 'Email',
//                   hintText: 'Enter your email',
//                   keyboardType: TextInputType.emailAddress,
//                   textInputAction: TextInputAction.next,
//                   prefixIcon: Icon(
//                     Icons.email_outlined,
//                     color: AppColors.iconColor,
//                   ),
//                   validator: controller.validateEmail,
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Password Field
//                 CustomTextField(
//                   controller: controller.passwordController,
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   obscureText: true,
//                   textInputAction: TextInputAction.next,
//                   prefixIcon: Icon(
//                     Icons.lock_outline,
//                     color: AppColors.iconColor,
//                   ),
//                   validator: controller.validatePassword,
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Confirm Password Field
//                 CustomTextField(
//                   controller: controller.confirmPasswordController,
//                   labelText: 'Confirm Password',
//                   hintText: 'Confirm your password',
//                   obscureText: true,
//                   textInputAction: TextInputAction.done,
//                   prefixIcon: Icon(
//                     Icons.lock_outline,
//                     color: AppColors.iconColor,
//                   ),
//                   validator: controller.validateConfirmPassword,
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 // Register Button
//                 Obx(() => CustomButton(
//                   text: 'Create Account',
//                   onPressed: controller.signUpWithEmail,
//                //   isLoading: controller.isLoading.value,
//                 )),
//
//                 const SizedBox(height: 30),
//
//                 // Terms and Privacy
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: RichText(
//                       textAlign: TextAlign.center,
//                       text: TextSpan(
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: AppColors.txtColor.withOpacity(0.6),
//                         ),
//                         children: [
//                           const TextSpan(text: 'By creating an account, you agree to our '),
//                           WidgetSpan(
//                             child: GestureDetector(
//                               onTap: () {
//                                 // Handle terms of service
//                               },
//                               child: Text(
//                                 'Terms of Service',
//                                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                   color: AppColors.primaryColor,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const TextSpan(text: ' and '),
//                           WidgetSpan(
//                             child: GestureDetector(
//                               onTap: () {
//                                 // Handle privacy policy
//                               },
//                               child: Text(
//                                 'Privacy Policy',
//                                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                   color: AppColors.primaryColor,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 // Login Link
//                 Center(
//                   child: RichText(
//                     text: TextSpan(
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: AppColors.txtColor,
//                       ),
//                       children: [
//                         const TextSpan(text: "Already have an account? "),
//                         WidgetSpan(
//                           child: GestureDetector(
//                             onTap: () => Get.back(),
//                             child: Text(
//                               'Sign In',
//                               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                 color: AppColors.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }