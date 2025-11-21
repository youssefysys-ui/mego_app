// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
//
// class ServicesFirestoreUpdate {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   /// Update all services in the collection with availableDays field
//   /// availableDays should be a list of day translation keys like ['day_sunday', 'day_monday']
//
//
//   /// Update a single service with availableDays
//   static Future<void> updateServiceWithAvailableDays({
//     required String serviceId,
//     required List<String> availableDays,
//   }) async {
//     try {
//       print('🔄 Updating service: $serviceId');
//       print('📅 Available days: $availableDays');
//
//       await _firestore.collection('services').doc(serviceId).update({
//         'availableDays': availableDays,
//       });
//
//       print('✅ Service $serviceId updated successfully!');
//       print('✨ Available days: $availableDays');
//
//       Get.snackbar(
//         'Success',
//         'Service updated with available days!',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 2),
//       );
//     } catch (e) {
//       print('❌ Error updating service: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to update service: $e',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   /// Add a new service with availableDays
//   static Future<String> addServiceWithAvailableDays({
//     required Map<String, dynamic> serviceData,
//     required List<String> availableDays,
//   }) async {
//     try {
//       print('📝 Adding new service...');
//       print('📅 Available days: $availableDays');
//       print('📋 Service data: $serviceData');
//
//       final newData = {
//         ...serviceData,
//         'availableDays': availableDays,
//       };
//
//       final docRef = await _firestore.collection('services').add(newData);
//
//       print('🎉 Service added successfully!');
//       print('✨ Service ID: ${docRef.id}');
//       print('📅 Available days: $availableDays');
//
//       Get.snackbar(
//         'Success',
//         'Service added successfully!',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 2),
//       );
//
//       return docRef.id;
//     } catch (e) {
//       print('❌ Error adding service: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to add service: $e',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       rethrow;
//     }
//   }
//
//   /// Get all services with their availableDays
//   static Future<List<Map<String, dynamic>>> getAllServicesWithDays() async {
//     try {
//       print('🔍 Fetching all services...');
//
//       final snapshot = await _firestore.collection('services').get();
//
//       final services = snapshot.docs.map((doc) {
//         final data = doc.data();
//         final availableDays = List<String>.from(data['availableDays'] ?? []);
//
//         print('📌 Service: ${data['name'] ?? 'Unknown'} - Days: $availableDays');
//
//         return {
//           'id': doc.id,
//           ...data,
//           'availableDays': availableDays,
//         };
//       }).toList();
//
//       print('✅ Fetched ${services.length} services');
//       return services;
//     } catch (e) {
//       print('❌ Error fetching services: $e');
//       rethrow;
//     }
//   }
//
//   /// Format available days for display (with .tr for translation)
//   static String formatAvailableDaysForDisplay(List<String> days) {
//     if (days.isEmpty) return 'No days specified'.tr;
//
//     final formattedDays = days.map((day) => day.tr).join(', ');
//     return formattedDays;
//   }
//
//   /// Example usage with common days
//   static Future<void> setupDefaultAvailableDays() async {
//     // Common days translation keys
//     const List<String> defaultDays = [
//       'day_sunday',
//       'day_monday',
//       'day_tuesday',
//       'day_wednesday',
//       'day_thursday',
//       'day_friday',
//       'day_saturday',
//     ];
//
//     print('🔧 Setting up default available days...');
//     print('📅 Days: ${defaultDays.map((d) => d.tr).join(", ")}');
//
//     await updateAllServicesWithAvailableDays(availableDays: defaultDays);
//   }
// }
//
