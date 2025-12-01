import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/auth/verify_otp/verify_otp_view.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/complete_profile/views/complete_profile_view.dart';
import '../../save_data/save_user_data.dart';
import 'package:mego_app/features/home/bindings/home_binding.dart';

class LoginController extends GetxController {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final SupabaseClient supabase = Supabase.instance.client;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  String? _verificationId;

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> sendFirebaseOTP({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("📱 STEP 1: Starting Firebase Phone Auth");
      print("   Phone Number: $phoneNumber");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          print("✅ CALLBACK: Auto-verification completed");
          await _signInWithFirebaseCredential(credential, context);
        },
        
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          print("❌ CALLBACK: Verification failed");
          print("   Error Code: ${e.code}");
          print("   Error Message: ${e.message}");
          isLoading.value = false;
          
          if (context.mounted) {
            appMessageFail(
              text: e.message ?? 'Verification failed',
              context: context,
            );
          }
        },
        
        codeSent: (String verificationId, int? resendToken) {
          print("✅ CALLBACK: OTP sent successfully via Firebase");
          print("   Verification ID: ${verificationId.substring(0, 20)}...");
          
          _verificationId = verificationId;
          isLoading.value = false;
          
          if (context.mounted) {
            appMessageSuccess(
              text: 'OTP sent to $phoneNumber',
              context: context,
            );
          }
          
          print("🔄 STEP 2: Navigating to OTP verification screen");
          Get.to(() => VerifyOtpView(phoneNumber: phoneNumber), arguments: {
            'verificationId': verificationId,
            'phoneNumber': phoneNumber,
            'source': 'firebase_phone',
          });
        },
        
        codeAutoRetrievalTimeout: (String verificationId) {
          print("⏰ CALLBACK: Auto-retrieval timeout");
          _verificationId = verificationId;
        },
      );

      return true;
    } catch (e) {
      print("❌ ERROR: Unexpected error sending Firebase OTP");
      print("   Error: $e");
      isLoading.value = false;
      
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to send OTP: $e',
          context: context,
        );
      }
      return false;
    }
  }

  Future<void> _signInWithFirebaseCredential(
    firebase_auth.PhoneAuthCredential credential,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔐 STEP 3: Signing in with Firebase credential");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        print("✅ Firebase sign-in successful");
        print("   User ID: ${userCredential.user!.uid}");
        print("   Phone: ${userCredential.user!.phoneNumber}");
        
        await _syncFirebaseUserWithSupabase(userCredential.user!, context);
      }
    } catch (e) {
      print("❌ ERROR: Firebase sign-in failed");
      print("   Error: $e");
      
      if (context.mounted) {
        appMessageFail(
          text: 'Sign in failed: $e',
          context: context,
        );
      }
    }
  }

  Future<void> _syncFirebaseUserWithSupabase(
    firebase_auth.User firebaseUser,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 STEP 4: Syncing Firebase user with Supabase");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      print("🔍 PROCESS 1: Checking Supabase users table");
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('phone', firebaseUser.phoneNumber!)
          .maybeSingle();

      if (existingUser != null) {
        print("✅ PROCESS 2A: Existing user found");
        print("   User ID: ${existingUser['id']}");
        print("   Name: ${existingUser['name']}");
        print("   Email: ${existingUser['email']}");
        
        await _handleExistingUserLogin(existingUser, context);
      } else {
        print("🆕 PROCESS 2B: New user detected");
        print("   Firebase UID: ${firebaseUser.uid}");
        print("   Phone: ${firebaseUser.phoneNumber}");
        print("   Action: Navigate to Complete Profile screen");
        
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
      print("❌ ERROR: Supabase sync failed");
      print("   Error: $e");
      
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
      print("💾 STEP 5: Saving user data to local storage");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      await SaveUserData.toLocalStorage(userData: userData);
      
      if (context.mounted) {
        appMessageSuccess(
          text: 'Welcome back ${userData['name']}!',
          context: context,
        );
      }
      
      print("🏠 STEP 6: Navigating to Home screen");
      Get.offAll(
        () => const HomeView(),
        binding: HomeBinding(),
        transition: Transition.leftToRightWithFade,
        duration: const Duration(milliseconds: 900),
      );
      
      print("✅ Login process completed successfully");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    } catch (e) {
      print("❌ ERROR: Failed to handle existing user login");
      print("   Error: $e");
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

    await sendFirebaseOTP(
      phoneNumber: phoneController.text.trim(),
      context: context,
    );
  }

  Future<Map<String, dynamic>> _ensureUserRecord({
    required User user,
    String? displayName,
    String? photoUrl,
    String? source,
  }) async {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🗄️ DATABASE CHECK: Verifying user record");
    print("   User ID: ${user.id}");
    print("   Source: $source");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    
    try {
      print('🔍 PROCESS 1: Querying Supabase users table');
      final existing = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        print('✅ PROCESS 2A: Existing user record found');
        print('   🆔 ID: ${existing['id']}');
        print('   👤 Name: ${existing['name']}');
        print('   📧 Email: ${existing['email']}');
        print('   📱 Phone: ${existing['phone'] ?? 'Not set'}');
        print('   🏷️ User Type: ${existing['user_type']}');
        print('   🖼️ Profile: ${existing['profile'] ?? 'No profile image'}');
        
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

  Future<void> googleLogin(BuildContext context) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔐 GOOGLE LOGIN: Starting Google Sign-In process");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      print("📱 STEP 1: Initializing Google Sign-In");
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
        '851699318144-qj34crl5g2avebai2mu1p5r3k33hm1eu.apps.googleusercontent.com',
        clientId:
        '851699318144-k0tr7281tkbcsj4u7vbleo3obna75sfu.apps.googleusercontent.com',
      );

      print("🔄 STEP 2: Clearing previous Google session");
      await googleSignIn.signOut();

      print("👤 STEP 3: Showing Google Sign-In prompt");
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print("❌ Google Sign-In cancelled by user");
        appMessageFail(text: 'Google Sign-In cancelled', context: context);
        return;
      }
      
      print("✅ STEP 4: User selected Google account");
      print("   Email: ${googleUser.email}");
      print("   Display Name: ${googleUser.displayName}");

      print("🔑 STEP 5: Retrieving Google authentication tokens");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        print("❌ Failed to retrieve Google tokens");
        appMessageFail(
          text: 'Failed to authenticate with Google',
          context: context,
        );
        return;
      }
      
      print("✅ STEP 6: Google tokens retrieved successfully");

      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 STEP 7: Authenticating with Supabase");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      print("✅ STEP 8: Supabase authentication successful");

      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("📊 STEP 9: Extracting Google user data");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      final String userName = googleUser.displayName ?? "No Name";
      final String userEmail = googleUser.email;
      final String userPhoto = googleUser.photoUrl ?? "https://www.svgrepo.com/show/384670/account-avatar-profile-user.svg";
      
      print("   👤 Name: $userName");
      print("   📧 Email: $userEmail");
      print("   🖼️ Photo: ${userPhoto.substring(0, 50)}...");

      if (response.user != null) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print('🔍 STEP 10: Checking Supabase users table BY EMAIL');
        print('   Email: $userEmail');
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        final existingUser = await supabase
            .from('users')
            .select('id, name, email, phone, profile')
            .eq('email', userEmail)
            .maybeSingle();

        if (existingUser == null) {
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          print('🆕 STEP 11A: NEW USER DETECTED');
          print('   Email not found in users table');
          print('   Action: Navigate to Complete Profile screen');
          print('   User will need to add phone number');
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          
          appMessageSuccess(
            text: 'Welcome! Please complete your profile',
            context: context,
          );
          
          Get.offAll(
            () => const CompleteProfileView(),
            arguments: {
              'userId': response.user!.id,
              'source': 'google',
              'name': userName,
              'email': userEmail,
              'photo': userPhoto,
            },
          );
          return;
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print('✅ STEP 11B: EXISTING USER FOUND BY EMAIL');
        print('   User ID: ${existingUser['id']}');
        print('   Name: ${existingUser['name']}');
        print('   Email: ${existingUser['email']}');
        print('   Action: Login and navigate to Home');
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        print('💾 STEP 12: Saving user data to local storage');
        
        await SaveUserData.toLocalStorage(
          userData: existingUser,
          fallbackProfile: userPhoto,
        );

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print('🏠 STEP 13: Navigating to Home screen');
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        appMessageSuccess(
          text: 'Welcome back ${existingUser['name']}!',
          context: context,
        );

        Get.offAll(
          () => const HomeView(),
          binding: HomeBinding(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        
        print("✅ Google Login completed successfully");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        return;
      }

      print("❌ ERROR: Supabase authentication returned null user");
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
