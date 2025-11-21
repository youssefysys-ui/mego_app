import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_models/ride_model.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/features/ride_accept_track/controllers/rider_accept_track_controller.dart';

class BuildMapArea extends StatelessWidget {
  final RiderAcceptTrackController controller;
  final DriverModel? driverModel;
  const BuildMapArea({super.key,required this.controller,this.driverModel});

  /// Get driver name from DriverModel or fallback
  String _getDriverName() {
    return driverModel?.name ?? 'Driver';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundColor,
      child: Stack(
        children: [
          // Google Map
          StreamBuilder<RideModel?>(
            stream: controller.rideStream,
            builder: (context, snapshot) {
              final ride = snapshot.data ?? controller.currentRide;
              
              // Default center (midpoint between Cairo Airport and user location)
              const LatLng initialCenter = LatLng(30.0922, 31.2276); // Midpoint for better overview
              
              // Create markers set
              Set<Marker> markers = {};
              Set<Polyline> polylines = {};
              
              // Add destination marker (always visible) - User's current location  
              markers.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  position: const LatLng(30.0626, 31.2497), // User's current location
                  icon: BitmapDescriptor.defaultMarkerWithHue(0), // Burgundy/red color to match screenshot
                  infoWindow: const InfoWindow(
                    title: '📍 Your Location',
                    snippet: 'Driver coming to you',
                  ),
                ),
              );
              
              // Add driver marker if location is available
              if (ride?.hasDriverLocation == true) {
                final driverPosition = LatLng(
                  ride!.currentDriverLat!,
                  ride.currentDriverLng!,
                );
                const destinationPosition = LatLng(30.0626, 31.2497); // User's current location
                
                // Add driver marker with custom car icon
                markers.add(
                  Marker(
                    markerId: const MarkerId('driver'),
                    position: driverPosition,
                    icon: controller.driverCarIcon ?? BitmapDescriptor.defaultMarkerWithHue(0), // Burgundy fallback
                    infoWindow: InfoWindow(
                      title: '🚗 Your Driver',
                      snippet: '${_getDriverName()} - ETA: ${controller.estimatedArrivalWithUnit}',
                    ),
                    rotation: controller.calculateBearing(driverPosition, destinationPosition),
                  ),
                );
                
                // Add a shadow/outline polyline for better visibility (render first)
                polylines.add(
                  Polyline(
                    polylineId: const PolylineId('route_shadow'),
                    points: [driverPosition, destinationPosition],
                    color: Colors.black.withOpacity(0.2),
                    width: 8,
                    endCap: Cap.roundCap,
                    startCap: Cap.roundCap,
                  ),
                );
                
                // Add main polyline between driver and destination (burgundy color like screenshot)
                polylines.add(
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: [driverPosition, destinationPosition],
                    color: const Color(0xFF8B1538), // Burgundy/maroon color matching screenshot
                    width: 6,
                    endCap: Cap.roundCap,
                    startCap: Cap.roundCap,
                  ),
                );
              }
              
              // Calculate camera position
              LatLng centerPosition = initialCenter;
              double zoom = 12.0;
              
              if (ride?.hasDriverLocation == true) {
                // Smart camera positioning based on distance
                final driverLat = ride!.currentDriverLat!;
                final driverLng = ride.currentDriverLng!;
                const userLat = 30.0626; // User's current location
                const userLng = 31.2497;
                
                // Calculate distance for optimal camera positioning
                final distance = controller.calculateDistance(
                  driverLat, driverLng, userLat, userLng
                );
                
                if (distance < 1000) {
                  // Close view - focus on driver
                  centerPosition = LatLng(driverLat, driverLng);
                  zoom = 15.0;
                } else if (distance < 5000) {
                  // Medium view - center between both
                  centerPosition = LatLng(
                    (driverLat + userLat) / 2,
                    (driverLng + userLng) / 2,
                  );
                  zoom = 13.0;
                } else {
                  // Wide view - show both points
                  centerPosition = LatLng(
                    (driverLat + userLat) / 2,
                    (driverLng + userLng) / 2,
                  );
                  zoom = 11.0;
                }
              }
              
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: centerPosition,
                  zoom: zoom,
                ),
                markers: markers,
                polylines: polylines,
                mapType: MapType.normal,
                myLocationEnabled: false,
                compassEnabled: true,
                trafficEnabled: true,
                buildingsEnabled: true,
                onMapCreated: (GoogleMapController mapController) {
                  // Set map controller in the controller
                  controller.setMapController(mapController);
                  
                  // If we have driver location, use smart camera positioning
                  if (ride?.hasDriverLocation == true && markers.length > 1) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      final driverLat = ride!.currentDriverLat!;
                      final driverLng = ride.currentDriverLng!;
                      const userLat = 30.0626; // User's current location
                      const userLng = 31.2497;
                      
                      // Calculate distance for camera positioning
                      final distance = controller.calculateDistance(
                        driverLat, driverLng, userLat, userLng
                      );
                      
                      if (distance < 1000) {
                        // Close view - focus on driver with tilt
                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(driverLat, driverLng),
                              zoom: 16.0,
                              tilt: 45.0, // Add tilt for better 3D perspective
                              bearing: controller.calculateBearing(
                                LatLng(driverLat, driverLng),
                                const LatLng(userLat, userLng),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Wide view - show both markers with bounds
                        final minLat = driverLat < userLat ? driverLat : userLat;
                        final maxLat = driverLat > userLat ? driverLat : userLat;
                        final minLng = driverLng < userLng ? driverLng : userLng;
                        final maxLng = driverLng > userLng ? driverLng : userLng;
                        
                        mapController.animateCamera(
                          CameraUpdate.newLatLngBounds(
                            LatLngBounds(
                              southwest: LatLng(minLat - 0.01, minLng - 0.01), // Add padding
                              northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
                            ),
                            100.0, // edge padding
                          ),
                        );
                      }
                    });
                  }
                },
                onTap: (LatLng position) {
                  print('📍 Map tapped at: ${position.latitude}, ${position.longitude}');
                },
              );
            },
          ),
          

          // Location info overlay
          Positioned(
            top: 16,
            right: 16,
            child: StreamBuilder<RideModel?>(
              stream: controller.rideStream,
              builder: (context, snapshot) {
                final ride = snapshot.data ?? controller.currentRide;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      if (ride?.hasDriverLocation == true) ...[
                        Text(
                          'ETA: ${controller.estimatedArrivalWithUnit}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${controller.routeDistance}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Map control buttons
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Center on driver button
                StreamBuilder<RideModel?>(
                  stream: controller.rideStream,
                  builder: (context, snapshot) {
                    final ride = snapshot.data ?? controller.currentRide;
                    if (ride?.hasDriverLocation != true) return const SizedBox.shrink();
                    
                    return FloatingActionButton(
                      mini: true,
                      backgroundColor: const Color(0xFF8B1538), // Burgundy color matching screenshot
                      onPressed: controller.centerMapOnDriver,
                      child: const Icon(Icons.directions_car, color: Colors.white),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Center on destination button
                FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF8B1538), // Burgundy color matching screenshot
                  onPressed: controller.centerMapOnDestination,
                  child: const Icon(Icons.location_on, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}