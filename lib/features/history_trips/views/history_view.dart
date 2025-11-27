import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import '../../../core/loading/loading.dart';
import '../controllers/history_trip_controller.dart';
import '../widgets/epmty_history.dart';
import '../widgets/trip_card_widget.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final HistoryTripController controller = Get.put(HistoryTripController());

  @override
  void initState() {
    super.initState();
    controller.getAllTripsWithRequestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 88,
        isBack: true,
      ),
      body: GetBuilder<HistoryTripController>(
        builder: (_) {
          if (controller.isLoading) {

            return LoadingWidget();


          }

          if (controller.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading trips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (controller.allTripsData.isEmpty) {
            return EmptyHistoryWidget();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.allTripsData.length,
            itemBuilder: (context, index) {
              final trip = controller.allTripsData[index];
              return TripHistoryCard(trip: trip);
            },
          );
        },
      ),
    );
  }
}

