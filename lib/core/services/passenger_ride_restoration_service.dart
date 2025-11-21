import 'package:get/get.dart';
import 'package:mego_app/core/local_db/local_db.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/core/shared_models/models.dart';
import 'package:mego_app/features/trip_tracking&completed&rating/controllers/trip_tracking_controller.dart';
import 'package:mego_app/features/trip_tracking&completed&rating/views/trip_tracking_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local_db/local_db.dart';

/// Service to handle automatic passenger ride restoration when app reopens
class PassengerRideRestorationService {
  /// Check for active passenger rides on app startup and restore if found
  /// Returns true if a passenger ride was restored, false otherwise
  static Future<bool> checkAndRestoreActivePassengerRide() async {
    try {
      print('🔍 Checking for active passenger rides...');
      
      if (await TripTrackingController.hasActiveRidingState()) {
        final savedState = await TripTrackingController.getActiveRidingState();
        
        if (savedState != null) {
          print('✅ Active passenger ride found - restoring...');
          final restored = await _restoreActivePassengerRide(savedState);
          return restored;
        }
      } else {
        print('ℹ️ No active passenger rides found');
      }
      return false;
    } catch (e) {
      print('❌ Error checking for active passenger rides: $e');
      return false;
    }
  }
  
  /// Clear passenger ride state from storage
  static Future<void> clearPassengerRideState() async {
    try {
      await _clearCorruptedState();
      print('🗑️ Passenger ride state cleared');
    } catch (e) {
      print('❌ Error clearing passenger ride state: $e');
    }
  }
  
  /// Restore active passenger ride and navigate to tracking screen
  /// Returns true if restoration was successful, false otherwise
  static Future<bool> _restoreActivePassengerRide(Map<String, dynamic> savedState) async {
    try {
      final rideId = savedState['rideId'] as String;
      
      // First, verify the ride status from database to ensure it's still active
      final currentRideStatus = await _checkCurrentRideStatus(rideId);
      
      if (currentRideStatus == null) {
        print('⚠️ Passenger ride not found in database - clearing saved state');
        await _clearCorruptedState();
        return false;
      }
      
      // Check if ride is completed, cancelled, or finished
      final completedStatuses = ['completed', 'cancelled', 'finished', 'arrived'];
      if (completedStatuses.contains(currentRideStatus.toLowerCase())) {
        print('ℹ️ Passenger ride is already ${currentRideStatus} - not restoring, clearing saved state');
        await _clearCorruptedState();
        return false;
      }
      
      // Parse user ride data (required)
      if (savedState['userRideData'] == null) {
        print('❌ Cannot restore: userRideData is missing');
        await _clearCorruptedState();
        //return;
      }
      
      final userRideData = UserRideData.fromJson(savedState['userRideData']);
      
      // Parse ride model (required)
      if (savedState['rideModel'] == null) {
        print('❌ Cannot restore: rideModel is missing');
        await _clearCorruptedState();
       // return;
      }
      
      final rideModel = RideModel.fromJson(savedState['rideModel']);
      
      // Parse driver model (optional)
      DriverModel? driverModel;
      if (savedState['driverModel'] != null) {
        driverModel = DriverModel.fromJson(savedState['driverModel']);
      }
      
      // Create controller with saved data
      final controller = TripTrackingController(
        userRideData: userRideData,
        driverModel: driverModel,
        rideModel: rideModel,
      );
      
      // Restore controller state from saved data
      await controller.restoreFromSavedRidingState(savedState);
      
      // Navigate to trip tracking view
      Get.to(() => TripTrackingView(
        userRideData: userRideData,
        driverModel: driverModel,
        ride: rideModel,
      ));
      
      print('✅ Active passenger ride restored successfully - Ride ID: $rideId');
      return true;
      
    } catch (e) {
      print('❌ Error restoring active passenger ride: $e');
      await _clearCorruptedState();
      return false;
    }
  }
  
  /// Check current ride status from database
  static Future<String?> _checkCurrentRideStatus(String rideId) async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('rides')
          .select('status')
          .eq('id', rideId)
          .maybeSingle();
      
      return response?['status'] as String?;
    } catch (e) {
      print('❌ Error checking passenger ride status: $e');
      return null;
    }
  }
  
  /// Clear corrupted state
  static Future<void> _clearCorruptedState() async {
    try {
      // Directly clear the corrupted state from storage
      await storage.delete('current_riding_state');
      print('🗑️ Corrupted passenger ride state cleared');
    } catch (e) {
      print('❌ Error clearing corrupted passenger ride state: $e');
    }
  }
}