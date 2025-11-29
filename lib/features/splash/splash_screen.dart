import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_widgets/loading_widget.dart';
import 'package:mego_app/features/auth/login/views/login_view.dart';
import 'package:mego_app/features/home/views/home_view.dart';
import '../../core/local_db/local_db.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _shimmerController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<double> _shimmerAnimation;

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

    // Logo fade with smooth ease
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Logo scale with bounce effect
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Subtle rotation for dynamic feel
    _logoRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Text fade in (faster)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
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

    // Shimmer effect
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
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
  }

  void _startSplashProcess() {
    Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() async {
    // ════════════════════════════════════════════════════════════════════════
    // CHECK LOCAL STORAGE FOR USER DATA (Not Supabase Session)
    // ════════════════════════════════════════════════════════════════════════
    
    // PROCESS 1: Get local storage instance
    final localStorage = GetIt.instance<LocalStorageService>();
    // PROCESS 2: Check if user data exists in local_db
    final userName = localStorage.userName;
    final userEmail = localStorage.userEmail;
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🔍 SPLASH SCREEN: Checking authentication");
    print("   User Name: ${userName ?? 'Not found'}");
    print("   User Email: ${userEmail ?? 'Not found'}");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    
    // PROCESS 3: Determine navigation based on local storage data
    if (userName != null && userName.isNotEmpty && 
        userEmail != null && userEmail.isNotEmpty) {
      // User data exists in local_db → Navigate to Home
      print("✅ User authenticated (local_db) → Home");
      Get.offAll(
        () => const HomeView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } else {
      // No user data in local_db → Navigate to Login
      print("❌ No user data (local_db) → Login");
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor:AppColors.backgroundColor,
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

              // App Name with Premium Animation
              // AnimatedBuilder(
              //   animation: _textController,
              //   builder: (context, child) {
              //     return Transform.translate(
              //       offset: Offset(0, _textSlideAnimation.value),
              //       child: FadeTransition(
              //         opacity: _textFadeAnimation,
              //         child: Stack(
              //           children: [
              //             // Shimmer effect overlay
              //             AnimatedBuilder(
              //               animation: _shimmerController,
              //               builder: (context, child) {
              //                 return ShaderMask(
              //                   blendMode: BlendMode.srcATop,
              //                   shaderCallback: (bounds) {
              //                     return LinearGradient(
              //                       begin: Alignment.topLeft,
              //                       end: Alignment.bottomRight,
              //                       colors: [
              //                         Colors.white.withValues(alpha: 0.0),
              //                         Colors.white.withValues(alpha: 0.3),
              //                         Colors.white.withValues(alpha: 0.0),
              //                       ],
              //                       stops: const [0.0, 0.5, 1.0],
              //                       transform: GradientRotation(_shimmerAnimation.value),
              //                     ).createShader(bounds);
              //                   },
              //                   child: RichText(
              //                     text: TextSpan(
              //                       children: [
              //                         TextSpan(
              //                           text: 'ME',
              //                           style: TextStyle(
              //                             fontSize: 42,
              //                             fontWeight: FontWeight.bold,
              //                             fontFamily: 'Montserrat',
              //                             color: AppColors.whiteColor,
              //                             fontStyle: FontStyle.italic,
              //                             letterSpacing: 2,
              //                           ),
              //                         ),
              //                         TextSpan(
              //                           text: 'GO',
              //                           style: TextStyle(
              //                             fontSize: 42,
              //                             fontWeight: FontWeight.bold,
              //                             fontFamily: 'Montserrat',
              //                             color: AppColors.buttonColor,
              //                             fontStyle: FontStyle.italic,
              //                             letterSpacing: 2,
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 );
              //               },
              //             ),
              //             // Base text
              //             RichText(
              //               text: TextSpan(
              //                 children: [
              //                   TextSpan(
              //                     text: 'ME',
              //                     style: TextStyle(
              //                       fontSize: 42,
              //                       fontWeight: FontWeight.bold,
              //                       fontFamily: 'Montserrat',
              //                       color: AppColors.whiteColor,
              //                       fontStyle: FontStyle.italic,
              //                       letterSpacing: 2,
              //                     ),
              //                   ),
              //                   TextSpan(
              //                     text: 'GO',
              //                     style: TextStyle(
              //                       fontSize: 42,
              //                       fontWeight: FontWeight.bold,
              //                       fontFamily: 'Montserrat',
              //                       color: AppColors.buttonColor,
              //                       fontStyle: FontStyle.italic,
              //                       letterSpacing: 2,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              // ),
              //
              // const SizedBox(height: 12),

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
                       fontWeight:FontWeight.w700
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
                                child: Text(
                                  "Welcome",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 25,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
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