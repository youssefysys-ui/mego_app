

import 'dart:math';
import 'package:get/get.dart';

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
}