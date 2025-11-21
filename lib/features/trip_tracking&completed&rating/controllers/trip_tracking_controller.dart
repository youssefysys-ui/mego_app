import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/core/local_db/local_db.dart';
import 'package:mego_app/core/shared_models/models.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/features/trip_tracking&completed&rating/views/trip_completion_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripTrackingController extends GetxController {
  final UserRideData userRideData;
  final DriverModel? driverModel;
  final RideModel rideModel;

  // Convenience getters from userRideData
  String get fromLocation => userRideData.placeFrom;
  String get toLocation => userRideData.placeTo;
  String get rideId => userRideData.rideRequestId ?? '';

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
  RideRequestModel? _rideRequest;
  List<RideLocationUpdateModel> _locationUpdates = [];

  // Getters
  RideModel? get currentRide => _currentRide;
  RideRequestModel? get rideRequest => _rideRequest;
  List<RideLocationUpdateModel> get locationUpdates => _locationUpdates;

  // Loading states
  bool isLoading = true;

  // Supabase subscriptions
  RealtimeChannel? _rideSubscription;
  RealtimeChannel? _locationSubscription;

  // Trip tracking specific
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _isCountingDown = false;

  // Trip simulation
  Timer? _tripSimulationTimer;
  bool isTripSimulating = false;

  // Coordinates from userRideData
  late double startLat;
  late double startLng;
  late double endLat;
  late double endLng;

  // Google Maps
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentDriverPosition;
  BitmapDescriptor? _carIcon;

  // Getters for map
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  LatLng? get currentDriverPosition => _currentDriverPosition;

  TripTrackingController({
    required this.userRideData,
    this.driverModel,
    required this.rideModel,
  }) {
    // Initialize coordinates from userRideData
    startLat = userRideData.latFrom;
    startLng = userRideData.lngFrom;
    endLat = userRideData.latTo;
    endLng = userRideData.lngTo;
  }

  @override
  void onInit() {
    print('current ride=='+rideModel.riderId.toString());
    super.onInit();
    _loadCustomMarkers();
    _initializeMapData();
    _initializeData();
    _setupRealtimeSubscriptions();
    _startInitialCountdown();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _tripSimulationTimer?.cancel();
    _rideSubscription?.unsubscribe();
    _locationSubscription?.unsubscribe();
    _rideStreamController.close();
    _locationStreamController.close();
    super.onClose();
  }

  Future<void> _loadCustomMarkers() async {
    _carIcon = await _createCarMarker();
  }

  Future<BitmapDescriptor> _createCarMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 120.0;

    // Draw burgundy circle background
    final Paint circlePaint = Paint()
      ..color = const Color(0xFF8B1538)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      circlePaint,
    );

    // Draw white car icon
    final icon = Icons.directions_car;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 60.0,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final img = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> _initializeData() async {
    try {
      isLoading = true;
      update();

      await Future.wait([
        _loadRide(),
        _loadLocationUpdates(),
      ]);

      print('📍 Trip coordinates from userRideData:');
      print('   From: ($startLat, $startLng)');
      print('   To: ($endLat, $endLng)');

    } catch (e) {
      print('❌ Error initializing trip tracking: $e');
      Get.snackbar(
        'Error',
        'Failed to load trip data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
          .select('*, ride_requests(*)')
          .eq('id', rideId)
          .maybeSingle();

      if (response != null) {
        _currentRide = RideModel.fromJson(response);

        if (response['ride_requests'] != null) {
          _rideRequest = RideRequestModel.fromJson(response['ride_requests']);
          print('✅ Ride request loaded: Pickup (${_rideRequest!.pickupLat}, ${_rideRequest!.pickupLng}) → Dropoff (${_rideRequest!.dropoffLat}, ${_rideRequest!.dropoffLng})');
        }

        _rideStreamController.add(_currentRide);
        print('✅ Trip ride loaded: ${_currentRide?.id}');
      }
    } catch (e) {
      print('❌ Error loading trip ride: $e');
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
      print('✅ Loaded ${_locationUpdates.length} trip location updates');
    } catch (e) {
      print('❌ Error loading trip location updates: $e');
    }
  }

  void _setupRealtimeSubscriptions() {
    final supabase = Supabase.instance.client;
    _rideSubscription = supabase
        .channel('trip_tracking_$rideId')
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
        print('🔄 Trip ride change detected: ${payload.eventType}');
        _handleRideChange(payload);
      },
    )
        .subscribe();

    _locationSubscription = supabase
        .channel('trip_location_updates_$rideId')
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
        print('📍 Trip location update detected: ${payload.eventType}');
        _handleLocationChange(payload);
      },
    )
        .subscribe();

    print('🔔 Trip tracking real-time subscriptions setup complete');
  }

  void _handleRideChange(PostgresChangePayload payload) {
    print(".........IM IN HANDLE RIDE CHANGE.................");
    print("payload new record=="+payload.newRecord.toString());
    try {
      final updatedRide = RideModel.fromJson(payload.newRecord);
      _currentRide = updatedRide;
      _rideStreamController.add(_currentRide);
      update();

      // Auto-save riding state whenever ride changes
      saveCurrentRiding();

      if (updatedRide.isCompleted) {
        _stopCountdown();
        stopTripSimulation();
        // Clear saved state when ride is completed
        clearRidingState();
        Future.delayed(const Duration(milliseconds: 500), () {
          //_showTripCompletedDialog();
          Get.to(TripCompletionView(
            ride:currentRide!,
            fareAmount: userRideData.est_price,

          ));
        });
      }
    } catch (e) {
      print('❌ Error handling trip ride change: $e');
    }
  }

  void _handleLocationChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          final newLocation = RideLocationUpdateModel.fromJson(payload.newRecord);
          _locationUpdates.insert(0, newLocation);
          _locationStreamController.add(_locationUpdates);

          if (_currentRide != null) {
            _currentRide = _currentRide!.copyWith(
              currentDriverLat: newLocation.lat,
              currentDriverLng: newLocation.lng,
            );
            _rideStreamController.add(_currentRide);
            
            // Auto-save riding state on location updates
            saveCurrentRiding();
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
          break;

        case PostgresChangeEvent.all:
          _loadLocationUpdates();
          break;
      }
      update();
    } catch (e) {
      print('❌ Error handling trip location change: $e');
    }
  }

  void _startInitialCountdown() {
    final distance = _calculateTripDistance();
    final estimatedMinutes = (distance / 1000 * 2).ceil();
    _remainingSeconds = estimatedMinutes * 60;

    _isCountingDown = true;
    _startCountdown();

    print('🚗 Trip started! Estimated duration: $estimatedMinutes minutes');

    Future.delayed(const Duration(seconds: 2), () {
      startTripSimulation();
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        update();
      } else {
        _stopCountdown();
        _completeTripIfNearDestination();
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _isCountingDown = false;
    update();
  }

  void startTripSimulation() {
    if (isTripSimulating) return;

    isTripSimulating = true;
    int step = 0;
    const totalSteps = 50;

    print('🚗 Starting trip simulation...');
    print('📍 From: $fromLocation ($startLat, $startLng)');
    print('📍 To: $toLocation ($endLat, $endLng)');

    final distance = _calculateTripDistance();
    print('📏 Total distance: ${(distance / 1000).toStringAsFixed(2)} km');

    _tripSimulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      step++;

      if (step > totalSteps) {
        timer.cancel();
        isTripSimulating = false;
        print('🏁 Trip simulation completed - Arrived at destination');

        final finalLat = endLat;
        final finalLng = endLng;

        _currentDriverPosition = LatLng(finalLat, finalLng);
        _markers.removeWhere((marker) => marker.markerId.value == 'driver');
        if (_carIcon != null) {
          _addCarMarker(_currentDriverPosition!);
        }

        _stopCountdown();
        _remainingSeconds = 0;

        update();

        await _updateRideStatus(RideModel.statusCompleted);

        Future.delayed(const Duration(milliseconds: 500), () {
         // _showTripCompletedDialog();
          Get.to(TripCompletionView(
            ride:currentRide!,
            fareAmount: userRideData.est_price,

          ));
        });
        return;
      }

      final progress = step / totalSteps;

      final currentLat = startLat + (endLat - startLat) * progress;
      final currentLng = startLng + (endLng - startLng) * progress;

      final random = Random();
      final latVariation = (random.nextDouble() - 0.5) * 0.0003;
      final lngVariation = (random.nextDouble() - 0.5) * 0.0003;

      final finalLat = currentLat + latVariation;
      final finalLng = currentLng + lngVariation;

      _updateDriverMarker(finalLat, finalLng);
      _updateRemainingTimeBasedOnProgress(progress);

      print('🚗 Step $step/$totalSteps - Progress: ${(progress * 100).toStringAsFixed(1)}% - Position: (${finalLat.toStringAsFixed(6)}, ${finalLng.toStringAsFixed(6)})');

       if(step==totalSteps){
         print(".............FINAL UPDATE CALLING..............");
         print("You reach the pick up destination now");
          await _updateRideStatus(RideModel.statusCompleted);
         Get.to(() => TripCompletionView(
           ride: rideModel,
           driverModel: driverModel,
           fareAmount:rideModel.totalPrice
         ));
       }

    });

    Get.snackbar(
      'Trip Started! 🚗',
      'Simulating journey from $fromLocation to $toLocation',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6B0F1A),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
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

      _updateDriverMarker(lat, lng);

      print('📍 Trip location added: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}');

    } catch (e) {
      print('❌ Error adding trip location: $e');
    }
  }

  Future<void> _updateRideStatus(String status) async {
    try {
      final supabase = Supabase.instance.client;

      final updateData = <String, dynamic>{'status': status};

      if (status == RideModel.statusCompleted) {
        updateData['end_time'] = DateTime.now().toIso8601String();
      }

      await supabase
          .from('rides')
          .update(updateData)
          .eq('id', rideId);

      print('✅ Trip status updated to: $status');

    } catch (e) {
      print('❌ Error updating trip status: $e');
    }
  }

  void _updateRemainingTimeBasedOnProgress(double progress) {
    if (progress > 0 && _isCountingDown) {
      final totalDistance = _calculateTripDistance();
      final remainingDistance = totalDistance * (1 - progress);

      final estimatedRemainingMinutes = (remainingDistance / 1000 * 2).ceil();
      _remainingSeconds = estimatedRemainingMinutes * 60;

      if (_remainingSeconds < 30) {
        _remainingSeconds = 30;
      }
    }
  }

  void _completeTripIfNearDestination() {
    if (_currentRide?.hasDriverLocation == true) {
      final currentDistance = RideLocationUpdateModel(
          id: '',
          rideId: '',
          driverId: '',
          lat: _currentRide!.currentDriverLat!,
          lng: _currentRide!.currentDriverLng!,
          recordedAt: DateTime.now()
      ).distanceTo(endLat, endLng);

      if (currentDistance < 100) {
        _updateRideStatus(RideModel.statusCompleted);
      }
    }
  }

  double _calculateTripDistance() {
    return RideLocationUpdateModel(
        id: '',
        rideId: '',
        driverId: '',
        lat: startLat,
        lng: startLng,
        recordedAt: DateTime.now()
    ).distanceTo(endLat, endLng);
  }

  void stopTripSimulation() {
    _tripSimulationTimer?.cancel();
    isTripSimulating = false;
    _stopCountdown();
    print('🛑 Trip simulation stopped');
  }

  String get formattedCountdown {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get estimatedArrivalTime {
    final now = DateTime.now();
    final arrivalTime = now.add(Duration(seconds: _remainingSeconds));
    return '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }

  bool get isCountingDown => _isCountingDown;

  String get currentStatus {
    if (_currentRide?.isCompleted == true) {
      return 'Trip Completed';
    } else if (isTripSimulating) {
      return 'In Trip';
    } else {
      return 'Preparing Trip';
    }
  }

  Color get statusColor {
    if (_currentRide?.isCompleted == true) {
      return Colors.green;
    } else if (isTripSimulating) {
      return const Color(0xFF8B1538);
    } else {
      return Colors.orange;
    }
  }

  String get progressPercentage {
    if (!isTripSimulating) return '0%';

    if (_currentRide?.hasDriverLocation == true) {
      final currentDistance = RideLocationUpdateModel(
          id: '',
          rideId: '',
          driverId: '',
          lat: _currentRide!.currentDriverLat!,
          lng: _currentRide!.currentDriverLng!,
          recordedAt: DateTime.now()
      ).distanceTo(endLat, endLng);

      final totalDistance = _calculateTripDistance();
      final progress = ((totalDistance - currentDistance) / totalDistance * 100).clamp(0.0, 100.0);

      return '${progress.toInt()}%';
    }

    return '0%';
  }

  void refreshTripData() {
    _loadRide();
    _loadLocationUpdates();
  }

  void emergencyStop() {
    stopTripSimulation();
    Get.dialog(
      AlertDialog(
        title: const Text('Emergency Stop'),
        content: const Text('Trip has been stopped. Emergency services have been notified.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void callEmergency() {
    Get.snackbar(
      'Emergency Call',
      'Calling emergency services...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showTripCompletedDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green checkmark icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              // Trip Completed text
              const Text(
                'Trip Completed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B1538),
                  fontFamily: 'Montserrat',
                ),
              ),

              const SizedBox(height: 16),

              // Nice message with MEGO branding
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Roboto',
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Have a nice trip with ',
                    ),
                    TextSpan(
                      text: 'ME',
                      style: TextStyle(
                        color: Color(0xFF8B1538),
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: 'GO',
                      style: TextStyle(
                        color: Color(0xFFFFA500),
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: '!\n\nGreat, you reached your destination.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _showTripCompletionView();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1538),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showTripCompletionView() {
    if (_currentRide == null) return;

    final distance = _calculateTripDistance();
    final baseFare = 5.0;
    final perKmRate = 2.5;
    final fareAmount = baseFare + (distance / 1000 * perKmRate);

    Get.to(() => TripCompletionView(
      ride: _currentRide!,
      driverModel: driverModel,
      fareAmount: fareAmount,
    ));
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    update();
  }

  void _initializeMapData() {
    _markers.clear();
    _polylines.clear();

    // Pickup marker (green)
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(startLat, startLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        anchor: const Offset(0.5, 0.5),
      ),
    );

    // Dropoff marker (burgundy)
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(endLat, endLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        anchor: const Offset(0.5, 0.5),
      ),
    );

    // Driver marker with car icon
    _currentDriverPosition = LatLng(startLat, startLng);
    if (_carIcon != null) {
      _addCarMarker(_currentDriverPosition!);
    }

    // Route polyline
    _createRoutePolyline();

    update();
  }

  void _addCarMarker(LatLng position) {
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: position,
        icon: _carIcon ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
      ),
    );
  }

  void _createRoutePolyline() {
    final List<LatLng> routePoints = [
      LatLng(startLat, startLng),
      LatLng(endLat, endLng),
    ];

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: const Color(0xFF8B1538),
        width: 4,
      ),
    );
  }

  void _updateDriverMarker(double lat, double lng) {
    final newPosition = LatLng(lat, lng);
    _currentDriverPosition = newPosition;

    // Remove old driver marker
    _markers.removeWhere((marker) => marker.markerId.value == 'driver');

    // Add updated car marker
    if (_carIcon != null) {
      _addCarMarker(newPosition);
    }

    // Calculate remaining distance to destination
    final remainingDistance = RideLocationUpdateModel(
        id: '',
        rideId: '',
        driverId: '',
        lat: lat,
        lng: lng,
        recordedAt: DateTime.now()
    ).distanceTo(endLat, endLng);

    // Check if we've reached the destination (less than 50 meters)
    if (remainingDistance < 50 && isTripSimulating) {
      print('🎯 Destination reached! Distance: ${remainingDistance.toInt()}m');
      _handleDestinationReached();
      return;
    }

    // Update camera to follow car with smooth animation
    if (_mapController != null) {
      double zoom = 15.0;
      if (remainingDistance > 5000) {
        zoom = 13.0;
      } else if (remainingDistance > 2000) {
        zoom = 14.0;
      } else if (remainingDistance > 1000) {
        zoom = 15.0;
      } else {
        zoom = 16.0;
      }

      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: zoom,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    }

    update();
  }

  // Handle when destination is reached
  void _handleDestinationReached() async {
    // Stop simulation immediately
    _tripSimulationTimer?.cancel();
    isTripSimulating = false;

    // Stop countdown
    _stopCountdown();
    _remainingSeconds = 0;

    print('✅ Trip completed - Arrived at destination');

    // Update ride status to completed
    await _updateRideStatus(RideModel.statusCompleted);

    // Show completion dialog
    Future.delayed(const Duration(milliseconds: 500), () {
     // _showTripCompletedDialog();

      Get.to(TripCompletionView(
        ride:currentRide!,
        fareAmount: userRideData.est_price,

      ));
    });

    update();
  }

  LatLng get mapCenter {
    if (startLat == 0.0 || endLat == 0.0) {
      return const LatLng(30.0444, 31.2357);
    }

    final centerLat = (startLat + endLat) / 2;
    final centerLng = (startLng + endLng) / 2;
    return LatLng(centerLat, centerLng);
  }

  double get mapZoom {
    if (startLat == 0.0 || endLat == 0.0) {
      return 12.0;
    }

    final distance = _calculateTripDistance();

    if (distance < 1000) {
      return 15.0;
    } else if (distance < 5000) {
      return 13.0;
    } else if (distance < 20000) {
      return 11.0;
    } else {
      return 9.0;
    }
  }

  // Get remaining distance to destination
  String get remainingDistance {
    if (_currentDriverPosition == null) {
      final totalDistance = _calculateTripDistance();
      return '${(totalDistance / 1000).toStringAsFixed(1)} km';
    }

    final distance = RideLocationUpdateModel(
        id: '',
        rideId: '',
        driverId: '',
        lat: _currentDriverPosition!.latitude,
        lng: _currentDriverPosition!.longitude,
        recordedAt: DateTime.now()
    ).distanceTo(endLat, endLng);

    if (distance < 1000) {
      return '${distance.toInt()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Save current riding state to local storage for persistence
  Future<void> saveCurrentRiding() async {
    try {
      if (_currentRide == null) return;
      
      final ridingStateData = {
        'rideId': rideId,
        'currentRide': _currentRide!.toJson(),
        'userRideData': userRideData.toJson(),
        'driverModel': driverModel?.toJson(),
        'rideModel': rideModel.toJson(),
        'locationUpdates': _locationUpdates.map((e) => e.toJson()).toList(),
        'isTripSimulating': isTripSimulating,
        'remainingSeconds': _remainingSeconds,
        'isCountingDown': _isCountingDown,
        'currentDriverPosition': _currentDriverPosition != null
            ? {
                'lat': _currentDriverPosition!.latitude,
                'lng': _currentDriverPosition!.longitude,
              }
            : null,
        'savedAt': DateTime.now().toIso8601String(),
        'rideStatus': _currentRide!.status,
        'tripType': 'passenger_ride', // Identify this as passenger ride
      };
      
      await storage.write('current_riding_state', ridingStateData);
      print('💾 Current riding state saved successfully - Ride ID: $rideId');
      
    } catch (e) {
      print('❌ Error saving riding state: $e');
    }
  }
  
  /// Check if there's an active riding state and if ride is still ongoing
  static Future<bool> hasActiveRidingState() async {
    try {
      final ridingStateData = await storage.read('current_riding_state');
      if (ridingStateData == null) return false;
      
      final savedAt = DateTime.parse(ridingStateData['savedAt']);
      final timeDifference = DateTime.now().difference(savedAt);
      final rideStatus = ridingStateData['rideStatus'] as String?;
      
      // Only restore if ride is not completed/cancelled and saved within last 12 hours
      final isRideOngoing = rideStatus != null && 
          !['completed', 'cancelled', 'finished'].contains(rideStatus.toLowerCase());
      
      return isRideOngoing && timeDifference.inHours < 12;
    } catch (e) {
      print('❌ Error checking active riding state: $e');
      return false;
    }
  }
  
  /// Get active riding state from local storage
  static Future<Map<String, dynamic>?> getActiveRidingState() async {
    try {
      final ridingStateData = await storage.read('current_riding_state');
      if (ridingStateData == null) return null;
      
      return Map<String, dynamic>.from(ridingStateData);
    } catch (e) {
      print('❌ Error getting active riding state: $e');
      return null;
    }
  }
  
  /// Clear saved riding state (call when ride is completed/cancelled)
  Future<void> clearRidingState() async {
    try {
      await storage.delete('current_riding_state');
      print('🗑️ Riding state cleared');
    } catch (e) {
      print('❌ Error clearing riding state: $e');
    }
  }
  
  /// Restore controller state from saved riding data
  Future<void> restoreFromSavedRidingState(Map<String, dynamic> savedState) async {
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
      
      // Restore driver position
      if (savedState['currentDriverPosition'] != null) {
        final position = savedState['currentDriverPosition'];
        _currentDriverPosition = LatLng(position['lat'], position['lng']);
      }
      
      // Restore countdown state
      if (savedState['remainingSeconds'] != null) {
        _remainingSeconds = savedState['remainingSeconds'];
      }
      
      if (savedState['isCountingDown'] == true && _remainingSeconds > 0) {
        _resumeCountdown();
      }
      
      // Restore trip simulation state
      if (savedState['isTripSimulating'] == true) {
        _resumeTripSimulationFromSavedState();
      }
      
      print('✅ Riding state restored successfully');
      
      // Update streams with restored data
      _rideStreamController.add(_currentRide);
      _locationStreamController.add(_locationUpdates);
      
      // Update map with restored data
      _updateMapWithRestoredData();
      
      isLoading = false;
      update();
      
    } catch (e) {
      print('❌ Error restoring riding state: $e');
      isLoading = false;
      update();
    }
  }
  
  /// Resume countdown from saved state
  void _resumeCountdown() {
    if (_remainingSeconds <= 0) return;
    
    _isCountingDown = true;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      update();
      
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _isCountingDown = false;
        _onCountdownComplete();
      }
    });
    
    print('⏰ Countdown resumed: ${_remainingSeconds}s remaining');
  }
  
  /// Resume trip simulation from saved state
  void _resumeTripSimulationFromSavedState() {
    if (_locationUpdates.isNotEmpty) {
      // Resume from last known position
      print('🚗 Resuming trip simulation from saved state');
      _startTripMovement();
    } else {
      // Start fresh simulation
      _startTripMovement();
    }
  }
  
  /// Update map with restored data
  void _updateMapWithRestoredData() {
    // Recreate markers and polylines
    _updateMapMarkers();
    
    // Center map appropriately
    if (_currentDriverPosition != null) {
      _centerMapOnDriver();
    } else {
      _centerMapOnRoute();
    }
  }

  void _updateMapMarkers() {
    _markers.clear();

    // Pickup marker (green)
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(startLat, startLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        anchor: const Offset(0.5, 0.5),
      ),
    );

    // Dropoff marker (burgundy)
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(endLat, endLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        anchor: const Offset(0.5, 0.5),
      ),
    );

    // Driver marker with car icon
    if (_currentDriverPosition != null) {
      _addCarMarker(_currentDriverPosition!);
    }

    update();
  }

  void _centerMapOnDriver() {
    if (_currentDriverPosition == null) return;

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentDriverPosition!,
          zoom: 15,
          tilt: 0,
          bearing: 0,
        ),
      ),
    );
  }

  void _centerMapOnRoute() {
    final bounds = _calculateRouteBounds();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  LatLngBounds _calculateRouteBounds() {
    double southWestLat = min(startLat, endLat);
    double southWestLng = min(startLng, endLng);
    double northEastLat = max(startLat, endLat);
    double northEastLng = max(startLng, endLng);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  /// Handle countdown completion
  void _onCountdownComplete() {
    print('⏰ Countdown completed - checking if destination reached');
    _completeTripIfNearDestination();
  }

  /// Start trip movement simulation (alias for existing method)
  void _startTripMovement() {
    if (!isTripSimulating) {
      startTripSimulation();
    }
  }
}
