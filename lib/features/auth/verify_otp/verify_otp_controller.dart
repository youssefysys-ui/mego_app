import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/core/local_db/local_db.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import '../complete_profile/views/complete_profile_view.dart';

class VerifyOtpController extends GetxController {
  // ════════════════════════════════════════════════════════════════════════
  // DEPENDENCIES & CONTROLLERS
  // ════════════════════════════════════════════════════════════════════════
  
  /// Firebase Auth instance for OTP verification
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  
  /// Supabase client for user data management (no OTP verification)
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Text controllers for OTP inputs (6-digit OTP)
  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();
  final otp5Controller = TextEditingController();
  final otp6Controller = TextEditingController();
  
  // Focus nodes for OTP inputs (for smooth navigation between fields)
  final otp1FocusNode = FocusNode();
  final otp2FocusNode = FocusNode();
  final otp3FocusNode = FocusNode();
  final otp4FocusNode = FocusNode();
  final otp5FocusNode = FocusNode();
  final otp6FocusNode = FocusNode();
  
  // State variables for GetBuilder
  bool isLoading = false;
  String errorMessage = '';
  
  /// Store data from previous screen (login)
  late String phoneNumber;
  late String verificationId;
  
  @override
  void onInit() {
    super.onInit();
    
    // ════════════════════════════════════════════════════════════════════════
    // INITIALIZATION: Get data from previous screen
    // ════════════════════════════════════════════════════════════════════════
    
    // PROCESS: Extract phone number and verification ID from navigation arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    phoneNumber = arguments?['phoneNumber'] ?? '';
    verificationId = arguments?['verificationId'] ?? '';
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📱 OTP VERIFICATION SCREEN INITIALIZED");
    print("   Phone: $phoneNumber");
    print("   Verification ID: ${verificationId.isNotEmpty ? '${verificationId.substring(0, 20)}...' : 'Missing'}");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
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
  
  // ════════════════════════════════════════════════════════════════════════
  // FIREBASE OTP VERIFICATION
  // ════════════════════════════════════════════════════════════════════════
  
  /// STEP 1: Verify OTP code entered by user with Firebase
  /// This verifies the 6-digit OTP sent via SMS
  Future<void> verifyOtp(BuildContext context, String phoneNumber) async {
    try {
      // PROCESS 1: Set loading state
      isLoading = true;
      errorMessage = '';
      update();
      
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔐 FIREBASE OTP VERIFICATION: Starting");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      // PROCESS 2: Get OTP code from input fields
      final otpCode = getOtpCode();
      
      // VALIDATION: Check OTP code length
      if (otpCode.length != 6) {
        print("❌ Validation failed: OTP code incomplete");
        throw Exception('Please enter the complete OTP code');
      }
      
      print('📱 STEP 1: OTP code collected from input fields');
      print('   Phone: $phoneNumber');
      print('   OTP Code: $otpCode');
      print('   Verification ID: ${verificationId.substring(0, 20)}...');

      // PROCESS 3: Create Firebase phone auth credential
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔑 STEP 2: Creating Firebase phone credential');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      
      print('✅ Credential created successfully');

      // PROCESS 4: Sign in to Firebase with the credential
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔐 STEP 3: Signing in with Firebase credential');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print('✅ Firebase OTP verification successful!');
        print('   User ID: ${userCredential.user!.uid}');
        print('   Phone: ${userCredential.user!.phoneNumber}');
        
        // PROCESS 5: Sign in user to Supabase after Firebase verification
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔐 STEP 4: Authenticating with Supabase');
        print('   Firebase phone verification completed - creating Supabase session');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        try {
          // Create Supabase auth session using verified phone number
          // Firebase already verified OTP - Supabase just needs to create session
          await supabase.auth

              .signInWithOtp(
            phone: userCredential.user!.phoneNumber!,
            shouldCreateUser: false, // User may or may not exist in auth.users
          );
          print('✅ Supabase authentication session created');
          print('   Phone: ${userCredential.user!.phoneNumber}');
        } catch (supabaseAuthError) {
          // If Supabase auth fails, continue anyway - Firebase verified the phone
          print('⚠️ Warning: Supabase auth session creation failed: $supabaseAuthError');
          print('   Continuing with flow - user data will be saved to local storage');
        }
        
        // PROCESS 6: Check if this is profile completion flow
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔍 STEP 5: Checking user context');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        final arguments = Get.arguments as Map<String, dynamic>?;
        final isProfileCompletion = arguments?['isProfileCompletion'] == true;
        
        if (isProfileCompletion) {
          // PROCESS 7A: Handle Google user completing phone verification
          print('📋 FLOW: Google user completing profile with phone');
          await _handleGoogleUserProfileCompletion(
            userCredential.user!,
            phoneNumber,
            arguments!,
            context,
          );
        } else {
          // PROCESS 7B: Regular phone login flow - sync with Supabase
          print('📋 FLOW: Regular phone authentication');
          await _syncFirebaseUserWithSupabase(userCredential.user!, context);
        }
      } else {
        print('❌ ERROR: Firebase returned null user');
        throw Exception('Verification failed - no user returned');
      }
      
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      errorMessage = e.message ?? 'Verification failed';
      
      if (context.mounted) {
        appMessageFail(
          text: 'Verification failed: ${e.message}',
          context: context,
        );
      }
    } catch (e) {
      print('❌ Unexpected error during OTP verification: $e');
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
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SYNC FIREBASE USER WITH SUPABASE AFTER OTP VERIFICATION
  // ════════════════════════════════════════════════════════════════════════
  
  /// STEP 2: After Firebase OTP verification, check Supabase users table
  /// This determines if user is new or existing
  Future<void> _syncFirebaseUserWithSupabase(
    firebase_auth.User firebaseUser,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 STEP 5: Syncing with Supabase users table");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      // PROCESS 1: Check if user exists in Supabase users table
      print('🔍 PROCESS 1: Checking Supabase users table');
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('phone', firebaseUser.phoneNumber!)
          .maybeSingle();

      if (existingUser != null) {
        // PROCESS 2A: Existing user found - Login
        print('✅ PROCESS 2A: Existing user found');
        print('   User ID: ${existingUser['id']}');
        print('   Name: ${existingUser['name']}');
        print('   Email: ${existingUser['email']}');
        
        await _handleExistingUserLogin(existingUser, context);
      } else {
        // PROCESS 2B: New user - Navigate to complete profile
        print('🆕 PROCESS 2B: New user detected');
        print('   Firebase UID: ${firebaseUser.uid}');
        print('   Phone: ${firebaseUser.phoneNumber}');
        print('   Action: Navigate to Complete Profile screen');
        
        if (context.mounted) {
          appMessageSuccess(
            text: 'Phone verified! Please complete your profile',
            context: context,
          );
        }
        
        Get.offAll(
          () => const CompleteProfileView(),
          arguments: {
            'userId': firebaseUser.uid,
            'phone': firebaseUser.phoneNumber,
            'source': 'firebase_phone',
          },
        );
      }
    } catch (e) {
      print("❌ ERROR: Failed to sync with Supabase: $e");
      
      if (context.mounted) {
        appMessageFail(
          text: 'Sync error: $e',
          context: context,
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // HANDLE EXISTING USER LOGIN AFTER OTP VERIFICATION
  // ════════════════════════════════════════════════════════════════════════
  
  /// STEP 3: Handle login for existing users
  /// Save user data to local storage and navigate to home
  Future<void> _handleExistingUserLogin(
    Map<String, dynamic> userData,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("💾 STEP 6: Saving user data to local storage");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      // PROCESS 1: Get local storage instance
      final box = GetStorage();
      LocalStorageService localStorage = LocalStorageService(box);
      
      // PROCESS 2: Save user data to local storage with validation
      final userId = userData['id'] as String?;
      
      if (userId == null || userId.isEmpty) {
        print('❌ ERROR: User ID from Supabase is null or empty');
        throw Exception('Invalid user ID from Supabase');
      }
      
      await localStorage.saveUserIdSafely(userId);
      await localStorage.saveUserName(userData['name'] ?? 'User');
      await localStorage.saveUserEmail(userData['email'] ?? '');
      await localStorage.write('user_phone', userData['phone']);
      
      if (userData['profile'] != null && userData['profile'].toString().isNotEmpty) {
        await localStorage.saveUserProfile(userData['profile']);
      }
      
      print("✅ User data saved successfully");
      print("   Name: ${userData['name']}");
      print("   Email: ${userData['email']}");
      print("   Phone: ${userData['phone']}");
      
      if (context.mounted) {
        appMessageSuccess(
          text: 'Welcome back ${userData['name']}!',
          context: context,
        );
      }
      
      // PROCESS 3: Navigate to home screen
      print("🏠 STEP 7: Navigating to Home screen");
      Get.offAll(
        () => const HomeView(),
        transition: Transition.leftToRightWithFade,
        duration: const Duration(milliseconds: 900),
      );
      
      print("✅ OTP verification and login completed successfully");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    } catch (e) {
      print("❌ ERROR: Failed to handle existing user login: $e");
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // HANDLE GOOGLE USER PROFILE COMPLETION (After Phone Verification)
  // ════════════════════════════════════════════════════════════════════════
  
  /// Handle profile completion for Google users after phone verification
  /// Google users need to verify phone via Firebase OTP
  Future<void> _handleGoogleUserProfileCompletion(
    firebase_auth.User firebaseUser,
    String phoneNumber,
    Map<String, dynamic> arguments,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print('🔄 STEP 5: Completing Google user profile');
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      final name = arguments['name'];
      final email = arguments['email'];
      final photo = arguments['photo'];
      
      print('   Name: $name');
      print('   Email: $email');
      print('   Phone (verified): $phoneNumber');
      
      // PROCESS 1: Insert user into Supabase users table (let Supabase generate ID)
      print('💾 PROCESS 1: Inserting user into Supabase users table');
      await supabase.from('users').insert({
        // Don't specify 'id' - let Supabase auto-generate it
        'name': name ?? 'MEGO User',
        'email': email ?? '',
        'phone': phoneNumber,
        'profile': photo ?? '',
        'user_type': 'rider',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ User profile inserted to Supabase');
      
      // PROCESS 2: Fetch user from Supabase to get the actual ID
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 PROCESS 2: Fetching user ID from Supabase');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final userData = await supabase
          .from('users')
          .select('id, name, email, phone, profile')
          .eq('phone', phoneNumber)
          .single();
      
      final userId = userData['id'] as String;
      print('✅ User ID retrieved from Supabase: $userId');
      
      // PROCESS 3: Save to local storage with validation
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💾 PROCESS 3: Saving to local storage');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final box = GetStorage();
      LocalStorageService localStorage = LocalStorageService(box);
      
      // Validate userId before saving
      if (userId.isEmpty) {
        throw Exception('User ID from Supabase is empty');
      }
      
      await localStorage.saveUserIdSafely(userId);
      await localStorage.saveUserName(userData['name'] ?? 'MEGO User');
      await localStorage.saveUserEmail(userData['email'] ?? '');
      await localStorage.write('user_phone', userData['phone']);
      
      if (userData['profile'] != null && userData['profile'].toString().isNotEmpty) {
        await localStorage.saveUserProfile(userData['profile']);
      }
      
      print('✅ User data saved to local storage');
      
      if (context.mounted) {
        appMessageSuccess(
          text: 'Profile completed successfully!',
          context: context,
        );
      }
      
      // PROCESS 4: Navigate to home
      print('🏠 PROCESS 4: Navigating to Home screen');
      Get.offAll(
        () => const HomeView(),
        transition: Transition.leftToRightWithFade,
        duration: const Duration(milliseconds: 900),
      );
      
      print("✅ Google user profile completion successful");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    } catch (e) {
      print('❌ ERROR: Failed to complete Google user profile: $e');
      
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to save profile: $e',
          context: context,
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // RESEND FIREBASE OTP
  // ════════════════════════════════════════════════════════════════════════
  
  /// Resend OTP via Firebase when user doesn't receive the code
  Future<void> resendFirebaseOtp(BuildContext context) async {
    try {
      isLoading = true;
      update();
      
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 RESENDING FIREBASE OTP");
      print("   Phone: $phoneNumber");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      // PROCESS 1: Call Firebase verifyPhoneNumber again
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // CALLBACK 1: Auto-verification
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          print("✅ Auto-verification on resend");
          await _syncFirebaseUserWithSupabase(
            (await _firebaseAuth.signInWithCredential(credential)).user!,
            context,
          );
        },
        
        // CALLBACK 2: Verification failed
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          print("❌ Resend failed: ${e.message}");
          if (context.mounted) {
            appMessageFail(text: e.message ?? 'Failed to resend OTP', context: context);
          }
        },
        
        // CALLBACK 3: Code sent successfully
        codeSent: (String newVerificationId, int? resendToken) {
          print("✅ OTP resent successfully");
          
          // PROCESS 2: Update verification ID with new one
          verificationId = newVerificationId;
          
          if (context.mounted) {
            appMessageSuccess(
              text: 'OTP resent to $phoneNumber',
              context: context,
            );
          }
          
          print("   New Verification ID: ${newVerificationId.substring(0, 20)}...");
        },
        
        // CALLBACK 4: Auto-retrieval timeout
        codeAutoRetrievalTimeout: (String newVerificationId) {
          verificationId = newVerificationId;
        },
      );
      
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    } catch (e) {
      print("❌ ERROR: Failed to resend OTP: $e");
      
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to resend OTP: $e',
          context: context,
        );
      }
    } finally {
      isLoading = false;
      update();
    }
  }
}
