// import 'package:get/get.dart';
// import 'package:mego_app/core/shared_models/driver_model.dart';
// import 'package:mego_app/core/shared_models/user_ride_data.dart';
// import 'package:mego_app/features/ride_accept_track/controllers/rider_accept_track_controller.dart';
// import 'package:mego_app/features/ride_accept_track/ride_accept_track_view.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// /// Service to handle automatic ride restoration when app reopens
// class RideRestorationService {
//   /// Check for active rides on app startup and restore if found
//   /// Returns true if a ride was restored, false otherwise
//   static Future<bool> checkAndRestoreActiveRide() async {
//     try {
//       print('🔍 Checking for active rides...');
//
//       if (await RiderAcceptTrackController.hasActiveRideState()) {
//         final savedState = await RiderAcceptTrackController.getActiveRideState();
//
//         if (savedState != null) {
//           print('✅ Active ride found - restoring...');
//           final restored = await _restoreActiveRide(savedState);
//           return restored;
//         }
//       } else {
//         print('ℹ️ No active rides found');
//       }
//       return false;
//     } catch (e) {
//       print('❌ Error checking for active rides: $e');
//       return false;
//     }
//   }
//
//   /// Clear driver ride state from storage
//   static Future<void> clearDriverRideState() async {
//     try {
//       await _clearSavedRideState();
//       print('🗑️ Driver ride state cleared');
//     } catch (e) {
//       print('❌ Error clearing driver ride state: $e');
//     }
//   }
//
//   /// Restore active ride and navigate to tracking screen
//   /// Returns true if restoration was successful, false otherwise
//   static Future<bool> _restoreActiveRide(Map<String, dynamic> savedState) async {
//     try {
//       final rideId = savedState['rideId'] as String;
//
//       // First, verify the ride status from database to ensure it's still active
//       final currentRideStatus = await _checkCurrentRideStatus(rideId);
//
//       if (currentRideStatus == null) {
//         print('⚠️ Ride not found in database - clearing saved state');
//         await _clearSavedRideState();
//         return false;
//       }
//
//       // Check if ride is completed, cancelled, or finished
//       final completedStatuses = ['completed', 'cancelled', 'finished', 'arrived'];
//       if (completedStatuses.contains(currentRideStatus.toLowerCase())) {
//         print('ℹ️ Ride is already ${currentRideStatus} - not restoring, clearing saved state');
//         await _clearSavedRideState();
//         return false;
//       }
//
//       // Parse driver model if exists
//       DriverModel? driverModel;
//       if (savedState['driverModel'] != null) {
//         driverModel = DriverModel.fromJson(savedState['driverModel']);
//       }
//
//       // Parse user ride data if exists
//       UserRideData? userRideData;
//       if (savedState['userRideData'] != null) {
//         userRideData = UserRideData.fromJson(savedState['userRideData']);
//       }
//
//       // Create controller with saved data
//       final controller = RiderAcceptTrackController(
//         rideId: rideId,
//         driverModel: driverModel,
//         userRideData: userRideData,
//       );
//
//       // Restore controller state from saved data
//       await controller.restoreFromSavedState(savedState);
//
//       // Navigate to ride tracking view only if we have required data
//       if (driverModel != null && userRideData != null) {
//         Get.to(() => RideAcceptTrackView(
//           rideId: rideId,
//           driverModel: driverModel!,
//           userRideData: userRideData!,
//         ));
//
//         print('✅ Active ride restored successfully - Ride ID: $rideId');
//         return true;
//       } else {
//         print('⚠️ Cannot restore ride: missing required data (driverModel: ${driverModel != null}, userRideData: ${userRideData != null})');
//         await _clearSavedRideState();
//         return false;
//       }
//
//     } catch (e) {
//       print('❌ Error restoring active ride: $e');
//       await _clearSavedRideState();
//       return false;
//     }
//   }
//
//   /// Check current ride status from database
//   static Future<String?> _checkCurrentRideStatus(String rideId) async {
//     try {
//       final supabase = Supabase.instance.client;
//
//       final response = await supabase
//           .from('rides')
//           .select('status')
//           .eq('id', rideId)
//           .maybeSingle();
//
//       return response?['status'] as String?;
//     } catch (e) {
//       print('❌ Error checking ride status: $e');
//       return null;
//     }
//   }
//
//   /// Clear saved ride state
//   static Future<void> _clearSavedRideState() async {
//     try {
//       final tempController = RiderAcceptTrackController(rideId: 'temp');
//       await tempController.clearRideState();
//     } catch (e) {
//       print('❌ Error clearing saved ride state: $e');
//     }
//   }
// }