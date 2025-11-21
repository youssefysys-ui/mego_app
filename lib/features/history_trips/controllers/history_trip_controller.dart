import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../../../core/shared_models/ride_model.dart';
import '../../../core/shared_models/ride_request_model.dart';

/// Combined trip data model containing both ride and ride request information
class TripData {
  final RideModel ride;
  final RideRequestModel? rideRequest;

  TripData({
    required this.ride,
    this.rideRequest,
  });

  // Convenience getters
  String get id => ride.id;
  String get status => ride.status;
  DateTime get createdAt => ride.createdAt;
  double? get estimatedPrice => rideRequest?.estimatedPrice;
  int? get estimatedTime => rideRequest?.estimatedTime;
  String? get formattedPrice => rideRequest?.formattedPrice;
  String? get formattedTime => rideRequest?.formattedTime;
}

class HistoryTripController extends GetxController {
  final supabase = Supabase.instance.client;

  // State variables
  List<TripData> allTripsData = [];
  bool isLoading = false;
  String error = '';

  // Get current user ID
  String? get currentUserId => supabase.auth.currentUser?.id;

  /// Fetch all trips with ride request data for the current user
  Future<List<TripData>> getAllTripsWithRequestData() async {
    if (currentUserId == null) {
      error = 'User not authenticated';
      update();
      return [];
    }

    try {
      isLoading = true;
      error = '';
      update();

      // Fetch rides with ride_requests joined
      final response = await supabase
          .from('rides')
          .select('*, ride_requests!inner(*)')
          .eq('rider_id', currentUserId!)
          .order('created_at', ascending: false);

      final List<TripData> fetchedTrips = (response as List).map((json) {
        final ride = RideModel.fromJson(json);
        final rideRequest = json['ride_requests'] != null
            ? RideRequestModel.fromJson(json['ride_requests'])
            : null;

        return TripData(ride: ride, rideRequest: rideRequest);
      }).toList();

      allTripsData = fetchedTrips;
      isLoading = false;
      update();
      return fetchedTrips;
    } catch (e) {
      error = 'Error fetching trips: $e';
      isLoading = false;
      print('Error fetching trips: $e');
      update();
      return [];
    }
  }

  /// Fetch active trips (started or in_progress) with ride request data
  Future<List<TripData>> getActiveTripsWithRequestData() async {
    if (currentUserId == null) {
      error = 'User not authenticated';
      update();
      return [];
    }

    try {
      isLoading = true;
      error = '';
      update();

      final response = await supabase
          .from('rides')
          .select('*, ride_requests!inner(*)')
          .eq('rider_id', currentUserId!)
          .inFilter('status', [RideModel.statusStarted, RideModel.statusInProgress])
          .order('created_at', ascending: false);

      final List<TripData> fetchedTrips = (response as List).map((json) {
        final ride = RideModel.fromJson(json);
        final rideRequest = json['ride_requests'] != null
            ? RideRequestModel.fromJson(json['ride_requests'])
            : null;

        return TripData(ride: ride, rideRequest: rideRequest);
      }).toList();

      isLoading = false;
      update();
      return fetchedTrips;
    } catch (e) {
      error = 'Error fetching active trips: $e';
      isLoading = false;
      print('Error fetching active trips: $e');
      update();
      return [];
    }
  }

  /// Fetch trip history (completed or cancelled) with ride request data
  Future<List<TripData>> getTripHistory() async {
    if (currentUserId == null) {
      error = 'User not authenticated';
      update();
      return [];
    }

    try {
      isLoading = true;
      error = '';
      update();

      final response = await supabase
          .from('rides')
          .select('*, ride_requests!inner(*)')
          .eq('rider_id', currentUserId!)
          .inFilter('status', [RideModel.statusCompleted, RideModel.statusCancelled])
          .order('created_at', ascending: false);

      final List<TripData> fetchedTrips = (response as List).map((json) {
        final ride = RideModel.fromJson(json);
        final rideRequest = json['ride_requests'] != null
            ? RideRequestModel.fromJson(json['ride_requests'])
            : null;

        return TripData(ride: ride, rideRequest: rideRequest);
      }).toList();

      isLoading = false;
      update();
      return fetchedTrips;
    } catch (e) {
      error = 'Error fetching trip history: $e';
      isLoading = false;
      print('Error fetching trip history: $e');
      update();
      return [];
    }
  }

  /// Get a specific trip by ride ID with ride request data
  Future<TripData?> getTripById(String rideId) async {
    try {
      isLoading = true;
      error = '';
      update();

      final response = await supabase
          .from('rides')
          .select('*, ride_requests!inner(*)')
          .eq('id', rideId)
          .single();

      final ride = RideModel.fromJson(response);
      final rideRequest = response['ride_requests'] != null
          ? RideRequestModel.fromJson(response['ride_requests'])
          : null;

      isLoading = false;
      update();
      return TripData(ride: ride, rideRequest: rideRequest);
    } catch (e) {
      error = 'Error fetching trip: $e';
      isLoading = false;
      print('Error fetching trip: $e');
      update();
      return null;
    }
  }

  /// Subscribe to real-time updates for current user's trips
  // RealtimeChannel subscribeToTrips() {
  //   if (currentUserId == null) {
  //     throw Exception('User not authenticated');
  //   }
  //
  //   return supabase
  //       .channel('rides_channel')
  //       .onPostgresChanges(
  //     event: PostgresChangeEvent.all,
  //     schema: 'public',
  //     table: 'rides',
  //     filter: PostgresChangeFilter(
  //       type: PostgresChangeFilterType.eq,
  //       column: 'rider_id',
  //       value: currentUserId,
  //     ),
  //     callback: (payload) async {
  //       print('Ride update received: ${payload.eventType}');
  //
  //       switch (payload.eventType) {
  //         case PostgresChangeEvent.insert:
  //         // Fetch the complete trip data including ride_request
  //           final newTrip = await getTripById(payload.newRecord['id']);
  //           if (newTrip != null) {
  //             allTripsData.insert(0, newTrip);
  //             update();
  //           }
  //           break;
  //
  //         case PostgresChangeEvent.update:
  //         // Fetch the updated trip data including ride_request
  //           final updatedTrip = await getTripById(payload.newRecord['id']);
  //           if (updatedTrip != null) {
  //             final index = allTripsData.indexWhere((t) => t.id == updatedTrip.id);
  //             if (index != -1) {
  //               allTripsData[index] = updatedTrip;
  //               update();
  //             }
  //           }
  //           break;
  //
  //         case PostgresChangeEvent.delete:
  //           allTripsData.removeWhere((t) => t.id == payload.oldRecord['id']);
  //           update();
  //           break;
  //       }
  //     },
  //   )
  //       .subscribe();
  // }

  // Legacy methods for backward compatibility (if needed)
  Future<List<RideModel>> getRidesForCurrentUser() async {
    final trips = await getAllTripsWithRequestData();
    return trips.map((t) => t.ride).toList();
  }

  Future<List<RideModel>> getActiveRides() async {
    final trips = await getActiveTripsWithRequestData();
    return trips.map((t) => t.ride).toList();
  }

  Future<List<RideModel>> getRideHistory() async {
    final trips = await getTripHistory();
    return trips.map((t) => t.ride).toList();
  }

  Future<RideModel?> getRideById(String rideId) async {
    final trip = await getTripById(rideId);
    return trip?.ride;
  }

  @override
  void onClose() {
    // Clean up subscriptions if needed
    super.onClose();
  }
}