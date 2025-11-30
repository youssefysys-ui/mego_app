import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../complete_profile/views/complete_profile_view.dart';
import '../save_data/save_user_data.dart';

class VerifyOtpController extends GetxController {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final SupabaseClient supabase = Supabase.instance.client;
  
  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();
  final otp5Controller = TextEditingController();
  final otp6Controller = TextEditingController();
  
  final otp1FocusNode = FocusNode();
  final otp2FocusNode = FocusNode();
  final otp3FocusNode = FocusNode();
  final otp4FocusNode = FocusNode();
  final otp5FocusNode = FocusNode();
  final otp6FocusNode = FocusNode();
  
  bool isLoading = false;
  String errorMessage = '';
  
  late String phoneNumber;
  late String verificationId;
  
  @override
  void onInit() {
    super.onInit();
    
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
  
  Future<void> verifyOtp(BuildContext context, String phoneNumber) async {
    try {
      isLoading = true;
      errorMessage = '';
      update();
      
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔐 FIREBASE OTP VERIFICATION: Starting");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      final otpCode = getOtpCode();
      
      if (otpCode.length != 6) {
        print("❌ Validation failed: OTP code incomplete");
        throw Exception('Please enter the complete OTP code');
      }
      
      print('📱 STEP 1: OTP code collected from input fields');
      print('   Phone: $phoneNumber');
      print('   OTP Code: $otpCode');
      print('   Verification ID: ${verificationId.substring(0, 20)}...');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔑 STEP 2: Creating Firebase phone credential');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      
      print('✅ Credential created successfully');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔐 STEP 3: Signing in with Firebase credential');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print('✅ Firebase OTP verification successful!');
        print('   User ID: ${userCredential.user!.uid}');
        print('   Phone: ${userCredential.user!.phoneNumber}');
        
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔐 STEP 4: Authenticating with Supabase');
        print('   Firebase phone verification completed - creating Supabase session');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        try {
          await supabase.auth.signInWithOtp(
            phone: userCredential.user!.phoneNumber!,
            shouldCreateUser: false,
          );
          print('✅ Supabase authentication session created');
          print('   Phone: ${userCredential.user!.phoneNumber}');
        } catch (supabaseAuthError) {
          print('⚠️ Warning: Supabase auth session creation failed: $supabaseAuthError');
          print('   Continuing with flow - user data will be saved to local storage');
        }
        
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔍 STEP 5: Checking user context');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        final arguments = Get.arguments as Map<String, dynamic>?;
        final isProfileCompletion = arguments?['isProfileCompletion'] == true;
        
        if (isProfileCompletion) {
          print('📋 FLOW: Google user completing profile with phone');
          await _handleGoogleUserProfileCompletion(
            userCredential.user!,
            phoneNumber,
            arguments!,
            context,
          );
        } else {
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

  Future<void> _syncFirebaseUserWithSupabase(
    firebase_auth.User firebaseUser,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 STEP 5: Syncing with Supabase users table");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      print('🔍 PROCESS 1: Checking Supabase users table');
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('phone', firebaseUser.phoneNumber!)
          .maybeSingle();

      if (existingUser != null) {
        print('✅ PROCESS 2A: Existing user found');
        print('   User ID: ${existingUser['id']}');
        print('   Name: ${existingUser['name']}');
        print('   Email: ${existingUser['email']}');
        
        await _handleExistingUserLogin(existingUser, context);
      } else {
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

  Future<void> _handleExistingUserLogin(
    Map<String, dynamic> userData,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("💾 STEP 6: Saving user data to local storage");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      await SaveUserData.toLocalStorage(userData: userData);
      
      if (context.mounted) {
        appMessageSuccess(
          text: 'Welcome back ${userData['name']}!',
          context: context,
        );
      }
      
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
      
      print('💾 PROCESS 1: Inserting user into Supabase users table');
      await supabase.from('users').insert({
        'name': name ?? 'MEGO User',
        'email': email ?? '',
        'phone': phoneNumber,
        'profile': photo ?? '',
        'user_type': 'rider',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ User profile inserted to Supabase');
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 PROCESS 2: Fetching user ID from Supabase');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final userData = await supabase
          .from('users')
          .select('id, name, email, phone, profile')
          .eq('phone', phoneNumber)
          .single();
      
      print('✅ User ID retrieved from Supabase: ${userData['id']}');
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💾 PROCESS 3: Saving to local storage');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      await SaveUserData.toLocalStorage(
        userData: userData,
        fallbackProfile: photo,
      );
      
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

  Future<void> resendFirebaseOtp(BuildContext context) async {
    try {
      isLoading = true;
      update();
      
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 RESENDING FIREBASE OTP");
      print("   Phone: $phoneNumber");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

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
