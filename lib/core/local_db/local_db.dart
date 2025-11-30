
// lib/core/services/storage_service.dart
import 'dart:math';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/widgets.dart';

/// Global GetIt instance
final getIt = GetIt.instance;

/// Global storage accessor - Use this anywhere in your app!
/// Example: Storage.authToken or Storage.save.authToken('token123')
class Storage {
  Storage._(); // Private constructor to prevent instantiation

  static final _box = GetStorage();

  // ════════════════════════════════════════════════════════════════════════
  // SETUP - Call once at app startup
  // ════════════════════════════════════════════════════════════════════════

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    print('✅ Storage initialized');
  }

  // ════════════════════════════════════════════════════════════════════════
  // SAVE - Access with Storage.save.xxx()
  // ════════════════════════════════════════════════════════════════════════

  static final save = _StorageWrite._();

  // ════════════════════════════════════════════════════════════════════════
  // GET - Direct property access with Storage.xxx
  // ════════════════════════════════════════════════════════════════════════

  // Auth & User
  static String? get authToken => _box.read('auth_token');
  static String? get userId => _box.read('user_id');
  static String? get userName => _box.read('user_name');
  static String? get userEmail => _box.read('user_email');
  static String? get userPhone => _box.read('user_phone');
  static String? get userProfile => _box.read('user_profile');

  // Location
  static String? get country => _box.read('user_country');
  static String? get city => _box.read('user_city');
  static double? get latitude => _box.read('user_latitude');
  static double? get longitude => _box.read('user_longitude');
  static String? get locationName => _box.read('user_location_name');
  static String? get fullAddress => _box.read('user_full_address');
  static String? get lastLocationUpdate => _box.read('last_location_update');

  // Category
  static String? get categoryId => _box.read('selected_category_id');
  static String? get categoryName => _box.read('selected_category_name');
  static String? get categoryNameEn => _box.read('selected_category_name_en');
  static String? get categoryType => _box.read('selected_category_type');
  static String? get categoryImage => _box.read('selected_category_image');

  // Coupon
  static Map<String, dynamic>? get coupon => _box.read('selected_coupon');

  // Splash Video
  static bool? get splashVideoShown => _box.read('splash_video_shown');
  static String? get splashVideoTimestamp => _box.read('splash_video_timestamp');

  // Language
  static String? get language => _box.read('app_language');

  // ════════════════════════════════════════════════════════════════════════
  // DELETE - Access with Storage.delete.xxx()
  // ════════════════════════════════════════════════════════════════════════

  static final delete = _StorageDelete._();

  // ════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════════════════════

  /// Check if user is authenticated
  static bool get isLoggedIn => authToken != null && userId != null;

  /// Check if location data exists
  static bool get hasLocation => latitude != null && longitude != null;

  /// Check if category is selected
  static bool get hasCategory => categoryId != null;

  /// Check if user has complete profile data
  static bool get hasCompleteProfile {
    return userName != null &&
        userName!.isNotEmpty &&
        userEmail != null &&
        userEmail!.isNotEmpty &&
        userName != 'user' &&
        userName != 'المستخدم';
  }

  /// Check if user name needs to be fetched
  static bool get needsUserNameFetch {
    final name = userName;
    return name == null ||
        name.isEmpty ||
        name == 'user' ||
        name == 'المستخدم';
  }

  // ════════════════════════════════════════════════════════════════════════
  // COUPON VALIDATION
  // ════════════════════════════════════════════════════════════════════════

  /// Get valid active coupon (checks expiration and active status)
  static Map<String, dynamic>? get validCoupon {
    try {
      final couponData = coupon;
      if (couponData == null) return null;

      // Check if active
      final isActive = couponData['active'] as bool? ?? false;
      if (!isActive) {
        delete.coupon();
        return null;
      }

      // Check expiration
      final validUntilStr = couponData['valid_until'] as String?;
      if (validUntilStr == null) {
        delete.coupon();
        return null;
      }

      final validUntil = DateTime.parse(validUntilStr);
      if (DateTime.now().isAfter(validUntil)) {
        delete.coupon();
        return null;
      }

      return couponData;
    } catch (e) {
      delete.coupon();
      return null;
    }
  }

  /// Check if user has valid coupon
  static bool get hasValidCoupon => validCoupon != null;

  /// Get coupon discount percentage
  static double get couponDiscount {
    final couponData = validCoupon;
    if (couponData == null) return 0.0;

    final type = couponData['type'] as String;

    if (type.contains('PERCENT')) {
      final percentStr = type.replaceAll('_PERCENT', '').replaceAll('PERCENT', '');
      return double.tryParse(percentStr) ?? 0.0;
    } else if (type == 'FREE_RIDE') {
      return 100.0;
    }

    return 0.0;
  }

  /// Apply coupon discount to price
  static double applyDiscount(double price) {
    final discount = couponDiscount;
    if (discount <= 0) return price;

    final discountAmount = price * (discount / 100);
    return price - discountAmount;
  }

  // ════════════════════════════════════════════════════════════════════════
  // SPLASH VIDEO
  // ════════════════════════════════════════════════════════════════════════

  /// Check if splash video should be shown (every 5 days)
  static bool get shouldShowSplash {
    final shown = splashVideoShown;
    final timestamp = splashVideoTimestamp;

    if (shown == null || !shown || timestamp == null) return true;

    try {
      final lastShown = DateTime.parse(timestamp);
      final daysSince = DateTime.now().difference(lastShown).inDays;

      if (daysSince >= 5) {
        delete.splashVideoData();
        return true;
      }

      return false;
    } catch (e) {
      return true;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // LOCATION HELPERS
  // ════════════════════════════════════════════════════════════════════════

  /// Calculate distance from stored location (in km)
  static double? distanceFrom(double newLat, double newLng) {
    final lat = latitude;
    final lng = longitude;
    if (lat == null || lng == null) return null;

    const double earthRadius = 6371;
    final double latDiff = (newLat - lat) * (pi / 180);
    final double lngDiff = (newLng - lng) * (pi / 180);

    final double a = pow(sin(latDiff / 2), 2) +
        cos(lat * pi / 180) * cos(newLat * pi / 180) * pow(sin(lngDiff / 2), 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  // ════════════════════════════════════════════════════════════════════════
  // CLEAR ALL
  // ════════════════════════════════════════════════════════════════════════

  /// Complete logout - clears all data except language
  static Future<void> logout() async {
    final lang = language; // Preserve language
    await _box.erase();
    if (lang != null) await save.language(lang);
    print('✅ Logged out - all data cleared');
  }

  /// Nuclear option - clear everything
  static Future<void> clearAll() async {
    await _box.erase();
    print('✅ All storage cleared');
  }
}

// ════════════════════════════════════════════════════════════════════════
// WRITE OPERATIONS CLASS
// ════════════════════════════════════════════════════════════════════════

class _StorageWrite {
  _StorageWrite._();

  final _box = GetStorage();

  // Auth & User
  Future<void> authToken(String token) => _box.write('auth_token', token);
  Future<void> userId(String id) => _box.write('user_id', id);
  Future<void> userName(String name) => _box.write('user_name', name);
  Future<void> userEmail(String email) => _box.write('user_email', email);
  Future<void> userPhone(String phone) => _box.write('user_phone', phone);
  Future<void> userProfile(String profile) => _box.write('user_profile', profile);

  // Location
  Future<void> country(String country) => _box.write('user_country', country);
  Future<void> city(String city) => _box.write('user_city', city);
  Future<void> latitude(double lat) => _box.write('user_latitude', lat);
  Future<void> longitude(double lng) => _box.write('user_longitude', lng);
  Future<void> locationName(String name) => _box.write('user_location_name', name);
  Future<void> fullAddress(String address) => _box.write('user_full_address', address);

  /// Save complete location data at once
  Future<void> location({
    required String country,
    required String city,
    required double latitude,
    required double longitude,
    String? locationName,
    String? fullAddress,
  }) async {
    await this.country(country);
    await this.city(city);
    await this.latitude(latitude);
    await this.longitude(longitude);
    if (locationName != null) await this.locationName(locationName);
    if (fullAddress != null) await this.fullAddress(fullAddress);
    await _box.write('last_location_update', DateTime.now().toIso8601String());
  }

  // Category
  Future<void> categoryId(String id) => _box.write('selected_category_id', id);
  Future<void> categoryName(String name) => _box.write('selected_category_name', name);
  Future<void> categoryNameEn(String name) => _box.write('selected_category_name_en', name);
  Future<void> categoryType(String type) => _box.write('selected_category_type', type);
  Future<void> categoryImage(String image) => _box.write('selected_category_image', image);

  /// Save complete category data at once
  Future<void> category({
    required String id,
    required String name,
    required String nameEn,
    required String type,
    String? image,
  }) async {
    await categoryId(id);
    await categoryName(name);
    await categoryNameEn(nameEn);
    await categoryType(type);
    if (image != null) await categoryImage(image);
  }

  // Coupon
  Future<void> coupon(Map<String, dynamic> coupon) => _box.write('selected_coupon', coupon);

  // Splash
  Future<void> splashShown() async {
    await _box.write('splash_video_shown', true);
    await _box.write('splash_video_timestamp', DateTime.now().toIso8601String());
  }

  // Language
  Future<void> language(String lang) => _box.write('app_language', lang);

  // Generic write
  Future<void> custom(String key, dynamic value) => _box.write(key, value);
}

// ════════════════════════════════════════════════════════════════════════
// DELETE OPERATIONS CLASS
// ════════════════════════════════════════════════════════════════════════

class _StorageDelete {
  _StorageDelete._();

  final _box = GetStorage();

  // Auth & User
  Future<void> authToken() => _box.remove('auth_token');
  Future<void> userId() => _box.remove('user_id');
  Future<void> userName() => _box.remove('user_name');
  Future<void> userEmail() => _box.remove('user_email');
  Future<void> userPhone() => _box.remove('user_phone');
  Future<void> userProfile() => _box.remove('user_profile');

  Future<void> allUserData() async {
    await authToken();
    await userId();
    await userName();
    await userEmail();
    await userPhone();
    await userProfile();
  }

  // Location
  Future<void> country() => _box.remove('user_country');
  Future<void> city() => _box.remove('user_city');
  Future<void> latitude() => _box.remove('user_latitude');
  Future<void> longitude() => _box.remove('user_longitude');
  Future<void> locationName() => _box.remove('user_location_name');
  Future<void> fullAddress() => _box.remove('user_full_address');

  Future<void> allLocationData() async {
    await country();
    await city();
    await latitude();
    await longitude();
    await locationName();
    await fullAddress();
    await _box.remove('last_location_update');
  }

  // Category
  Future<void> categoryId() => _box.remove('selected_category_id');
  Future<void> categoryName() => _box.remove('selected_category_name');
  Future<void> categoryNameEn() => _box.remove('selected_category_name_en');
  Future<void> categoryType() => _box.remove('selected_category_type');
  Future<void> categoryImage() => _box.remove('selected_category_image');

  Future<void> allCategoryData() async {
    await categoryId();
    await categoryName();
    await categoryNameEn();
    await categoryType();
    await categoryImage();
  }

  // Coupon
  Future<void> coupon() => _box.remove('selected_coupon');

  // Splash
  Future<void> splashVideoData() async {
    await _box.remove('splash_video_shown');
    await _box.remove('splash_video_timestamp');
  }

  // Language
  Future<void> language() => _box.remove('app_language');

  // Generic delete
  Future<void> custom(String key) => _box.remove(key);
}


/*
═══════════════════════════════════════════════════════════════════════════
USAGE EXAMPLES - SUPER SIMPLE! 🚀
═══════════════════════════════════════════════════════════════════════════

// 1. INITIALIZE (in main.dart before runApp)
await Storage.init();

// 2. SAVE DATA - One liner!
await Storage.save.authToken('abc123');
await Storage.save.userName('Ahmed');
await Storage.save.latitude(30.0444);

// Save multiple at once
await Storage.save.location(
  country: 'Egypt',
  city: 'Cairo',
  latitude: 30.0444,
  longitude: 31.2357,
);

// 3. GET DATA - Direct property access!
final token = Storage.authToken;           // String?
final name = Storage.userName;             // String?
final lat = Storage.latitude;              // double?
final coupon = Storage.validCoupon;        // Map<String, dynamic>?

// 4. CHECK STATUS
if (Storage.isLoggedIn) {
  print('User is logged in!');
}

if (Storage.hasValidCoupon) {
  final discount = Storage.couponDiscount;  // double
  final finalPrice = Storage.applyDiscount(100.0);
}

if (Storage.shouldShowSplash) {
  // Show splash video
  await Storage.save.splashShown();
}

// 5. DELETE DATA
await Storage.delete.authToken();
await Storage.delete.allUserData();
await Storage.delete.allLocationData();

// 6. LOGOUT
await Storage.logout();  // Clears everything except language

═══════════════════════════════════════════════════════════════════════════
USE ANYWHERE IN YOUR APP - NO IMPORTS NEEDED (after initial setup)!
═══════════════════════════════════════════════════════════════════════════

// In any widget:
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello ${Storage.userName ?? "Guest"}!');
  }
}

// In any controller:
class HomeController extends GetxController {
  void loadUserData() {
    if (Storage.isLoggedIn) {
      final userId = Storage.userId;
      // Do something
    }
  }
}

// In any service:
class ApiService {
  Future<Response> makeRequest() async {
    final token = Storage.authToken;
    // Use token
  }
}

═══════════════════════════════════════════════════════════════════════════
*/