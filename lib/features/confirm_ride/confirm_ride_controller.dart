import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/features/drivers_offers/drivers_offers_view.dart';
import 'package:mego_app/features/search_places%20&%20calculation/controllers/create_ride_request_contoller.dart';

enum RideStatus { 
  initial, 
  calculating, 
  confirmed, 
  searching, 
  found, 
  cancelled 
}

enum PaymentMethod { cash, card }

class ConfirmRideController extends GetxController {
  late CreateRideRequestController createRideRequestController;
  
  // Observable variables
  final Rx<RideStatus> rideStatus = RideStatus.initial.obs;
  final RxString selectedPaymentMethod = 'Cash'.obs;
  final RxDouble fareAmount = 0.0.obs;
  final RxDouble recommendedFare = 0.0.obs;
  final RxDouble distance = 0.0.obs;
  final RxInt estimatedDuration = 0.obs; // in minutes
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Map related observables
  final Rx<CameraPosition?> initialCameraPosition = Rx<CameraPosition?>(null);
  final RxSet<Marker> markers = RxSet<Marker>({});
  final RxSet<Polyline> polylines = RxSet<Polyline>({});
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final RxBool isMapReady = false.obs;
  
  // Data
  late UserRideData userLocationData;
  Position? currentPosition;
  
  // Constants
  static const double baseFareRate = 2.5; // Base rate per km
  static const double minimumFare = 5.0;
  static const double maximumFare = 2000.0;
  static const int fareAdjustmentStep = 1;

  @override
  void onInit() {
    super.onInit();
    createRideRequestController = Get.put(CreateRideRequestController());
    _initializeController();
  }

  void _initializeController() {
    // Initialize with default values
    selectedPaymentMethod.value = 'Cash';
    rideStatus.value = RideStatus.initial;
  }

  // Initialize ride data
  void initializeRide(UserRideData locationData) {
    try {
      userLocationData = locationData;
      // Use the estimated price and time from UserRideData
      recommendedFare.value = locationData.est_price;
      fareAmount.value = locationData.est_price;
      estimatedDuration.value = locationData.est_time;
      _setupMapCamera();
      _createMarkers();
      rideStatus.value = RideStatus.confirmed;
    } catch (e) {
      _handleError('Failed to initialize ride: $e');
    }
  }

  // Setup map camera position
  void _setupMapCamera() {
    try {
      // Calculate center point between pickup and destination
      double centerLat = (userLocationData.latFrom + userLocationData.latTo) / 2;
      double centerLng = (userLocationData.lngFrom + userLocationData.lngTo) / 2;
      
      // Calculate zoom level based on distance
      double zoom = _calculateZoomLevel();
      
      initialCameraPosition.value = CameraPosition(
        target: LatLng(centerLat, centerLng),
        zoom: zoom,
      );
    } catch (e) {
      // Fallback to pickup location
      initialCameraPosition.value = CameraPosition(
        target: LatLng(userLocationData.latFrom, userLocationData.lngFrom),
        zoom: 14.0,
      );
      print('Error setting up camera: $e');
    }
  }

  // Calculate appropriate zoom level based on distance
  double _calculateZoomLevel() {
    if (distance.value <= 1) return 15.0;
    if (distance.value <= 5) return 13.0;
    if (distance.value <= 10) return 12.0;
    if (distance.value <= 20) return 11.0;
    return 10.0;
  }

  // Create map markers
  void _createMarkers() {
    try {
      markers.clear();
      
      // Pickup marker
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(userLocationData.latFrom, userLocationData.lngFrom),
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: userLocationData.placeFrom,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Destination marker
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(userLocationData.latTo, userLocationData.lngTo),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: userLocationData.placeTo,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    } catch (e) {
      print('Error creating markers: $e');
    }
  }

  // Set map controller when map is ready
  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
    isMapReady.value = true;
    _fitMarkersInView();
  }

  // Fit both markers in view
  void _fitMarkersInView() {
    if (mapController.value == null) return;
    
    try {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(userLocationData.latFrom, userLocationData.latTo) - 0.01,
          min(userLocationData.lngFrom, userLocationData.lngTo) - 0.01,
        ),
        northeast: LatLng(
          max(userLocationData.latFrom, userLocationData.latTo) + 0.01,
          max(userLocationData.lngFrom, userLocationData.lngTo) + 0.01,
        ),
      );
      
      mapController.value!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    } catch (e) {
      print('Error fitting markers: $e');
    }
  }

  // Payment method selection
  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  // Fare adjustment methods
  void increaseFare() {
    double newFare = fareAmount.value + fareAdjustmentStep;
    if (newFare <= maximumFare) {
      fareAmount.value = newFare;
    }
  }

  void decreaseFare() {
    double newFare = fareAmount.value - fareAdjustmentStep;
    if (newFare >= minimumFare) {
      fareAmount.value = newFare;
    }
  }

  // Reset fare to recommended amount
  void resetFareToRecommended() {
    fareAmount.value = recommendedFare.value;
  }

  // Find offers (main action)
  Future<void> findOffers() async {
    try {
      isLoading.value = true;
      rideStatus.value = RideStatus.searching;
      errorMessage.value = '';

      // Validate ride data
      if (!_validateRideData()) {
        return;
      }

      // Check if we have rideRequestId, if not create ride request first
      String? rideRequestId = userLocationData.rideRequestId;
      
      if (rideRequestId == null || rideRequestId.isEmpty) {
        // Create ride request if not already created
        rideRequestId = await _createRideRequest(userLocationData);
        if (rideRequestId == null) {
          return; // Error already handled in _createRideRequest
        }
        
        // Update userLocationData with the new rideRequestId
        userLocationData = userLocationData.copyWith(rideRequestId: rideRequestId);
      }

      // Success feedback
      // Get.snackbar(
      //   'Success',
      //   'Finding drivers for your ride...',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 2),
      // );

      rideStatus.value = RideStatus.found;
      
      // Print ride details for debugging
      _logRideDetails();
      
      // Navigate to DriversOffersView with the rideRequestId
      await Future.delayed(const Duration(seconds: 1));
      _navigateToDriversOffers(rideRequestId);
      
    } catch (e) {
      _handleError('Failed to find offers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validate ride data before submission
  bool _validateRideData() {
    if (userLocationData.placeFrom.isEmpty || userLocationData.placeTo.isEmpty) {
      _handleError('Please select both pickup and destination locations');
      return false;
    }
    
    if (
    userLocationData.est_price<minimumFare
    //fareAmount.value < minimumFare
    ) {
      print('❌ Fare amount too low: ${fareAmount.value}');
      _handleError('Fare amount is too low. Minimum fare is ${minimumFare.toStringAsFixed(0)}€');
      return false;
    }
    
    // if (distance.value <= 0) {
    //   _handleError('Invalid route distance');
    //   return false;
    // }
    return true;
  }

  // Create ride request using CreateRideRequestController
  Future<String?> _createRideRequest(UserRideData userRideData) async {
    try {
      // Use CreateRideRequestController to create and send ride request with updated fare amount
      final rideRequestId = await createRideRequestController.createAndSendRideRequest(

        fareAmount: fareAmount.value, // Use the updated fare amount from controller
        paymentMethod: selectedPaymentMethod.value, userRideData: userRideData,
      );
      
      return rideRequestId;
    } catch (e) {
      print('❌ Error creating ride request: $e');
      _handleError('Failed to create ride request: ${e.toString()}');
      return null;
    }
  }

  // Navigate to drivers offers view
  void _navigateToDriversOffers(String rideRequestId) {
    // Update userLocationData with the actual fare amount (user-adjusted price)
    userLocationData = userLocationData.copyWith(
      est_price: fareAmount.value, // Update estimated price to actual user-adjusted fare
    );

    Get.to(() => DriversOffersView(rideRequestId: rideRequestId,
    userRideData: userLocationData
    ),
      transition: Transition.leftToRightWithFade,
      duration: const Duration(milliseconds: 500),
    );
  }

  // Cancel ride
  void cancelRide() {
    rideStatus.value = RideStatus.cancelled;
    Get.back();
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever || 
          permission == LocationPermission.denied) {
        _handleError('Location permission is required');
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      currentPosition = position;
      
      // Add current location marker
      _addCurrentLocationMarker(position);
      
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Add current location marker
  void _addCurrentLocationMarker(Position position) {
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  // Center map on current location
  void centerOnCurrentLocation() {
    if (currentPosition != null && mapController.value != null) {
      mapController.value!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
        ),
      );
    }
  }

  // Get formatted distance string
  String get formattedDistance {
    if (distance.value < 1) {
      return '${(distance.value * 1000).toInt()} m';
    }
    return '${distance.value.toStringAsFixed(1)} km';
  }

  // Get formatted duration string
  // String get formattedDuration {
  //   if (estimatedDuration.value < 60) {
  //     return '${estimatedDuration.value} min';
  //   }
  //   int hours = estimatedDuration.value ~/ 60;
  //   int minutes = estimatedDuration.value % 60;
  //   return '${hours}h ${minutes}min';
  // }

  String formatFare(int fare) {
    if (estimatedDuration.value < 60) {
      return '${estimatedDuration.value} min';
    }
    int hours = estimatedDuration.value ~/ 60;
    int minutes = estimatedDuration.value % 60;
    return '${hours}h ${minutes}min';
  }

  // Get fare difference from recommended
  String get fareDifferenceText {
    double difference = fareAmount.value - recommendedFare.value;
    if (difference == 0) return '';
    if (difference > 0) {
      return '+${difference.toStringAsFixed(0)}€ above recommended';
    } else {
      return '${difference.toStringAsFixed(0)}€ below recommended';
    }
  }

  // Handle errors
  void _handleError(String message) {
    errorMessage.value = message;
    rideStatus.value = RideStatus.initial;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Log ride details for debugging
  void _logRideDetails() {
    print('=== Ride Details ===');
    print('From: ${userLocationData.placeFrom}');
    print('To: ${userLocationData.placeTo}');
    print('Distance: ${formattedDistance}');
    //print('Duration: ${formattedDuration}');
    print('Fare: ${fareAmount.value.toStringAsFixed(0)}€');
    print('Payment: ${selectedPaymentMethod.value}');
    print('Status: ${rideStatus.value}');
    print('==================');
  }

  @override

  void onClose() {
    mapController.value?.dispose();
    super.onClose();
  }
}
