import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:mego_app/core/local_db/local_db.dart';
import 'package:mego_app/features/splash/splash_screen.dart';
import 'package:mego_app/features/splash/splash_view.dart';

/// Router that decides whether to show video splash or logo splash
/// based on when the video was last shown (5-day rule)
class SplashRouter extends StatelessWidget {
  const SplashRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Get local storage instance
    final localStorage = GetIt.instance<LocalStorageService>();
    
    // Check if splash video should be shown
    final shouldShowVideo = localStorage.shouldShowSplashVideo();
    
    if (shouldShowVideo) {
      // Show video splash (first time or after 5 days)
      print('🎬 Routing to SplashView (video)');
      return const SplashView();
    } else {
      // Show logo splash (video was shown within last 5 days)
      print('⚡ Routing to SplashScreen (logo)');
      return const SplashScreen();
    }
  }
}
