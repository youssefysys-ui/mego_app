import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:mego_app/core/local_db/local_db.dart';
import 'package:mego_app/core/shared_models/coupon_model.dart';
import 'package:mego_app/features/search_places%20&%20calculation/controllers/est_services_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place_model.dart';

class SearchPlacesController extends GetxController {

  late EstServicesController estServicesController;
  late LocalStorageService _localStorage;
  
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  final FocusNode fromFocusNode = FocusNode();
  final FocusNode toFocusNode = FocusNode();

  List<PlaceModel> searchResults = [];
  bool isSearching = false;
  bool isSelectingPlace = false;
  bool isLoadingLocation = true; // Loading state for getting current location
  bool isFromField = true;

  PlaceModel? selectedFromPlace;
  PlaceModel? selectedToPlace;
  
  // Applied coupon for discount
  Coupon? appliedCoupon;

  static const String apiKey = "AIzaSyDYKfcCmSzheZh7zGH7wsPiIM58-R6y020";

  @override
  void onInit() {
    super.onInit();
    estServicesController = Get.put(EstServicesController());
    _localStorage = GetIt.instance<LocalStorageService>();
    
    // Load selected coupon from local storage
    _loadSelectedCoupon();
    
    // Get current location on init
    getCurrentLocation();
  }

  /// Load selected coupon from local storage
  void _loadSelectedCoupon() {
    try {
      final savedCoupon = _localStorage.selectedCoupon;
      if (savedCoupon != null) {
        final coupon = Coupon.fromJson(savedCoupon);
        // Check if coupon is still valid
        if (coupon.isValid) {
          appliedCoupon = coupon;
          print('✅ Loaded valid coupon from storage: ${coupon.type}');
          update();
        } else {
          // Remove invalid coupon from storage
          _localStorage.deleteSelectedCoupon();
          print('⚠️ Removed invalid coupon from storage');
        }
      }
    } catch (e) {
      print('❌ Error loading coupon from storage: $e');
      _localStorage.deleteSelectedCoupon();
    }
  }


  Future<void> getCurrentLocation() async {
    isLoadingLocation = true;
    fromController.text = 'Getting your location...';
    update();

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied');
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permission permanently denied');
        _setDefaultLocation();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Current location: ${position.latitude}, ${position.longitude}');

      // Get address from coordinates
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Set the location
      selectedFromPlace = PlaceModel(
        name: address,
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
        placeId: 'current_location',
      );

      fromController.text = address;
      print('✅ Current location set: $address');

    } catch (e) {
      print('❌ Error getting current location: $e');
      _setDefaultLocation();
    } finally {
      isLoadingLocation = false;
      update();
    }
  }

  // Fallback if location fails
  void _setDefaultLocation() {
    selectedFromPlace = PlaceModel(
      name: 'My Location',
      address: 'Current Location',
      latitude: 0.0,
      longitude: 0.0,
      placeId: 'current_location',
    );
    fromController.text = 'My Location';
    isLoadingLocation = false;
    update();
  }

  @override
  void onClose() {
    fromController.dispose();
    toController.dispose();
    fromFocusNode.dispose();
    toFocusNode.dispose();
    super.onClose();
  }

  Future<void> setCurrentLocation(double lat, double lng) async {
    if (selectedFromPlace?.placeId == 'current_location') {
      final address = await getAddressFromCoordinates(lat, lng);

      selectedFromPlace = PlaceModel(
        name: address,
        address: address,
        latitude: lat,
        longitude: lng,
        placeId: 'current_location',
      );
      fromController.text = address;
      update();
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      print('🌍 Getting address for coordinates: $lat, $lng');
      String geoCodingApiKey ='AIzaSyA0xWRjiEL0MqcMdtfLO3NIFWUX-6IleWA';
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$geoCodingApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print("IM HERE RESPONSE=="+response.body);
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'] as String;
          print('✅ Address found: $address');
          return address;
        }
      }
      print('⚠️ Could not get address, using fallback');
    } catch (e) {
      print('❌ Error getting address: $e');
    }
    return 'My Location';
  }

  void setActiveField(bool isFrom) {
    isFromField = isFrom;
    searchResults.clear();
    update();
  }

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 1) {
      searchResults.clear();
      update();
      return;
    }

    isSearching = true;
    update();

    try {
      print('🔍 Searching for: $query');
      final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$apiKey&components=country:egy';
      print('🌐 API URL: $url');

      final response = await http.get(Uri.parse(url));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Decoded data: $data');

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          print('✅ Found ${predictions.length} predictions');

          searchResults.clear();
          final newResults = predictions
              .map((place) => PlaceModel.fromJson(place))
              .toList();
          searchResults.addAll(newResults);

          print('🏢 Search results count: ${searchResults.length}');
          print('🏢 Search results: ${searchResults.map((p) => p.name).toList()}');
          print('🔄 Calling update() to refresh UI');
        } else {
          print('❌ API Error Status: ${data['status']}');
          if (data.containsKey('error_message')) {
            print('❌ API Error Message: ${data['error_message']}');
          }
          searchResults.clear();
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        searchResults.clear();
      }
    } catch (e) {
      print('💥 Exception searching places: $e');
      searchResults.clear();
    }

    isSearching = false;
    update();
  }

  Future<PlaceModel?> getPlaceDetails(String placeId) async {
    try {
      print('🔍 Getting place details for: $placeId');
      final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,geometry&key=$apiKey';
      print('🌐 Details URL: $url');

      final response = await http.get(Uri.parse(url));

      print('📡 Details response status: ${response.statusCode}');
      print('📄 Details response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = PlaceModel.fromJson(data['result']);
          print('✅ Place details loaded: ${result.name} (${result.latitude}, ${result.longitude})');
          return result;
        } else {
          print('❌ Details API Error Status: ${data['status']}');
          if (data.containsKey('error_message')) {
            print('❌ Details API Error Message: ${data['error_message']}');
          }
        }
      }
    } catch (e) {
      print('💥 Exception getting place details: $e');
    }
    return null;
  }

  Future<void> selectPlace(PlaceModel place) async {
    isSelectingPlace = true;
    update();

    PlaceModel? detailedPlace = place;

    try {
      if (place.latitude == 0.0 && place.longitude == 0.0 && place.placeId.isNotEmpty) {
        print('🔍 Getting place details for: ${place.name}');
        detailedPlace = await getPlaceDetails(place.placeId);
        if (detailedPlace == null) {
          detailedPlace = place;
        }
      }

      if (isFromField) {
        selectedFromPlace = detailedPlace;
        fromController.text = detailedPlace.name;
        print('✅ FROM PLACE SELECTED:');
        print('Name: ${detailedPlace.name}');
        print('Address: ${detailedPlace.address}');
        print('Latitude: ${detailedPlace.latitude}');
        print('Longitude: ${detailedPlace.longitude}');
      } else {
        selectedToPlace = detailedPlace;
        toController.text = detailedPlace.name;
        print('✅ TO PLACE SELECTED:');
        print('Name: ${detailedPlace.name}');
        print('Address: ${detailedPlace.address}');
        print('Latitude: ${detailedPlace.latitude}');
        print('Longitude: ${detailedPlace.longitude}');
      }

      searchResults.clear();
      FocusScope.of(Get.context!).unfocus();

    } catch (e) {
      print('❌ Error selecting place: $e');
      Get.snackbar(
        'Error',
        'Failed to select location. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSelectingPlace = false;
      update();
    }
  }

  void clearSearch() {
    searchResults.clear();
    update();
  }

  void swapLocations() {
    final tempPlace = selectedFromPlace;
    final tempText = fromController.text;

    selectedFromPlace = selectedToPlace;
    fromController.text = toController.text;

    selectedToPlace = tempPlace;
    toController.text = tempText;

    update();

    print('LOCATIONS SWAPPED');
    if (selectedFromPlace != null) {
      print('New FROM: ${selectedFromPlace?.name} (${selectedFromPlace?.latitude}, ${selectedFromPlace?.longitude})');
    }
    if (selectedToPlace != null) {
      print('New TO: ${selectedToPlace?.name} (${selectedToPlace?.latitude}, ${selectedToPlace?.longitude})');
    }
  }


  // Refresh current location
  Future<void> refreshCurrentLocation() async {
    await getCurrentLocation();
  }

  /// Apply coupon to ride request
  void applyCoupon(Coupon coupon) {
    appliedCoupon = coupon;
    update();
    print('✅ Coupon applied: ${coupon.type}');
  }

  /// Remove applied coupon
  void removeCoupon() {
    appliedCoupon = null;
    update();
    print('🗑️ Coupon removed');
  }
}