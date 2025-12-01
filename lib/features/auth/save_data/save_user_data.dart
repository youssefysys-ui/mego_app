// lib/features/auth/save_data/save_user_data.dart

import '../../../../core/local_db/local_db.dart';

/// Centralized User Data Saving Service
/// 
/// This service provides a reusable method to save all user data to local storage
/// consistently across the entire application.
/// 
/// Usage:
/// ```dart
/// await SaveUserData.toLocalStorage(
///   userData: userDataFromSupabase,
///   fallbackProfile: optionalProfileImageUrl,
/// );
/// ```
class SaveUserData {
  SaveUserData._(); // Private constructor to prevent instantiation

  // ════════════════════════════════════════════════════════════════════════
  // SAVE USER DATA TO LOCAL STORAGE
  // ════════════════════════════════════════════════════════════════════════
  
  /// Saves all user data to local storage using the Storage API
  /// 
  /// This method ensures consistency across all authentication flows:
  /// - Phone login
  /// - Google login
  /// - Profile completion
  /// 
  /// Parameters:
  /// - [userData]: Map containing user data from Supabase database
  /// - [fallbackProfile]: Optional profile image URL to use if not in userData
  /// 
  /// Required fields in userData:
  /// - `id` (String): User ID from Supabase - **Required**
  /// 
  /// Optional fields in userData:
  /// - `name` (String): User's display name
  /// - `email` (String): User's email address
  /// - `phone` (String): User's phone number
  /// - `profile` (String): User's profile image URL
  /// 
  /// Throws:
  /// - [Exception] if user ID is null or empty
  /// 
  /// Example:
  /// ```dart
  /// final userData = {
  ///   'id': 'user123',
  ///   'name': 'Ahmed Ali',
  ///   'email': 'ahmed@example.com',
  ///   'phone': '+201234567890',
  ///   'profile': 'https://example.com/avatar.jpg',
  /// };
  /// 
  /// await SaveUserData.toLocalStorage(userData: userData);
  /// ```
  static Future<void> toLocalStorage({
    required Map<String, dynamic> userData,
    String? fallbackProfile,
  }) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("💾 SaveUserData: Starting save operation");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      
      // ═══════════════════════════════════════════════════════════════
      // STEP 1: VALIDATE USER ID (Required)
      // ═══════════════════════════════════════════════════════════════
      final userId = userData['id'] as String?;
      
      if (userId == null || userId.isEmpty) {
        print('❌ ERROR: User ID is null or empty');
        print('   Cannot save user data without valid ID');
        throw Exception('Invalid user ID: User ID is required for saving data');
      }
      
      print('✅ VALIDATION: User ID is valid');
      
      // ═══════════════════════════════════════════════════════════════
      // STEP 2: SAVE USER ID (Required Field)
      // ═══════════════════════════════════════════════════════════════
      await Storage.save.userId(userId);
      print('   ✅ User ID saved: $userId');
      
      // ═══════════════════════════════════════════════════════════════
      // STEP 3: SAVE USER NAME (With Fallback)
      // ═══════════════════════════════════════════════════════════════
      final userName = userData['name'] as String? ?? 'User';
      await Storage.save.userName(userName);
      print('   ✅ Name saved: $userName');
      
      // ═══════════════════════════════════════════════════════════════
      // STEP 4: SAVE USER EMAIL (Optional)
      // ═══════════════════════════════════════════════════════════════
      final userEmail = userData['email'] as String? ?? '';
      
      if (userEmail.isNotEmpty) {
        await Storage.save.userEmail(userEmail);
        print('   ✅ Email saved: $userEmail');
      } else {
        print('   ⚠️  Email not provided (optional)');
      }
      
      // ═══════════════════════════════════════════════════════════════
      // STEP 5: SAVE USER PHONE (Optional)
      // ═══════════════════════════════════════════════════════════════
      final userPhone = userData['phone'] as String? ?? '';
      
      if (userPhone.isNotEmpty) {
        await Storage.save.userPhone(userPhone);
        print('   ✅ Phone saved: $userPhone');
      } else {
        print('   ⚠️  Phone not provided (optional)');
      }
      
      // ═══════════════════════════════════════════════════════════════
      // STEP 6: SAVE PROFILE IMAGE (Optional with Fallback)
      // ═══════════════════════════════════════════════════════════════
      final profileFromData = userData['profile'] as String?;
      
      if (profileFromData != null && profileFromData.isNotEmpty) {
        // Use profile from userData
        await Storage.save.userProfile(profileFromData);
        final displayUrl = profileFromData.length > 50 
            ? '${profileFromData.substring(0, 50)}...' 
            : profileFromData;
        print('   ✅ Profile image saved: $displayUrl');
        
      } else if (fallbackProfile != null && fallbackProfile.isNotEmpty) {
        // Use fallback profile (e.g., from Google)
        await Storage.save.userProfile(fallbackProfile);
        final displayUrl = fallbackProfile.length > 50 
            ? '${fallbackProfile.substring(0, 50)}...' 
            : fallbackProfile;
        print('   ✅ Profile image saved (fallback): $displayUrl');
        
      } else {
        print('   ⚠️  Profile image not provided (optional)');
      }
      
      // ═══════════════════════════════════════════════════════════════
      // STEP 7: COMPLETION
      // ═══════════════════════════════════════════════════════════════
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("✅ SaveUserData: All data saved successfully");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
      
    } catch (e, stackTrace) {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("❌ SaveUserData: Failed to save user data");
      print("   Error: $e");
      print("   Stack trace: $stackTrace");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      rethrow;
    }
  }
  
  // ════════════════════════════════════════════════════════════════════════
  // QUICK SAVE - FOR SIMPLE CASES
  // ════════════════════════════════════════════════════════════════════════
  
  /// Quick save method for simple user data without detailed logging
  /// Use this when you need a simpler, quieter save operation
  static Future<void> quick({
    required String userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userProfile,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User ID is required');
    }
    
    await Storage.save.userId(userId);
    
    if (userName != null && userName.isNotEmpty) {
      await Storage.save.userName(userName);
    }
    
    if (userEmail != null && userEmail.isNotEmpty) {
      await Storage.save.userEmail(userEmail);
    }
    
    if (userPhone != null && userPhone.isNotEmpty) {
      await Storage.save.userPhone(userPhone);
    }
    
    if (userProfile != null && userProfile.isNotEmpty) {
      await Storage.save.userProfile(userProfile);
    }
  }
  
  // ════════════════════════════════════════════════════════════════════════
  // VALIDATION HELPERS
  // ════════════════════════════════════════════════════════════════════════
  
  /// Check if user data map has all required fields
  static bool hasRequiredFields(Map<String, dynamic> userData) {
    final userId = userData['id'] as String?;
    return userId != null && userId.isNotEmpty;
  }
  
  /// Get validation error message if data is invalid
  static String? validateUserData(Map<String, dynamic> userData) {
    final userId = userData['id'] as String?;
    
    if (userId == null || userId.isEmpty) {
      return 'User ID is required';
    }
    
    return null; // Data is valid
  }
  
  /// Get local user data as a Map from Storage
  static Map<String, dynamic> getLocalUser() {
    final id = Storage.userId as String? ?? '';
    final name = Storage.userName as String? ?? '';
    final email = Storage.userEmail as String? ?? '';
    final phone = Storage.userPhone as String? ?? '';
    final profile = Storage.userProfile as String? ?? '';

    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile': profile,
    };
  }

  /// Returns true when a valid userId exists in local storage
  static bool isUserLoggedIn() {
    final id = Storage.userId as String? ?? '';
    return id.isNotEmpty;
  }
}


/*
═══════════════════════════════════════════════════════════════════════════
USAGE EXAMPLES 🚀
═══════════════════════════════════════════════════════════════════════════

// 1. BASIC USAGE - Save complete user data from Supabase
final userData = await supabase.from('users').select().eq('id', userId).single();
await SaveUserData.toLocalStorage(userData: userData);

// 2. WITH FALLBACK PROFILE - For Google login with photo
final userData = await supabase.from('users').select().eq('email', email).single();
await SaveUserData.toLocalStorage(
  userData: userData,
  fallbackProfile: 'https://lh3.googleusercontent.com/a/...',
);

// 3. QUICK SAVE - For simple cases
await SaveUserData.quick(
  userId: 'user123',
  userName: 'Ahmed Ali',
  userEmail: 'ahmed@example.com',
  userPhone: '+201234567890',
);

// 4. VALIDATION BEFORE SAVE
if (SaveUserData.hasRequiredFields(userData)) {
  await SaveUserData.toLocalStorage(userData: userData);
} else {
  print('Invalid user data');
}

// 5. IN LOGIN CONTROLLER
Future<void> _handleExistingUserLogin(Map<String, dynamic> userData, BuildContext context) async {
  // Save user data using centralized service
  await SaveUserData.toLocalStorage(userData: userData);
  
  // Navigate to home
  Get.offAll(() => const HomeView());
}

// 6. IN COMPLETE PROFILE CONTROLLER
Future<void> saveProfile() async {
  final userData = await supabase.from('users').select().eq('id', userId).single();
  
  await SaveUserData.toLocalStorage(
    userData: userData,
    fallbackProfile: profileImageUrl.value,
  );
  
  Get.offAll(() => const HomeView());
}

═══════════════════════════════════════════════════════════════════════════
*/