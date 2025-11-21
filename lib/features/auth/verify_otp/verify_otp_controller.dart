import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/core/local_db/local_db.dart';
import 'package:mego_app/core/shared_models/user_model.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyOtpController extends GetxController {
  // Text controllers for OTP inputs
  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();
  final otp5Controller = TextEditingController();
  final otp6Controller = TextEditingController();
  
  // Focus nodes for OTP inputs
  final otp1FocusNode = FocusNode();
  final otp2FocusNode = FocusNode();
  final otp3FocusNode = FocusNode();
  final otp4FocusNode = FocusNode();
  final otp5FocusNode = FocusNode();
  final otp6FocusNode = FocusNode();
  
  // Variables for GetBuilder
  bool isLoading = false;
  String errorMessage = '';
  
  final SupabaseClient supabase = Supabase.instance.client;
  
  @override
  void onInit() {
    super.onInit();
    // Get phone number from arguments

  }
  
  @override
  void onClose() {
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    otp6Controller.dispose();
    
    otp1FocusNode.dispose();
    otp2FocusNode.dispose();
    otp3FocusNode.dispose();
    otp4FocusNode.dispose();
    otp5FocusNode.dispose();
    otp6FocusNode.dispose();
    
    super.onClose();
  }
  
  String getOtpCode() {
    return otp1Controller.text +
        otp2Controller.text +
        otp3Controller.text +
        otp4Controller.text +
        otp5Controller.text +
        otp6Controller.text;
  }
  
  Future<void> verifyOtp(BuildContext context,String phoneNumber) async {
    try {
      isLoading = true;
      errorMessage = '';
      update();
      
      final otpCode = getOtpCode();
      
      if (otpCode.length != 6) {
        throw Exception('Please enter the complete OTP code');
      }
      
      print('🔐 Verifying OTP for phone: ${phoneNumber}');
      print('📱 OTP Code: $otpCode');

      print('⏳ Sending verification request to Supabase...');
      print("🔑 Phone: ${phoneNumber}, OTP: $otpCode"+"...."+OtpType.sms.toString());
      print('-----------------------------------');
      
      final response = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: phoneNumber,
        token: otpCode,
      );

      if (response.user != null) {
        print('✅ OTP verification successful!');
        print('User ID: ${response.user!.id}');
        print('Phone: ${response.user!.phone}');
        
        // Check if user exists in users table and create if needed
        await _checkAndCreateUserProfile(response.user!, phoneNumber);
        
        if (context.mounted) {
          appMessageSuccess(
            text: 'Verification successful!',
            context: context,
          );
        }
        
        // Navigate to home
        Get.offAll(() => const HomeView(),
          transition: Transition.leftToRightWithFade,
          duration: const Duration(milliseconds: 900),
        );
      } else {
        throw Exception('Verification failed - no user returned');
      }
      
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      errorMessage = e.message;
      if (context.mounted) {
        appMessageFail(
          text: 'Verification failed: ${e.message}',
          context: context,
        );
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      errorMessage = e.toString();
      if (context.mounted) {
        appMessageFail(
          text: 'Verification failed: ${e.toString()}',
          context: context,
        );
      }
    } finally {
      isLoading = false;
      update();
    }
  }
  
  Future<void> _checkAndCreateUserProfile(User user, String phoneNumber) async {
    try {
      final existingUser = await _checkIfUserExists(user.id);
      
      if (existingUser == null) {
        await _createNewUserProfile(user, phoneNumber);
      } else {
        await _handleExistingUser(existingUser);
      }
    } catch (e) {
      print('❌ Error managing user profile: $e');
      // Don't throw error here, verification was successful
    }
  }

  /// Check if user exists in Supabase users table
  Future<Map<String, dynamic>?> _checkIfUserExists(String userId) async {
    print('🔍 Checking if user profile exists...');
    return await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  /// Create new user profile in Supabase and save to local storage
  Future<void> _createNewUserProfile(User user, String phoneNumber) async {
    print('👤 Creating new user profile...');
    
    final userData = _buildUserData(user, phoneNumber);
    
    await supabase
        .from('users')
        .insert(userData);
        
    print('✅ User profile created successfully!');
    print('User Data: $userData');
    
    await _saveUserToLocalStorage(userData, isNewUser: true);
  }

  /// Handle existing user login and save to local storage
  Future<void> _handleExistingUser(Map<String, dynamic> existingUser) async {
    print('✅ User profile already exists');
    print('Existing User: $existingUser');
    
    await _saveUserToLocalStorage(existingUser, isNewUser: false);
  }

  /// Build user data object from User and registration arguments
  Map<String, dynamic> _buildUserData(User user, String phoneNumber) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    
    return {
      'id': user.id,
      'name': arguments?['name'] ?? user.userMetadata?['name'] ?? 'User',
      'email': arguments?['email'] ?? user.email ?? '',
      'phone': arguments?['phone'] ?? user.phone ?? phoneNumber,
      'user_type': 'rider',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Save user data to local storage with duplicate check
  Future<void> _saveUserToLocalStorage(Map<String, dynamic> userData, {required bool isNewUser}) async {
    final userModel = UserModel.fromJson(userData);
    final existingLocalUser = storage.userModel;
    
    if (_shouldSkipSaving(existingLocalUser, userModel)) {
      _logDuplicateSkip(existingLocalUser!);
      return;
    }
    
    await storage.saveUserModel(userModel);
    _logSuccessfulSave(isNewUser);
  }

  /// Check if we should skip saving due to duplicate data
  bool _shouldSkipSaving(UserModel? existingLocalUser, UserModel newUserModel) {
    return existingLocalUser != null && existingLocalUser.id == newUserModel.id;
  }

  /// Log message when skipping duplicate save
  void _logDuplicateSkip(UserModel existingUser) {
    print('📱 Same user data already exists in local storage - skipping save');
    print('💡 User login: ${existingUser.name} (${existingUser.email})');
  }

  /// Log message for successful save
  void _logSuccessfulSave(bool isNewUser) {
    if (isNewUser) {
      print('💾 Complete user data saved to local storage successfully!');
    } else {
      print('💾 Existing user data saved to local storage successfully!');
    }
  }
  
  Future<void> resendOtp(BuildContext context,String phoneNumber) async {
    try {
      isLoading = true;
      update();
      
      await supabase.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );

      if (context.mounted) {
        appMessageSuccess(
          text: 'OTP resent to ${phoneNumber}',
          context: context,
        );
      }
      
    } on AuthException catch (e) {
      if (context.mounted) {
        appMessageFail(
          text: 'Error: ${e.message}',
          context: context,
        );
      }
    } catch (e) {
      if (context.mounted) {
        appMessageFail(
          text: 'Unexpected error: $e',
          context: context,
        );
      }
    } finally {
      isLoading = false;
      update();
    }
  }
}
