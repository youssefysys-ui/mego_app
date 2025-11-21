import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/auth/verify_otp/verify_otp_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController extends GetxController {
  // Text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Variables for GetBuilder
  bool isLoading = false;
  bool agreedToTerms = false;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Validate input fields
  bool validateInputs(BuildContext context) {

    if (nameController.text.trim().isEmpty) {
      appMessageFail(text: 'Please enter your name', context: context);

      return false;
    }

    if (emailController.text.trim().isEmpty) {
      appMessageFail(text: 'Please enter your email', context: context);

      return false;
    }

    // Email validation
    if (!GetUtils.isEmail(emailController.text.trim())) {
      appMessageFail(text: 'Please enter a valid email address', context: context);

      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      appMessageFail(text: 'Please enter your phone number', context: context);
      return false;
    }

    // Phone validation (basic - adjust based on your requirements)
    if (phoneController.text.trim().length < 7) {
      appMessageFail(text: 'Please enter a valid phone number', context: context);

      return false;
    }





    if (!agreedToTerms) {
      appMessageFail(text: 'Please agree to Terms of Service and Privacy Policy', context: context);
      return false;
    }

    return true;
  }

  // Register function with Supabase Phone Auth (OTP)
  Future<void> register(BuildContext context) async {
    if (!validateInputs(context)) {
      return;
    }

    try {
      isLoading = true;
      update();
      
      // Send OTP to phone number
      await Supabase.instance.client.auth.signInWithOtp(
        phone: phoneController.text.trim(),

        data: {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'user_type': 'user',
          'password':"",
        },
      );

      appMessageSuccess(
        text: 'OTP sent successfully! Please check your phone.',
        context: context,
      );

      // Navigate to OTP verification screen with phone number
      Get.to(() => VerifyOtpView(phoneNumber: phoneController.text.trim(),

      ),
        arguments: {
          'phone': phoneController.text.trim(),
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
        },
      );

    } on AuthException catch (e) {
      print('Auth error during registration: ${e.message}');
      appMessageFail(
        text: e.message,
        context: context,
      );
    } catch (e) {
      print('Error during registration: $e');
      appMessageFail(
        text: 'Something went wrong: ${e.toString()}',
        context: context,
      );
    } finally {
      isLoading = false;
      update();
    }
  }



  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      isLoading = true;
      update();
      // TODO: Implement Google Sign In
      // Example:
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      // Then send to your backend

      await Future.delayed(Duration(seconds: 2));

      Get.snackbar(
        'Info',
        'Google Sign In - Coming Soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google Sign In failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }
  
  // Apple Sign In
  Future<void> signInWithApple() async {
    try {
      isLoading = true;
      update();

      // TODO: Implement Apple Sign In
      // Example:
      // final credential = await SignInWithApple.getAppleIDCredential(...);
      // Then send to your backend

      await Future.delayed(Duration(seconds: 2));

      Get.snackbar(
        'Info',
        'Apple Sign In - Coming Soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Apple Sign In failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // Toggle terms agreement
  void toggleTermsAgreement(bool? value) {
    agreedToTerms = value ?? false;
    update();
  }

  // Clear all fields
  void clearFields() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    agreedToTerms = false;
    update();
  }
}