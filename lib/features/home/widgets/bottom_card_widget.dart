import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_images.dart';
import '../../search_places & calculation/controllers/search_places_controller.dart';
import '../../search_places & calculation/search_places_view.dart';

class BottomCardWidget extends StatefulWidget {
  final List<String>lastUserDropOffLocation;
  const BottomCardWidget({super.key,required this.lastUserDropOffLocation});

  @override
  State<BottomCardWidget> createState() => _BottomCardWidgetState();
}

class _BottomCardWidgetState extends State<BottomCardWidget> {
  // Toggle state for Ride/Food
  String selectedService = 'Ride'; // 'Ride' or 'Food'

  // Toggle function
  void toggleService(String service) {
    setState(() {
      selectedService = service;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.56,
          minHeight: MediaQuery.of(context).size.height * 0.36,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grey divider at top
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ride Options (Toggle)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRideOption(
                            imagePath: AppImages.car,
                            label: 'Ride',
                            isSelected: selectedService == 'Ride',
                            onTap: () => toggleService('Ride'),
                          ),
                          const SizedBox(width: 8),
                          _buildRideOption(
                            imagePath: AppImages.food,
                            label: 'Food',
                            isSelected: selectedService == 'Food',
                            onTap: () => toggleService('Food'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Search Bar
                    GestureDetector(
                      onTap: () => Get.to(() => const SearchPlacesView(),
                        transition: Transition.leftToRightWithFade,
                        duration: const Duration(milliseconds: 500),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppImages.search),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                selectedService == 'Ride'
                                    ? 'Where to?'
                                    : 'What do you want to eat?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Recent locations
                    _buildLocationItem(
                      Icons.location_on,
                      selectedService == 'Ride'
                          ? widget.lastUserDropOffLocation[0]:"",
                      // 'Coffee house'
                      //     : 'Pizza Restaurant',
                    ),
                    const SizedBox(height: 12),
                    _buildLocationItem(
                      Icons.location_on,
                      selectedService == 'Ride'
                          ? widget.lastUserDropOffLocation[1]:"",
                      //'Inn Hotel'
                        //  : 'Burger Place',
                    ),

                    const SizedBox(height: 20),

                    // Promotional Cards
                    _buildPromotionalCard(),

                    const SizedBox(height: 16),

                    // Promo Code Card
                    Row(
                      children: [
                        Expanded(
                          child: _buildPromoCodeCard(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDiscountCard(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Brand Banner
                    _buildBrandBanner(),

                    // Add some bottom padding for safe scrolling
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build ride option toggle button
  Widget _buildRideOption({
    IconData? icon,
    String? imagePath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              SvgPicture.asset(
                imagePath,
                width: 20,
                height: 20,

                color:
                  isSelected ? Colors.white : AppColors.primaryColor,

              )
            else if (icon != null)
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primaryColor,
                size: 20,
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build location item
  Widget _buildLocationItem(IconData icon, String title) {
    return InkWell(
      onTap: () async {
        if (title.isNotEmpty) {
          // Navigate to SearchPlacesView
          Get.to(
            () => const SearchPlacesView(),
            transition: Transition.leftToRightWithFade,
            duration: const Duration(milliseconds: 500),
          );
          
          // Get the controller and search for the location to get full details
          final controller = Get.find<SearchPlacesController>();
          controller.toController.text = title;
          controller.isFromField = false;
          
          // Search for the place to get coordinates
          await controller.searchPlaces(title);
          
          controller.update();
        }
      },
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  // Build promotional card
  Widget _buildPromotionalCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.8),
            AppColors.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedService == 'Ride'
                      ? 'Get a ride in minutes!'
                      : 'Order food now!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedService == 'Ride'
                      ? 'Book your ride now with MEGO'
                      : 'Delicious meals delivered to you',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => const SearchPlacesView(),
                          transition: Transition.leftToRightWithFade,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          selectedService == 'Ride' ? 'Book Now' : 'Order Now',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build promo code card
  Widget _buildPromoCodeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Use code:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'MEGO10',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Build discount card
  Widget _buildDiscountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5€ OFF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Code: MEG05',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'MEGO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Build brand banner
  Widget _buildBrandBanner() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Center(
        child: Text(
          'More than a ride, it\'s Mego',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
