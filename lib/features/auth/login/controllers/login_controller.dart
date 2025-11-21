

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/auth/verify_otp/verify_otp_view.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repo/login_repo.dart';

class LoginController extends GetxController {
  // Dependencies
  final LoginRepository _loginRepository;
  
  // Text controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  
  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Constructor with dependency injection
  LoginController(this._loginRepository);
  
  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> sendOTP({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("📱 Sending OTP to: $phoneNumber");
      
      await supabase.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );

      if (context.mounted) {
        appMessageSuccess(
          text: 'OTP sent to $phoneNumber',
          context: context,
        );
      }
      
      Get.to(() => VerifyOtpView(phoneNumber: phoneNumber));
      return true;
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      if (context.mounted) {
        appMessageFail(
          text: 'Error: ${e.message}',
          context: context,
        );
      }
      return false;
    } catch (e) {
      print("❌ Unexpected error: $e");
      if (context.mounted) {
        appMessageFail(
          text: 'Unexpected error: $e',
          context: context,
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(BuildContext context) async {
    if (phoneController.text.trim().isEmpty) {
      appMessageFail(text: 'Please enter your phone number', context: context);
      return;
    }
    
    if (phoneController.text.trim().length < 7) {
      appMessageFail(text: 'Please enter a valid phone number', context: context);
      return;
    }
    
    await sendOTP(phoneNumber: phoneController.text.trim(), context: context);
  }



  Future<void> signOut() async {
    try {
      await _loginRepository.signOut();
      _clearForm();
    } catch (e) {
      // Handle sign out error
      print('Sign out error: $e');
    }
  }

  User? getCurrentUser() {
    return _loginRepository.getCurrentUser();
  }

  Session? getCurrentSession() {
    return _loginRepository.getCurrentSession();
  }

  void _clearForm() {
    phoneController.clear();
    passwordController.clear();
    errorMessage.value = '';
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}