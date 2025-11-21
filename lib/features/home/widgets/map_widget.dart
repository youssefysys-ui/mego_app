



 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/features/home/controller/home_controller.dart';

import '../../../core/loading/loading.dart';

class MapWidget extends StatelessWidget {
  final HomeController controller;
   const MapWidget({super.key,required this.controller});

   @override
   Widget build(BuildContext context) {
     return   GetBuilder<HomeController>(
       init: controller,
       builder: (_) {
         if (controller.isLoading) {
           return const LoadingWidget(
             message: 'Getting your location...',
             size: 100,
           );
         }

         return GoogleMap(
           initialCameraPosition: CameraPosition(
             target: LatLng(
               controller.latitude,
               controller.longitude,
             ),
             zoom: 15,
           ),
           onMapCreated: (GoogleMapController mapController) {
             controller.onMapCreated(mapController);
           },
           myLocationEnabled: true,
           myLocationButtonEnabled: false,
           zoomControlsEnabled: false,
           mapType: MapType.normal,
         );
       },
     );
   }
 }
