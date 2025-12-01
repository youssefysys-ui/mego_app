import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_widgets/loading_widget.dart';
import 'package:mego_app/features/auth/login/views/login_view.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import 'package:mego_app/features/home/bindings/home_binding.dart';
import 'package:mego_app/features/splash/widgets/animated_welcome_text.dart';

import '../auth/save_data/save_user_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _shimmerController;
  late AnimationController _stage3Controller; // Added missing controller

  late Animation<double> _textSlideAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<double> _welcomeFadeAnimation; // Added missing animation

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _startSplashProcess();
  }

  void _initializeAnimations() {
    // Logo animations - smooth and elegant
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Text animations - sequential reveal (faster)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Shimmer effect for premium feel
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Stage 3 controller for welcome text
    _stage3Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text slide up (faster)
    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline delayed fade (faster)
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    // Welcome fade animation
    _welcomeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stage3Controller,
        curve: Curves.easeIn,
      ),
    );
  }

  void _startAnimationSequence() {
    // Start logo animation immediately
    _logoController.forward();

    // Start text animation with slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // Start shimmer effect
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _shimmerController.repeat();
      }
    });

    // Start stage 3 animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _stage3Controller.forward();
      }
    });
  }

  void _startSplashProcess() {
    Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() async {
    final loggedIn = SaveUserData.isUserLoggedIn();
    final localUser = SaveUserData.getLocalUser();

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🔍 SPLASH SCREEN: Checking authentication (local)");
    print("   User ID: ${localUser['id']}");
    print("   User Name: ${localUser['name']}");
    print("   User Email: ${localUser['email']}");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    if (loggedIn) {
      print("✅ User authenticated (local) → Home");
      Get.offAll(
        () => const HomeView(),
        binding: HomeBinding(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } else {
      print("❌ No user data (local) → Login");
      Get.offAll(
        () => LoginView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    _stage3Controller.dispose(); // Dispose the added controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Premium Animated Logo
                SvgPicture.asset(
                  AppImages.logo,
                  width: 120,
                  height: 120,
                ),

                const SizedBox(height: 40),

                // Tagline with Delayed Fade
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: Text(
                        "More than a ride it's MEGo",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Loading Widget with Fade
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: LoadingWidget(),
                    );
                  },
                ),

                // Animated Welcome Text
                Padding(
                  padding: const EdgeInsets.only(top: 101),
                  child: AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value * 1.5),
                        child: FadeTransition(
                          opacity: _taglineFadeAnimation,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: 0.8 + (0.2 * value),
                                  child: AnimatedBuilder(
                                    animation: _stage3Controller,
                                    builder: (context, child) {
                                      return Center(
                                        child: FadeTransition(
                                          opacity: _welcomeFadeAnimation,
                                          child: AnimatedWelcomeText(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}