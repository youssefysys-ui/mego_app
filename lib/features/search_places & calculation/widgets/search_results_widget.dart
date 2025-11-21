


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/features/search_places%20&%20calculation/models/place_model.dart';
import '../controllers/search_places_controller.dart';

class SearchResultsWidget extends StatelessWidget {
  final SearchPlacesController controller;
  const SearchResultsWidget({super.key,required this.controller});

  @override
  Widget build(BuildContext context) {
    return   Expanded(
            child: GetBuilder<SearchPlacesController>(
              builder: (_) {
                return Container(
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      // Loading indicator at top if searching
                      if (controller.isSearching || controller.isSelectingPlace)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(9),
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                controller.isSearching 
                                    ? 'Searching places...' 
                                    : 'Loading details...',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Debug info
                      if (controller.searchResults.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          color: Colors.green[50],
                          child: Text(
                            '${controller.searchResults.length} places found',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // Search results or empty state
                      Expanded(
                        child: controller.searchResults.isNotEmpty
                            ? ListView.builder(
                               shrinkWrap: true,
                                padding: const EdgeInsets.all(5),
                                itemCount: controller.searchResults.length,
                                itemBuilder: (context, index) {
                                  final place = controller.searchResults[index];
                                  print('🏢 Building place item: ${place.name}');
                                  return _buildPlaceItem(place);
                                },
                              )
                            : Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_searching,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Enter your pickup and destination locations',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Type at least 3 characters to search for places',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

    Widget _buildPlaceItem(PlaceModel place) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: () => controller.selectPlace(place),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
          radius: 18,
          child: Icon(
            Icons.location_on,
            color: AppColors.primaryColor,
            size: 16,
          ),
        ),
        title: Text(
          place.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          place.address,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.add_circle_outline,
          color: AppColors.primaryColor,
          size: 16,
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}