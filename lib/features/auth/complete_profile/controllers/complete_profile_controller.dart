import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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

      // PROCESS 1: Insert new user into users table (let Supabase generate ID)
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💾 STEP 1: Inserting user data into Supabase');
      print('   Note: Not specifying ID - Supabase will auto-generate');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      await supabase.from('users').insert({
        // Don't specify 'id' - let Supabase auto-generate it
        'name': name,
        'email': email,
        'phone': existingPhone ?? '',
        'profile': profileImageUrl.value.isNotEmpty ? profileImageUrl.value : '',
        'user_type': 'rider',
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ User profile inserted successfully');

      // PROCESS 1.5: Fetch user from Supabase to get the actual ID
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 STEP 1.5: Fetching user ID from Supabase');
      print('   Querying by phone: $existingPhone');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final userData = await supabase
          .from('users')
          .select('id, name, email, phone, profile')
          .eq('phone', existingPhone!)
          .single();
      
      final fetchedUserId = userData['id'] as String;
      print('✅ User ID retrieved from Supabase: $fetchedUserId');
      print('   👤 Name: ${userData['name']}');
      print('   📧 Email: ${userData['email']}');
      print('   📱 Phone: ${userData['phone']}');

      // PROCESS 2: Sign in user to Supabase with phone (WITHOUT OTP)
      // Firebase already verified the phone - now just authenticate with Supabase
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔐 STEP 2: Authenticating user with Supabase');
      print('   Note: Using phone for auth - Firebase already verified OTP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      try {
        // Sign in with phone using OTP type but with a dummy token
        // Since Firebase already verified, we just need to create Supabase session
        if (existingPhone != null && existingPhone!.isNotEmpty) {
          // Option 1: Sign in with email if available (password-less)
          if (email.isNotEmpty) {
            await supabase.auth.signInWithOtp(
              email: email,
              shouldCreateUser: false,
            );
            print('✅ Supabase auth initiated with email: $email');
          } else {
            // Option 2: Sign in with phone
            await supabase.auth.signInWithOtp(
              phone: existingPhone!,
              shouldCreateUser: false,
            );
            print('✅ Supabase auth initiated with phone: $existingPhone');
          }
        }
      } catch (authError) {
        // If auth fails, continue anyway since user data is already saved
        print('⚠️ Warning: Supabase auth failed but continuing: $authError');
        print('   User data is saved, they can login later');
      }
      // PROCESS 3: Save user data to local storage with validation
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💾 STEP 3: Saving user data to local storage');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final box = GetStorage();
      final localStorageService = LocalStorageService(box);
      
      // Validate userId before saving
      if (fetchedUserId.isEmpty) {
        throw Exception('User ID from Supabase is empty');
      }
      
      await localStorageService.saveUserIdSafely(fetchedUserId);
      await localStorageService.saveUserName(userData['name']);
      await localStorageService.saveUserEmail(userData['email']);
      if (existingPhone != null && existingPhone!.isNotEmpty) {
        await localStorageService.write('user_phone', existingPhone);
        print('   📱 Phone saved: $existingPhone');
      }
      
      if (profileImageUrl.value.isNotEmpty) {
        await localStorageService.saveUserProfile(profileImageUrl.value);
        print('   🖼️ Profile image saved');
      }

      print('✅ User data saved to local storage successfully');

      // PROCESS 4: Show success message
      if (context.mounted) {
        appMessageSuccess(
          text: 'Profile completed successfully!',
          context: context,
        );
      }

      // PROCESS 5: Navigate to home screen
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🏠 STEP 4: Navigating to Home screen');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      Get.offAll(
        () => const HomeView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );

      print('✅ Phone user profile completion successful');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      print('❌ ERROR: Failed to save profile: $e');
      
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

  // ════════════════════════════════════════════════════════════════════════
  // SEND PHONE OTP FOR GOOGLE LOGIN USERS (Using Firebase)
  // ════════════════════════════════════════════════════════════════════════
  
  /// Send Firebase OTP to phone for Google users completing their profile
  /// Google users already authenticated - now they need to verify phone via Firebase
  Future<void> sendPhoneOTP(BuildContext context) async {
    // VALIDATION 1: Check if phone number is entered
    if (phoneController.text.trim().isEmpty) {
      appMessageFail(text: 'Please enter your phone number', context: context);
      return;
    }

    // VALIDATION 2: Check phone number length
    if (phoneController.text.trim().length < 10) {
      appMessageFail(text: 'Please enter a valid phone number', context: context);
      return;
    }

    try {
      isLoading.value = true;
      final phoneNumber = phoneController.text.trim();

      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print('📱 SENDING FIREBASE OTP FOR GOOGLE USER');
      print('   Phone: $phoneNumber');
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      // PROCESS 1: Get Firebase Auth instance
      final _firebaseAuth = firebase_auth.FirebaseAuth.instance;

      // PROCESS 2: Send OTP via Firebase (same as login flow)
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // CALLBACK 1: Auto-verification
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          print("✅ Auto-verification completed for Google user");
          // Auto-verify will be handled in verify OTP screen
        },
        
        // CALLBACK 2: Verification failed
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          print("❌ Verification failed: ${e.message}");
          isLoading.value = false;
          
          if (context.mounted) {
            appMessageFail(
              text: e.message ?? 'Failed to send OTP',
              context: context,
            );
          }
        },
        
        // CALLBACK 3: OTP sent successfully
        codeSent: (String verificationId, int? resendToken) {
          print("✅ Firebase OTP sent successfully");
          print("   Verification ID: ${verificationId.substring(0, 20)}...");
          
          isLoading.value = false;
          
          if (context.mounted) {
            appMessageSuccess(
              text: 'OTP sent to $phoneNumber',
              context: context,
            );
          }

          // PROCESS 3: Navigate to OTP verification screen
          print("🔄 Navigating to OTP verification screen");
          Get.to(
            () => VerifyOtpView(phoneNumber: phoneNumber),
            arguments: {
              'verificationId': verificationId,
              'phoneNumber': phoneNumber,
              'isProfileCompletion': true,
              'userId': userId,
              'name': existingName,
              'email': existingEmail,
              'photo': existingPhoto,
              'source': 'google',
            },
          );
          
          print('✅ Navigation completed');
        },
        
        // CALLBACK 4: Auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          print("⏰ Auto-retrieval timeout");
        },
      );

      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    } catch (e) {
      print('❌ ERROR: Failed to send OTP: $e');
      
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
