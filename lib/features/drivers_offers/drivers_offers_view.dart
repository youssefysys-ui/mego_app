import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_models/models.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/features/drivers_offers/controllers/drivers_offers_controller.dart';
import 'package:mego_app/features/drivers_offers/widgets/widgets.dart';

class DriversOffersView extends StatefulWidget {
  final String rideRequestId;
  final UserRideData userRideData;

  const DriversOffersView({
    Key? key,
    required this.rideRequestId,
    required this.userRideData,
  }) : super(key: key);

  @override
  State<DriversOffersView> createState() => _DriversOffersViewState();
}

class _DriversOffersViewState extends State<DriversOffersView> {
  late DriversOffersController controller;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    controller = Get.put(DriversOffersController(rideRequestId: widget.rideRequestId));
    _setupMapMarkers();
  }

  void _setupMapMarkers() {
    markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.userRideData.latFrom, widget.userRideData.lngFrom),
        infoWindow: InfoWindow(title: 'Pickup: ${widget.userRideData.placeFrom}'),
        icon: BitmapDescriptor.defaultMarker,
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.userRideData.latTo, widget.userRideData.lngTo),
        infoWindow: InfoWindow(title: 'Destination: ${widget.userRideData.placeTo}'),
      ),
    };
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriversOffersController>(
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        bottomNavigationBar: BottomFareSectionWidget(userRideData: widget.userRideData),
        appBar: CustomAppBar(height: 140, isBack: true),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController mapController) {
                this.mapController = mapController;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.userRideData.latFrom, widget.userRideData.lngFrom),
                zoom: 14.0,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
            StreamBuilder<List<DriverOfferModel>>(
              
              stream: controller.offersStream,
              builder: (context, snapshot) {
                final offers = snapshot.data ?? controller.currentOffers;
                if (controller.isLoading) {
                  return const LoadingOverlayWidget();
                }
                if (offers.isEmpty) {
                  return const SearchingOverlayWidget();
                }
                return AllOffersViewWidget(
                  offers: offers,
                  controller: controller,
                  userRideData: widget.userRideData,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
