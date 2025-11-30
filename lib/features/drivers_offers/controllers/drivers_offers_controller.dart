import 'dart:async';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/shared_models/models.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/ride_accept_track/ride_accept_track_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/local_db/local_db.dart';
import '../../../core/shared_models/user_ride_data.dart';
import '../models/test_driver_data.dart';

class DriversOffersController extends GetxController {
  final String rideRequestId;
  
  // Stream controllers for real-time updates
  final StreamController<List<DriverOfferModel>> _offersStreamController = 
      StreamController<List<DriverOfferModel>>.broadcast();
  
  final StreamController<RideRequestModel?> _rideRequestStreamController = 
      StreamController<RideRequestModel?>.broadcast();

  // Stream getters
  Stream<List<DriverOfferModel>> get offersStream => _offersStreamController.stream;
  Stream<RideRequestModel?> get rideRequestStream => _rideRequestStreamController.stream;

  // Current data
  List<DriverOfferModel> _currentOffers = [];
  RideRequestModel? _currentRideRequest;
  
  // Getters
  List<DriverOfferModel> get currentOffers => _currentOffers;
  RideRequestModel? get currentRideRequest => _currentRideRequest;
  
  // Loading states
  bool isLoading = true;
  bool isAcceptingOffer = false;

  // Supabase subscription
  RealtimeChannel? _offersSubscription;
  RealtimeChannel? _rideRequestSubscription;

  DriversOffersController({required this.rideRequestId});

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupRealtimeSubscriptions();
    _startPeriodicCleanup();
    
    // Start auto test offers after a delay to let initialization complete
    Future.delayed(const Duration(seconds: 2), () {
      startAutoTestOffers();
    });
  }

  @override
  void onClose() {
    _testOfferTimer?.cancel();
    _cleanupTimer?.cancel();
    _offersSubscription?.unsubscribe();
    _rideRequestSubscription?.unsubscribe();
    _offersStreamController.close();
    _rideRequestStreamController.close();
    super.onClose();
  }

  Future<void> _initializeData() async {
    try {
      isLoading = true;
      update();

      await Future.wait([
        _loadRideRequest(),
        _loadOffers(),
      ]);

    } catch (e) {
      print('❌ Error initializing data: $e');
      appMessageFail(text: 'Failed to load ride data', context: Get.context!);
     
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _loadRideRequest() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('ride_requests')
          .select()
          .eq('id', rideRequestId)
          .maybeSingle();

      if (response != null) {
        _currentRideRequest = RideRequestModel.fromJson(response);
        _rideRequestStreamController.add(_currentRideRequest);
        print('✅ Ride request loaded: ${_currentRideRequest?.id}');
      }
    } catch (e) {
      print('❌ Error loading ride request: $e');
    }
  }

  Future<void> _loadOffers() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Join with drivers table to get driver information
      final response = await supabase
          .from('driver_offers')
          .select('''
            *,
            drivers (
              id,
              name,
              email,
              phone,
              rate,
              car_info,
              profile_image,
              activated,
              online
            )
          ''')
          .eq('ride_request_id', rideRequestId)
          .order('created_at', ascending: false);

      _currentOffers = (response as List)
          .map((offer) => DriverOfferModel.fromJson(offer))
          .toList();
      
      _offersStreamController.add(_currentOffers);
      print('✅ Loaded ${_currentOffers.length} offers with driver data');
    } catch (e) {
      print('❌ Error loading offers: $e');
      // Fallback to load offers without driver join
      try {
        final fallbackResponse = await Supabase.instance.client
            .from('driver_offers')
            .select()
            .eq('ride_request_id', rideRequestId)
            .order('created_at', ascending: false);

        _currentOffers = (fallbackResponse as List)
            .map((offer) => DriverOfferModel.fromJson(offer))
            .toList();
        
        _offersStreamController.add(_currentOffers);
        print('✅ Loaded ${_currentOffers.length} offers (fallback without driver data)');
      } catch (fallbackError) {
        print('❌ Error in fallback loading offers: $fallbackError');
      }
    }
  }

  void _setupRealtimeSubscriptions() {
    final supabase = Supabase.instance.client;

    // Subscribe to driver offers changes
    _offersSubscription = supabase
        .channel('driver_offers_$rideRequestId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'driver_offers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ride_request_id',
            value: rideRequestId,
          ),
          callback: (payload) {
            print('🔄 Driver offers change detected: ${payload.eventType}');
            _handleOffersChange(payload);
          },
        )
        .subscribe();

    // Subscribe to ride request changes
    _rideRequestSubscription = supabase
        .channel('ride_request_$rideRequestId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ride_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: rideRequestId,
          ),
          callback: (payload) {
            print('🔄 Ride request change detected: ${payload.eventType}');
            _handleRideRequestChange(payload);
          },
        )
        .subscribe();

    print('🔔 Real-time subscriptions setup complete');
  }

  void _handleOffersChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          _handleNewOffer(payload.newRecord);
          break;

        case PostgresChangeEvent.update:
          final updatedOffer = DriverOfferModel.fromJson(payload.newRecord);
          final index = _currentOffers.indexWhere((o) => o.id == updatedOffer.id);
          if (index != -1) {
            _currentOffers[index] = updatedOffer;
            _offersStreamController.add(_currentOffers);
          }
          break;

        case PostgresChangeEvent.delete:
          final deletedId = payload.oldRecord['id'].toString();
          _currentOffers.removeWhere((o) => o.id == deletedId);
          _offersStreamController.add(_currentOffers);
          break;

        case PostgresChangeEvent.all:
          // Refresh all data on 'all' event
          _loadOffers();
          break;
      }
      update();
    } catch (e) {
      print('❌ Error handling offers change: $e');
    }
  }

  Future<void> _handleNewOffer(Map<String, dynamic> offerData) async {
    try {
      var newOffer = DriverOfferModel.fromJson(offerData);
      
      // If driver data is missing, fetch it
      if (newOffer.driver == null) {
        print('⚠️ New offer missing driver data, fetching...');
        final supabase = Supabase.instance.client;
        
        final driverResponse = await supabase
            .from('drivers')
            .select()
            .eq('id', newOffer.driverId)
            .maybeSingle();
        
        if (driverResponse != null) {
          final driver = DriverModel.fromJson(driverResponse);
          newOffer = newOffer.copyWith(driver: driver);
          print('✅ Driver data fetched: ${driver.name}');
        }
      }
      
      // Filter out expired offers and add new one
      _currentOffers = _currentOffers.where((offer) => !offer.isExpired).toList();
      _currentOffers.add(newOffer); // Add to end to keep all offers visible
      _offersStreamController.add(_currentOffers);
      
      // Schedule removal after 40 seconds
      Timer(const Duration(seconds: 40), () {
        _removeOfferAfterExpiry(newOffer.id);
      });
      
    } catch (e) {
      print('❌ Error handling new offer: $e');
    }
  }

  void _handleRideRequestChange(PostgresChangePayload payload) {
    try {
      final updatedRideRequest = RideRequestModel.fromJson(payload.newRecord);
      _currentRideRequest = updatedRideRequest;
      _rideRequestStreamController.add(_currentRideRequest);
      update();

      // Handle status changes
      if (updatedRideRequest.isAccepted) {
        appMessageSuccess(text: 'Ride Accepted!', context: Get.context!);
        
      }
    } catch (e) {
      print('❌ Error handling ride request change: $e');
    }
  }

  Future<void> acceptOffer(DriverOfferModel offer,UserRideData userRideData,

  ) async {
    if (isAcceptingOffer) return;

    try {
      isAcceptingOffer = true;
      update();

      final supabase = Supabase.instance.client;



      String userId = Storage.userId.toString();


      if (userId =='null') {
        throw Exception('User not authenticated');
      }

      // Validate driver data exists
      if (offer.driver == null) {
        print('⚠️ Driver data missing, fetching from database...');
        
        // Fetch driver data from database
        final driverResponse = await supabase
            .from('drivers')
            .select()
            .eq('id', offer.driverId)
            .maybeSingle();
        
        if (driverResponse == null) {
          throw Exception('Driver not found in database');
        }
        
        // Create updated offer with driver data
        final driver = DriverModel.fromJson(driverResponse);
        offer = offer.copyWith(driver: driver);
        
        print('✅ Driver data fetched successfully: ${driver.name}');
      }

      print('🚀 Starting offer acceptance process...');
      print('Offer ID: ${offer.id}');
      print('Driver ID: ${offer.driverId}');
      print('Driver Name: ${offer.displayName}');
      print('Driver Phone: ${offer.displayPhone}');
      print('Price: ${offer.formattedPrice}');

      // 1. Update the accepted offer status
      print('📝 Updating accepted offer status...');
      await supabase
          .from('driver_offers')
          .update({'status':'accepted'})
          .eq('id', offer.id);

      // 2. Reject all other offers for this ride request
      print('❌ Rejecting other offers...');
      await supabase
          .from('driver_offers')
          .update({'status':'refused'})
          .eq('ride_request_id', rideRequestId)
          .neq('id', offer.id);

      // 3. Update the ride request status to accepted
      print('✅ Updating ride request status...');
      await supabase
          .from('ride_requests')
          .update({'status': 'accepted'})
          .eq('id', rideRequestId);

      // 4. Create ride record in rides table
      print('🚗 Creating ride record...');
      final rideData = {
        'ride_request_id': rideRequestId,
        'driver_id': offer.driverId,
        'rider_id': userId,
        'start_time': DateTime.now().toIso8601String(),
        'total_price': offer.offeredPrice,
        'status': 'started',
       // RideModel.statusStarted,
        'created_at': DateTime.now().toIso8601String(),
      };

      final rideResponse = await supabase
          .from('rides')
          .insert(rideData)
          .select()
          .single();

      final rideId = rideResponse['id'].toString();

      print('✅ Offer acceptance completed successfully!');
      print('Ride ID: $rideId');
      print('Driver: ${offer.displayName} (${offer.driverId})');
      print('Driver Phone: ${offer.displayPhone}');
      print('Price: ${offer.formattedPrice}');
      print('Status: Started');

      appMessageSuccess(text:'Offer accepted! Ride started with ${offer.displayName}.'
       , context: Get.context!);
      
      

      // Navigate to ride tracking screen after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        // Double check driver data exists before navigation
        if (offer.driver == null) {
          print('❌ Error: Driver data is null, cannot navigate');
          appMessageFail(text: 'Driver data unavailable', context: Get.context!);
          return;
        }
        
        print('🎯 Navigating to ride tracking with driver: ${offer.driver!.name}');
        Get.off(() => RideAcceptTrackView(
          rideId: rideId, 
          userRideData: userRideData,
          driverModel: offer.driver!, // Pass the complete driver data
        ),
          transition: Transition.leftToRightWithFade,
          duration: const Duration(milliseconds: 500),
        );
      });

    } catch (e) {
      print('❌ Error accepting offer: $e');
      appMessageFail(text: 'Failed to accept offer', context: Get.context!);
     
    } finally {
      isAcceptingOffer = false;
      update();
    }
  }

  Future<void> cancelRideRequest() async {
    try {
      final supabase = Supabase.instance.client;

      await supabase
          .from('ride_requests')
          .update({'status': 'refused'})
          .eq('id', rideRequestId);

      print('✅ Ride request cancelled');

      appMessageSuccess(text: 'Ride request cancelled', context: Get.context!);
      
    

      Get.back();

    } catch (e) {
      print('❌ Error cancelling ride request: $e');
      appMessageFail(text: 'Failed to cancel ride request', context: Get.context!);
     
    }
  }

  void refreshData() {
    _loadOffers();
    _loadRideRequest();
  }

  // Remove offer after 40 seconds expiry
  void _removeOfferAfterExpiry(String offerId) {
    try {
      _currentOffers.removeWhere((offer) => offer.id == offerId);
      _offersStreamController.add(_currentOffers);
      
      print('🕒 Offer $offerId removed after 40 seconds expiry');
    } catch (e) {
      print('❌ Error removing expired offer: $e');
    }
    update();
  }

  // Start periodic cleanup of expired offers
  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final initialCount = _currentOffers.length;
      _currentOffers.removeWhere((offer) => offer.isExpired);
      
      if (_currentOffers.length != initialCount) {
        _offersStreamController.add(_currentOffers);
        update();
        print('🧹 Cleaned up expired offers: ${initialCount - _currentOffers.length} removed');
      }
    });
  }

  // Auto-generate test offers every 5 seconds
  Timer? _testOfferTimer;
  Timer? _cleanupTimer;
  int _testOfferCounter = 1;

  void startAutoTestOffers() {
    _testOfferTimer?.cancel(); // Cancel existing timer if any
  
    _testOfferTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _addTestOffer();
      // Stop after 3 offers to prevent infinite loop
      if (_testOfferCounter > 3) {
        timer.cancel();
        print('🛑 Auto test offers stopped after 3 offers');
        
        // Show completion message
       
      }
    });
    
    print('🚀 Auto test offers started - will add 3 offers (every 3 seconds)');
  }

  Future<void> _addTestOffer() async {
  try {
    final supabase = Supabase.instance.client;
    
    // Fetch drivers from Supabase each time
    final drivers = await TestDriverData.fetchDriversFromSupabase();
    
    if (drivers.isEmpty) {
      print('❌ No drivers available in database');
      return;
    }
    
    // Get test driver from the list
    final testDriver = TestDriverData.getTestDriver(
      drivers,
      _testOfferCounter - 1,
    );
    
    // Convert to offer data
    final testOfferData = testDriver.toOfferData(
      rideRequestId: rideRequestId,
    );
    
    print("///TEST OFFER DATA............: $testOfferData");
    
    await supabase
        .from('driver_offers')
        .insert(testOfferData);

    print('✅ Test offer $_testOfferCounter: ${testDriver.name} - ${testOfferData['offered_price']} EGP - ${testOfferData['estimated_time']}min');
    _testOfferCounter++;
    
  } catch (e) {
    print('❌ Error adding test offer: $e');
  }
}
  void stopAutoTestOffers() {
    _testOfferTimer?.cancel();
    _testOfferTimer = null;
    print('🛑 Auto test offers stopped');
  }

  Future<void> rejectOffer(DriverOfferModel offer) async {
    try {
      final supabase = Supabase.instance.client;

      print('❌ Rejecting offer: ${offer.id}');
      
      // Update the offer status to rejected
      await supabase
          .from('driver_offers')
          .update({'status': DriverOfferModel.statusRejected})
          .eq('id', offer.id);

      // Remove the rejected offer from the list immediately
      _currentOffers.removeWhere((o) => o.id == offer.id);
      _offersStreamController.add(_currentOffers);
      update();

      print('✅ Offer rejected successfully and removed from view');



    } catch (e) {
      print('❌ Error rejecting offer: $e');
     
    }
  }
}
