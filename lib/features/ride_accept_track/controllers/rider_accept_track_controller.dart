import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/core/local_db/local_db.dart';
import 'package:mego_app/core/shared_models/models.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../trip_tracking&completed&rating/views/trip_tracking_view.dart';

class RiderAcceptTrackController extends GetxController {
  final String rideId;
  final DriverModel? driverModel;
  final UserRideData? userRideData;
  // Stream controllers for real-time updates
  final StreamController<RideModel?> _rideStreamController = 
      StreamController<RideModel?>.broadcast();
  
  final StreamController<List<RideLocationUpdateModel>> _locationStreamController = 
      StreamController<List<RideLocationUpdateModel>>.broadcast();

  // Stream getters
  Stream<RideModel?> get rideStream => _rideStreamController.stream;
  Stream<List<RideLocationUpdateModel>> get locationStream => _locationStreamController.stream;

  // Current data
  RideModel? _currentRide;
  List<RideLocationUpdateModel> _locationUpdates = [];
  
  // Getters
  RideModel? get currentRide => _currentRide;
  List<RideLocationUpdateModel> get locationUpdates => _locationUpdates;
  BitmapDescriptor? get driverCarIcon => _driverCarIcon;
  
  // Loading states
  bool isLoading = true;
  
  // Supabase subscriptions
  RealtimeChannel? _rideSubscription;
  RealtimeChannel? _locationSubscription;

  // Test simulation
  Timer? _simulationTimer;
  bool isSimulating = false;

  // Google Map controller
  GoogleMapController? _mapController;
  
  // Custom car icon for driver marker
  BitmapDescriptor? _driverCarIcon;

  // Test coordinates (Cairo Airport to user's current location simulation)
  static const double cairoAirportLat = 30.1219;  // Driver start: Cairo Airport
  static const double cairoAirportLng = 31.4056;
  
  // User's current location (you can update these to your actual location)
  static const double userCurrentLat = 30.0626;   // User location: Cairo downtown area
  static const double userCurrentLng = 31.2497;

  RiderAcceptTrackController({
    required this.rideId,
    this.driverModel,
    this.userRideData,
  });

  @override
  void onInit() {
    super.onInit();
    _loadCustomCarIcon();
    _initializeData();
    _setupRealtimeSubscriptions();
    
    // Start test simulation after initialization
    Future.delayed(const Duration(seconds: 2), () {
      startTestSimulation();
    });
  }

  @override
  void onClose() {
    _simulationTimer?.cancel();
    _rideSubscription?.unsubscribe();
    _locationSubscription?.unsubscribe();
    _rideStreamController.close();
    _locationStreamController.close();
    super.onClose();
  }

  /// Save current ride data to local storage for persistence
  Future<void> saveCurrentRideData() async {
    try {
      if (_currentRide == null) return;
      
      final rideStateData = {
        'rideId': rideId,
        'currentRide': _currentRide!.toJson(),
        'driverModel': driverModel?.toJson(),
        'userRideData': userRideData?.toJson(),
        'locationUpdates': _locationUpdates.map((e) => e.toJson()).toList(),
        'isSimulating': isSimulating,
        'savedAt': DateTime.now().toIso8601String(),
        'rideStatus': _currentRide!.status,
      };
      
      await storage.write('active_ride_state', rideStateData);
      print('💾 Ride state saved successfully - Ride ID: $rideId');
      
    } catch (e) {
      print('❌ Error saving ride state: $e');
    }
  }
  
  /// Check if there's an active ride state and restore it
  static Future<bool> hasActiveRideState() async {
    try {
      final rideStateData = await storage.read('active_ride_state');
      if (rideStateData == null) return false;
      
      final savedAt = DateTime.parse(rideStateData['savedAt']);
      final timeDifference = DateTime.now().difference(savedAt);
      
      // Consider ride active if saved within last 24 hours
      return timeDifference.inHours < 24;
    } catch (e) {
      print('❌ Error checking active ride state: $e');
      return false;
    }
  }
  
  /// Restore ride state from local storage
  static Future<Map<String, dynamic>?> getActiveRideState() async {
    try {
      final rideStateData = await storage.read('active_ride_state');
      if (rideStateData == null) return null;
      
      return Map<String, dynamic>.from(rideStateData);
    } catch (e) {
      print('❌ Error getting active ride state: $e');
      return null;
    }
  }
  
  /// Clear saved ride state (call when ride is completed/cancelled)
  Future<void> clearRideState() async {
    try {
      await storage.delete('active_ride_state');
      print('🗑️ Ride state cleared');
    } catch (e) {
      print('❌ Error clearing ride state: $e');
    }
  }
  
  /// Restore controller state from saved data
  Future<void> restoreFromSavedState(Map<String, dynamic> savedState) async {
    try {
      // Restore current ride
      if (savedState['currentRide'] != null) {
        _currentRide = RideModel.fromJson(savedState['currentRide']);
      }
      
      // Restore location updates
      if (savedState['locationUpdates'] != null) {
        _locationUpdates = (savedState['locationUpdates'] as List)
            .map((e) => RideLocationUpdateModel.fromJson(e))
            .toList();
      }
      
      // Restore simulation state
      if (savedState['isSimulating'] == true) {
        // Resume simulation from last known position
        _resumeSimulationFromSavedState();
      }
      
      print('✅ Ride state restored successfully');
      
      // Update streams with restored data
      _rideStreamController.add(_currentRide);
      _locationStreamController.add(_locationUpdates);
      
      isLoading = false;
      update();
      
    } catch (e) {
      print('❌ Error restoring ride state: $e');
      isLoading = false;
      update();
    }
  }

  Future<void> _initializeData() async {
    try {
      isLoading = true;
      update();

      await Future.wait([
        _loadRide(),
        _loadLocationUpdates(),
      ]);

    } catch (e) {
      print('❌ Error initializing ride tracking: $e');
      appMessageFail(text:'❌ Error initializing ride tracking: $e' , context: Get.context!);

    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _loadRide() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('rides')
          .select()
          .eq('id', rideId)
          .maybeSingle();

      if (response != null) {
        _currentRide = RideModel.fromJson(response);
        _rideStreamController.add(_currentRide);
        print('✅ Ride loaded: ${_currentRide?.id}');
      }
    } catch (e) {
      print('❌ Error loading ride: $e');
    }
  }

  Future<void> _loadLocationUpdates() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('ride_location_updates')
          .select()
          .eq('ride_id', rideId)
          .order('recorded_at', ascending: false)
          .limit(10);

      _locationUpdates = (response as List)
          .map((location) => RideLocationUpdateModel.fromJson(location))
          .toList();
      
      _locationStreamController.add(_locationUpdates);
      print('✅ Loaded ${_locationUpdates.length} location updates');
    } catch (e) {
      print('❌ Error loading location updates: $e');
    }
  }

  void _setupRealtimeSubscriptions() {
    final supabase = Supabase.instance.client;

    // Subscribe to ride changes
    _rideSubscription = supabase
        .channel('ride_tracking_$rideId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rides',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: rideId,
          ),
          callback: (payload) {
            print('🔄 Ride change detected: ${payload.eventType}');
            _handleRideChange(payload);
          },
        )
        .subscribe();

    // Subscribe to location updates
    _locationSubscription = supabase
        .channel('location_updates_$rideId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ride_location_updates',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ride_id',
            value: rideId,
          ),
          callback: (payload) {
            print('📍 Location update detected: ${payload.eventType}');
            _handleLocationChange(payload);
          },
        )
        .subscribe();

    print('🔔 Real-time tracking subscriptions setup complete');
  }

  void _handleRideChange(PostgresChangePayload payload) {
    try {
      final updatedRide = RideModel.fromJson(payload.newRecord);
      _currentRide = updatedRide;
      _rideStreamController.add(_currentRide);
      update();

      // Auto-save ride state whenever it changes
      saveCurrentRideData();

      // Handle status changes
      if (updatedRide.isInProgress) {
        appMessageSuccess(text: 'Your driver is on the way', context: Get.context!);
      } else if (updatedRide.isCompleted) {
        appMessageSuccess(text: 'You have arrived at your destination', context: Get.context!);
        // Clear saved state when ride is completed
        clearRideState();
      }
    } catch (e) {
      print('❌ Error handling ride change: $e');
    }
  }

  void _handleLocationChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          final newLocation = RideLocationUpdateModel.fromJson(payload.newRecord);
          _locationUpdates.insert(0, newLocation);
          _locationStreamController.add(_locationUpdates);
          
          // Update ride with current driver location
          if (_currentRide != null) {
            _currentRide = _currentRide!.copyWith(
              currentDriverLat: newLocation.lat,
              currentDriverLng: newLocation.lng,
            );
            _rideStreamController.add(_currentRide);
            
            // Auto-save ride state on location updates
            saveCurrentRideData();
            
            // Update map camera to follow the driver
            _followDriverOnMap();
          }
          break;

        case PostgresChangeEvent.update:
          final updatedLocation = RideLocationUpdateModel.fromJson(payload.newRecord);
          final index = _locationUpdates.indexWhere((l) => l.id == updatedLocation.id);
          if (index != -1) {
            _locationUpdates[index] = updatedLocation;
            _locationStreamController.add(_locationUpdates);
          }
          break;

        case PostgresChangeEvent.delete:
          // Handle location deletion if needed
          break;

        case PostgresChangeEvent.all:
          _loadLocationUpdates();
          break;
      }
      update();
    } catch (e) {
      print('❌ Error handling location change: $e');
    }
  }

  // Test simulation function
  void startTestSimulation({double? startLat, double? startLng}) {
    if (isSimulating) return;
    
    // Check if we need to simulate (no current driver location)
    if (_currentRide?.hasDriverLocation == true) {
      print('🔍 Driver location already exists, skipping simulation');
      return;
    }

    isSimulating = true;
    int step = 0;
    const totalSteps = 25; // Extended steps to reach exact user location
    
    double simulationStartLat = startLat ?? cairoAirportLat;
    double simulationStartLng = startLng ?? cairoAirportLng;
    
    print('🚗 Starting ride tracking simulation...');
    print('📍 From: Cairo Airport (${cairoAirportLat}, ${cairoAirportLng})');
    print('📍 To: User Location (${userCurrentLat}, ${userCurrentLng})');

    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (step >= totalSteps) {
        timer.cancel();
        isSimulating = false;
        
        // Final update - driver reaches exact user location
        await _addTestLocationUpdate(userCurrentLat, userCurrentLng);
        print('🏁 Simulation completed - Driver arrived at exact user location');
        
        // Update ride status to arrived
        await _updateRideStatus('arrived');
        return;
      }

      // Calculate interpolated position
      double currentLat;
      double currentLng;
      
      if (step < totalSteps - 5) {
        // Normal progress
        final progress = step / totalSteps;
        currentLat = simulationStartLat + (userCurrentLat - simulationStartLat) * progress;
        currentLng = simulationStartLng + (userCurrentLng - simulationStartLng) * progress;
        
        // Add some random variation to make it more realistic
        final random = Random();
        final latVariation = (random.nextDouble() - 0.5) * 0.002;
        final lngVariation = (random.nextDouble() - 0.5) * 0.002;
        
        currentLat += latVariation;
        currentLng += lngVariation;
      } else {
        // Last 5 steps - move closer to exact user location (less than 1km)
        final remainingSteps = totalSteps - step;
        final progressToUser = (5 - remainingSteps) / 5.0;
        
        // Get current position
        final previousProgress = (step - 1) / totalSteps;
        final previousLat = simulationStartLat + (userCurrentLat - simulationStartLat) * previousProgress;
        final previousLng = simulationStartLng + (userCurrentLng - simulationStartLng) * previousProgress;
        
        // Move from previous position to exact user location
        currentLat = previousLat + (userCurrentLat - previousLat) * progressToUser;
        currentLng = previousLng + (userCurrentLng - previousLng) * progressToUser;
      }

      await _addTestLocationUpdate(currentLat, currentLng);
      
      step++;
      
      // Update ride status to in_progress after first location update
      if (step == 1 && _currentRide?.isStarted == true) {
        await _updateRideStatus(RideModel.statusInProgress);
      }

      final distance = RideLocationUpdateModel(
        id: '', rideId: '', driverId: '', 
        lat: currentLat, lng: currentLng, recordedAt: DateTime.now()
      ).distanceTo(userCurrentLat, userCurrentLng);

      print('🚗 Step $step/$totalSteps - Distance: ${(distance / 1000).toStringAsFixed(2)}km (${distance.toInt()}m)');
    });

    appMessageSuccess(text:'Simulation Started', context: Get.context!);

  }

  Future<void> _addTestLocationUpdate(double lat, double lng) async {
    try {
      final supabase = Supabase.instance.client;
      
      if (_currentRide == null) return;
      
      final locationData = {
        'ride_id': rideId,
        'driver_id': _currentRide!.driverId,
        'lat': lat,
        'lng': lng,
        'recorded_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('ride_location_updates')
          .insert(locationData);

      print('📍 Test location added: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}');
      
    } catch (e) {
      print('❌ Error adding test location: $e');
    }
  }

  Future<void> _updateRideStatus(String status) async {
    try {
      final supabase = Supabase.instance.client;
      
      final updateData = <String, dynamic>{'status': status};
      
      // If completing the ride, set end time
      if (status == RideModel.statusCompleted) {
        updateData['end_time'] = DateTime.now().toIso8601String();
      }

      await supabase
          .from('rides')
          .update(updateData)
          .eq('id', rideId);

      print('✅ Ride status updated to: $status');
      
    } catch (e) {
      print('❌ Error updating ride status: $e');
    }
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    isSimulating = false;
    print('🛑 Ride simulation stopped');
  }

  /// Resume simulation from saved state
  void _resumeSimulationFromSavedState() {
    if (_locationUpdates.isNotEmpty) {
      final lastLocation = _locationUpdates.last;
      // Resume simulation from last known position
      startTestSimulation(
        startLat: lastLocation.lat,
        startLng: lastLocation.lng,
      );
    } else {
      // Start fresh simulation
      startTestSimulation();
    }
  }

  // Calculate estimated time of arrival based on current location and speed
  String get estimatedArrival {
    if (_currentRide == null || !_currentRide!.hasDriverLocation) {
      return '10'; // Default estimate in minutes only
    }

    // Calculate distance in kilometers
    final distance = RideLocationUpdateModel(
      id: '', 
      rideId: '', 
      driverId: '', 
      lat: _currentRide!.currentDriverLat!, 
      lng: _currentRide!.currentDriverLng!, 
      recordedAt: DateTime.now()
    ).distanceTo(userCurrentLat, userCurrentLng);

    // Simple rule: 1 km = 1 minute
    final distanceInKm = distance / 1000;
    int estimatedMinutes = distanceInKm.ceil();
    
    // Minimum 1 minute if driver is within 1km
    if (estimatedMinutes < 1) {
      estimatedMinutes = 1;
    }
    
    return estimatedMinutes.toString().padLeft(2, '0'); // Format like "05", "10" etc.
  }

  // Check if driver is very near (within 100 meters)
  bool get isDriverVeryNear {
    if (_currentRide == null || !_currentRide!.hasDriverLocation) {
      return false;
    }

    final distance = RideLocationUpdateModel(
      id: '', 
      rideId: '', 
      driverId: '', 
      lat: _currentRide!.currentDriverLat!, 
      lng: _currentRide!.currentDriverLng!, 
      recordedAt: DateTime.now()
    ).distanceTo(userCurrentLat, userCurrentLng);

    return distance <= 100; // Within 100 meters
  }

  // Check if driver is approaching (within 1km)
  bool get isDriverApproaching {
    if (_currentRide == null || !_currentRide!.hasDriverLocation) {
      return false;
    }

    final distance = RideLocationUpdateModel(
      id: '', 
      rideId: '', 
      driverId: '', 
      lat: _currentRide!.currentDriverLat!, 
      lng: _currentRide!.currentDriverLng!, 
      recordedAt: DateTime.now()
    ).distanceTo(userCurrentLat, userCurrentLng);

    return distance > 100 && distance <= 1000; // Between 100m and 1km
  }

  // Get user-friendly status message
  String get driverStatusMessage {
    if (_currentRide == null || !_currentRide!.hasDriverLocation) {
      return 'Driver is on the way';
    }

    if (isDriverVeryNear) {
      return 'Driver is here waiting for you';
    } else if (isDriverApproaching) {
      return 'Driver is almost here - Less than 1 min';
    } else {
      return 'Driver is coming for you in ${estimatedArrival} min';
    }
  }

  // Get driver's current location as formatted string
  String get driverLocation {
    if (_currentRide?.hasDriverLocation != true) {
      return 'Location updating...';
    }
    
    return '${_currentRide!.currentDriverLat!.toStringAsFixed(4)}, ${_currentRide!.currentDriverLng!.toStringAsFixed(4)}';
  }

  // Get route distance between driver and destination
  String get routeDistance {
    if (_currentRide == null || !_currentRide!.hasDriverLocation) {
      return '';
    }

    final distance = RideLocationUpdateModel(
      id: '', 
      rideId: '', 
      driverId: '', 
      lat: _currentRide!.currentDriverLat!, 
      lng: _currentRide!.currentDriverLng!, 
      recordedAt: DateTime.now()
    ).distanceTo(userCurrentLat, userCurrentLng);

    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  void refreshData() {
    _loadRide();
    _loadLocationUpdates();
  }

  // Call/Message actions
  void callDriver() {
    appMessageSuccess(text: 'Initiating call to ${_currentRide?.driverId ?? 'driver'}...', context: Get.context!);

  }

  void messageDriver() {
    appMessageSuccess(text: 'Opening message to ${_currentRide?.driverId ?? 'driver'}...', context: Get.context!);

  }

  // Map controller methods
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    print('🗺️ Map controller set successfully');
  }

  void centerMapOnDriver() {
    if (_mapController != null && _currentRide?.hasDriverLocation == true) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentRide!.currentDriverLat!, _currentRide!.currentDriverLng!),
        ),
      );
    }
  }

  void centerMapOnDestination() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          const LatLng(userCurrentLat, userCurrentLng), // User's current location
        ),
      );
    }
  }

  // Load custom car icon from assets
  Future<void> _loadCustomCarIcon() async {
    try {
      // Convert SVG to BitmapDescriptor
      _driverCarIcon = await _createCarIconFromSvg();
      print('🚗 Custom SVG car icon loaded successfully');
      update(); // Update UI after icon is loaded
    } catch (e) {
      print('⚠️ Error loading SVG car icon: $e, using default marker');
      // Fallback to default red marker with custom hue
      _driverCarIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      update();
    }
  }

  // Create car icon from SVG
  Future<BitmapDescriptor> _createCarIconFromSvg() async {
    // Load the SVG string from assets
    final String svgString = 
    await rootBundle.loadString('assets/images/car_red.svg');
    
    // Parse SVG and create a DrawableRoot
    final DrawableRoot svgRoot =
     await svg.fromSvgString(svgString, svgString);
    
    // Create a picture recorder
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    
    // Set the size for the icon (larger for better visibility on map)
    const double size = 36.0;
    // Draw white circular background for better visibility
    final Paint backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      backgroundPaint,
    );
    
    // Draw border
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF8B1538)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 2,
      borderPaint,
    );
    
    // Scale and center the SVG
    final double svgSize = size * 0.5; // SVG takes 50% of the circle
    final double svgOffset = (size - svgSize) / 2;
    
    canvas.save();
    canvas.translate(svgOffset, svgOffset);
    canvas.scale(svgSize / 19.0, svgSize / 13.0); // Original SVG is 19x13
    svgRoot.draw(canvas, const Rect.fromLTWH(0, 0, 19, 13));
    canvas.restore();
    
    // Convert to image
    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = byteData!.buffer.asUint8List();
    
    return BitmapDescriptor.bytes(imageData);
  }

  // Calculate bearing between two points for car rotation
  double calculateBearing(LatLng start, LatLng end) {
    final startLat = start.latitude * (pi / 180.0);
    final startLng = start.longitude * (pi / 180.0);
    final endLat = end.latitude * (pi / 180.0);
    final endLng = end.longitude * (pi / 180.0);

    final deltaLng = endLng - startLng;

    final y = sin(deltaLng) * cos(endLat);
    final x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(deltaLng);

    final bearing = atan2(y, x) * (180.0 / pi);
    
    // Normalize to 0-360 degrees
    return (bearing + 360.0) % 360.0;
  }

  // Calculate distance between two coordinates (in meters)
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return RideLocationUpdateModel(
      id: '', rideId: '', driverId: '', 
      lat: lat1, lng: lng1, recordedAt: DateTime.now()
    ).distanceTo(lat2, lng2);
  }

  // Get user-friendly location names
  String get driverStartLocation => 'Cairo Airport';
  String get userDestinationLocation => 'Your Current Location';

  // Get ETA with "min" suffix for info displays
  String get estimatedArrivalWithUnit => '${estimatedArrival} min';

  // Navigate to trip tracking
  void startTripMode() {
    if (_currentRide == null) {
      appMessageFail(text: 'No active ride found', context: Get.context!);

      return;
    }

    if (userRideData == null) {
      appMessageFail(text: 'Ride data not found', context: Get.context!);

      return;
    }

    // Update ride status to in trip
    _updateRideStatus('in_trip');

    appMessageSuccess(text: '  🚗 Tracking your journey to ${userRideData!.placeTo}', context: Get.context!);
    


    // Navigate to trip tracking with UserRideData and DriverModel
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.to(() => TripTrackingView(
        userRideData: userRideData!,
        driverModel: driverModel,
        ride: _currentRide!,
      ));
    });
  }

  // Follow driver on map with smart camera positioning
  void _followDriverOnMap() {
    if (_mapController != null && _currentRide?.hasDriverLocation == true) {
      final driverLat = _currentRide!.currentDriverLat!;
      final driverLng = _currentRide!.currentDriverLng!;
      
      // Calculate distance between driver and user
      final distance = RideLocationUpdateModel(
        id: '', rideId: '', driverId: '', 
        lat: driverLat, lng: driverLng, recordedAt: DateTime.now()
      ).distanceTo(userCurrentLat, userCurrentLng);
      
      // Determine optimal zoom and center based on distance
      double zoom;
      LatLng center;
      
      if (distance < 1000) { // Less than 1km - close up view
        zoom = 15.0;
        center = LatLng(driverLat, driverLng); // Focus on driver
      } else if (distance < 5000) { // 1-5km - medium view
        zoom = 13.0;
        center = LatLng(
          (driverLat + userCurrentLat) / 2,
          (driverLng + userCurrentLng) / 2,
        );
      } else { // > 5km - wide view to show both points
        zoom = 11.0;
        center = LatLng(
          (driverLat + userCurrentLat) / 2,
          (driverLng + userCurrentLng) / 2,
        );
      }
      
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(center, zoom),
      );
    }
  }
}
