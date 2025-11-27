import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/shared_models/coupon_model.dart';
import '../../core/local_db/local_db.dart';

class CouponsController extends GetxController {
  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Toggle for test mode
  final RxBool useTestData = false.obs;
  
  // Selected coupon for applying to ride
  final Rx<Coupon?> selectedCoupon = Rx<Coupon?>(null);

  late final SupabaseClient _supabase;
  late final LocalStorageService _localStorage;
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    _supabase = Supabase.instance.client;
    _localStorage = GetIt.instance<LocalStorageService>();
    _loadSelectedCouponFromStorage();
    loadCoupons();
  }

  /// Load previously selected coupon from local storage
  void _loadSelectedCouponFromStorage() {
    try {
      final savedCoupon = _localStorage.selectedCoupon;
      if (savedCoupon != null) {
        selectedCoupon.value = Coupon.fromJson(savedCoupon);
        print('✅ Loaded selected coupon from storage: ${selectedCoupon.value?.type}');
      }
    } catch (e) {
      print('⚠️ Error loading selected coupon from storage: $e');
      // Clear invalid data
      _localStorage.deleteSelectedCoupon();
    }
  }

  /// Generate test data for development/testing
  /// Generate test data for development/testing
  List<Coupon> _generateTestData() {
    print("🛠️ Generating test coupon data...");
    final now = DateTime.now();
    final userId = currentUserId ?? '00000000-0000-0000-0000-000000000000';

    // للكوبونات المتاحة للجميع، استخدم نفس user_id أو UUID ثابت
    final systemUserId = currentUserId ?? '00000000-0000-0000-0000-000000000000';

    return [
      // Client-specific coupons (for current user only)
      Coupon(
        id: 'test-1',
        userId: userId,
        type: 'DISCOUNT_10',
        couponFor: 'client',
        active: true,
        validUntil: now.add(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Coupon(
        id: 'test-2',
        userId: userId,
        type: 'DISCOUNT_20',
        couponFor: 'client',
        active: true,
        validUntil: now.add(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Coupon(
        id: 'test-3',
        userId: userId,
        type: 'DISCOUNT_50',
        couponFor: 'client',
        active: true,
        validUntil: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),

      // All-users coupons (available to everyone)
      Coupon(
        id: 'test-4',
        userId: systemUserId,  // ✅ UUID صحيح
        type: 'FREE_RIDE',
        couponFor: 'all',
        active: true,
        validUntil: now.add(const Duration(hours: 12)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Coupon(
        id: 'test-5',
        userId: systemUserId,  // ✅ UUID صحيح
        type: 'FLAT_50',
        couponFor: 'all',
        active: true,
        validUntil: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Coupon(
        id: 'test-6',
        userId: userId,
        type: 'FLAT_100',
        couponFor: 'client',
        active: true,
        validUntil: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),

      // Expired coupons
      Coupon(
        id: 'test-7',
        userId: userId,
        type: 'DISCOUNT_25',
        couponFor: 'client',
        active: true,
        validUntil: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      Coupon(
        id: 'test-8',
        userId: userId,
        type: 'DISCOUNT_20',
        couponFor: 'client',
        active: false,
        validUntil: now.add(const Duration(days: 20)),
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Coupon(
        id: 'test-9',
        userId: systemUserId,  // ✅ UUID صحيح
        type: 'DISCOUNT_10',
        couponFor: 'all',
        active: true,
        validUntil: now.subtract(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  /// Load user coupons from Supabase or test data
  Future<void> loadCoupons() async {
    if (currentUserId == null) {
      errorMessage.value = 'Please login to view your coupons';
      print('⚠️ No current user ID found');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔍 Fetching coupons for user: $currentUserId');

      // Fetch coupons where user_id = current user OR coupon_for = 'all'
      final response = await _supabase
          .from('coupons')
          .select()
          .or('user_id.eq.$currentUserId,coupon_for.eq.all')
          .order('created_at', ascending: false);

      print('📦 Raw response: $response');

      if (response == null) {
        print('⚠️ Received null response from Supabase');
        coupons.value = [];
        return;
      }

      final fetchedCoupons = (response as List)
          .map((json) {
        try {
          return Coupon.fromJson(json);
        } catch (e) {
          print('❌ Error parsing coupon: $json');
          print('Error details: $e');
          return null;
        }
      })
          .whereType<Coupon>()
          .toList();

      // If no data in Supabase and test mode is enabled, use test data
      if (fetchedCoupons.isEmpty && useTestData.value) {
        print('⚠️ No coupons found in Supabase, using test data...');
        coupons.value = _generateTestData();
        print('✅ Loaded ${coupons.length} test coupons');
      } else {
        coupons.value = fetchedCoupons;
        print('✅ Successfully loaded ${coupons.length} coupons from Supabase');
      }

    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to load coupons: $e';
      print('❌ Error loading coupons: $e');
      print('Stack trace: $stackTrace');
      
      // If error occurs and test mode is enabled, fallback to test data
      if (useTestData.value) {
        print('⚠️ Error loading from Supabase, using test data as fallback...');
        coupons.value = _generateTestData();
        errorMessage.value = ''; // Clear error since we have fallback data
      } else {
        coupons.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Get active coupons only
  List<Coupon> get activeCoupons {
    return coupons.where((coupon) => coupon.isValid).toList();
  }

  /// Get expired coupons
  List<Coupon> get expiredCoupons {
    return coupons.where((coupon) => coupon.isExpired).toList();
  }

  /// Get inactive coupons
  List<Coupon> get inactiveCoupons {
    return coupons.where((coupon) => !coupon.active && !coupon.isExpired).toList();
  }

  /// Select a coupon for applying to ride
  Future<void> selectCoupon(Coupon coupon) async {
    if (!coupon.isValid) {
      appMessageFail(text: 'This coupon is expired or inactive', context: Get.context!);
      print('⚠️ Cannot select invalid coupon: ${coupon.type}');
      return;
    }

    try {
      // Delete old coupon selection from local storage if exists
      if (selectedCoupon.value != null) {
        await _localStorage.deleteSelectedCoupon();
        print('🗑️ Deleted old coupon from storage: ${selectedCoupon.value?.type}');
      }

      // Save new selected coupon to local storage
      await _localStorage.saveSelectedCoupon(coupon.toJson());
      print('💾 Saved new coupon to storage: ${coupon.toJson()}');
      // Update the selected coupon in memory
      selectedCoupon.value = coupon;
      print('✅ Selected coupon: ${coupon.type}');
      appMessageSuccess(text: 'Coupon is activated now in your next trip', context: Get.context!);

     // Get.back(); // Return to previous screen with selected coupon
    } catch (e) {
      print('❌ Error saving selected coupon: $e');
      appMessageFail(text: 'Failed to save coupon selection', context: Get.context!);
    }
  }

  /// Clear selected coupon
  Future<void> clearSelectedCoupon() async {
    try {
      await _localStorage.deleteSelectedCoupon();
      selectedCoupon.value = null;
      print('🗑️ Cleared selected coupon from memory and storage');
    } catch (e) {
      print('❌ Error clearing selected coupon: $e');
    }
  }

  /// Deactivate a coupon
  Future<void> deactivateCoupon(String couponId) async {
    // Test mode simulation
    if (useTestData.value) {
      try {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));

        // Update local test data
        final index = coupons.indexWhere((c) => c.id == couponId);
        if (index != -1) {
          coupons[index] = coupons[index].copyWith(
            active: false,
            updatedAt: DateTime.now(),
          );
          coupons.refresh();
        }

        Get.snackbar(
          'Success',
          'Coupon deactivated successfully (Test Mode)',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to deactivate coupon: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
      return;
    }

    // Original Supabase logic
    try {
      print('🔄 Deactivating coupon: $couponId');

      await _supabase
          .from('coupons')
          .update({
        'active': false,
        'updated_at': DateTime.now().toIso8601String()
      })
          .eq('id', couponId);

      print('✅ Coupon deactivated successfully');

      // Refresh coupons list
      await loadCoupons();

      Get.snackbar(
        'Success',
        'Coupon deactivated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error deactivating coupon: $e');
      Get.snackbar(
        'Error',
        'Failed to deactivate coupon: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Toggle between test data and real data
  void toggleTestMode() {
    useTestData.value = !useTestData.value;
    loadCoupons();
    print('🔄 Test mode ${useTestData.value ? "enabled" : "disabled"}');
  }

  /// Get coupon type display name
  String getCouponTypeName(String type) {
    switch (type) {
      case 'DISCOUNT_10':
        return '10% Discount';
      case 'DISCOUNT_20':
        return '20% Discount';
      case 'DISCOUNT_25':
        return '25% Discount';
      case 'DISCOUNT_50':
        return '50% Discount';
      case 'FREE_RIDE':
        return 'Free Ride';
      case 'FLAT_50':
        return '\$50 Off';
      case 'FLAT_100':
        return '\$100 Off';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  /// Get coupon description
  String getCouponDescription(String type) {
    switch (type) {
      case 'DISCOUNT_10':
        return 'Get 10% off on your next ride';
      case 'DISCOUNT_20':
        return 'Get 20% off on your next ride';
      case 'DISCOUNT_25':
        return 'Get 25% off on your next ride';
      case 'DISCOUNT_50':
        return 'Get 50% off on your next ride';
      case 'FREE_RIDE':
        return 'Enjoy a free ride on us!';
      case 'FLAT_50':
        return 'Save \$50 on your ride';
      case 'FLAT_100':
        return 'Save \$100 on your ride';
      default:
        return 'Special offer coupon';
    }
  }

  /// Format date for display
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inDays == 0) {
      return 'Expires today';
    } else if (difference.inDays == 1) {
      return 'Expires tomorrow';
    } else if (difference.inDays < 7) {
      return 'Expires in ${difference.inDays} days';
    } else {
      return 'Valid until ${date.day}/${date.month}/${date.year}';
    }
  }

  /// Refresh coupons
  Future<void> refreshCoupons() async {
    await loadCoupons();
  }

  /// Insert test data into Supabase (for initial setup)
  Future<void> insertTestDataToSupabase() async {
    if (currentUserId == null) {
      Get.snackbar(
        'Error',
        'Please login first to insert test data',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      print('📝 Preparing test data for insertion...');

      final testData = _generateTestData();

      // Convert to JSON for insertion
      final dataToInsert = testData.map((coupon) => coupon.toInsertJson()).toList();

      print('💾 Inserting ${dataToInsert.length} coupons into database...');

      // Insert into Supabase
      await _supabase.from('coupons').insert(dataToInsert);

      print('✅ Test data inserted successfully');

      Get.snackbar(
        'Success',
        'Test data inserted successfully! ${testData.length} coupons added.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Reload coupons from database
      await loadCoupons();

    } catch (e, stackTrace) {
      print('❌ Error inserting test data: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to insert test data: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}