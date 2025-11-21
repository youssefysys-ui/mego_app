import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/core/res/app_colors.dart';
import '../controllers/trip_tracking_controller.dart';


class MapSectionWidget extends StatelessWidget {
  final TripTrackingController controller;
  const MapSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return controller.startLat == 0.0 || controller.endLat == 0.0
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading route...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.txtColor,
            ),
          ),
        ],
      ),
    )
        : GoogleMap(
      initialCameraPosition: CameraPosition(
        target: controller.mapCenter,
        zoom: controller.mapZoom,
      ),
      onMapCreated: controller.onMapCreated,
      markers: controller.markers,
      polylines: controller.polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      mapType: MapType.normal,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      style: _mapStyle,
    );
  }

  // Custom map style to match screenshot
  static const String _mapStyle = '''
  [
    {
      "featureType": "all",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#f5f5f5"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#c9e9f6"
        }
      ]
    },
    {
      "featureType": "landscape.natural",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#dcedc8"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#ffffff"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    }
  ]
  ''';
}