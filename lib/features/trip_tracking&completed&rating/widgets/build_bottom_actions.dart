

import 'package:flutter/material.dart';
import '../controllers/trip_tracking_controller.dart';


class BuildBottomActions extends StatelessWidget {
  final TripTrackingController controller;
  const BuildBottomActions({super.key,required this.controller});

  @override
  Widget build(BuildContext context) {
     return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary action buttons
        Row(
          children: [
            // Emergency stop button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.emergencyStop,
                icon: const Icon(Icons.stop, color: Colors.white),
                label: const Text(
                  'Emergency Stop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Call emergency button
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: controller.callEmergency,
                icon: const Icon(
                  Icons.phone,
                  color: Colors.red,
                  size: 24,
                ),
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Secondary actions
        Row(
          children: [
            // Refresh data button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.refreshTripData,
                icon: Icon(
                  Icons.refresh,
                  color: const Color(0xFF8B1538),
                ),
                label: Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8B1538),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFF8B1538)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Test controls for development
            if (controller.isTripSimulating)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.stopTripSimulation,
                  icon: const Icon(
                    Icons.pause,
                    color: Colors.orange,
                  ),
                  label: const Text(
                    'Stop Test',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
  }
}