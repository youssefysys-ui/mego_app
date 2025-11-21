import 'package:flutter/material.dart';
import 'package:mego_app/core/res/app_colors.dart';
import '../controllers/search_places_controller.dart';

class SearchInputSection extends StatelessWidget {
  final SearchPlacesController controller;

  const SearchInputSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          // From Field
          _buildInputField(
            controller: controller.fromController,
            focusNode: controller.fromFocusNode,
            hintText: 'From',
            icon: Icons.my_location,
            isFrom: true,
          ),
          
          const SizedBox(height: 16),
          
          // Swap Button
          Center(
            child: GestureDetector(
              onTap: controller.swapLocations,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_vert,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // To Field
          _buildInputField(
            controller: controller.toController,
            focusNode: controller.toFocusNode,
            hintText: 'Where to?',
            icon: Icons.location_on,
            isFrom: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required bool isFrom,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus ? AppColors.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: 1,
        style:  TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color:AppColors.txtColor,
        ),
        onTap: () {
          this.controller.setActiveField(isFrom);
          // Clear search results when focusing on field
          if (controller.text.isEmpty || 
              controller.text == 'Getting location...') {
            this.controller.clearSearch();
          }
        },
        onChanged: (value) {
          this.controller.setActiveField(isFrom);
          print('🔤 Text field changed: "$value" (length: ${value.length})');
          if (value != 'Getting location...' && value.isNotEmpty && value.length >= 3) {
            print('🔍 Starting search for: "$value"');
            this.controller.searchPlaces(value);
          } else {
            print('🧹 Clearing search results');
            this.controller.clearSearch();
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 22),
          suffixIcon: controller.text.isNotEmpty && 
                      controller.text != 'Getting location...'
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    controller.clear();
                    this.controller.clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}