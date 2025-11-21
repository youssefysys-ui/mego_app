# Shared Models Documentation

This directory contains all the data models used throughout the MEGO ride-hailing app. These models correspond to the database tables and provide type-safe data structures with helpful utility methods.

## Models Overview

### 1. **UserModel** (`user_model.dart`)
Represents users in the system (both riders and drivers).
```dart
// Properties: id, name, email, phone, userType, createdAt
// Helpers: isDriver, isRider, displayName, initials
```

### 2. **OrderModel** (`order_model.dart`)
Represents ride orders/bookings.
```dart
// Properties: id, userId, fromName, toName, coordinates, price, status
// Helpers: route, shortRoute, formattedPrice, isActive, isFinished
```

### 3. **RideRequestModel** (`ride_request_model.dart`)
Represents ride requests from passengers.
```dart
// Properties: id, userId, pickup/dropoff coordinates, estimatedPrice, status
// Helpers: isPending, isAccepted, isActive, formattedPrice, formattedTime
```

### 4. **DriverOfferModel** (`driver_offer_model.dart`)
Represents offers made by drivers for ride requests.
```dart
// Properties: id, rideRequestId, driverId, offeredPrice, status, expiresAt
// Helpers: isActive, isExpired, formattedTimeUntilExpiry
```

### 5. **RideModel** (`ride_model.dart`)
Represents active/completed rides.
```dart
// Properties: id, rideRequestId, driverId, riderId, startTime, endTime, totalPrice
// Helpers: isActive, isFinished, rideDuration, hasDriverLocation
```

### 6. **RideLocationUpdateModel** (`ride_location_update_model.dart`)
Represents real-time location updates during rides.
```dart
// Properties: id, rideId, driverId, lat, lng, recordedAt
// Helpers: coordinates, isRecent, distanceTo(), formattedDistanceTo()
```

### 7. **PaymentModel** (`payment_model.dart`)
Represents payment transactions.
```dart
// Properties: id, rideId, amount, paymentMethod, status
// Helpers: isCash, isElectronic, isSuccessful, paymentMethodDisplay
```

### 8. **RatingModel** (`rating_model.dart`)
Represents user ratings and reviews.
```dart
// Properties: id, rideId, raterId, rateeId, ratingValue, comment
// Helpers: isPositive, qualityDescription, starDisplay, hasComment
// Static: calculateAverageRating(), getRatingDistribution()
```

## Usage Examples

### Import Models
```dart
// Import all models at once
import 'package:mego_app/core/shared_models/models.dart';

// Or import individual models
import 'package:mego_app/core/shared_models/user_model.dart';
```

### Creating Models from JSON
```dart
// From Supabase response
final user = UserModel.fromJson(supabaseResponse);

// From API response
final order = OrderModel.fromJson(apiData);
```

### Using Model Helpers
```dart
// User helpers
if (user.isDriver) {
  print('Driver: ${user.displayName}');
}

// Order status helpers
if (order.isActive) {
  showTrackingUI();
}

// Rating helpers
print('Rating: ${rating.starDisplay}'); // ★★★★☆
```

### Model Transformations
```dart
// Convert to JSON for API calls
final orderJson = order.toJson();

// Create modified copies
final updatedOrder = order.copyWith(
  status: OrderModel.statusInProgress,
);
```

### Status Constants
```dart
// Use predefined status constants
final newOrder = order.copyWith(
  status: OrderModel.statusPending,
);

// Check status
if (driverOffer.status == DriverOfferModel.statusAccepted) {
  proceedWithRide();
}
```

## Common Patterns

### 1. **Real-time Updates**
```dart
// Listen to Supabase changes
supabase
  .from('ride_location_updates')
  .stream(primaryKey: ['id'])
  .listen((List<Map<String, dynamic>> data) {
    final updates = data.map((json) => 
      RideLocationUpdateModel.fromJson(json)).toList();
    updateMapMarkers(updates);
  });
```

### 2. **Status Management**
```dart
// Track ride lifecycle
void handleRideStatusChange(RideModel ride) {
  if (ride.isInProgress) {
    startLocationTracking();
  } else if (ride.isCompleted) {
    showPaymentScreen();
  }
}
```

### 3. **Data Validation**
```dart
// Validate coordinates
if (order.hasValidCoordinates) {
  showMapRoute(order.latFrom, order.lngFrom, order.latTo, order.lngTo);
}

// Validate rating
if (rating.isValidRating) {
  updateDriverScore(rating.ratingValue);
}
```

### 4. **Calculations**
```dart
// Distance calculation
final distance = locationUpdate.distanceTo(
  destinationLat, 
  destinationLng
);

// Average ratings
final avgRating = RatingModel.calculateAverageRating(driverRatings);
```

## Database Table Mapping

| Model | Database Table | Primary Use |
|-------|---------------|-------------|
| UserModel | `users` | Authentication, profiles |
| OrderModel | `orders` (custom) | Order management |
| RideRequestModel | `ride_requests` | Passenger requests |
| DriverOfferModel | `driver_offers` | Driver responses |
| RideModel | `rides` | Active ride tracking |
| RideLocationUpdateModel | `ride_location_updates` | GPS tracking |
| PaymentModel | `payments` | Transaction records |
| RatingModel | `ratings` | Feedback system |

## Best Practices

1. **Always use model helpers** instead of raw status strings
2. **Use copyWith()** for immutable updates
3. **Import via barrel file** (`models.dart`) for consistency
4. **Validate data** using model helper methods
5. **Use formatted getters** for UI display
6. **Handle null values** properly in factory constructors

## Integration with Real-time Features

All models are designed to work seamlessly with:
- ✅ Supabase real-time subscriptions
- ✅ StreamBuilder widgets
- ✅ GetX reactive state management
- ✅ JSON serialization/deserialization
- ✅ Database migrations and updates

These models provide the foundation for all data operations in the MEGO app, ensuring type safety, consistency, and developer productivity.