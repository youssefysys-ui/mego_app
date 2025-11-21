import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Custom page route with slide transition from right to left
class SlideRightToLeftRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideRightToLeftRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Custom page route with slide transition from left to right
class SlideLeftToRightRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideLeftToRightRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Custom page route with fade transition
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  FadeRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
}

/// Custom page route with scale transition
class ScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  ScaleRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 350),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutBack,
              )),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
            );
          },
        );
}

/// Custom page route with slide up transition
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideUpRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 350),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// Professional slide transition with subtle scale effect
class ProfessionalSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  ProfessionalSlideRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 320),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Forward animation (entering screen)
            const slideBegin = Offset(1.0, 0.0);
            const slideEnd = Offset.zero;
            const slideCurve = Curves.easeOutCubic;

            var slideTween = Tween(begin: slideBegin, end: slideEnd).chain(
              CurveTween(curve: slideCurve),
            );

            // Scale animation for depth effect
            var scaleTween = Tween<double>(begin: 0.95, end: 1.0).chain(
              CurveTween(curve: Curves.easeOutCubic),
            );

            // Fade animation
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeOut),
            );

            return SlideTransition(
              position: animation.drive(slideTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: FadeTransition(
                  opacity: animation.drive(fadeTween),
                  child: child,
                ),
              ),
            );
          },
        );
}

/// Extension methods for easier navigation with animations
extension AnimatedNavigation on Widget {
  /// Navigate with professional slide animation
  Future<T?> pushWithSlide<T>() {
    return Navigator.of(Get.context!).push<T>(
      ProfessionalSlideRoute(child: this),
    );
  }

  /// Navigate with fade animation
  Future<T?> pushWithFade<T>() {
    return Navigator.of(Get.context!).push<T>(
      FadeRoute(child: this),
    );
  }

  /// Navigate with scale animation
  Future<T?> pushWithScale<T>() {
    return Navigator.of(Get.context!).push<T>(
      ScaleRoute(child: this),
    );
  }

  /// Navigate with slide up animation
  Future<T?> pushWithSlideUp<T>() {
    return Navigator.of(Get.context!).push<T>(
      SlideUpRoute(child: this),
    );
  }
}

/// Get extensions for animated navigation
class AnimatedGet {
  /// Navigate to a page with professional slide animation
  static Future<T?> toWithSlide<T>(Widget page) async {
    return await Get.to<T>(() => page, transition: Transition.native);
  }

  /// Navigate with fade animation
  static Future<T?> toWithFade<T>(Widget page) async {
    return await Get.to<T>(() => page, transition: Transition.fadeIn, duration: const Duration(milliseconds: 400));
  }

  /// Navigate with scale animation  
  static Future<T?> toWithScale<T>(Widget page) async {
    return await Get.to<T>(() => page, transition: Transition.zoom, duration: const Duration(milliseconds: 350));
  }

  /// Navigate with slide up animation
  static Future<T?> toWithSlideUp<T>(Widget page) async {
    return await Get.to<T>(() => page, transition: Transition.downToUp, duration: const Duration(milliseconds: 350));
  }

  /// Navigate with slide from right
  static Future<T?> toWithSlideRight<T>(Widget page) async {
    return await Get.to<T>(() => page, transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
  }

  /// Navigate with slide from left
  static Future<T?> toWithSlideLeft<T>(Widget page) async {
    return await Get.to<T>(() => page, transition: Transition.leftToRight, duration: const Duration(milliseconds: 300));
  }

  /// Navigate with size animation
  static Future<T?> toWithSize<T>(Widget page) async {
    return await Get.to<T>(() => page, transition: Transition.size, duration: const Duration(milliseconds: 400));
  }

  /// Navigate with professional curve
  static Future<T?> toWithCurve<T>(Widget page) async {
    return await Get.to<T>(
      () => page, 
      transition: Transition.cupertino,
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 350),
    );
  }
}