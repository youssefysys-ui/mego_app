import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/features/drivers_offers/driver_offer_model.dart';

class TestDriverData {
  final String id;
  final String name;
  final double rating;
  final String carModel;
  final String carColor;
  final String plateNumber;
  final String phone;
  final String email;
  final String? profileImage;
  final DateTime createdAt;

  const TestDriverData({
    required this.id,
    required this.name,
    required this.rating,
    required this.carModel,
    required this.carColor,
    required this.plateNumber,
    required this.phone,
    required this.email,
    required this.profileImage,
    required this.createdAt,
  });

  /// Create TestDriverData from Supabase driver data
  factory TestDriverData.fromSupabase(Map<String, dynamic> data) {
    final carInfo = data['car_info'] as Map<String, dynamic>? ?? {};
    
    return TestDriverData(
      id: data['id'] as String,
      name: data['name'] as String,
      rating: (data['rate'] as num?)?.toDouble() ?? 4.5,
      carModel: carInfo['model'] as String? ?? 'Unknown',
      carColor: carInfo['color'] as String? ?? 'Unknown',
      plateNumber: carInfo['plate_number'] as String? ?? 'N/A',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      profileImage: data['profile_image'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  /// Create a DriverModel from test data
  DriverModel toDriverModel() {
    return DriverModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      rate: rating,
      carInfo: {
        'model': carModel,
        'color': carColor,
        'plate_number': plateNumber,
        'year': 2020,
      },
      activated: true,
      online: true,
      profileImage: profileImage ?? 'https://i.pravatar.cc/150?u=$id',
      createdAt: createdAt,
    );
  }

  /// Fetch first 3 drivers from Supabase
  static Future<List<TestDriverData>> fetchDriversFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('drivers')
          .select()
          .eq('activated', true)
          .eq('online', true)
          .limit(3);

      if (response.isEmpty) {
        throw Exception('No drivers found in database');
      }

      return (response as List)
          .map((driver) => TestDriverData.fromSupabase(driver))
          .toList();
    } catch (e) {
      print('Error fetching drivers: $e');
      rethrow;
    }
  }

  /// Get a test driver by index from cached list
  static TestDriverData getTestDriver(List<TestDriverData> drivers, int index) {
    if (drivers.isEmpty) {
      throw Exception('No drivers available');
    }
    return drivers[index % drivers.length];
  }

  /// Convert to map for Supabase insertion with embedded driver data
  Map<String, dynamic> toOfferData({
    required String rideRequestId,
  }) {
    return {
      'ride_request_id': rideRequestId,
      'driver_id': id,
      'offered_price': _calculateRandomPrice(),
      'estimated_time': _calculateRandomTime(),
      'status': 'pending',
      'offer_expires_at': DateTime.now().add(const Duration(seconds: 40)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'driver_name': name,
      'driver_rating': rating,
      'car_model': carModel,
      'reviews_count': _calculateReviewsCount(),
    };
  }

  /// Calculate random price based on driver rating
  double _calculateRandomPrice() {
    final random = Random();
    final basePrice = 35.0 + (rating * 2); // Higher rating = slightly higher base
    final variance = random.nextDouble() * 10 - 5; // ±5 EGP variance
    return double.parse((basePrice + variance).toStringAsFixed(1));
  }

  /// Calculate random estimated time (3-10 minutes)
  int _calculateRandomTime() {
    final random = Random();
    return 3 + random.nextInt(8); // 3 to 10 minutes
  }

  /// Calculate reviews count based on rating
  int _calculateReviewsCount() {
    final random = Random();
    final baseReviews = (rating * 100).toInt();
    return baseReviews + random.nextInt(100);
  }

  /// Create a complete DriverOfferModel for testing
  static Future<DriverOfferModel> createTestOffer({
    required String rideRequestId,
    required int counter,
    List<TestDriverData>? cachedDrivers,
  }) async {
    // Fetch drivers if not cached
    final drivers = cachedDrivers ?? await fetchDriversFromSupabase();
    
    if (drivers.isEmpty) {
      throw Exception('No drivers available to create offer');
    }

    final testDriver = getTestDriver(drivers, counter - 1);
    final driver = testDriver.toDriverModel();
    
    return DriverOfferModel(
      id: 'offer_${counter}_${DateTime.now().millisecondsSinceEpoch}',
      rideRequestId: rideRequestId,
      driverId: driver.id,
      offeredPrice: testDriver._calculateRandomPrice(),
      estimatedTime: testDriver._calculateRandomTime(),
      status: 'pending',
      offerExpiresAt: DateTime.now().add(const Duration(seconds: 40)),
      createdAt: DateTime.now(),
      driver: driver,
      driverName: testDriver.name,
      driverRating: testDriver.rating,
      carModel: testDriver.carModel,
      reviewsCount: testDriver._calculateReviewsCount(),
    );
  }

  /// Batch create multiple test offers
  static Future<List<DriverOfferModel>> createMultipleTestOffers({
    required String rideRequestId,
    required int count,
  }) async {
    // Fetch drivers once and reuse
    final drivers = await fetchDriversFromSupabase();
    
    final offers = <DriverOfferModel>[];
    for (int i = 1; i <= count; i++) {
      final offer = await createTestOffer(
        rideRequestId: rideRequestId,
        counter: i,
        cachedDrivers: drivers,
      );
      offers.add(offer);
    }
    
    return offers;
  }
}