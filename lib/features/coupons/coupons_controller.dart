import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/shared_models/coupon_model.dart';

class CouponsController extends GetxController {
  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Toggle for test mode
  final RxBool useTestData = false.obs;

  late final SupabaseClient _supabase;
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    _supabase = Supabase.instance.client;
    loadCoupons();
  }

  /// Generate test data for development/testing
  List<Coupon> _generateTestData() {
    final now = DateTime.now();
    final userId = currentUserId ?? 'test-user-id';
    
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
        userId: 'system',
        type: 'FREE_RIDE',
        couponFor: 'all',
        active: true,
        validUntil: now.add(const Duration(hours: 12)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Coupon(
        id: 'test-5',
        userId: 'system',
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
        userId: 'system',
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
    // Use test data if enabled
    if (useTestData.value) {
      try {
        isLoading.value = true;
        errorMessage.value = '';

        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 800));

        coupons.value = _generateTestData();

        print('✅ Loaded ${coupons.length} test coupons');
      } catch (e) {
        errorMessage.value = 'Failed to load test coupons: $e';
        print('Error loading test coupons: $e');
      } finally {
        isLoading.value = false;
      }
      return;
    }

    // Original Supabase logic
    if (currentUserId == null) {
      errorMessage.value = 'Please login to view your coupons';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch coupons where user_id = current user OR coupon_for = 'all'
      final response = await _supabase
          .from('coupons')
          .select()
          .or('user_id.eq.$currentUserId,coupon_for.eq.all')
          .order('created_at', ascending: false);

      coupons.value = (response as List)
          .map((json) => Coupon.fromJson(json))
          .toList();

    } catch (e) {
      errorMessage.value = 'Failed to load coupons: $e';
      print('Error loading coupons: $e');
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
          final updatedCoupon = Coupon(
            id: coupons[index].id,
            userId: coupons[index].userId,
            type: coupons[index].type,
            couponFor: coupons[index].couponFor,
            active: false,
            validUntil: coupons[index].validUntil,
            createdAt: coupons[index].createdAt,
            updatedAt: DateTime.now(),
          );
          coupons[index] = updatedCoupon;
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
      await _supabase
          .from('coupons')
          .update({'active': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', couponId);

      // Refresh coupons list
      await loadCoupons();

      Get.snackbar(
        'Success',
        'Coupon deactivated successfully',
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
      
      final testData = _generateTestData();
      
      // Convert to JSON for insertion (without id, created_at, updated_at)
      final dataToInsert = testData.map((coupon) {
        return {
          'user_id': coupon.userId,
          'type': coupon.type,
          'coupon_for': coupon.couponFor,
          'valid_until': coupon.validUntil.toIso8601String(),
          'active': coupon.active,
        };
      }).toList();

      // Insert into Supabase
      await _supabase.from('coupons').insert(dataToInsert);

      Get.snackbar(
        'Success',
        'Test data inserted successfully! ${testData.length} coupons added.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Reload coupons from database
      await loadCoupons();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to insert test data: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      print('Error inserting test data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}