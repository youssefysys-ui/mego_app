import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/core/loading/loading.dart';

import '../../search_places & calculation/controllers/search_places_controller.dart';


class HomeController extends GetxController {
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = false;
  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    update();
  }

  Future<void> getCurrentLocation({BuildContext? context}) async {
    isLoading = true;
    update(); // Notify UI about loading state

    // Show loading overlay if context is provided
    if (context != null) {
      LoadingOverlay.show(context, message: 'Getting your location...');
    }

    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context != null) {
            LoadingOverlay.hide();
          }
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;
      
      // Update search places controller with current location if available
      try {
        final searchController = Get.find<SearchPlacesController>();
        searchController.setCurrentLocation(latitude, longitude);
      } catch (e) {
        // SearchPlacesController not initialized yet
      }
      
      update(); // Notify UI about new location
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      isLoading = false;
      if (context != null) {
        LoadingOverlay.hide();
      }
      update(); // Notify UI about finished loading
    }
  }
}
