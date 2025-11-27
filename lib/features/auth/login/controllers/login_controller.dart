

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/auth/verify_otp/verify_otp_view.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repo/login_repo.dart';

class LoginController extends GetxController {
  // Dependencies
  //final LoginRepository _loginRepository;
  
  // Text controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  
  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Constructor with dependency injection
  //LoginController(this._loginRepository);
  
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

  /// Google Sign-In function with Supabase integration
  Future<void> googleLogin(BuildContext context) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🚀 STEP 1: Starting Google Sign-In Process");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      isLoading.value = true;
      errorMessage.value = '';
      print("✅ STEP 1.1: Loading state set to true");
      print("✅ STEP 1.2: Error message cleared");

      // Initialize Google Sign-In with Web Client ID
      print("\n📱 STEP 2: Initializing Google Sign-In");
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
        '851699318144-k0tr7281tkbcsj4u7vbleo3obna75sfu.apps.googleusercontent.com',
        //'851699318144-nhok4jk0b1rjc7vf1re1vjleuok5e7dh.apps.googleusercontent.com',
      );
      print("✅ STEP 2.1: Google Sign-In instance created");
      print("   📋 Scopes: email, profile");
      print("   🔑 Server Client ID: 851699318144-k0tr7281tkbcsj4u7vbleo3obna75sfu.apps.googleusercontent.com");

      // Sign out first to ensure fresh login
      print("\n🔄 STEP 3: Clearing any existing Google session");
      await googleSignIn.signOut();
      print("✅ STEP 3.1: Successfully signed out from previous session");

      // Trigger Google Sign-In
      print("\n🔐 STEP 4: Triggering Google Sign-In UI");
      print("⏳ Waiting for user to select Google account...");
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      print("G==="+googleUser.toString());
      if (googleUser == null) {
        print("\n❌ STEP 4.1: User cancelled Google Sign-In");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        if (context.mounted) {
          appMessageFail(
            text: 'Google Sign-In cancelled',
            context: context,
          );
        }
        return;
      }

      print("\n✅ STEP 4.2: User selected Google account");
      print("   👤 Display Name: ${googleUser.displayName}");
      print("   📧 Email: ${googleUser.email}");
      print("   🆔 Google User ID: ${googleUser.id}");
      print("   📸 Photo URL: ${googleUser.photoUrl ?? 'No photo'}");

      // Get authentication tokens
      print("\n🔑 STEP 5: Requesting Google authentication tokens");
      print("⏳ Getting authentication details from Google...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("✅ STEP 5.1: Google authentication object received");
      
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      print("\n🔍 STEP 6: Validating received tokens");
      print("   Access Token: ${accessToken != null ? '✅ Present (${accessToken.length} chars)' : '❌ Missing'}");
      print("   ID Token: ${idToken != null ? '✅ Present (${idToken.length} chars)' : '❌ Missing'}");

      if (accessToken == null || idToken == null) {
        print("\n❌ STEP 6.1: Failed to obtain required tokens");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        if (context.mounted) {
          appMessageFail(
            text: 'Failed to authenticate with Google',
            context: context,
          );
        }
        return;
      }

      print("✅ STEP 6.2: All required tokens validated successfully");
      print("   🎟️ Access Token (first 30 chars): ${accessToken.substring(0, 30)}...");
      print("   🎟️ ID Token (first 30 chars): ${idToken.substring(0, 30)}...");

      // Sign in to Supabase
      print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 STEP 7: Authenticating with Supabase");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("⏳ Sending tokens to Supabase...");
      
      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      print("\n✅ STEP 7.1: Supabase authentication response received");
      print("🔍 STEP 8: Analyzing Supabase response");

      if (response.user != null) {
        print("\n✅ STEP 8.1: User authenticated successfully!");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print("📋 USER DETAILS:");
        print("   🆔 User ID: ${response.user!.id}");
        print("   📧 Email: ${response.user!.email}");
        print("   📱 Phone: ${response.user!.phone ?? 'Not set'}");
        print("   ⏰ Created At: ${response.user!.createdAt}");
        print("   🔄 Last Sign In: ${response.user!.lastSignInAt}");
        print("   ✅ Email Confirmed: ${response.user!.emailConfirmedAt != null}");
        
        if (response.session != null) {
          print("\n🔐 SESSION DETAILS:");
          print("   ✅ Session Active: Yes");
          print("   🎫 Access Token (first 30 chars): ${response.session!.accessToken.substring(0, 30)}...");
          print("   ⏰ Expires At: ${response.session!.expiresAt}");
          print("   🔄 Refresh Token Present: ${response.session!.refreshToken != null}");
        }
        
        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print("🎉 STEP 9: Login completed successfully!");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        if (context.mounted) {
          print("\n✅ STEP 9.1: Showing success message to user");
          appMessageSuccess(
            text: 'Welcome ${response.user!.email ?? 'User'}!',
            context: context,
          );
        }

        // Navigate to home
        print("\n🏠 STEP 10: Navigating to Home Screen");
        print("   🔄 Transition: Fade In");
        print("   ⏱️ Duration: 500ms");
        
        Get.offAll(
          () => const HomeView(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        
        print("✅ STEP 10.1: Navigation initiated");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print("✨ Google Sign-In Process Completed Successfully!");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        
      } else {
        print("\n❌ STEP 8.2: Supabase authentication failed");
        print("   ⚠️ No user data returned from Supabase");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        if (context.mounted) {
          appMessageFail(
            text: 'Failed to sign in with Google',
            context: context,
          );
        }
      }

    } on AuthException catch (e) {
      print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("❌ SUPABASE AUTHENTICATION ERROR");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔴 Error Type: AuthException");
      print("📊 Status Code: ${e.statusCode}");
      print("💬 Error Message: ${e.message}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
      
      if (context.mounted) {
        appMessageFail(
          text: 'Authentication error: ${e.message}',
          context: context,
        );
      }
    } catch (e, stackTrace) {
      print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("❌ UNEXPECTED ERROR");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔴 Error Type: ${e.runtimeType}");
      print("💬 Error Message: $e");
      print("\n📋 Stack Trace:");
      print(stackTrace);
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
      
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to sign in: $e',
          context: context,
        );
      }
    } finally {
      isLoading.value = false;
      print("🔚 FINAL: Loading state set to false");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    }
  }
  ///
  ///
  // Future<void> googleLogin(BuildContext context) async {
  //   try {
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //     print("🚀 STATE: Starting Google Sign-In Process");
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //
  //     isLoading.value = true;
  //     errorMessage.value = '';
  //
  //     // Initialize Google Sign-In
  //     print("📱 STATE: Initializing Google Sign-In");
  //     final GoogleSignIn googleSignIn = GoogleSignIn(
  //       scopes: ['email', 'profile'],
  //     );
  //
  //     // Check if user is already signed in
  //     print("🔍 STATE: Checking for existing Google session");
  //     await googleSignIn.signOut(); // Sign out first to ensure fresh login
  //     print("✅ STATE: Cleared any existing Google session");
  //
  //     // Trigger Google Sign-In flow
  //     print("🔐 STATE: Triggering Google Sign-In UI");
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //
  //     if (googleUser == null) {
  //       print("❌ STATE: User cancelled Google Sign-In");
  //       if (context.mounted) {
  //         appMessageFail(
  //           text: 'Google Sign-In cancelled',
  //           context: context,
  //         );
  //       }
  //       return;
  //     }
  //
  //     print("✅ STATE: Google user selected");
  //     print("   📧 Email: ${googleUser.email}");
  //     print("   👤 Name: ${googleUser.displayName}");
  //     print("   🆔 ID: ${googleUser.id}");
  //
  //     // Get Google authentication tokens
  //     print("🔑 STATE: Requesting Google authentication tokens");
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final String? accessToken = googleAuth.accessToken;
  //     final String? idToken = googleAuth.idToken;
  //
  //     print("🔍 STATE: Validating tokens");
  //     print("   Access Token: ${accessToken != null ? '✅ Present' : '❌ Missing'}");
  //     print("   ID Token: ${idToken != null ? '✅ Present' : '❌ Missing'}");
  //
  //     if (accessToken == null || idToken == null) {
  //       print("❌ STATE: Failed to obtain Google tokens");
  //       if (context.mounted) {
  //         appMessageFail(
  //           text: 'Failed to authenticate with Google',
  //           context: context,
  //         );
  //       }
  //       return;
  //     }
  //
  //     print("✅ STATE: Google tokens obtained successfully");
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //     print("🔄 STATE: Authenticating with Supabase");
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //
  //     // Sign in to Supabase with Google credentials
  //     final AuthResponse response = await supabase.auth.signInWithIdToken(
  //       provider: OAuthProvider.google,
  //       idToken: idToken,
  //       accessToken: accessToken,
  //     );
  //
  //     print("🔍 STATE: Checking Supabase authentication response");
  //
  //     if (response.user != null) {
  //       print("✅ STATE: Supabase authentication successful");
  //       print("   🆔 User ID: ${response.user!.id}");
  //       print("   📧 Email: ${response.user!.email}");
  //       print("   ⏰ Created: ${response.user!.createdAt}");
  //       print("   🔄 Last Sign In: ${response.user!.lastSignInAt}");
  //
  //       if (response.session != null) {
  //         print("   🔐 Session: Active");
  //         print("   🎫 Access Token: ${response.session!.accessToken.substring(0, 20)}...");
  //       }
  //
  //       print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //       print("🎉 STATE: Login completed successfully!");
  //       print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //
  //       if (context.mounted) {
  //         appMessageSuccess(
  //           text: 'Welcome ${response.user!.email ?? 'User'}!',
  //           context: context,
  //         );
  //       }
  //
  //       // Navigate to home screen
  //       print("🏠 STATE: Navigating to Home Screen");
  //       Get.offAll(
  //         () => const HomeView(),
  //         transition: Transition.fadeIn,
  //         duration: const Duration(milliseconds: 500),
  //       );
  //
  //       print("✅ STATE: Navigation completed");
  //
  //     } else {
  //       print("❌ STATE: Supabase authentication failed - No user returned");
  //       if (context.mounted) {
  //         appMessageFail(
  //           text: 'Failed to sign in with Google',
  //           context: context,
  //         );
  //       }
  //     }
  //
  //   } on AuthException catch (e) {
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //     print("❌ STATE: Supabase Authentication Error");
  //     print("   Error Code: ${e.statusCode}");
  //     print("   Error Message: ${e.message}");
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //
  //     if (context.mounted) {
  //       appMessageFail(
  //         text: 'Authentication error: ${e.message}',
  //         context: context,
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //     print("❌ STATE: Unexpected Error");
  //     print("   Error: $e");
  //     print("   Stack Trace: $stackTrace");
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  //
  //     if (context.mounted) {
  //       appMessageFail(
  //         text: 'Failed to sign in with Google: $e',
  //         context: context,
  //       );
  //     }
  //   } finally {
  //     isLoading.value = false;
  //     print("🔚 STATE: Google Sign-In process ended");
  //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
  //   }
  // }



  // Future<void> signOut() async {
  //   try {
  //     await _loginRepository.signOut();
  //     _clearForm();
  //   } catch (e) {
  //     // Handle sign out error
  //     print('Sign out error: $e');
  //   }
  // }
  //
  // User? getCurrentUser() {
  //   return _loginRepository.getCurrentUser();
  // }
  //
  // Session? getCurrentSession() {
  //   return _loginRepository.getCurrentSession();
  // }

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