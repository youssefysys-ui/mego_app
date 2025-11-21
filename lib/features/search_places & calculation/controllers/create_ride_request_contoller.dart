import 'package:get/get.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mego_app/core/shared_models/models.dart';
import '../../../core/shared_models/user_ride_data.dart';
import 'est_services_controller.dart';

class CreateRideRequestController extends GetxController {
  late EstServicesController estServicesController;
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    estServicesController = Get.find<EstServicesController>();
  }

  /// Create and send ride request to Supabase
  /// Returns the ride request ID if successful, null otherwise
  Future<String?> createAndSendRideRequest({
    required UserRideData  userRideData,
    required double fareAmount,
    required String paymentMethod,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        errorMessage.value = 'Please login to create a ride request';
        appMessageFail(
          text: 'Please login to create a ride request',
          context: Get.context!,
        );
        isLoading.value = false;
        return null;
      }

      print('price 1=='+userRideData.est_price.toString());
      print('price 2=='+fareAmount.toString());

      // Create ride request data for insertion
      final insertData = {
        'user_id': userId,
        'pickup_lat': userRideData.latFrom,
        'pickup_lng': userRideData.lngFrom,
        'dropoff_lat': userRideData.latFrom,
        'dropoff_lng': userRideData.lngFrom,
        'pickup_place': userRideData.placeFrom,
        'dropoff_place': userRideData.placeTo,
        'estimated_price': fareAmount,
        'estimated_time': userRideData.est_time,
        'payment_method': paymentMethod,
        'status': RideRequestModel.statusPending,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Creating ride request with data:');
      print("..................///////////.......................");
      print("DATA: $insertData");
      print("..................///////////.......................");

      // Insert ride request to Supabase
      final response = await supabase
          .from('ride_requests')
          .insert(insertData)
          .select()
          .single();

      final String rideRequestId = response['id'].toString();

      print('✅ Ride request created successfully!');
      print('Ride Request ID: $rideRequestId');
      // print('From: $pickupPlace');
      // print('To: $dropoffPlace');
      print('Estimated Price: €${fareAmount.toStringAsFixed(2)}');
      // print('Estimated Time: $estimatedTime minutes');
      print('Payment Method: $paymentMethod');

      isLoading.value = false;
      return rideRequestId;
    } catch (e) {
      print('❌ Error creating ride request: $e');
      errorMessage.value = 'Failed to create ride request: ${e.toString()}';
      appMessageFail(
        text: 'Failed to create ride request: ${e.toString()}',
        context: Get.context!,
      );
      isLoading.value = false;
      return null;
    }
  }

  // /// Get ride request details by ID
  // Future<RideRequestModel?> getRideRequest(String rideRequestId) async {
  //   try {
  //     final supabase = Supabase.instance.client;
  //     final response = await supabase
  //         .from('ride_requests')
  //         .select()
  //         .eq('id', rideRequestId)
  //         .single();
  //
  //     return RideRequestModel.fromJson(response);
  //   } catch (e) {
  //     print('❌ Error fetching ride request: $e');
  //     return null;
  //   }
  // }
  //
  // /// Cancel a ride request
  // Future<bool> cancelRideRequest(String rideRequestId) async {
  //   try {
  //     final supabase = Supabase.instance.client;
  //     await supabase
  //         .from('ride_requests')
  //         .update({'status': RideRequestModel.statusCancelled})
  //         .eq('id', rideRequestId);
  //
  //     print('✅ Ride request cancelled: $rideRequestId');
  //     return true;
  //   } catch (e) {
  //     print('❌ Error cancelling ride request: $e');
  //     appMessageFail(
  //       text: 'Failed to cancel ride request: ${e.toString()}',
  //       context: Get.context!,
  //     );
  //     return false;
  //   }
  // }
  //
  // /// Update ride request status
  // Future<bool> updateRideRequestStatus(String rideRequestId, String newStatus) async {
  //   try {
  //     final supabase = Supabase.instance.client;
  //     await supabase
  //         .from('ride_requests')
  //         .update({'status': newStatus})
  //         .eq('id', rideRequestId);
  //
  //     print('✅ Ride request status updated to: $newStatus');
  //     return true;
  //   } catch (e) {
  //     print('❌ Error updating ride request status: $e');
  //     return false;
  //   }
  // }
}
