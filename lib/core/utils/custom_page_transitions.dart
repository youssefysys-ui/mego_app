import 'package:flutter/material.dart';

class CustomPageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionType transitionType;
  final Curve curve;
  final Duration duration;
  final Alignment alignment;

  CustomPageTransition({
    required this.page,
    this.transitionType = TransitionType.slideRight,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 300),
    this.alignment = Alignment.center,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            switch (transitionType) {
              case TransitionType.fade:
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                  child: child,
                );

              case TransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );

              case TransitionType.slideLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );

              case TransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );

              case TransitionType.slideDown:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -1.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );

              case TransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                  alignment: alignment,
                  child: child,
                );

              case TransitionType.rotation:
                return RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                  alignment: alignment,
                  child: child,
                );

              case TransitionType.size:
                return SizeTransition(
                  sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                  axisAlignment: 0.0,
                  child: child,
                );

              case TransitionType.fadeAndScale:
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
                    ),
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                    child: child,
                  ),
                );

              default:
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                  child: child,
                );
            }
          },
        );
}

enum TransitionType {
  fade,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  scale,
  rotation,
  size,
  fadeAndScale,
}