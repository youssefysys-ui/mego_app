import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/local_db/local_db.dart';
import '../../../../core/utils/app_message.dart';
import '../../../home/views/home_view.dart';
import '../../verify_otp/verify_otp_view.dart';

class CompleteProfileController extends GetxController {
  // Dependencies
  final SupabaseClient supabase = Supabase.instance.client;
  final localStorage = GetIt.instance<LocalStorageService>();

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString profileImageUrl = ''.obs;

  // User context data
  String userId = '';
  String loginSource = ''; // 'phone' or 'google'
  String? existingName;
  String? existingEmail;
  String? existingPhone;
  String? existingPhoto;

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// Initialize user data from arguments
  void _initializeUserData() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      userId = args['userId'] ?? '';
      loginSource = args['source'] ?? '';
      existingName = args['name'];
      existingEmail = args['email'];
      existingPhone = args['phone'];
      existingPhoto = args['photo'];

      // Pre-fill controllers based on login source
      if (loginSource == 'google') {
        nameController.text = existingName ?? '';
        emailController.text = existingEmail ?? '';
        profileImageUrl.value = existingPhoto ?? '';
      } else if (loginSource == 'phone') {
        phoneController.text = existingPhone ?? '';
      }

      print('📋 Complete Profile initialized');
      print('   🆔 User ID: $userId');
      print('   🔑 Source: $loginSource');
      print('   👤 Name: $existingName');
      print('   📧 Email: $existingEmail');
      print('   📱 Phone: $existingPhone');
    }
  }

  /// Validate and save profile for phone login users
  Future<void> savePhoneUserProfile(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      print('\n💾 Saving phone user profile...');

      final name = nameController.text.trim();
      final email = emailController.text.trim();

      // Insert new user into users table
      await supabase.from('users').insert({
        'id': userId,
        'name': name,
        'email': email,
        'phone': existingPhone ?? '',
        'profile': profileImageUrl.value.isNotEmpty ? profileImageUrl.value : '',
        'user_type': 'rider',
      });

      print('✅ User profile inserted into Supabase users table');
      print('   🆔 User ID: $userId');
      print('   👤 Name: $name');
      print('   📧 Email: $email');
      print('   📱 Phone: ${existingPhone ?? ""}');

      // Save to local storage
      await localStorage.saveUserName(name);
      await localStorage.saveUserEmail(email);
      if (existingPhone != null && existingPhone!.isNotEmpty) {
        await localStorage.write('user_phone', existingPhone);
      }
      if (profileImageUrl.value.isNotEmpty) {
        await localStorage.saveUserProfile(profileImageUrl.value);
      }

      print('✅ User data saved to local storage');

      if (context.mounted) {
        appMessageSuccess(
          text: 'Profile completed successfully!',
          context: context,
        );
      }

      // Navigate to home
      Get.offAll(
        () => const HomeView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );

      print('✅ Navigation to Home completed');
    } catch (e) {
      print('❌ Error saving profile: $e');
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to save profile: $e',
          context: context,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Send OTP to phone for Google login users
  Future<void> sendPhoneOTP(BuildContext context) async {
    if (phoneController.text.trim().isEmpty) {
      appMessageFail(text: 'Please enter your phone number', context: context);
      return;
    }

    if (phoneController.text.trim().length < 10) {
      appMessageFail(text: 'Please enter a valid phone number', context: context);
      return;
    }

    try {
      isLoading.value = true;
      final phoneNumber = phoneController.text.trim();

      print('\n📱 Sending OTP to: $phoneNumber');

      await supabase.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: false,
      );

      if (context.mounted) {
        appMessageSuccess(
          text: 'OTP sent to $phoneNumber',
          context: context,
        );
      }

      // Navigate to OTP verification with callback
      Get.to(
        () => VerifyOtpView(phoneNumber: phoneNumber),
        arguments: {
          'isProfileCompletion': true,
          'userId': userId,
          'name': existingName,
          'email': existingEmail,
          'photo': existingPhoto,
        },
      );

      print('✅ Navigated to OTP verification');
    } catch (e) {
      print('❌ Error sending OTP: $e');
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to send OTP: $e',
          context: context,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Save Google user profile after phone verification
  Future<void> saveGoogleUserWithPhone(BuildContext context) async {
    try {
      isLoading.value = true;
      print('\n💾 Saving Google user with phone...');

      final phone = phoneController.text.trim();

      // Update users table with complete data
      await supabase.from('users').update({
        'name': existingName ?? 'MEGO User',
        'email': existingEmail ?? '',
        'phone': phone,
        'profile': existingPhoto ?? '',
        'user_type': 'rider',
      }).eq('id', userId);

      print('✅ Google user profile updated with phone');

      // Save to local storage
      await localStorage.saveUserName(existingName ?? 'MEGO User');
      await localStorage.saveUserEmail(existingEmail ?? '');
      await localStorage.write('user_phone', phone);
      if (existingPhoto != null && existingPhoto!.isNotEmpty) {
        await localStorage.saveUserProfile(existingPhoto!);
      }

      print('✅ Complete user data saved to local storage');

      if (context.mounted) {
        appMessageSuccess(
          text: 'Welcome ${existingName ?? "User"}!',
          context: context,
        );
      }

      // Navigate to home
      Get.offAll(
        () => const HomeView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );

      print('✅ Profile completion successful');
    } catch (e) {
      print('❌ Error saving profile: $e');
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to complete profile: $e',
          context: context,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Validators
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Simple email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10 || value.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
