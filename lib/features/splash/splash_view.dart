import 'dart:async';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/features/splash/splash_screen.dart';
import '../../core/res/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _stage1Controller;
  late AnimationController _stage2Controller;
  late AnimationController _stage3Controller;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;

  late Animation<double> _splash1FadeAnimation;
  late Animation<double> _splash1ScaleAnimation;
  late Animation<double> _loadingFadeAnimation;
  late Animation<double> _welcomeFadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  int _currentStage = 1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Stage 1: Splash1 image animations (0-1.5s)
    _stage1Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Stage 2: Loading GIF animations (2-4s)
    _stage2Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Stage 3: Welcome image animations (4-6s)
    _stage3Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse animation for loading stage
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Background color transition controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Splash1 fade in
    _splash1FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stage1Controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Splash1 scale with elastic effect
    _splash1ScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _stage1Controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Loading GIF fade in
    _loadingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stage2Controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Welcome SVG fade in
    _welcomeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stage3Controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Background color animation from primary to background
    _backgroundColorAnimation = ColorTween(
      begin: AppColors.primaryColor,
      end: AppColors.backgroundColor,
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimationSequence() {
    // Stage 1: Show splash1 image (0-2s)
    _stage1Controller.forward();

    // Stage 2: Transition to loading GIF (2s)
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _currentStage = 2;
        });
        _backgroundController.forward();
        _stage2Controller.forward();
        _pulseController.repeat(reverse: true);
      }
    });

    // Stage 3: Show welcome.svg (4s)
    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        setState(() {
          _currentStage = 3;
        });
        _pulseController.stop();
        _stage3Controller.forward();
      }
    });

    // Stage 4: Navigate to splash screen (6s)
    Timer(const Duration(milliseconds: 6000), () {
      if (mounted) {
        _navigateToSplashScreen();
      }
    });
  }

  void _navigateToSplashScreen() async {
    // Navigate to SplashScreen with fade transition
    Get.offAll(
      () => const SplashScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _stage1Controller.dispose();
    _stage2Controller.dispose();
    _stage3Controller.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: _currentStage == 1
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.7),
                        AppColors.primaryColor,
                        AppColors.primaryColor.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: _currentStage == 1
                  ? null
                  : (_backgroundColorAnimation.value ??
                      AppColors.backgroundColor),
            ),
            child: Stack(
              children: [
                // Stage 1: Opening Gradient Animation
                if (_currentStage == 1)
                  AnimatedBuilder(
                    animation: _stage1Controller,
                    builder: (context, child) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.center,
                          heightFactor: _splash1ScaleAnimation.value,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.drawerColor,
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Stage 2: Loading GIF with pulse effect
                if (_currentStage == 2)
                  AnimatedBuilder(
                    animation: _stage2Controller,
                    builder: (context, child) {
                      return Center(
                        child: FadeTransition(
                          opacity: _loadingFadeAnimation,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Image.asset(
                                    AppImages.loading,
                                    height: 50,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                // Stage 3: Welcome Text with Loading Animation
                if (_currentStage == 3)
                  AnimatedBuilder(
                    animation: _stage3Controller,
                    builder: (context, child) {
                      return Center(
                        child: FadeTransition(
                          opacity: _welcomeFadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // "Welc" text
                              Text(
                                'Welc',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  color: AppColors.primaryColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              // Small star2.svg replacing "o"
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: SvgPicture.asset(
                                  AppImages.star2,
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                              // "me" text
                              Text(
                                'me',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  color: AppColors.primaryColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for animated wave gradient
class WaveGradientPainter extends CustomPainter {
  final double animationValue;

  WaveGradientPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Bottom section (drawerColor)
    final bottomPaint = Paint()
      ..color = AppColors.drawerColor
      ..style = PaintingStyle.fill;

    // Top section (primaryColor)
    final topPaint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.fill;

    // Wave line paint
    // final wavePaint = Paint()
    //   ..color = AppColors.primaryColor
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 3.0;

    // Calculate wave position (moves with animation)
    final waveHeight = size.height * 0.6;
    final waveAmplitude = 40 * animationValue;

    // Draw top section (primaryColor)
    final topPath = Path();
    topPath.moveTo(0, 0);
    topPath.lineTo(size.width, 0);
    topPath.lineTo(size.width, waveHeight);

    // Create curved wave
    for (double i = size.width; i >= 0; i -= 10) {
      final x = i;
      final y = waveHeight +
          waveAmplitude * Math.sin((i / size.width) * 2 * Math.pi * 2);
      topPath.lineTo(x, y);
    }

    topPath.lineTo(0, waveHeight);
    topPath.close();
    canvas.drawPath(topPath, topPaint);

    // Draw bottom section (drawerColor)
    final bottomRect = Rect.fromLTWH(
        0, waveHeight + waveAmplitude, size.width, size.height - waveHeight);
    canvas.drawRect(bottomRect, bottomPaint);

    // Draw wave line
    final waveLine = Path();
    waveLine.moveTo(0, waveHeight);
    for (double i = 0; i <= size.width; i += 5) {
      final x = i;
      final y = waveHeight +
          waveAmplitude * Math.sin((i / size.width) * 2 * Math.pi * 2);
      waveLine.lineTo(x, y);
    }
    // canvas.drawPath(waveLine, wavePaint);
  }

  @override
  bool shouldRepaint(WaveGradientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
