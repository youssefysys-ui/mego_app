// // lib/services/local_storage_service.dart
// import 'dart:math';
// import 'package:get_it/get_it.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:flutter/widgets.dart';
// import '../shared_models/user_model.dart';
//
// /// A simple service for local persistent storage using GetStorage.
// class LocalStorageService {
//   final GetStorage _box;
//
//   LocalStorageService(this._box);
//
//   // --------- Generic methods ---------
//   Future<void> write(String key, dynamic value) async => await _box.write(key, value);
//   T? read<T>(String key) => _box.read<T>(key);
//   Future<void> delete(String key) async => await _box.remove(key);
//   Future<void> clear() async => await _box.erase();
//
//   // --------- Convenient shortcuts for common keys ---------
//   static const _authTokenKey = 'auth_token';
//   static const _userIdKey = 'user_id';
//   static const _email = 'user_email';
//   static const _name = 'user_name';
//   static const _userModelKey = 'user_model';
//   static const _userProfileKey = 'user_profile';
//
//   // Location storage keys
//   static const _countryKey = 'user_country';
//   static const _cityKey = 'user_city';
//   static const _latitudeKey = 'user_latitude';
//   static const _longitudeKey = 'user_longitude';
//   static const _locationNameKey = 'user_location_name';
//   static const _fullAddressKey = 'user_full_address';
//   static const _lastLocationUpdateKey = 'last_location_update';
//
//   // Category storage keys
//   static const _selectedCategoryIdKey = 'selected_category_id';
//   static const _selectedCategoryNameKey = 'selected_category_name';
//   static const _selectedCategoryNameEnKey = 'selected_category_name_en';
//   static const _selectedCategoryTypeKey = 'selected_category_type';
//   static const _selectedCategoryImageKey = 'selected_category_image';
//
//   // Coupon storage key
//   static const _selectedCouponKey = 'selected_coupon';
//
//   // Splash video tracking keys
//   static const _splashVideoShownKey = 'splash_video_shown';
//   static const _splashVideoTimestampKey = 'splash_video_timestamp';
//
// //read
//   String? get authToken => read<String>(_authTokenKey);
//   String? get userId => read<String>(_userIdKey);
//   String? get userEmail => read<String>(_email);
//   String? get userName => read<String>(_name);
//
//   /// Get complete user model from storage
//   UserModel? get userModel {
//     final userData = read<Map<String, dynamic>>(_userModelKey);
//     return userData != null ? UserModel.fromJson(userData) : null;
//   }
//
//   // Location read methods
//   String? get userCountry => read<String>(_countryKey);
//   String? get userCity => read<String>(_cityKey);
//   double? get userLatitude => read<double>(_latitudeKey);
//   double? get userLongitude => read<double>(_longitudeKey);
//   String? get userLocationName => read<String>(_locationNameKey);
//   String? get userFullAddress => read<String>(_fullAddressKey);
//   String? get lastLocationUpdate => read<String>(_lastLocationUpdateKey);
//
//   // Category read methods
//   String? get selectedCategoryId => read<String>(_selectedCategoryIdKey);
//   String? get selectedCategoryName => read<String>(_selectedCategoryNameKey);
//   String? get selectedCategoryNameEn => read<String>(_selectedCategoryNameEnKey);
//   String? get selectedCategoryType => read<String>(_selectedCategoryTypeKey);
//   String? get selectedCategoryImage => read<String>(_selectedCategoryImageKey);
//
//   // Coupon read method
//   Map<String, dynamic>? get selectedCoupon => read<Map<String, dynamic>>(_selectedCouponKey);
//
//   // Splash video read methods
//   bool? get splashVideoShown => read<bool>(_splashVideoShownKey);
//   String? get splashVideoTimestamp => read<String>(_splashVideoTimestampKey);
//   String? get userProfile => read<String>(_userProfileKey);
//
// //write
//   Future<void> saveAuthToken(String token) async => await write(_authTokenKey, token);
//   Future<void> saveUserId(String userId) async => await write(_userIdKey, userId);
//   Future<void> saveUserName(String name) async => await write(_name, name);
//   Future<void> saveUserEmail(String email) async => await write(_email, email);
//
//   /// Validate and save user ID with strict checks
//   /// Throws exception if userId is null or empty
//   Future<void> saveUserIdSafely(String? userId) async {
//     if (userId == null || userId.isEmpty) {
//       print('❌ ERROR: Cannot save null or empty user ID');
//       throw Exception('User ID is required and cannot be empty');
//     }
//
//     await saveUserId(userId);
//     print('✅ User ID saved successfully: $userId');
//   }
//
//   /// Save complete user model to storage
//   Future<void> saveUserModel(UserModel user) async {
//     await write(_userModelKey, user.toJson());
//     // Also save individual fields for backward compatibility
//     await saveAuthToken(user.id);
//     await saveUserName(user.name);
//     await saveUserEmail(user.email);
//   }
//
//   // Location write methods
//   Future<void> saveUserCountry(String country) async => await write(_countryKey, country);
//   Future<void> saveUserCity(String city) async => await write(_cityKey, city);
//   Future<void> saveUserLatitude(double latitude) async => await write(_latitudeKey, latitude);
//   Future<void> saveUserLongitude(double longitude) async => await write(_longitudeKey, longitude);
//   Future<void> saveUserLocationName(String locationName) async => await write(_locationNameKey, locationName);
//   Future<void> saveUserFullAddress(String fullAddress) async => await write(_fullAddressKey, fullAddress);
//   Future<void> saveLastLocationUpdate(String timestamp) async => await write(_lastLocationUpdateKey, timestamp);
//
//   // Category write methods
//   Future<void> saveSelectedCategoryId(String categoryId) async => await write(_selectedCategoryIdKey, categoryId);
//   Future<void> saveSelectedCategoryName(String categoryName) async => await write(_selectedCategoryNameKey, categoryName);
//   Future<void> saveSelectedCategoryNameEn(String categoryNameEn) async => await write(_selectedCategoryNameEnKey, categoryNameEn);
//   Future<void> saveSelectedCategoryType(String categoryType) async => await write(_selectedCategoryTypeKey, categoryType);
//   Future<void> saveSelectedCategoryImage(String categoryImage) async => await write(_selectedCategoryImageKey, categoryImage);
//
//   // Coupon write method
//   Future<void> saveSelectedCoupon(Map<String, dynamic> coupon) async => await write(_selectedCouponKey, coupon);
//
//   // ════════════════════════════════════════════════════════════════════════
//   // COUPON VALIDATION & ACTIVATION CHECK
//   // ════════════════════════════════════════════════════════════════════════
//
//   /// Check if a valid coupon exists in local storage and return it
//   /// Returns null if no coupon exists, is expired, or is inactive
//   Map<String, dynamic>? getValidActiveCoupon() {
//     try {
//       print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
//       print("🎫 CHECKING COUPON IN LOCAL_DB");
//       print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
//
//       // STEP 1: Get coupon from local storage
//       final couponData = selectedCoupon;
//
//       if (couponData == null) {
//         print("❌ No coupon found in local_db");
//         return null;
//       }
//
//       print("✅ Coupon found in local_db");
//       print("   ID: ${couponData['id']}");
//       print("   Type: ${couponData['type']}");
//
//       // STEP 2: Check if coupon is active
//       final isActive = couponData['active'] as bool? ?? false;
//
//       if (!isActive) {
//         print("❌ Coupon is INACTIVE");
//         print("   Removing inactive coupon from local_db");
//         deleteSelectedCoupon();
//         return null;
//       }
//
//       print("✅ Coupon is ACTIVE");
//
//       // STEP 3: Check if coupon is expired
//       final validUntilStr = couponData['valid_until'] as String?;
//
//       if (validUntilStr == null) {
//         print("❌ Coupon has no expiration date");
//         deleteSelectedCoupon();
//         return null;
//       }
//
//       final validUntil = DateTime.parse(validUntilStr);
//       final now = DateTime.now();
//
//       if (now.isAfter(validUntil)) {
//         print("❌ Coupon is EXPIRED");
//         print("   Valid Until: $validUntil");
//         print("   Current Time: $now");
//         print("   Removing expired coupon from local_db");
//         deleteSelectedCoupon();
//         return null;
//       }
//
//       final remainingTime = validUntil.difference(now);
//       print("✅ Coupon is NOT EXPIRED");
//       print("   Valid Until: $validUntil");
//       print("   Remaining Time: ${remainingTime.inHours} hours");
//
//       // STEP 4: Coupon is valid and active
//       print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
//       print("🎉 COUPON IS VALID AND ACTIVE");
//       print("   Can be applied to the current transaction");
//       print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
//
//       return couponData;
//
//     } catch (e) {
//       print("❌ ERROR checking coupon: $e");
//       print("   Removing invalid coupon from local_db");
//       deleteSelectedCoupon();
//       return null;
//     }
//   }
//
//   /// Check if user has an active, valid coupon
//   bool hasValidCoupon() {
//     final coupon = getValidActiveCoupon();
//     return coupon != null;
//   }
//
//   /// Get coupon discount percentage or amount
//   /// Returns 0 if no valid coupon exists
//   double getCouponDiscountValue() {
//     try {
//       final coupon = getValidActiveCoupon();
//
//       if (coupon == null) {
//         return 0.0;
//       }
//
//       final type = coupon['type'] as String;
//
//       // Parse discount from coupon type
//       // Example types: "10_PERCENT", "FREE_RIDE", "50_PERCENT"
//       if (type.contains('PERCENT')) {
//         final percentStr = type.replaceAll('_PERCENT', '').replaceAll('PERCENT', '');
//         return double.tryParse(percentStr) ?? 0.0;
//       } else if (type == 'FREE_RIDE') {
//         return 100.0; // 100% discount
//       }
//
//       return 0.0;
//     } catch (e) {
//       print("❌ ERROR getting coupon discount: $e");
//       return 0.0;
//     }
//   }
//
//   /// Apply coupon discount to a price
//   /// Returns the discounted price
//   double applyCouponDiscount(double originalPrice) {
//     final discountPercent = getCouponDiscountValue();
//
//     if (discountPercent <= 0) {
//       return originalPrice;
//     }
//
//     final discountAmount = originalPrice * (discountPercent / 100);
//     final finalPrice = originalPrice - discountAmount;
//
//     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
//     print("💰 APPLYING COUPON DISCOUNT");
//     print("   Original Price: \$${originalPrice.toStringAsFixed(2)}");
//     print("   Discount: ${discountPercent.toStringAsFixed(0)}%");
//     print("   Discount Amount: \$${discountAmount.toStringAsFixed(2)}");
//     print("   Final Price: \$${finalPrice.toStringAsFixed(2)}");
//     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
//
//     return finalPrice;
//   }
//
//   // Splash video write methods
//   Future<void> saveSplashVideoShown(bool shown) async => await write(_splashVideoShownKey, shown);
//   Future<void> saveSplashVideoTimestamp(String timestamp) async => await write(_splashVideoTimestampKey, timestamp);
//   Future<void> saveUserProfile(String profile) async => await write(_userProfileKey, profile);
//
//   /// Mark splash video as shown with current timestamp
//   Future<void> markSplashVideoAsShown() async {
//     await saveSplashVideoShown(true);
//     await saveSplashVideoTimestamp(DateTime.now().toIso8601String());
//     print('✅ Splash video marked as shown at ${DateTime.now()}');
//   }
//
//   /// Save complete location data in one call
//   Future<void> saveLocationData({
//     required String country,
//     required String city,
//     required double latitude,
//     required double longitude,
//     String? locationName,
//     String? fullAddress,
//   }) async {
//     await saveUserCountry(country);
//     await saveUserCity(city);
//     await saveUserLatitude(latitude);
//     await saveUserLongitude(longitude);
//     if (locationName != null) await saveUserLocationName(locationName);
//     if (fullAddress != null) await saveUserFullAddress(fullAddress);
//     await saveLastLocationUpdate(DateTime.now().toIso8601String());
//   }
//
//   /// Save complete category data in one call
//   Future<void> saveCategoryData({
//     required String categoryId,
//     required String categoryName,
//     required String categoryNameEn,
//     required String categoryType,
//     String? categoryImage,
//   }) async {
//     await saveSelectedCategoryId(categoryId);
//     await saveSelectedCategoryName(categoryName);
//     await saveSelectedCategoryNameEn(categoryNameEn);
//     await saveSelectedCategoryType(categoryType);
//     if (categoryImage != null) await saveSelectedCategoryImage(categoryImage);
//   }
//
// //delete
//   Future<void> deleteAuthToken() async => await delete(_authTokenKey);
//   Future<void> deleteUserName() async => await delete(_name);
//   Future<void> deleteUserEmail() async => await delete(_email);
//   Future<void> deleteUserModel() async => await delete(_userModelKey);
//   Future<void> deleteUserProfile() async => await delete(_userProfileKey);
//
//   // Location delete methods
//   Future<void> deleteUserCountry() async => await delete(_countryKey);
//   Future<void> deleteUserCity() async => await delete(_cityKey);
//   Future<void> deleteUserLatitude() async => await delete(_latitudeKey);
//   Future<void> deleteUserLongitude() async => await delete(_longitudeKey);
//   Future<void> deleteUserLocationName() async => await delete(_locationNameKey);
//   Future<void> deleteUserFullAddress() async => await delete(_fullAddressKey);
//   Future<void> deleteLastLocationUpdate() async => await delete(_lastLocationUpdateKey);
//
//   // Category delete methods
//   Future<void> deleteSelectedCategoryId() async => await delete(_selectedCategoryIdKey);
//   Future<void> deleteSelectedCategoryName() async => await delete(_selectedCategoryNameKey);
//   Future<void> deleteSelectedCategoryNameEn() async => await delete(_selectedCategoryNameEnKey);
//   Future<void> deleteSelectedCategoryType() async => await delete(_selectedCategoryTypeKey);
//
//   // Coupon delete method
//   Future<void> deleteSelectedCoupon() async => await delete(_selectedCouponKey);
//   Future<void> deleteSelectedCategoryImage() async => await delete(_selectedCategoryImageKey);
//
//   // Splash video delete methods
//   Future<void> deleteSplashVideoShown() async => await delete(_splashVideoShownKey);
//   Future<void> deleteSplashVideoTimestamp() async => await delete(_splashVideoTimestampKey);
//
//   /// Clear splash video data
//   Future<void> clearSplashVideoData() async {
//     await deleteSplashVideoShown();
//     await deleteSplashVideoTimestamp();
//     print('🗑️ Splash video data cleared');
//   }
//
//   /// Delete all location data
//   Future<void> deleteAllLocationData() async {
//     await deleteUserCountry();
//     await deleteUserCity();
//     await deleteUserLatitude();
//     await deleteUserLongitude();
//     await deleteUserLocationName();
//     await deleteUserFullAddress();
//     await deleteLastLocationUpdate();
//   }
//
//   /// Delete all category data
//   Future<void> deleteAllCategoryData() async {
//     await deleteSelectedCategoryId();
//     await deleteSelectedCategoryName();
//     await deleteSelectedCategoryNameEn();
//     await deleteSelectedCategoryType();
//     await deleteSelectedCategoryImage();
//   }
//
//   /// Check if location data exists
//   bool hasLocationData() {
//     return userLatitude != null && userLongitude != null;
//   }
//
//   /// Check if category data exists
//   bool hasCategoryData() {
//     return selectedCategoryId != null && selectedCategoryType != null;
//   }
//
//   /// Check if user name is empty or null and needs to be fetched
//   bool needsUserNameFetch() {
//     final name = userName;
//     return name == null || name.isEmpty || name == 'user' || name == 'المستخدم';
//   }
//
//   /// Check if user has complete profile data
//   bool hasCompleteUserData() {
//     return userName != null && userName!.isNotEmpty &&
//            userEmail != null && userEmail!.isNotEmpty &&
//            userName != 'user' && userName != 'المستخدم';
//   }
//
//   // ════════════════════════════════════════════════════════════════════════
//   // LOGOUT & CLEAR ALL USER DATA
//   // ════════════════════════════════════════════════════════════════════════
//
//   /// Delete user ID from local storage
//   Future<void> deleteUserId() async => await delete(_userIdKey);
//
//   /// Delete all user authentication data (logout functionality)
//   Future<void> deleteAllUserData() async {
//     await deleteAuthToken();
//     await deleteUserId();
//     await deleteUserName();
//     await deleteUserEmail();
//     await deleteUserModel();
//     await delete('user_phone');
//     await delete('user_profile');
//     print('✅ All user data deleted from local storage');
//   }
//
//   /// Complete logout - clears all user and app data
//   /// Call this when user logs out to reset everything
//   Future<void> logout() async {
//     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
//     print("🗑️ LOCAL_DB: Starting complete logout cleanup");
//     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
//
//     await deleteAllUserData();
//     await deleteAllLocationData();
//     await deleteAllCategoryData();
//
//     // Keep language preference during logout
//     print("✅ LOCAL_DB: All user data cleared (language preserved)");
//     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
//   }
//
//   /// Get location distance between stored and new coordinates
//   double? getLocationDistance(double newLat, double newLng) {
//     final storedLat = userLatitude;
//     final storedLng = userLongitude;
//
//     if (storedLat == null || storedLng == null) return null;
//
//     // Calculate distance using Haversine formula (simplified)
//     const double earthRadius = 6371; // km
//     final double latDiff = (newLat - storedLat) * (pi / 180);
//     final double lngDiff = (newLng - storedLng) * (pi / 180);
//
//     final double a = pow(sin(latDiff / 2), 2) +
//         cos(storedLat * pi / 180) * cos(newLat * pi / 180) *
//         pow(sin(lngDiff / 2), 2);
//
//     final double c = 2 * asin(sqrt(a));
//     return earthRadius * c;
//   }
//
//   /// Check if splash video should be shown (returns true if video should play)
//   /// Video plays if: never shown before OR last shown more than 5 days ago
//   bool shouldShowSplashVideo() {
//     final shown = this.splashVideoShown;
//     final timestamp = this.splashVideoTimestamp;
//
//     // If never shown before, show the video
//     if (shown == null || !shown || timestamp == null) {
//       print('🎬 Splash video should show: Never shown before');
//       return true;
//     }
//
//     try {
//       final lastShownDate = DateTime.parse(timestamp);
//       final daysSinceShown = DateTime.now().difference(lastShownDate).inDays;
//
//       // If more than 5 days, clear old data and show video again
//       if (daysSinceShown >= 5) {
//         print('🎬 Splash video should show: Last shown $daysSinceShown days ago');
//         this.clearSplashVideoData(); // Auto-remove after 5 days
//         return true;
//       }
//
//       print('⏭️ Skip splash video: Last shown $daysSinceShown days ago');
//       return false;
//     } catch (e) {
//       print('⚠️ Error parsing splash video timestamp: $e');
//       // If error parsing, show video to be safe
//       return true;
//     }
//   }
// }
//
// /// Global service locator
// final GetIt getIt = GetIt.instance;
//
// /// Global shortcut to access storage anywhere without boilerplate
// LocalStorageService get storage => getIt<LocalStorageService>();
//
// /// Call this once at app startup (before runApp)
// Future<void> setupLocalStorage() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready
//   await GetStorage.init();                   // Initialize GetStorage
//   getIt.registerLazySingleton<LocalStorageService>(
//     () => LocalStorageService(GetStorage()),
//   );
// }
//
//
// /*
// // Write
// await storage.saveAuthToken('abcd1234');
//
// // Read
// final token = storage.authToken;
//
// // Delete
// await storage.deleteAuthToken();
//
// // Clear all local data
// await storage.clear();
//
// */