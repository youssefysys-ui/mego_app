

import 'dart:math';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_models/coupon_model.dart';

class EstServicesController extends GetxController {
  // Calculate distance between two coordinates in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) *
        sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }
  // Calculate estimated price based on distance
  double calculateEstimatedPrice(double pickupLat, double pickupLng, double dropoffLat, double dropoffLng) {
    final distance = _calculateDistance(pickupLat, pickupLng, dropoffLat, dropoffLng);
    final estimatedPrice = distance * 2.5 + 5.0; // Base fare + per km rate
    return estimatedPrice;
  }

  // Calculate estimated time based on distance
  int calculateEstimatedTime(double pickupLat, double pickupLng, double dropoffLat, double dropoffLng) {
    final distance = _calculateDistance(pickupLat, pickupLng, dropoffLat, dropoffLng);
    final estimatedTime = (distance * 3 + 10).round(); // Rough time estimation in minutes
    return estimatedTime;
  }

  /// Calculate discount based on coupon type
  double calculateDiscount(double originalPrice, Coupon? coupon) {
    if (coupon == null || !coupon.isValid) return 0.0;
    
    switch (coupon.type) {
      case 'DISCOUNT_10':
        return originalPrice * 0.10;
      case 'DISCOUNT_20':
        return originalPrice * 0.20;
      case 'DISCOUNT_25':
        return originalPrice * 0.25;
      case 'DISCOUNT_50':
        return originalPrice * 0.50;
      case 'FLAT_50':
        return 50.0;
      case 'FLAT_100':
        return 100.0;
      case 'FREE_RIDE':
        return originalPrice; // 100% discount
      default:
        return 0.0;
    }
  }

  /// Calculate price with discount applied
  Map<String, double> calculatePriceWithDiscount(
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
    Coupon? coupon,
  ) {
    final originalPrice = calculateEstimatedPrice(
      pickupLat, pickupLng, dropoffLat, dropoffLng
    );
    
    final discount = calculateDiscount(originalPrice, coupon);
    final finalPrice = (originalPrice - discount).clamp(0.0, double.infinity);
    
    print('💰 Price Calculation:');
    print('   Original: \$${originalPrice.toStringAsFixed(2)}');
    print('   Discount: -\$${discount.toStringAsFixed(2)}');
    print('   Final: \$${finalPrice.toStringAsFixed(2)}');
    
    return {
      'originalPrice': originalPrice,
      'discount': discount,
      'finalPrice': finalPrice,
    };
  }
}