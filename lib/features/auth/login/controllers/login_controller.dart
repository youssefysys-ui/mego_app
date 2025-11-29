import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/auth/verify_otp/verify_otp_view.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/local_db/local_db.dart';
import '../../../auth/complete_profile/views/complete_profile_view.dart';

class LoginController extends GetxController {
  // ════════════════════════════════════════════════════════════════════════
  // DEPENDENCIES & CONTROLLERS
  // ════════════════════════════════════════════════════════════════════════
  
  /// Firebase Auth instance for phone authentication with OTP
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  
  /// Supabase client for user data management (no OTP)
  final SupabaseClient supabase = Supabase.instance.client;

  // Text controllers for form inputs
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  /// Store verification ID from Firebase for OTP verification
  String? _verificationId;

  // Constructor with dependency injection
  //LoginController(this._loginRepository);

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ════════════════════════════════════════════════════════════════════════
  // FIREBASE PHONE AUTHENTICATION - SEND OTP
  // ════════════════════════════════════════════════════════════════════════
  
  /// STEP 1: Send OTP via Firebase Phone Authentication
  /// This method sends OTP to the user's phone number using Firebase
  /// Firebase handles OTP generation and delivery (no Twilio needed)
  Future<bool> sendFirebaseOTP({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      // PROCESS 1: Set loading state and clear previous errors
      isLoading.value = true;
      errorMessage.value = '';
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("📱 STEP 1: Starting Firebase Phone Auth");
      print("   Phone Number: $phoneNumber");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      // PROCESS 2: Call Firebase verifyPhoneNumber method
      // This will trigger OTP sending via Firebase
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // CALLBACK 1: Auto-verification completed (instant verification)
        // This happens on some Android devices when SMS permission is granted
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          print("✅ CALLBACK: Auto-verification completed");
          await _signInWithFirebaseCredential(credential, context);
        },
        
        // CALLBACK 2: Verification failed
        // This happens when Firebase rejects the phone number or encounters error
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
        
        // CALLBACK 3: OTP code sent successfully
        // This is the main callback - OTP has been sent to user's phone
        codeSent: (String verificationId, int? resendToken) {
          print("✅ CALLBACK: OTP sent successfully via Firebase");
          print("   Verification ID: ${verificationId.substring(0, 20)}...");
          
          // PROCESS 3: Store verification ID for later OTP verification
          _verificationId = verificationId;
          isLoading.value = false;
          
          if (context.mounted) {
            appMessageSuccess(
              text: 'OTP sent to $phoneNumber',
              context: context,
            );
          }
          
          // PROCESS 4: Navigate to OTP verification screen
          print("🔄 STEP 2: Navigating to OTP verification screen");
          Get.to(() => VerifyOtpView(phoneNumber: phoneNumber), arguments: {
            'verificationId': verificationId,
            'phoneNumber': phoneNumber,
            'source': 'firebase_phone',
          });
        },
        
        // CALLBACK 4: Code auto-retrieval timeout
        // This is called after the timeout duration
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

  // ════════════════════════════════════════════════════════════════════════
  // FIREBASE CREDENTIAL SIGN IN (Auto-verification or Manual OTP)
  // ════════════════════════════════════════════════════════════════════════
  
  /// STEP 2: Sign in with Firebase credential after OTP verification
  /// This method is called either automatically or after manual OTP entry
  Future<void> _signInWithFirebaseCredential(
    firebase_auth.PhoneAuthCredential credential,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔐 STEP 3: Signing in with Firebase credential");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      // PROCESS 1: Sign in to Firebase with the phone credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        print("✅ Firebase sign-in successful");
        print("   User ID: ${userCredential.user!.uid}");
        print("   Phone: ${userCredential.user!.phoneNumber}");
        
        // PROCESS 2: Sync Firebase user with Supabase database
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

  // ════════════════════════════════════════════════════════════════════════
  // SYNC FIREBASE USER WITH SUPABASE (NO OTP VERIFICATION IN SUPABASE)
  // ════════════════════════════════════════════════════════════════════════
  
  /// STEP 3: Check if user exists in Supabase and handle accordingly
  /// Firebase handled the OTP - now we just manage user data in Supabase
  Future<void> _syncFirebaseUserWithSupabase(
    firebase_auth.User firebaseUser,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 STEP 4: Syncing Firebase user with Supabase");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      // PROCESS 1: Check if user exists in Supabase users table
      print("🔍 PROCESS 1: Checking Supabase users table");
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('phone', firebaseUser.phoneNumber!)
          .maybeSingle();

      if (existingUser != null) {
        // PROCESS 2A: Existing user found - Login
        print("✅ PROCESS 2A: Existing user found");
        print("   User ID: ${existingUser['id']}");
        print("   Name: ${existingUser['name']}");
        print("   Email: ${existingUser['email']}");
        
        await _handleExistingUserLogin(existingUser, context);
      } else {
        // PROCESS 2B: New user - Navigate to complete profile
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

  // ════════════════════════════════════════════════════════════════════════
  // HANDLE EXISTING USER LOGIN
  // ════════════════════════════════════════════════════════════════════════
  
  /// STEP 4: Handle login for existing users
  /// Save user data to local storage and navigate to home
  Future<void> _handleExistingUserLogin(
    Map<String, dynamic> userData,
    BuildContext context,
  ) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("💾 STEP 5: Saving user data to local storage");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      // PROCESS 1: Get local storage instance
      final box = GetStorage();
      LocalStorageService localStorage = Get.put(LocalStorageService(box));
      
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
      print("🏠 STEP 6: Navigating to Home screen");
      Get.offAll(
        () => const HomeView(),
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

  // ════════════════════════════════════════════════════════════════════════
  // LOGIN BUTTON ACTION
  // ════════════════════════════════════════════════════════════════════════
  
  /// Main login method - validates phone and sends Firebase OTP
  Future<void> login(BuildContext context) async {
    // VALIDATION 1: Check if phone number is entered
    if (phoneController.text.trim().isEmpty) {
      appMessageFail(text: 'Please enter your phone number', context: context);
      return;
    }

    // VALIDATION 2: Check phone number length
    if (phoneController.text.trim().length < 7) {
      appMessageFail(text: 'Please enter a valid phone number', context: context);
      return;
    }

    // PROCESS: Send OTP via Firebase
    await sendFirebaseOTP(
      phoneNumber: phoneController.text.trim(),
      context: context,
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // ENSURE USER RECORD EXISTS IN SUPABASE (Helper Method)
  // ════════════════════════════════════════════════════════════════════════
  
  /// Helper method to check if user exists in Supabase users table
  /// Used for both Google and Phone authentication
  /// Returns user data map with 'existed' status
  Future<Map<String, dynamic>> _ensureUserRecord({
    required User user,
    String? displayName,
    String? photoUrl,
    String? source, // 'phone' or 'google'
  }) async {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🗄️ DATABASE CHECK: Verifying user record");
    print("   User ID: ${user.id}");
    print("   Source: $source");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    
    try {
      // PROCESS 1: Query Supabase users table for existing user
      print('🔍 PROCESS 1: Querying Supabase users table');
      final existing = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        // PROCESS 2A: User found - Return existing data
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

  // ════════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN-IN WITH SUPABASE INTEGRATION (NO OTP)
  // ════════════════════════════════════════════════════════════════════════
  
  /// Google Sign-In authentication flow
  /// This method uses Google OAuth for authentication and syncs with Supabase
  /// No OTP is needed for Google login - direct authentication
  Future<void> googleLogin(BuildContext context) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔐 GOOGLE LOGIN: Starting Google Sign-In process");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      // PROCESS 1: Initialize Google Sign-In with required scopes
      print("📱 STEP 1: Initializing Google Sign-In");
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
        '851699318144-qj34crl5g2avebai2mu1p5r3k33hm1eu.apps.googleusercontent.com',
        clientId:
        '851699318144-k0tr7281tkbcsj4u7vbleo3obna75sfu.apps.googleusercontent.com',
      );

      // PROCESS 2: Sign out any previous Google session (force fresh login)
      print("🔄 STEP 2: Clearing previous Google session");
      await googleSignIn.signOut();

      // PROCESS 3: Show Google Sign-In prompt to user
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

      // PROCESS 4: Get authentication credentials from Google
      print("🔑 STEP 5: Retrieving Google authentication tokens");
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

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

      // PROCESS 5: Authenticate with Supabase using Google ID token
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("🔄 STEP 7: Authenticating with Supabase");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      print("✅ STEP 8: Supabase authentication successful");

      // PROCESS 6: Extract user data from Google authentication
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("📊 STEP 9: Extracting Google user data");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      final String userName = googleUser.displayName ?? "No Name";
      final String userEmail = googleUser.email;
      final String userPhoto = googleUser.photoUrl ?? "https://www.svgrepo.com/show/384670/account-avatar-profile-user.svg";
      
      print("   👤 Name: $userName");
      print("   📧 Email: $userEmail");
      print("   🖼️ Photo: ${userPhoto.substring(0, 50)}...");

      // PROCESS 7: Check if user exists in Supabase users table BY EMAIL
      if (response.user != null) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print('🔍 STEP 10: Checking Supabase users table BY EMAIL');
        print('   Email: $userEmail');
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        // PROCESS 8: Query database by EMAIL to check if user exists
        final existingUser = await supabase
            .from('users')
            .select('id, name, email, phone, profile')
            .eq('email', userEmail)
            .maybeSingle();

        if (existingUser == null) {
          // PROCESS 9A: New user - Navigate to Complete Profile
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
          
          // Navigate to complete profile screen
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

        // PROCESS 9B: Existing user - Login directly
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print('✅ STEP 11B: EXISTING USER FOUND BY EMAIL');
        print('   User ID: ${existingUser['id']}');
        print('   Name: ${existingUser['name']}');
        print('   Email: ${existingUser['email']}');
        print('   Action: Login and navigate to Home');
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        // PROCESS 10: Get local storage instance
        print('💾 STEP 12: Saving user data to local storage');
        final box = GetStorage();
        LocalStorageService localStorage = Get.put(LocalStorageService(box));
        
        // PROCESS 11: Save user data to local storage with validation
        final userId = existingUser['id'] as String?;
        
        if (userId == null || userId.isEmpty) {
          print('❌ ERROR: User ID from Supabase is null or empty');
          throw Exception('Invalid user ID from Supabase');
        }
        
        await localStorage.saveUserIdSafely(userId);
        await localStorage.saveUserEmail(existingUser['email'] ?? userEmail);
        await localStorage.saveUserName(existingUser['name'] ?? userName);
        
        if (existingUser['profile'] != null && existingUser['profile'].toString().isNotEmpty) {
          await localStorage.saveUserProfile(existingUser['profile']);
        } else {
          await localStorage.saveUserProfile(userPhoto);
        }
        
        if (existingUser['phone'] != null && existingUser['phone'].toString().isNotEmpty) {
          await localStorage.write('user_phone', existingUser['phone']);
          print('   📱 Phone: ${existingUser['phone']}');
        }
        
        print('   👤 Name: ${existingUser['name']}');
        print('   📧 Email: ${existingUser['email']}');
        print('✅ User data saved successfully');

        // PROCESS 12: Show success message
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print('🏠 STEP 13: Navigating to Home screen');
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        appMessageSuccess(
          text: 'Welcome back ${existingUser['name']}!',
          context: context,
        );

        // PROCESS 13: Navigate to home screen
        Get.offAll(
          () => const HomeView(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        
        print("✅ Google Login completed successfully");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        return;
      }

      // PROCESS 14: Authentication failed
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
