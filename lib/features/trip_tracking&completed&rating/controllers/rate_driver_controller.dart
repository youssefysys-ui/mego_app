import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/res/app_colors.dart';
import '../../home/views/home_view.dart';

class RateDriverController extends GetxController {
  final DriverModel driverModel;
  final String rideId;

  RateDriverController({
    required this.driverModel,
    required this.rideId,
  });

  final SupabaseClient supabase = Supabase.instance.client;

  // State variables
  int selectedRating = 0;
  bool isLoading = false;
  String errorMessage = '';
  final TextEditingController commentController = TextEditingController();

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }


  saveCurrentRiding(){

  }

  // Set rating when user taps a star
  void setRating(int rating) {
    selectedRating = rating;
    update();
  }

  // Submit rating to Supabase
  Future<void> submitRating(BuildContext context) async {
    if (selectedRating == 0) {
      appMessageFail(text: 'Please select a rating', context: context);
      return;
    }

    try {
      isLoading = true;
      update();

      print('⭐ Submitting rating: $selectedRating for driver: ${driverModel.id}');

      // 1. Insert the rating into ratings table
      await _insertRating();

      // 2. Calculate new average rating
      final newAverageRating = await _calculateNewAverageRating();

      // 3. Update driver's rating in drivers table
      await _updateDriverRating(newAverageRating);

      if (context.mounted) {
        Get.back(); // Close rating dialog
     //   Get.back(); // Go back from completion view
        appMessageSuccess(text: 'Thank You! ⭐', context: context);
        Get.offAll(HomeView());
      }

    } catch (e) {
      print('❌ Error submitting rating: $e');
      errorMessage = e.toString();
      if (context.mounted) {
        appMessageFail(text: 'Failed to submit rating: $e', context: context);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  // Insert rating into ratings table
  Future<void> _insertRating() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // ✅ تحقق من وجود السائق في قاعدة البيانات
    final driverExists = await supabase
        .from('drivers')  // أو 'drivers' حسب جدولك
        .select('id')
        .eq('id', driverModel.id)
        .maybeSingle();

    if (driverExists == null) {
      throw Exception('Driver not found in database');
    }

    final ratingData = {
      'ride_id': rideId,
      'user_id': userId,
      'driver_id': driverModel.id,
      'rating_value': selectedRating,
      'comment': commentController.text.trim().isEmpty
          ? null
          : commentController.text.trim(),
    };

    await supabase.from('ratings').insert(ratingData);

    print('✅ Rating inserted successfully');
  }

  // Calculate new average rating from all ratings
  Future<double> _calculateNewAverageRating() async {
    try {
      // Get all ratings for this driver
      final response = await supabase
          .from('ratings')
          .select('rating_value')  // ✅ Changed from 'rating' to 'rating_value'
          .eq('driver_id', driverModel.id);

      if (response.isEmpty) {
        return selectedRating.toDouble();
      }

      // Calculate average
      final ratings = response.map((r) => r['rating_value'] as int).toList();  // ✅ Changed key
      final sum = ratings.reduce((a, b) => a + b);
      final average = sum / ratings.length;

      print('📊 Total ratings: ${ratings.length}');
      print('📊 New average: ${average.toStringAsFixed(2)}');

      return average;

    } catch (e) {
      print('❌ Error calculating average: $e');
      return selectedRating.toDouble();
    }
  }

  // Update driver's rating in drivers table
  Future<void> _updateDriverRating(double newRating) async {
    await supabase
        .from('drivers')
        .update({'rate': newRating})
        .eq('id', driverModel.id);
    print('✅ Driver rating updated to: ${newRating.toStringAsFixed(2)}');
  }
}