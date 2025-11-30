import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/features/auth/login/views/login_view.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:video_player/video_player.dart';
import '../../core/local_db/local_db.dart';
import '../../core/res/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isVideoInitialized = false;


  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeFadeAnimation();

    // Navigate after 3.2 seconds
    Timer(const Duration(milliseconds: 3200), () {
      _navigateToNextScreen();
    });
  }

  void _initializeFadeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(AppImages.splashVideo);

    try {
      await _videoController.initialize();
      setState(() {
        _isVideoInitialized = true;
      });

      // Set playback speed to slow motion (0.5 = half speed, 0.75 = 3/4 speed)
      _videoController.setPlaybackSpeed(0.68);

      // Play the video
      _videoController.play();
      _videoController.setLooping(true);
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _navigateToNextScreen() async {
    // Mark splash video as shown with current timestamp
    await Storage.save.splashShown();
    
    // Start fade out animation
    await _fadeController.forward();

    // Check if user is authenticated
   // final session = Supabase.instance.client.auth.currentSession;


    // PROCESS 2: Check if user data exists in local_db
   // final userName = localStorage.userName;
    final userEmail = Storage.userEmail.toString();
    if (userEmail.toString().length>2&&userEmail.toString()!='null') {
      // User is logged in, go to home with fade transition
      Get.offAll(
        () => const HomeView(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 500),
      );
    } else {
      // User is not logged in, go to login with fade transition
      Get.offAll(
        LoginView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isVideoInitialized
            ? SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController.value.size.width,
              height: _videoController.value.size.height,
              child: VideoPlayer(_videoController),
            ),
          ),
        )
            : SizedBox(),
        //Center(child: SvgPicture.asset(AppImages.logo)),
      ),
    );
  }
}