
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(height: 80, isBack: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12,),
            // Logo Section with Gradient Background
            Padding(
              padding: const EdgeInsets.only(left:28.0,right: 28),
              child: _buildLogoSection(),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Name and Tagline
                  _buildAppNameSection(),
                  
                  const SizedBox(height: 24),
                  
                  // About Description
                  _buildAboutSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Services Section
                  _buildServicesSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Georgian Culture Section
                  _buildCultureSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Features Grid
                  _buildFeaturesGrid(),
                  
                  const SizedBox(height: 32),
                  
                  // Mission Section
                  _buildMissionSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Version Info
                  _buildVersionInfo(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor,
            //AppColors.appSurfaceColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          SvgPicture.asset(
            AppImages.whiteLogo2,
             width: 200,
             height: 160,
          ),
          
          const SizedBox(height: 16),
          
          // // App Name with Style
          // RichText(
          //   text: TextSpan(
          //     children: [
          //       TextSpan(
          //         text: 'ME',
          //         style: TextStyle(
          //           fontFamily: 'Montserrat',
          //           fontSize: 42,
          //           fontWeight: FontWeight.w900,
          //           color: Colors.white,
          //           fontStyle: FontStyle.italic,
          //         ),
          //       ),
          //       TextSpan(
          //         text: 'GO',
          //         style: TextStyle(
          //           fontFamily: 'Montserrat',
          //           fontSize: 42,
          //           fontWeight: FontWeight.w900,
          //           color: AppColors.buttonColor,
          //           fontStyle: FontStyle.italic,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          
          const SizedBox(height: 8),
          
          Text(
            'More than a ride, it\'s MEGO',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildAppNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About MEGO',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.txtColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor,
               // AppColors.appSurfaceColor,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor
              .withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        'MEGO is your premier platform for seamless transportation and food delivery services. '
        'We connect you with reliable drivers for comfortable rides and partner with professional '
        'restaurants to deliver delicious meals right to your doorstep. Experience convenience, '
        'quality, and exceptional service with every order.',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          height: 1.6,
          color: AppColors.socialMediaText,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Services',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.txtColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // Ride Service Card
        _buildServiceCard(
          icon: AppImages.car,
          title: 'Ride Services',
          description: 'Safe and comfortable rides with professional drivers. Book instantly and track your journey in real-time.',
          gradient: [AppColors.primaryColor, AppColors.primaryColor],
        ),
        
        const SizedBox(height: 16),
        
        // Food Service Card
        _buildServiceCard(
          icon: AppImages.food,
          title: 'Food Delivery',
          description: 'Order from top-rated restaurants and enjoy delicious meals delivered fast and fresh to your location.',
          gradient: [AppColors.primaryColor, AppColors.primaryColor],
          //[Colors.orange.shade700, Colors.orange.shade500],
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String icon,
    required String title,
    required String description,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              icon,
              width: 40,
              height: 40,
              color:
              //(title=='Ride Services')?
              Colors.white

                  //:AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:  TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                  //  (title!='Food Delivery')?
                    Colors.white.withValues(alpha: 0.9)
                     //   :AppColors.txtColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    height: 1.4,
                    color:
                 //   (title!='Food Delivery')?
                    Colors.white.withValues(alpha: 0.9)
                        //:AppColors.txtColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCultureSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppColors.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Georgian Excellence',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rooted in Georgian culture and hospitality, MEGO brings together traditional values '
            'of warmth and modern technology. We take pride in serving our community with the same '
            'dedication and care that defines Georgian hospitality - making every journey and meal '
            'a memorable experience.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15,
              height: 1.6,
              color: AppColors.txtColor,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose MEGO?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.txtColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildFeatureCard(
              icon: AppImages.settingsIcon,
              //Icons.flash_on,
              title: 'Fast Service',
              color: Colors.orange,
            ),
            _buildFeatureCard(
              icon: AppImages.safety,
              title: 'Safe & Secure',
              color: Colors.green,
            ),
            _buildFeatureCard(
              icon: AppImages.customerSupportIcon,
              title: '24/7 Support',
              color: Colors.blue,
            ),
            _buildFeatureCard(
              icon: AppImages.star,
              title: 'Top Quality',
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(icon,
            height: 45,
            color:
            (title!='Safe & Secure')?
            AppColors.primaryColor:null,
            )

            // Icon(
            //   icon,
            //   color: color,
            //   size: 32,
            // ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.txtColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return Padding(
      padding: const EdgeInsets.only(left:21,right: 21,top:6),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.1),
              AppColors.appSurfaceColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_objects,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Our Mission',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'To revolutionize transportation and food delivery by providing reliable, '
              'efficient, and customer-focused services that enhance daily life and bring '
              'communities closer together.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 15,
                height: 1.6,
                color: AppColors.txtColor,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: AppColors.socialMediaText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2025 MEGO. All rights reserved.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: AppColors.socialMediaText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
