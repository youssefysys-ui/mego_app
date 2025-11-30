

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/core/loading/loading.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/local_db/local_db.dart';
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

  List<String> lastDropOffLocations = [];

  Future<void> getLastUserDropOffLocation() async {
    try {
      // Get current user from local storage


      // if (userModel == null) {
      //   print('❌ No user found in local storage');
      //   return;
      // }

      final currentUserId =Storage.userId.toString();
      //localDb.userId.toString();
      print('🔍 Fetching dropoff locations for user: $currentUserId');

      // Get Supabase client
      final supabase = Supabase.instance.client;

      // Fetch rides for current user with ride_request relationship
      // Note: The column name is 'ride_request_' not 'ride_request_id'
      final ridesResponse = await supabase
          .from('rides')
          .select('''
          id, 
          ride_request_id, 
          created_at,
          ride_requests!ride_request_id(dropoff_place)
        ''')
          .eq('rider_id', currentUserId)
          .not('ride_request_id', 'is', null)  // Only get rides with valid ride_request_
          .order('created_at', ascending: false)
          .limit(10);

      print('📦 Fetched ${ridesResponse.length} rides from database');

      // Clear the list before adding new data
      lastDropOffLocations.clear();

      // Extract dropoff places and remove duplicates
      final Set<String> uniqueLocations = {};

      for (var ride in ridesResponse) {
        // Access the nested ride_requests data
        // The relationship name in the response will be 'ride_requests'
        final rideRequest = ride['ride_requests'];

        if (rideRequest != null) {
          final dropoffPlace = rideRequest['dropoff_place']?.toString().trim();
          if (dropoffPlace != null && dropoffPlace.isNotEmpty) {
            uniqueLocations.add(dropoffPlace);
            print('  ✓ Found location: $dropoffPlace');
          }
        }
      }

      lastDropOffLocations = uniqueLocations.toList();

      print('✅ Successfully fetched ${lastDropOffLocations.length} unique dropoff locations');
      print('📍 Dropoff locations: $lastDropOffLocations');

      update(); // Notify UI

    } catch (e) {
      print('❌ Error fetching dropoff locations: $e');
      print('Error details: ${e.toString()}');
      lastDropOffLocations = [];
      update(); // Notify UI even on error
    }
  }


}
