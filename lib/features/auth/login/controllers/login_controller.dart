import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/auth/verify_otp/verify_otp_view.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/local_db/local_db.dart';
import '../../../auth/complete_profile/views/complete_profile_view.dart';

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

  /// Ensure a row exists in 'users' table for the authenticated user.
  /// Returns user data map with existed status and user details.
  Future<Map<String, dynamic>> _ensureUserRecord({
    required User user,
    String? displayName,
    String? photoUrl,
    String? source, // 'phone' or 'google'
  }) async {
    print("USER===" + user.toString());
    try {
      print('\n🗄️ STEP DB-1: Checking users table for existing record');
      final existing = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      print("EX==" + existing.toString());
      if (existing != null) {
        print('✅ STEP DB-2: Existing user found in users table');
        print('   🆔 id: ${existing['id']}');
        print('   👤 name: ${existing['name']}');
        print('   📧 email: ${existing['email']}');
        print('   📱 phone: ${existing['phone']}');
        print('   🏷️ user_type: ${existing['user_type']}');
        print('   🖼️ profile: ${existing['profile']}');
        
        return {
          'existed': true,
          'userId': existing['id'],
          'userName': existing['name'],
          'userEmail': existing['email'],
          'userPhone': existing['phone'],
          'userPhoto': existing['profile'],
          'source': source ?? 'unknown',
        };
      }

      print('🆕 STEP DB-3: No user row found - New user detected');
      print("   Will need to complete profile");
      
      // Return new user data (don't insert yet, let complete profile do it)
      return {
        'existed': false,
        'userId': user.id,
        'userName': displayName ?? user.userMetadata?['name'] ?? user.email ?? 'MEGO User',
        'userEmail': user.email ?? '',
        'userPhone': user.phone ?? '',
        'userPhoto': photoUrl ?? user.userMetadata?['avatar_url'] ?? '',
        'source': source ?? 'unknown',
      };
    } catch (e, st) {
      print('❌ STEP DB-ERR: Failed ensuring user record: $e');
      print(st);
      // If DB check fails, treat as new to be safe
      return {
        'existed': false,
        'userId': user.id,
        'userName': displayName ?? 'MEGO User',
        'userEmail': user.email ?? '',
        'userPhone': user.phone ?? '',
        'userPhoto': photoUrl ?? '',
        'source': source ?? 'unknown',
      };
    }
  }

  /// Google Sign-In function with Supabase integration
  Future<void> googleLogin(BuildContext context) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
        '851699318144-qj34crl5g2avebai2mu1p5r3k33hm1eu.apps.googleusercontent.com',
        clientId:
        '851699318144-k0tr7281tkbcsj4u7vbleo3obna75sfu.apps.googleusercontent.com',
      );

      await googleSignIn.signOut(); // force fresh login

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        appMessageFail(text: 'Google Sign-In cancelled', context: context);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        appMessageFail(
          text: 'Failed to authenticate with Google',
          context: context,
        );
        return;
      }

      // ---------------------------
      // SUPABASE AUTH
      // ---------------------------
      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // ---------------------------
      // Extract Google User Data
      // ---------------------------
      final String userName = googleUser.displayName ?? "No Name";
      final String userEmail = googleUser.email;
      final String userPhoto = googleUser.photoUrl ?? "https://www.svgrepo.com/show/384670/account-avatar-profile-user.svg";

      // ---------------------------
      // HANDLE SUPABASE USER
      // ---------------------------
      if (response.user != null) {
        print('✅ STEP 7: Checking user record in database');
        
        final userRecord = await _ensureUserRecord(
          user: response.user!,
          displayName: userName,
          photoUrl: userPhoto,
          source: 'google',
        );

        if (!userRecord['existed']) {
          print('🆕 STEP 8: New user detected - Navigate to Complete Profile');
          appMessageSuccess(
            text: 'Welcome! Please complete your profile',
            context: context,
          );
          
          // Navigate to complete profile for phone verification
          Get.offAll(
            () => const CompleteProfileView(),
            arguments: {
              'userId': userRecord['userId'],
              'source': 'google',
              'name': userName,
              'email': userEmail,
              'photo': userPhoto,
            },
          );
          return;
        }

        print('✅ STEP 8: Existing user - Save to local storage');
        // Existing user → save data locally
        final box = GetStorage();
        LocalStorageService localStorage = Get.put(LocalStorageService(box));
        
        await localStorage.saveUserEmail(userRecord['userEmail'] ?? userEmail);
        await localStorage.saveUserName(userRecord['userName'] ?? userName);
        await localStorage.saveUserProfile(userRecord['userPhoto'] ?? userPhoto);
        if (userRecord['userPhone'] != null && userRecord['userPhone'].toString().isNotEmpty) {
          await localStorage.write('user_phone', userRecord['userPhone']);
        }

        print('✅ STEP 9: Navigate to Home');
        appMessageSuccess(
          text: 'Welcome back ${userRecord['userName']}!',
          context: context,
        );

        Get.offAll(() => const HomeView(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
        return;
      }

      // ---------------------------
      // SUPABASE FAILED → still save user data from Google
      // ---------------------------
      appMessageFail(
        text: 'Failed to sign in with Google',
        context: context,
      );

    } catch (e) {
      print("❌ Error during Google Sign-In: $e");
      appMessageFail(text: 'Sign in failed: $e', context: context);
    } finally {
      isLoading.value = false;
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
