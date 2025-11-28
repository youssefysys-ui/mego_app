import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../res/app_colors.dart';
import '../../res/app_images.dart';

class SafetyCallButton extends StatelessWidget {
  const SafetyCallButton({super.key});

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+123');
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await launchUrl(phoneUri);
        print('❌ Could not launch phone dialer');
      }
    } catch (e) {
      await launchUrl(phoneUri);
      print('❌ Error launching phone dialer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      left: 20,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: _makePhoneCall,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  AppImages.safety,
                //  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
